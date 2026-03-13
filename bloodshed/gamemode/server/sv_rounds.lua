MuR.GameStarted = true
MuR.Delay_Before_Lose = 0
MuR.Gamemode = 1
MuR.PoliceState = 0
MuR.SniperArrived = false
MuR.SniperSettings = {30,40, 15,75}
MuR.HeliArrived = false
MuR.HeliSettings = {15,25, 35,40}
MuR.PoliceArriveTime = 0
MuR.PoliceDelaySpawn = 0
MuR.TimeCount = 0
MuR.SecuritySpawned = false
MuR.TeamAssign = false
MuR.TeamAssignDelay = 30
MuR.NextGamemode = 0
MuR.NextTraitor = nil
MuR.NextTraitor2 = nil
MuR.NextModeRoleAssignments = MuR.NextModeRoleAssignments or {}
MuR.Ending = false
MuR.TimeBeforeStart = 0
MuR.NPC_To_Spawn = 0
MuR.VoteLog = 0
MuR.VoteAllowed = false
MuR.VoteLogDeadPolice = 0
MuR.GunShots = 0
MuR.TimerEndTime = 0
MuR.TimerActive = false
MuR.ExperimentWeapon = nil
MuR.DefaultSkyname = MuR.DefaultSkyname or ""
MuR.WeaponsTable = MuR.WeaponsTable or MuR:GenerateWeaponsTable()
MuR.LootMinDistance = MuR.LootMinDistance or 160
MuR.MaxLootRetries = MuR.MaxLootRetries or 8
MuR.LootSpawnPositions = MuR.LootSpawnPositions or {}
MuR.LootSpawnInterval = MuR.LootSpawnInterval or 0.25
MuR.LootSpawnBatch = MuR.LootSpawnBatch or 1
MuR.LootSpawnInitialDelay = MuR.LootSpawnInitialDelay or 4
MuR.LogTable = {
	dead = {},
	dead_cops = {},
	injured = {},
	heavy_injured = {},
}
MuR.CleanupInProgress = false
MuR.JustCleaned = false

hook.Add("InitPostEntity", "MuR.InitPostEntity", function()
	MuR.DefaultSkyname = GetConVar("sv_skyname"):GetString()
	MuR.WeaponsTable = MuR:GenerateWeaponsTable()
end)

function MuR:RemoveMapLogic()
	for _, ent in ents.Iterator() do
		if ent:IsNPC() or ent:IsWeapon() then
			ent:Remove()
		end
	end
end

function MuR:ReplaceMapProps()
	for _, ent in ipairs(ents.FindByClass("prop_*")) do
		local model = ent:GetModel()
		local replaceWith = MuR.EntityReplaceMapModel[model]
		if not replaceWith then continue end

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) and phys:IsMotionEnabled() then
			local pos = ent:GetPos()
			local ang = ent:GetAngles()
			ent:Remove()

			if string.StartWith(replaceWith, "mur_armor_") then
				local armorId = string.sub(replaceWith, 11)
				MuR:SpawnArmorPickup(pos, armorId)
			else
				local newEnt = ents.Create(replaceWith)
				if IsValid(newEnt) then
					newEnt:SetPos(pos)
					newEnt:SetAngles(ang)
					newEnt:Spawn()
				end
			end
		end
	end
end

function MuR:SpawnZone()
	if MuR.Gamemode != -1 then return end
	timer.Simple(2, function()
		local ply = GetRandomPlayer()
		if IsValid(ply) then
			local ent = ents.Create("bloodshed_zone")
			ent:SetPos(ply:GetPos())
			ent:Spawn()
		end
	end)
end

function MuR:GiveRandomTableWithChance(tab, extra)
    local filtered = {}
    for idx, subtable in pairs(tab) do
        if not isfunction(extra) or extra(subtable) == true then
            table.insert(filtered, {orig_idx = idx, data = subtable})
        end
    end

    if #filtered == 0 then return end

    local totalChance = 0
    for _, v in ipairs(filtered) do
        totalChance = totalChance + (v.data.chance or 0)
    end

    if totalChance == 0 then return end

    local randomValue = math.random(totalChance)
    local currentChance = 0
    for _, v in ipairs(filtered) do
        currentChance = currentChance + (v.data.chance or 0)
        if randomValue <= currentChance then
            return v.data, v.orig_idx
        end
    end
end

local probabilities = {
	{chance = 1/20, value = function() return 6 end},
	{chance = 1/16, value = function() return 5 end},
	{chance = 1/12, value = function() return 4 end},
	{chance = 1/10, value = function() return 3 end},
	{chance = 1/6, value = function() return 2 end},
	{chance = 1/4, value = function() return 1 end},
}

function MuR:GetLootSpawnCount()
	local maxLoot = MuR.MaxLootNumber or 100
	local pcount = math.max(1, player.GetCount())
	local scaled = math.floor(20 + (pcount * 4))
	return math.Clamp(scaled, 20, maxLoot)
end

function MuR:MakeLootableProps()
	for _, ent in ipairs(ents.FindByClass("prop_*")) do
		if istable(ent.Inventory) then continue end

		ent.Inventory = {}
		local add = 0
		for _, p in ipairs(probabilities) do
			if math.Rand(0,1) < p.chance then
				add = p.value()
				break
			end
		end
		for i=1,add do
			local loot = MuR:GiveRandomTableWithChance(MuR.Loot)
			if not (MuR:DisableWeaponLoot() and (string.find(loot.class, "tfa_bs_") or loot.class == "mur_pepperspray")) then
				table.insert(ent.Inventory, loot.class)
			end
		end 
	end
end

function MuR:ChangeStateOfGame(state)
	if MuR.CleanupInProgress then return end

	local skipCleanup = state and MuR.JustCleaned
	if skipCleanup then
		MuR.JustCleaned = false

		MuR:ChangeStateOfGameLogic(state)
		return
	end

	MuR.CleanupInProgress = true
	game.CleanUpMap(false, {}, function()
		MuR.CleanupInProgress = false
		if not state then MuR.JustCleaned = true end
		MuR:ChangeStateOfGameLogic(state)
	end)
end

function MuR:ChangeStateOfGameLogic(state)
	if state then
		MuR.LootSpawnPositions = {}
		MuR.LootToSpawn = 0
		MuR.LootSpawnStartTime = 0
		local prev = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
		hook.Call("MuR.GameState", nil, true)
		MuR.GameStarted = true
		MuR.RoundNumber = (MuR.RoundNumber or 0) + 1
		MuR.TimeCount = CurTime()

		local gm_tbl, gm_rnd = MuR:GiveRandomTableWithChance(MuR.GamemodeChances, function(v) return player.GetCount() >= v.need_players end)
		MuR.Gamemode = gm_rnd

		if MuR.NextGamemode > 0 then
			MuR.Gamemode = MuR.NextGamemode
			MuR.NextGamemode = 0
		end

		MuR:RemoveMapLogic()
		MuR:ExecuteString("decals")

		local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
		if isfunction(mode.OnModeStarted) then
			mode.OnModeStarted(MuR.Gamemode)
		end

		if not MuR:DisablesGamemode() then
			MuR.LootToSpawn = MuR:GetLootSpawnCount()
			MuR.LootSpawnStartTime = CurTime() + (MuR.LootSpawnInitialDelay or 4)
			timer.Create("MuRSpawnLoot", MuR.LootSpawnInterval or 0.25, 0, function()
				if not MuR.GameStarted then
					timer.Remove("MuRSpawnLoot")
					return
				end
				if CurTime() < (MuR.LootSpawnStartTime or 0) then return end
				if (MuR.LootToSpawn or 0) <= 0 then
					timer.Remove("MuRSpawnLoot")
					return
				end

				local batch = MuR.LootSpawnBatch or 1
				for i = 1, batch do
					if (MuR.LootToSpawn or 0) <= 0 then break end
					MuR:SpawnLoot()
					MuR.LootToSpawn = MuR.LootToSpawn - 1
				end
			end)
		end

		timer.Simple(0.01, function()
			for _, ply in player.Iterator() do
				net.Start("MuR.StartScreen")
				net.WriteFloat(MuR.Gamemode)
				net.WriteString(ply:GetNW2String("Class"))
				net.Send(ply)
			end
			MuR:ReplaceMapProps()
		end)

		MuR:RandomizePlayers()

		local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
		if mode.timer and mode.timer > 0 then
			MuR.TimerEndTime = CurTime() + mode.timer
			MuR.TimerActive = true
		else
			MuR.TimerActive = false
		end

		MuR:MakeDoorsBreakable()
		MuR:MakeLootableProps()
		MuR:SpawnZone()

		for _, ent in ents.Iterator() do
			if ent:IsWeapon() then
				ent:Remove()
			end

			if ent:IsPlayer() then
				ent:ChangeGuilt(-0.5)
			end
		end

		local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
		if mode.countdown_on_start then
			timer.Simple(12, function() MuR:GiveCountdown(10) end)
		end
	else
		local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
		timer.Remove("MuR_SpecialForcesHeli")
		timer.Remove("MuR_SpecialForcesSniper")
		timer.Remove("MuRSpawnLoot")
		MuR.PoliceState = 0
		MuR.SniperArrived = false
		MuR.HeliArrived = false
		MuR:SetPoliceTime(0)
		MuR.NPC_To_Spawn = 0
		MuR.SecuritySpawned = false
		MuR.TeamAssign = false
		MuR.TeamAssignDelay = math.random(60, 300)
		MuR.Ending = false
		MuR.VoteLog = 0
		MuR.VoteAllowed = false
		MuR.VoteLogDeadPolice = 0
		MuR.GameStarted = false
		MuR.GunShots = 0
		MuR.TimerActive = false
		MuR.TimerEndTime = 0
		INFECTED_PLAYERS = {}
		MuR.LogTable = {
			dead = {},
			dead_cops = {},
			injured = {},
			heavy_injured = {},
		}
		hook.Call("MuR.GameState", nil, false)

		if isfunction(mode.OnModeEnded) then
			mode.OnModeEnded(MuR.Gamemode)
		end

		for _, ply in player.Iterator() do
			if ply:Alive() then
				ply:KillSilent()
			end
		end
	end
end

function MuR:SpawnPlayerPolice(assault)
	local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
	if MuR.Gamemode == 17 or MuR.PoliceClasses.no_player_police or mode.no_player_police then return end
	local donthave = false
	for _, ply in player.Iterator() do
		if ply:Alive() or ply:Team() == 1 then continue end
		if math.random(1,2) == 1 and donthave and not assault then continue end

		donthave = true
		ply.ForceSpawn = true

		if MuR.PoliceState == 4 or assault then
			ply:SetNW2String("Class", "ArmoredOfficer")
		else
			ply:SetNW2String("Class", "Officer")
		end

		ply:Spawn()
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
		local pos = MuR:GetRandomPos(false)

		if not isvector(pos) then
			pos = MuR:GetRandomPos(true)
		end

		if isvector(pos) then
			ply:SetPos(pos)
		end
		MuR:GiveAnnounce("officer_spawn", ply)
	end
	if not donthave then
		local ply = table.Random(team.GetPlayers(2))
		if IsValid(ply) then
			ply.ForceSpawn = true

			if MuR.PoliceState == 4 or assault then
				ply:SetNW2String("Class", "ArmoredOfficer")
			else
				ply:SetNW2String("Class", "Officer")
			end

			ply:Spawn()
			ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
			local pos = MuR:GetRandomPos(false)

			if not isvector(pos) then
				pos = MuR:GetRandomPos(true)
			end

			if isvector(pos) then
				ply:SetPos(pos)
			end
			MuR:GiveAnnounce("officer_spawn", ply)
		end
	end
	for _, ply in player.Iterator() do
		if ply:IsKiller() and ply:GetNW2Float("ArrestState") < 1 then
			ply:SetNW2Float("ArrestState", 1)
		end
	end
end

function MuR:GetLootFallbackPos()
	local spawnClasses = {
		"info_player_start", "info_player_deathmatch", "info_player_combine",
		"info_player_rebel", "info_player_counterterrorist", "info_player_terrorist",
		"info_player_axis", "info_player_allies", "gmod_player_start",
		"info_player_teamspawn"
	}
	for _, classname in ipairs(spawnClasses) do
		local ents_list = ents.FindByClass(classname)
		if #ents_list > 0 then
			local ent = ents_list[math.random(1, #ents_list)]
			if IsValid(ent) then
				return ent:GetPos()
			end
		end
	end
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() then
			return ply:GetPos() + Vector(math.random(-500, 500), math.random(-500, 500), 0)
		end
	end
	return nil
end

function MuR:SpawnLoot(pos)
	local pos2
	local attempts = MuR.MaxLootRetries or 8
	local basePos = pos

	local function IsLootPosBlocked(testPos)
		local minDist = MuR.LootMinDistance or 160
		local minDistSq = minDist * minDist
		local list = MuR.LootSpawnPositions
		if not istable(list) then return false end
		for i = 1, #list do
			local prev = list[i]
			if prev and prev:DistToSqr(testPos) < minDistSq then
				return true
			end
		end
		return false
	end

	while attempts > 0 do
		if not basePos then
			basePos = MuR:GetRandomPos(true)
			if not isvector(basePos) then
				basePos = MuR:GetLootFallbackPos()
			end
			if not isvector(basePos) then return end
			pos2 = MuR.FindPositionInRadius and MuR:FindPositionInRadius(basePos, 256)
			if not isvector(pos2) then pos2 = basePos end
		else
			pos2 = basePos
		end

		if isvector(pos2) and not IsLootPosBlocked(pos2) then
			break
		end

		basePos = nil
		pos2 = nil
		attempts = attempts - 1
	end

	if isvector(pos2) then
		local loot = MuR:GiveRandomTableWithChance(MuR.Loot)
		if not loot then return end
		local class = loot.class
		local ent

		if string.StartWith(class, "mur_armor_") then
			local armorId = string.sub(class, 11)
			ent = MuR:SpawnArmorPickup(pos2, armorId)
			if IsValid(ent) then
				ent.MuR_IsLootSpawned = true
				if istable(MuR.LootSpawnPositions) then
					table.insert(MuR.LootSpawnPositions, pos2)
				end
			end
		else
			ent = ents.Create(class)

			if IsValid(ent) then
				ent:SetPos(pos2)
				ent:Spawn()

				if ent:IsWeapon() then
					if ent.ClipSize then
						ent.Primary.DefaultClip = 0

						if ent.ClipSize then
							ent:SetClip1(math.random(0, ent.ClipSize))
							ent:SetClip2(0)
						end
					end
					if MuR:DisableWeaponLoot() then
						ent:Remove()
						return
					end
				end
			end

			if IsValid(ent) then
				ent.MuR_IsLootSpawned = true
				if istable(MuR.LootSpawnPositions) then
					table.insert(MuR.LootSpawnPositions, pos2)
				end
			end
		end
	end
end

function MuR:MakeDoorsBreakable()
	for _, ent in ipairs(ents.FindByClass("*_door_*")) do
		local health = math.Clamp(math.floor(ent:OBBMaxs():Length() * 10), 10, 2500)
		ent:SetNW2Bool("BreakableThing", true)
		ent:SetMaxHealth(health)
		ent:SetHealth(health)
		ent.FixMaxHP = health
	end
end

local function CheckOtherReasons()
	local reason = false
	for _, ply in player.Iterator() do
		if ply:Health() <= 80 then
			reason = "assault"
		end
	end
	for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if rag.IsDead and rag.IsDead == true and reason != "officer" then
			reason = "homicide"
		end
		if rag.IsPoliceCorpse then
			reason = "officer"
		end
	end
	return reason
end

function MuR:SetPoliceTime(val, wm)
	if wm then
		MuR.PoliceArriveTime = CurTime()+val
	else
		MuR.PoliceArriveTime = CurTime()+(val*1.5)
	end
end

function MuR:CallPolice(mult, reason)
	if not mult then
		mult = 1
	end

	local mode = MuR.Mode(MuR.Gamemode)
	local isswat = mode.is_swat
	if MuR.PoliceState > 0 or not MuR.GameStarted or MuR:DisablesGamemode() or MuR.Ending or mode.disables_police then return false end

	if mode.police_call_mult then
		mult = mode.police_call_mult
	end
	if mode.police_time_mult then
		mult = mode.police_time_mult
	end

	if isswat then
		MuR:SetPoliceTime((120 + math.Rand(10,12) * player.GetCount()) * mult)
		MuR.PoliceState = 3
	else
		MuR:SetPoliceTime((120 + math.Rand(12,14) * player.GetCount()) * mult)
		MuR.PoliceState = 1
	end

	local disp = mode.dispatch
	if disp then
		MuR:PlayDispatch(disp)
	elseif reason then
		MuR:PlayDispatch(reason)
	elseif CheckOtherReasons() then
		MuR:PlayDispatch(CheckOtherReasons())
	else
		MuR:PlayDispatch("unknown")
	end

	MuR:CheckOtherForces()

	return true
end

function MuR:ExfilPlayers(pos, dist)
	if not pos then
		pos = Vector(0,0,0)
	end
	if not dist then
		dist = 32000
	end
	for _, ply in player.Iterator() do
		local allow = ply:GetPos():Distance(pos) <= dist
		if !ply:IsKiller() and ply:GetNW2String("Class") != "Zombie" and ply:Alive() then
			if allow then
				ply:KillSilent()
				ply:SetNW2Float("DeathStatus", 4)
			else
				ply:Kill()
			end
		end
	end
end

function MuR:MakeTeamsInGame()
	local tab, tab2 = {}, {}
	for _, ply in player.Iterator() do
		table.insert(tab, ply)
		if ply:Alive() then
			table.insert(tab2, ply)
		end
	end

	if #tab2 >= 2 then
		local id = math.random(1, #tab2)
		local ply = tab2[id]
		ply:SetNW2String("Class", "Traitor")
		ply:SetTeam(1)
		local sidearmPool = MuR.WeaponData and MuR.WeaponData["DefenderWeapons"]
		local sidearm = istable(sidearmPool) and table.Random(sidearmPool) or nil
		local gaveFallbackPistol = false
		if sidearm and sidearm.class then
			ply:GiveWeapon(sidearm.class)
			if sidearm.ammo and sidearm.ammo ~= "" and sidearm.count then
				ply:GiveAmmo(sidearm.count * 2, sidearm.ammo, true)
			end
		else
			ply:GiveWeapon("tfa_bs_m9")
			ply:GiveAmmo(30, "Pistol", true)
			gaveFallbackPistol = true
		end
		ply:AllowFlashlight(true)
		if not gaveFallbackPistol then
			ply:GiveAmmo(30, "Pistol", true)
		end
		ply:GiveWeapon("mur_combat_knife", true)
		ply:GiveWeapon("mur_disguise", true)
		ply:GiveWeapon("mur_scanner", true)
		MuR:GiveAnnounce("you_killer", ply)
		table.remove(tab2, id)
		local id = math.random(1, #tab2)
		local ply = tab2[id]
		ply:SetNW2String("Class", "Defender")
		ply:GiveWeapon("tfa_bs_m9")
		MuR:GiveAnnounce("you_defender", ply)
		table.remove(tab2, id)
	end
end

function MuR:RandomizePlayers()
	local kteam, dteam, iteam = "Killer", "Defender", "Innocent"

	local modeDef = MuR.Mode(MuR.Gamemode)
	if isstring(modeDef.kteam) then kteam = modeDef.kteam end
	if isstring(modeDef.dteam) then dteam = modeDef.dteam end
	if isstring(modeDef.iteam) then iteam = modeDef.iteam end

	if modeDef.experiment_weapon then
		MuR.ExperimentWeapon = table.Random(MuR.ExperimentWeapons)
	end

	local tab = {}
	for _, ply in player.Iterator() do
		table.insert(tab, ply)
	end

	if modeDef.soldier_spawning then
		for _, ply in ipairs(tab) do
			ply:SetNW2String("Class", "Soldier")
			ply:Spawn()
			ply:SetTeam(1)
			ply:Freeze(true)
			ply:GodEnable()
			timer.Simple(12, function()
				if IsValid(ply) then
					ply:Freeze(false)
					ply:GodDisable()
				end
			end)
		end
		return
	end

	if MuR.Gamemode == 50 then
		for i = 1, #tab do
			local ply = tab[i]
			ply:SetNW2String("Class", "Legionnaire")
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()

			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)
		end
		return
	end

	if MuR.Gamemode == 51 then
		local kteam = modeDef.kteam or "GeorgeDroidFloyd"
		local iteam = modeDef.iteam or "FailedDrugDealer"
		local assignedUniqueRoles = {}

		if #tab >= 1 then
			if not assignedUniqueRoles[kteam] then
				local id = math.random(1, #tab)
				local floyd = tab[id]

				local modeAssigns = MuR.NextModeRoleAssignments and MuR.NextModeRoleAssignments[MuR.Gamemode]
				if modeAssigns and modeAssigns[kteam] then
					local playerId = modeAssigns[kteam]
					for idx, p in ipairs(tab) do
						if IsValid(p) and p:SteamID() == playerId then
							floyd = p
							id = idx
							modeAssigns[kteam] = nil
							break
						end
					end
				elseif IsValid(MuR.NextTraitor) then
					floyd = MuR.NextTraitor
					id = table.KeyFromValue(tab, floyd)
					MuR.NextTraitor = nil
				end

				floyd:SetNW2String("Class", kteam)
				assignedUniqueRoles[kteam] = true
				floyd:Spawn()
				floyd:Freeze(true)
				floyd:GodEnable()

				timer.Simple(12, function()
					if not IsValid(floyd) then return end
					floyd:Freeze(false)
					floyd:GodDisable()
				end)

				table.remove(tab, id)
			end
		end

		for i = 1, #tab do
			local ply = tab[i]
			ply:SetNW2String("Class", iteam)
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()

			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)
		end
		return
	end

	if MuR.Gamemode == 53 then
		local assignedUniqueRoles = {}
		if #tab >= 1 then
			if not assignedUniqueRoles[kteam] then
				local id = math.random(1, #tab)
				local ply = tab[id]

				local modeAssigns = MuR.NextModeRoleAssignments and MuR.NextModeRoleAssignments[MuR.Gamemode]
				if modeAssigns and modeAssigns[kteam] then
					local playerId = modeAssigns[kteam]
					for idx, p in ipairs(tab) do
						if IsValid(p) and p:SteamID() == playerId then
							ply = p
							id = idx
							modeAssigns[kteam] = nil
							break
						end
					end
				elseif IsValid(MuR.NextTraitor) then
					ply = MuR.NextTraitor
					id = table.KeyFromValue(tab, ply)
					MuR.NextTraitor = nil
				end

				ply:SetNW2String("Class", kteam)
				assignedUniqueRoles[kteam] = true
				ply:Spawn()
				ply:Freeze(true)
				ply:GodEnable()

				timer.Simple(12, function()
					if not IsValid(ply) then return end
					ply:Freeze(false)
					ply:GodDisable()
				end)

				table.remove(tab, id)
			end
		end
		
		if MuR.Gamemode == 53 and #tab > 0 then
			for _, ply in ipairs(tab) do
				if IsValid(ply) then
					ply:SetNW2String("Class", iteam)
					ply:Spawn()
					ply:Freeze(true)
					ply:GodEnable()
					
					timer.Simple(12, function()
						if IsValid(ply) then
							ply:Freeze(false)
							ply:GodDisable()
						end
					end)
				end
			end
		end
		return
	end

	if not modeDef.custom_spawning and modeDef.spawn_type != "tdm" then
		if #tab >= 2 then
			local id = math.random(1, #tab)
			local ply = tab[id]

			local modeAssigns = MuR.NextModeRoleAssignments and MuR.NextModeRoleAssignments[MuR.Gamemode]
			if modeAssigns and modeAssigns[kteam] then
				local playerId = modeAssigns[kteam]
				for idx, p in ipairs(tab) do
					if IsValid(p) and p:SteamID() == playerId then
						ply = p
						id = idx
						modeAssigns[kteam] = nil
						break
					end
				end
			elseif IsValid(MuR.NextTraitor) then
				ply = MuR.NextTraitor
				id = table.KeyFromValue(tab, ply)
				MuR.NextTraitor = nil
			end

			ply:SetNW2String("Class", kteam)
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()

			if modeDef.killer_spawn_far then
				timer.Simple(1, function()
					if not IsValid(ply) or not ply:Alive() then return end
					local farPos = MuR:FindFarthestSpawnFromPlayers()
					if isvector(farPos) then
						ply:SetPos(farPos)
					end
				end)
			end

			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)

			table.remove(tab, id)

			if #tab > 0 then
				local id = math.random(1, #tab)
				local ply = tab[id]

				modeAssigns = MuR.NextModeRoleAssignments and MuR.NextModeRoleAssignments[MuR.Gamemode]
				if modeAssigns and modeAssigns[dteam] then
					local playerId = modeAssigns[dteam]
					for idx, p in ipairs(tab) do
						if IsValid(p) and p:SteamID() == playerId then
							ply = p
							id = idx
							modeAssigns[dteam] = nil
							break
						end
					end
				elseif IsValid(MuR.NextTraitor2) then
					ply = MuR.NextTraitor2
					id = table.KeyFromValue(tab, ply)
					MuR.NextTraitor2 = nil
				end

				ply:SetNW2String("Class", dteam)
				ply:Spawn()
				ply:Freeze(true)
				ply:GodEnable()

			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)

				table.remove(tab, id)
			end
		elseif MuR.Gamemode == 52 and #tab >= 1 then
			local id = math.random(1, #tab)
			local ply = tab[id]
			ply:SetNW2String("Class", dteam)
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()
			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)
			table.remove(tab, id)
		end

		if #tab >= 1 and modeDef.multi_traitor then
			local count = 1
			if modeDef.multi_traitor_scale then 
				local pCount = player.GetCount()
				if pCount <= 8 then
					count = 1
				elseif pCount <= 12 then
					count = 2
				else
					count = 3
				end
			end
			for i = 1, count do
				if #tab >= 1 then
					local id = math.random(1, #tab)
					local ply = tab[id]

					if i == 1 and IsValid(MuR.NextTraitor2) then
						ply = MuR.NextTraitor2
						id = table.KeyFromValue(tab, ply)
						MuR.NextTraitor2 = nil
					end

					ply:SetNW2String("Class", kteam)
					ply:Spawn()
					ply:Freeze(true)
					ply:GodEnable()

					if modeDef.killer_spawn_far then
						timer.Simple(1, function()
							if not IsValid(ply) or not ply:Alive() then return end
							local farPos = MuR:FindFarthestSpawnFromPlayers()
							if isvector(farPos) then
								ply:SetPos(farPos)
								if MuR.RecordSpawnDebug then MuR.RecordSpawnDebug(ply, farPos, "killer_spawn_far") end
							end
						end)
					end

					timer.Simple(12, function()
						if not IsValid(ply) then return end
						ply:Freeze(false)
						ply:GodDisable()
					end)

					table.remove(tab, id)
				end
			end
		end

		local roles = istable(modeDef.roles) and modeDef.roles or nil

		if roles then
			local isMode52 = (MuR.Gamemode == 52)
			local minCivilians = 5
			for _, r in ipairs(roles) do
				local count = math.max(1, tonumber(r.count) or 1)
				local odds = math.max(1, tonumber(r.odds) or 1)
				local minp = math.max(0, tonumber(r.min_players) or 0)
				local rname = r.class or r.name
				for i = 1, count do
					local canAssign = #tab > 0 and player.GetCount() >= minp and math.random(1, odds) == 1
					if canAssign and isMode52 then
						canAssign = (#tab - 1) >= minCivilians
					end
					if canAssign then
						local id = math.random(1, #tab)
						local ply = table.remove(tab, id)
						ply:SetNW2String("Class", rname)
						ply:Spawn()
						ply:Freeze(true)
						ply:GodEnable()
						timer.Simple(12, function()
							if IsValid(ply) then
								ply:Freeze(false)
								ply:GodDisable()
							end
						end)
					end
				end
			end
		elseif #tab >= 5 and not modeDef.no_default_roles then
			local classes = {
				{"Medic", 3, 5}, {"Builder", 3, 5}, {"HeadHunter", 4, 6},
				{"Criminal", 5, 6}, {"Security", 3, 6}, {"Witness", 3, 6},
				{"Officer", 8, 7}, {"FBI", 8, 7}
			}
			for _, class in ipairs(classes) do
				if math.random(1, class[2]) == 1 and #tab > 1 and player.GetCount() >= class[3] then
					local id = math.random(1, #tab)
					local ply = table.remove(tab, id)
					ply:SetNW2String("Class", class[1])
					ply:Spawn()
					ply:Freeze(true)
					ply:GodEnable()
					timer.Simple(12, function()
						if IsValid(ply) then
							ply:Freeze(false)
							ply:GodDisable()
						end
					end)
				end
			end
		end

		for i = 1, #tab do
			local ply = tab[i]
			ply:SetNW2String("Class", iteam)
			ply:SetTeam(2)
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()

			timer.Simple(12, function()
				if not IsValid(ply) then return end
				ply:Freeze(false)
				ply:GodDisable()
			end)
		end
	elseif modeDef.custom_spawning_func then 
		if isfunction(MuR[modeDef.custom_spawning_func]) then
			MuR[modeDef.custom_spawning_func](MuR)
		end
	else
		table.Shuffle(tab)
		local pos1, pos2 = MuR:FindTwoDistantSpawnLocations()

		local actualPos1, actualPos2
		if MuR.Gamemode == 54 and MuR.Mode54 then
			actualPos1 = MuR.Mode54.ActualSpawnTeam1
			actualPos2 = MuR.Mode54.ActualSpawnTeam2
		end
		if not isvector(actualPos1) or actualPos1 == Vector(0, 0, 0) then
			if isvector(pos1) then
				actualPos1 = MuR.FindNearbySpawnPosition and MuR:FindNearbySpawnPosition(pos1, 120) or pos1
			else
				actualPos1 = MuR:GetRandomPos()
			end
		end
		if not isvector(actualPos2) or actualPos2 == Vector(0, 0, 0) then
			if isvector(pos2) then
				actualPos2 = MuR.FindNearbySpawnPosition and MuR:FindNearbySpawnPosition(pos2, 120) or pos2
			else
				actualPos2 = MuR:GetRandomPos(actualPos1 and nil or false, isvector(actualPos1) and actualPos1 or nil, 300, 2000, true) or MuR:GetRandomPos()
			end
		end

		local team1_count = math.ceil(#tab / 2)
		if modeDef.kteam_count then
			team1_count = modeDef.kteam_count
		elseif modeDef.kteam_ratio then
			team1_count = math.ceil(#tab * modeDef.kteam_ratio)
		end

		local assignedKteam = nil
		local modeAssigns = MuR.NextModeRoleAssignments and MuR.NextModeRoleAssignments[MuR.Gamemode]
		if modeAssigns and modeAssigns[kteam] then
			local playerId = modeAssigns[kteam]
			for _, p in ipairs(tab) do
				if IsValid(p) and p:SteamID() == playerId then
					assignedKteam = p
					modeAssigns[kteam] = nil
					break
				end
			end
		end
		if not assignedKteam and IsValid(MuR.NextTraitor) then
			assignedKteam = MuR.NextTraitor
			MuR.NextTraitor = nil
		end
		if assignedKteam then
			local id = table.KeyFromValue(tab, assignedKteam)
			if id then
				table.remove(tab, id)
				table.insert(tab, 1, assignedKteam)
			end
		end

		local team2_count = #tab - team1_count

		if MuR.Gamemode == 54 then
			MuR.Mode54CombineCounts = {0, 0, 0, 0, 0}
			MuR.Mode54RebelCounts = {0, 0, 0, 0, 0}
			for _, p in ipairs(tab) do
				if IsValid(p) then p.Mode54HasChosen = false end
			end
		end

		local function TeamSpawnOffset(index)
			local col = index % 3
			local row = math.floor(index / 3)
			return Vector((col - 1) * 45, (row - 1) * 45, 0)
		end

		local team1Index, team2Index = 0, 0
		for i = 1, #tab do
			local ply = tab[i]

			if i <= team1_count then
				if MuR.Gamemode == 54 and IsValid(ply) then ply:SetNW2Int("CombineType", 0) end
				ply:SetNW2String("Class", kteam)
				ply:SetTeam(1)
				ply:Spawn()
				ply:Freeze(true)
				ply:GodEnable()
				if isvector(actualPos1) then
					local idx = team1Index
					team1Index = team1Index + 1
					timer.Simple(1, function()
						if !IsValid(ply) or !ply:Alive() then return end
						local offset = TeamSpawnOffset(idx)
						ply:SetPos(actualPos1 + offset + Vector(0, 0, 10))
					end)
				end

				timer.Simple(12, function()
					if not IsValid(ply) then return end
					ply:Freeze(false)
					ply:GodDisable()
				end)
			else
				if MuR.Gamemode == 54 and IsValid(ply) then ply:SetNW2Int("RebelType", 0) end
				ply:SetNW2String("Class", dteam)
				ply:SetTeam(2)
				ply:Spawn()
				ply:Freeze(true)
				ply:GodEnable()
				if isvector(actualPos2) then
					local idx = team2Index
					team2Index = team2Index + 1
					timer.Simple(1, function()
						if !IsValid(ply) or !ply:Alive() then return end
						local offset = TeamSpawnOffset(idx)
						ply:SetPos(actualPos2 + offset + Vector(0, 0, 10))
					end)
				end

				timer.Simple(12, function()
					if not IsValid(ply) then return end
					ply:Freeze(false)
					ply:GodDisable()
				end)
			end
		end

		if MuR.Gamemode == 54 then
			timer.Simple(12, function()
				if not MuR.GameStarted or MuR.Gamemode ~= 54 then return end
				for _, p in ipairs(player.GetAll()) do
					if IsValid(p) then
						local c = p:GetNW2String("Class", "")
						if c == "Combine" or c == "Rebel" then
							net.Start("MuR.Mode54CloseClassMenu")
							net.Send(p)
							if not p.Mode54HasChosen then
								local defaultClass = (c == "Combine") and 4 or 5
								local needRespawn = (c == "Combine" and p:GetNW2Int("CombineType", 4) ~= defaultClass) or (c == "Rebel" and p:GetNW2Int("RebelType", 5) ~= defaultClass)
								if c == "Combine" then
									p:SetNW2Int("CombineType", defaultClass)
								else
									p:SetNW2Int("RebelType", defaultClass)
								end
								if needRespawn then
									p:KillSilent()
									timer.Simple(0.2, function()
										if IsValid(p) then
											p.ForceSpawn = true
											p:Spawn()
											p:Freeze(true)
											p:GodEnable()
											local remain = math.max(0, 12 - (CurTime() - (MuR.TimeCount or CurTime())))
											timer.Simple(remain, function()
												if IsValid(p) then
													p:Freeze(false)
													p:GodDisable()
												end
											end)
										end
									end)
								end
							end
						end
					end
				end
			end)
		end
	end
end

local senddatadelay = 0

hook.Add("Think", "SuR_GameLogic", function()
	if MuR.GameStarted then
		local mode = MuR.Mode(MuR.Gamemode)
		if isfunction(mode.OnModeThink) then
			mode.OnModeThink(MuR.Gamemode)
		end

		if not timer.Exists("MuR_AIClearBadLinks") then
			timer.Create("MuR_AIClearBadLinks", 60, 0, function()
				RunConsoleCommand("ai_clear_bad_links")
			end)
		end

		local team1, team2 = 0, 0

		for _, ent in player.Iterator() do
			if ent:Alive() then
				if ent:Team() == 1 then
					team1 = team1 + 1
				elseif ent:Team() == 2 or ent:Team() == 3 then
					team2 = team2 + 1
				end
			end
		end

		local npc_count = 0
		if mode.npc_team_count then
			local activeNPCs = #ents.FindByClass("npc_vj_bloodshed_suspect")
			local remainingToSpawn = MuR.Mode14 and (MuR.Mode14.NPCToSpawn - MuR.Mode14.NPCSpawned) or 0
			npc_count = activeNPCs + remainingToSpawn
		end

		if MuR.EnableDebug then
			MuR.TimerActive = false
			MuR.TimeCount = 0
			MuR.Delay_Before_Lose = CurTime() + 8
		end

		if mode.win_condition == "zombie" then
			if team1 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif mode.soldier_spawning then
			if team1 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif mode.win_condition == "survivor" then
			if team1 > 1 or team2 > 1 or MuR.TimeCount > CurTime() - 12 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif mode.win_condition == "heist" then
			if team1 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif mode.win_condition == "raid" then
			if team2 > 0 and npc_count > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif MuR.Gamemode == 51 then

			local floydAlive = false
			local dealersAlive = 0
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then
					local class = ply:GetNW2String("Class", "")
					if class == "GeorgeDroidFloyd" then
						floydAlive = true
					elseif class == "FailedDrugDealer" then
						dealersAlive = dealersAlive + 1
					end
				end
			end
			if floydAlive and dealersAlive > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif MuR.Gamemode == 53 then

			local timeSinceStart = CurTime() - MuR.TimeCount
			if timeSinceStart < 45 then
				MuR.Delay_Before_Lose = CurTime() + 8
			else
				local tagilaAlive = false
				local pmcAlive = 0
				local wildsAlive = 0
				local totalAlive = 0
				
				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) and ply:Alive() then
						totalAlive = totalAlive + 1
						local class = ply:GetNW2String("Class", "")
						if class == "Tagila" then
							tagilaAlive = true
						elseif class == "PMC" then
							pmcAlive = pmcAlive + 1
						elseif class == "Wilds" then
							wildsAlive = wildsAlive + 1
						end
					end
				end
				
				local rolesAssigned = tagilaAlive or pmcAlive > 0 or wildsAlive > 0
				
				if not rolesAssigned then
					if totalAlive > 0 then
						MuR.Delay_Before_Lose = CurTime() + 8
					end
				else
					local useTwoTeams = MuR.Mode53UseTwoTeams or false
					
					if useTwoTeams then
						if tagilaAlive and (pmcAlive > 0 or wildsAlive > 0) then
							MuR.Delay_Before_Lose = CurTime() + 8
						elseif not tagilaAlive and pmcAlive > 0 and wildsAlive > 0 then
							MuR.Delay_Before_Lose = CurTime() + 8
						elseif tagilaAlive and pmcAlive > 0 and wildsAlive == 0 then
							MuR.Delay_Before_Lose = CurTime() + 8
						elseif tagilaAlive and wildsAlive > 0 and pmcAlive == 0 then
							MuR.Delay_Before_Lose = CurTime() + 8
						end
					else
						if tagilaAlive and pmcAlive > 0 then
							MuR.Delay_Before_Lose = CurTime() + 8
						end
					end
				end
			end
		elseif mode.win_condition == "tdm" or mode.win_condition == "riot" or mode.win_condition == "specops" then
			if team1 > 0 and team2 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		elseif mode.win_condition == "prison_break" then
			if MuR.Mode23 and not MuR.Mode23.GuardsSpawned then
				MuR.Delay_Before_Lose = CurTime() + 8
			elseif team1 > 0 and team2 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		else
			local standard_logic = not MuR:DisablesGamemode() and team1 > 0 and team2 > 0
			local team_assign_wait = mode.team_assign_delay and MuR.TimeCount > CurTime() - MuR.TeamAssignDelay
			local start_grace = MuR.TimeCount > CurTime() - 12

			if standard_logic or team_assign_wait or start_grace then
				MuR.Delay_Before_Lose = CurTime() + 8
			elseif mode.tdm_end_logic and team1 > 0 and team2 > 0 then
				MuR.Delay_Before_Lose = CurTime() + 8
			end
		end

		if mode.team_assign_delay and MuR.TimeCount < CurTime() - MuR.TeamAssignDelay and not MuR.TeamAssign then
			MuR.TeamAssign = true
			MuR:MakeTeamsInGame()
		end

		if (MuR.PoliceState == 1 or MuR.PoliceState == 3 or MuR.PoliceState == 5) and MuR.PoliceArriveTime < CurTime() then
			MuR.PoliceState = MuR.PoliceState + 1
			MuR:PlaySoundOnClient("murdered/other/policearrive.wav")
			MuR:SpawnPlayerPolice(MuR.PoliceState == 6 or MuR.PoliceState == 4)
			MuR.NPC_To_Spawn = math.floor(math.Clamp(player.GetCount()*math.Rand(0.5,2), 4, 16))
			if MuR.PoliceState == 6 then
				MuR.NPC_To_Spawn = 64
			end
		end

		if MuR.PoliceState == 7 and MuR.PoliceArriveTime < CurTime() then
			MuR:SetPoliceTime(math.random(45,60))
			MuR.PoliceState = MuR.PoliceState + 1
		elseif MuR.PoliceState == 8 and MuR.PoliceArriveTime < CurTime() then
			MuR.PoliceState = 0
		end

		if not MuR.EnableDebug and not mode.no_npc_police_spawn and MuR:CountNPCPolice(true) < MuR.PoliceClasses.max_npcs and MuR.PoliceDelaySpawn < CurTime() and not MuR.PoliceClasses.no_npc_police and MuR.NPC_To_Spawn > 0 then
			local pos = MuR:GetRandomPos(false)
			if not isvector(pos) then
				pos = MuR:GetRandomPos(true)
			end

			if isvector(pos) then
				MuR.PoliceDelaySpawn = CurTime() + MuR.PoliceClasses.delay_spawn
				MuR.NPC_To_Spawn = MuR.NPC_To_Spawn - 1

				if MuR.PoliceState == 4 or MuR.PoliceState == 6 then
					MuR:SpawnNPC("swat", pos)
				else
					MuR:SpawnNPC("patrol", pos)
				end
			end
		end

		if not MuR.EnableDebug and mode.zombie_spawning and #ents.FindByClass("npc_*") < MuR.PoliceClasses.max_npcs and MuR.TimeCount < CurTime() - 12 and MuR.PoliceDelaySpawn < CurTime() then
			local pos = MuR:GetRandomPos(tobool(math.random(0, 1)))

			if isvector(pos) then
				MuR.PoliceDelaySpawn = CurTime() + MuR.PoliceClasses.delay_spawn
				MuR:SpawnNPC("zombie", pos)
			end
		end

		if MuR.TimeCount < CurTime() - 12 then
			if MuR.Ending then
				MuR.PoliceState = 0
			elseif mode.call_police_on_think then
				MuR:CallPolice()
			elseif mode.police_reinforcements then
				MuR:CheckPoliceReinforcment()
			end

			if mode.zombie_spawning and MuR.PoliceState == 0 and MuR.TimeCount > CurTime() - 13 then
				MuR:SetPoliceTime(math.random(90,120))
				MuR.PoliceState = 7
			end

			if mode.escape_flare and MuR.PoliceState == 8 and !IsValid(MuR.EscapeFlareEntity) then
				local underroof = false
				local pos = MuR:GetRandomPos(underroof)
				if not isvector(pos) then
					pos = MuR:GetRandomPos(not underroof)
				end
				if isvector(pos) then
					local ent = ents.Create("escape_flare")
					ent:SetPos(pos)
					ent:Spawn()
					MuR.EscapeFlareEntity = ent
				end
			elseif mode.escape_flare and MuR.PoliceState != 8 and IsValid(MuR.EscapeFlareEntity) then
				MuR.EscapeFlareEntity:Remove()
			end

			if not MuR:DisablesGamemode() and not MuR.SecuritySpawned then
				MuR.SecuritySpawned = true

				for i = 1, MuR.PoliceClasses.security_spawn do
					local pos = MuR:GetRandomPos(MuR.PoliceClasses["security"].underroof)

					if not isvector(pos) then
						pos = MuR:GetRandomPos(not MuR.PoliceClasses["security"].underroof)
					end

					if isvector(pos) then
						MuR:SpawnNPC("security", pos)
					end
				end
			end
		end

		if MuR.Delay_Before_Lose < CurTime() and not MuR.Ending then
			MuR.TimeBeforeStart = CurTime() + 17
			MuR.Ending = true
			MuR.PoliceState = 0

			local show_vote = MuR:GetLogTable() and player.GetCount() > 4

			if MuR.Gamemode == 51 then
				MuR:ShowFinalScreen("", false)
			elseif MuR.Gamemode == 53 then
				MuR:ShowFinalScreen("", false)
			elseif mode.win_condition == "survivor" then
				local humans = 0
				for _, v in player.Iterator() do
					if v:Alive() and v:GetNW2String("Class") != "Zombie" then humans = humans + 1 end
				end
				if humans > 0 then
					MuR:ShowFinalScreen("humans_win", false)
				else
					MuR:ShowFinalScreen("zombies_win", false)
				end
			elseif mode.win_condition == "riot" then
				local police = 0
				for _, v in player.Iterator() do
					if v:Alive() and v:GetNW2String("Class") == "Riot" then police = police + 1 end
				end
				if police > 0 then
					MuR:ShowFinalScreen("police_win", false)
				else
					MuR:ShowFinalScreen("rioters_win", false)
				end
			elseif mode.win_condition == "specops" then
				local police = 0
				for _, v in player.Iterator() do
					if v:Alive() and v:GetNW2String("Class") == "SWAT" then police = police + 1 end
				end
				if police > 0 then
					MuR:ShowFinalScreen("specops_win", false)
				else
					MuR:ShowFinalScreen("terrorists_win", false)
				end
			elseif mode.win_condition == "heist" then
				local criminals = 0
				for _, v in player.Iterator() do
					if v:Alive() and v:GetNW2String("Class") == "Criminal" then criminals = criminals + 1 end
				end
				if criminals > 0 then
					MuR:ShowFinalScreen("criminals_win", false)
				else
					MuR:ShowFinalScreen("police_win", false)
				end
			elseif mode.win_condition == "raid" then
				local police = 0
				for _, v in player.Iterator() do
					if v:Alive() and v:GetNW2String("Class") == "ArmoredOfficer" then police = police + 1 end
				end
				if police > 0 then
					MuR:ShowFinalScreen("police_win", false)
				else
					MuR:ShowFinalScreen("criminals_win", false)
				end
			elseif mode.win_condition == "prison_break" then
				if team1 > 0 then
					MuR:ShowFinalScreen("prisoners_win", false)
				else
					MuR:ShowFinalScreen("guards_win", false)
				end
			elseif mode.tdm_end_logic then
				local team1_alive = 0
				local team2_alive = 0
				for _, v in player.Iterator() do
					if v:Alive() then
						if v:Team() == 1 then team1_alive = team1_alive + 1 end
						if v:Team() == 2 or v:Team() == 3 then team2_alive = team2_alive + 1 end
					end
				end
				if team1_alive > 0 and team2_alive == 0 then
					MuR:ShowFinalScreen(mode.win_screen_team1 or "team1_win", false)
				elseif team2_alive > 0 and team1_alive == 0 then
					MuR:ShowFinalScreen(mode.win_screen_team2 or "team2_win", false)
				else
					MuR:ShowFinalScreen("draw", false)
				end
			elseif mode.no_win_screen then
				MuR:ShowFinalScreen("", false)
			elseif team1 > 0 then
				if mode.win_screen_team1 then
					MuR:ShowFinalScreen(mode.win_screen_team1, show_vote)
				else
					MuR:ShowFinalScreen("traitor", show_vote)
				end
				if show_vote then
					MuR.VoteAllowed = true 
					MuR.VoteLog = 0
				end
			elseif team2 > 0 then
				if mode.win_screen_team2 then
					MuR:ShowFinalScreen(mode.win_screen_team2, show_vote)
				else
					MuR:ShowFinalScreen("innocent", show_vote)
				end
				if show_vote then
					MuR.VoteAllowed = true 
					MuR.VoteLog = 0
				end
			else
				MuR:ShowFinalScreen("", false)
			end

			local tab = player.GetAll()

			for i = 1, #tab do
				local ent = tab[i]
				ent:Freeze(true)
			end
		end

		if MuR.Ending and MuR.TimeBeforeStart < CurTime() then
			if MuR.VoteAllowed and MuR.VoteLog >= player.GetCount()/2 then
				MuR.VoteLog = 0
				MuR.VoteAllowed = false
				MuR:ShowLogScreen()
			else
				MuR:ChangeStateOfGame(false)
			end
		end
	else
		if not MuR.CleanupInProgress and (player.GetCount() > 1 or MuR.EnableDebug or (isnumber(MuR.NextGamemode) and istable(MuR.Mode(MuR.NextGamemode)) and MuR.Mode(MuR.NextGamemode).need_players == 1)) then
			MuR:ChangeStateOfGame(true)
		end
	end

	if senddatadelay < CurTime() then
		senddatadelay = CurTime() + 0.1
		MuR:SendDataToClient("HeliArrived", MuR.HeliArrived)
		MuR:SendDataToClient("SniperArrived", MuR.SniperArrived)
		MuR:SendDataToClient("VoteLog", MuR.VoteLog)
		MuR:SendDataToClient("PoliceState", MuR.PoliceState)
		MuR:SendDataToClient("PoliceArriveTime", MuR.PoliceArriveTime)
		MuR:SendDataToClient("EnableDebug", MuR.EnableDebug)
		if MuR.Gamemode == 54 and MuR.Mode54Defender then
			MuR:SendDataToClient("Mode54Defender", MuR.Mode54Defender)
		end

		local timerShouldPause = false
		local timerShouldStop = false

		if MuR.Ending then
			timerShouldStop = true
		end

		if MuR.Delay_Before_Lose-7 < CurTime() then
			timerShouldPause = true
		end

		if MuR.TimerActive and not timerShouldStop then
			if timerShouldPause then
				local timeLeft = math.max(0, MuR.TimerEndTime - CurTime())
				MuR:SendDataToClient("TimerActive", true)
				MuR:SendDataToClient("TimerLeft", timeLeft)
				MuR:SendDataToClient("TimerPaused", true)
			else
				local timeLeft = math.max(0, MuR.TimerEndTime - CurTime())
				MuR:SendDataToClient("TimerActive", true)
				MuR:SendDataToClient("TimerLeft", timeLeft)
				MuR:SendDataToClient("TimerPaused", false)
			end
		else
			MuR:SendDataToClient("TimerActive", false)
			MuR:SendDataToClient("TimerPaused", false)
		end

		local flare = ents.FindByClass("escape_flare")[1]
		if MuR.PoliceState == 8 and IsValid(flare) then
			MuR:SendDataToClient("ExfilPos", flare:GetPos()+Vector(0,0,32))
		end
	end

	if MuR.TimerActive and MuR.TimerEndTime <= CurTime() and not MuR.Ending and MuR.Delay_Before_Lose-7 > CurTime() then
		local team1, team2 = 0, 0
		local tab = player.GetAll()

		for i = 1, #tab do
			local ent = tab[i]
			if ent:Alive() then
				if ent:Team() == 1 then
					team1 = team1 + 1
				elseif ent:Team() == 2 or ent:Team() == 3 then
					team2 = team2 + 1
				end
			end
		end

		if MuR.Gamemode == 5 or MuR.Gamemode == 14 or MuR.Gamemode == 15 or MuR.Gamemode == 50 then
			for i = 1, #tab do
				local ent = tab[i]
				if ent:Alive() then
					ent:TakeDamage(9999)
				end
			end
			MuR.Delay_Before_Lose = CurTime() - 1
		elseif MuR.Gamemode == 53 then

			local tagilaAlive = false
			local pmcAlive = {}
			local wildsAlive = {}
			
			for _, ply in ipairs(tab) do
				if IsValid(ply) and ply:Alive() then
					local class = ply:GetNW2String("Class", "")
					if class == "Tagila" then
						tagilaAlive = true
					elseif class == "PMC" then
						table.insert(pmcAlive, ply)
					elseif class == "Wilds" then
						table.insert(wildsAlive, ply)
					end
				end
			end
			
			if tagilaAlive and #pmcAlive == 0 and #wildsAlive == 0 then
				for _, ply in ipairs(tab) do
					if IsValid(ply) and ply:GetNW2String("Class") == "Tagila" and ply:Alive() then
						ply:AddMoney(200)
					end
				end
			elseif not tagilaAlive then
				if #pmcAlive > 0 and #wildsAlive == 0 then
					for _, ply in ipairs(pmcAlive) do
						if IsValid(ply) and ply:Alive() then
							ply:AddMoney(150)
						end
					end
				elseif #wildsAlive > 0 and #pmcAlive == 0 then
					for _, ply in ipairs(wildsAlive) do
						if IsValid(ply) and ply:Alive() then
							ply:AddMoney(150)
						end
					end
				elseif #pmcAlive > 0 and #wildsAlive > 0 then
					for _, ply in ipairs(pmcAlive) do
						if IsValid(ply) and ply:Alive() then
							ply:AddMoney(100)
						end
					end
					for _, ply in ipairs(wildsAlive) do
						if IsValid(ply) and ply:Alive() then
							ply:AddMoney(100)
						end
					end
				end
			end
			
			for i = 1, #tab do
				local ent = tab[i]
				if ent:Alive() then
					ent:TakeDamage(9999)
				end
			end
			MuR.Delay_Before_Lose = CurTime() - 1
		elseif MuR.Gamemode == 51 then
			local floyd = nil
			local dealers = {}
			for i = 1, #tab do
				local ent = tab[i]
				if IsValid(ent) and ent:Alive() then
					local class = ent:GetNW2String("Class", "")
					if class == "GeorgeDroidFloyd" then
						floyd = ent
					elseif class == "FailedDrugDealer" then
						table.insert(dealers, ent)
					end
				end
			end
			if IsValid(floyd) and floyd:Alive() and #dealers > 0 then
				for _, dealer in ipairs(dealers) do
					if IsValid(dealer) and dealer:Alive() then
						dealer:AddMoney(100)
						MuR:GiveAnnounce("infentible_dealers_win", dealer)
					end
				end
			end
			MuR.Delay_Before_Lose = CurTime() - 1
		else
			local killTeam = 0
			if team1 < team2 then
				killTeam = 1
			elseif team2 < team1 then
				killTeam = 2
			elseif team1 == team2 and team1 > 0 then
				killTeam = math.random(1, 2)
			end

			if killTeam > 0 then
				for i = 1, #tab do
					local ent = tab[i]
					if ent:Alive() and (ent:Team() == killTeam or (killTeam == 2 and ent:Team() == 3)) then
						ent:TakeDamage(9999)
					end
				end
			end

			MuR.Delay_Before_Lose = CurTime() - 1
		end

		MuR.TimerActive = false
	end
end)

local maxBullets = math.random(8, 16)
hook.Add("EntityFireBullets", "TrackBulletsFired", function(entity, tab)
	local inf = tab.Inflictor
    if entity:IsPlayer() and IsValid(inf) and !inf.Melee then
        MuR.GunShots = MuR.GunShots + 1

        if MuR.GunShots >= maxBullets then       
            MuR:CallPolice(1, "gunfire")
            maxBullets = math.random(24, 32)
			MuR.GunShots = 0
        end
    end
end)