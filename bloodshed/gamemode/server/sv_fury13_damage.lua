

util.AddNetworkString("MuR.Fury13HeadExplode")

util.AddNetworkString("MuR.Fury13Laugh")

util.AddNetworkString("MuR.Fury13LaughClient")

hook.Add("Initialize", "MuR.Fury13_AddResources", function()

	local files = file.Find("sound/murdered/berserk/laugh/laugh*.wav", "GAME")
	for _, f in ipairs(files or {}) do
		resource.AddFile("sound/murdered/berserk/laugh/" .. f)
	end

	local files2 = file.Find("sound/murdered/berserk/laugh*.wav", "GAME")
	for _, f in ipairs(files2 or {}) do
		resource.AddFile("sound/murdered/berserk/" .. f)
	end

	if file.Exists("sound/murdered/berserk/deathsample.ogg", "GAME") then
		resource.AddFile("sound/murdered/berserk/deathsample.ogg")
	end
	if file.Exists("sound/murdered/berserk/pharmacia.mp3", "GAME") then
		resource.AddFile("sound/murdered/berserk/pharmacia.mp3")
	end
	if file.Exists("sound/murdered/berserk/heartbeat.mp3", "GAME") then
		resource.AddFile("sound/murdered/berserk/heartbeat.mp3")
	end

	if file.Exists("gamemodes/bloodshed/resource/fonts/Bloodru.ttf", "GAME") then
		resource.AddFile("gamemodes/bloodshed/resource/fonts/Bloodru.ttf")
	elseif file.Exists("resource/fonts/Bloodru.ttf", "GAME") then
		resource.AddFile("resource/fonts/Bloodru.ttf")
	end
end)

net.Receive("MuR.Fury13HeadExplode", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end
	

	local berserkEnd = ply:GetNW2Float("BerserkEnd", 0)
	if berserkEnd == 0 then

		return
	end
	

	if CurTime() - berserkEnd > 1 then
		return
	end
	

	local rag = ply:GetRD()
	if not IsValid(rag) then
		rag = ply:StartRagdolling(0, 0)
	end
	

	timer.Simple(0.15, function()
		if not IsValid(ply) then return end
		

		local currentBerserkEnd = ply:GetNW2Float("BerserkEnd", 0)
		if currentBerserkEnd == 0 then
			return
		end
		
		local rag = ply:GetRD()
		if IsValid(rag) then

			local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
			if headBone and headBone > 0 then
				local headPhysBone = rag:TranslateBoneToPhysBone(headBone)
				if isnumber(headPhysBone) and headPhysBone > 0 then
					rag:ZippyGoreMod3_BreakPhysBone(headPhysBone, {
						damage = 1000,
						forceVec = Vector(0, 0, 0),
						dismember = true
					})
				end
			end
		else

			local headPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1") or 0)
			if headPos == vector_origin then
				headPos = ply:EyePos()
			end
			
			local dmg = DamageInfo()
			dmg:SetDamage(1000)
			dmg:SetAttacker(ply)
			dmg:SetInflictor(Entity(0))
			dmg:SetDamageType(DMG_ALWAYSGIB)
			dmg:SetDamageForce(Vector(0, 0, 500))
			dmg:SetDamagePosition(headPos)
			ply:TakeDamageInfo(dmg)
		end
	end)
end)

hook.Add("PlayerSpawn", "MuR.Fury13ClearBerserkOnSpawn", function(ply)
	ply:SetNW2Int("MuR_LifeCount", (ply:GetNW2Int("MuR_LifeCount", 0) + 1))
	ply:SetNW2Float("BerserkLevel", 0)
	ply:SetNW2Float("BerserkEnd", 0)
	local ind = ply:EntIndex()
	if timer.Exists("BerserkThink"..ind) then
		timer.Remove("BerserkThink"..ind)
	end

	if timer.Exists("Fury13Stamina"..ind) then
		timer.Remove("Fury13Stamina"..ind)
	end
end)

hook.Add("PlayerDeath", "MuR.Fury13ClearBerserkOnDeath", function(ply)
	ply:SetNW2Float("BerserkLevel", 0)
	ply:SetNW2Float("BerserkEnd", 0)
	local ind = ply:EntIndex()
	if timer.Exists("BerserkThink"..ind) then
		timer.Remove("BerserkThink"..ind)
	end

	if timer.Exists("Fury13Stamina"..ind) then
		timer.Remove("Fury13Stamina"..ind)
	end
end)

hook.Add("MuR.GameState", "MuR.Fury13ClearBerserkOnRoundEnd", function(_, state)
	if state then return end
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) then
			ply:SetNW2Float("BerserkLevel", 0)
			ply:SetNW2Float("BerserkEnd", 0)
			local ind = ply:EntIndex()
			if timer.Exists("BerserkThink"..ind) then
				timer.Remove("BerserkThink"..ind)
			end
			if timer.Exists("Fury13Stamina"..ind) then
				timer.Remove("Fury13Stamina"..ind)
			end
		end
	end
end)

hook.Add("EntityTakeDamage", "MuR.Fury13BerserkDamageBoost", function(ent, dmg)
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	

	local furyLevel = attacker:GetNW2Float("BerserkLevel", 0)
	if furyLevel <= 0 then return end
	
	local furyEnd = attacker:GetNW2Float("BerserkEnd", 0)
	if CurTime() >= furyEnd then return end
	

	local damageMultiplier = 1 + (furyLevel / 10) * 1.0
	dmg:ScaleDamage(damageMultiplier)
end)

net.Receive("MuR.Fury13Laugh", function(len, ply)
	if not IsValid(ply) or not ply:Alive() then return end
	
	local soundPath = net.ReadString()
	if not soundPath or soundPath == "" then return end
	

	net.Start("MuR.Fury13LaughClient")
	net.WriteString(soundPath)
	net.WriteEntity(ply)
	net.Broadcast()
end)
