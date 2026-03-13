
local MODE54_SPAWNS_PATH = "bloodshed/mode54_spawns_%s.json"

if SERVER then

	function MuR.Mode54LoadSpawns()
		local path = string.format(MODE54_SPAWNS_PATH, game.GetMap())
		if not file.Exists(path, "DATA") then return nil end
		local data = file.Read(path, "DATA")
		if not data or data == "" then return nil end
		local ok, tbl = pcall(util.JSONToTable, data)
		if not ok or not tbl or (not tbl.combine and not tbl.rebel) then return nil end
		local function toVector(t)
			if not t or type(t) ~= "table" then return nil end
			if t.x and t.y and t.z then return Vector(t.x, t.y, t.z) end
			if t[1] and t[2] and t[3] then return Vector(t[1], t[2], t[3]) end
			return nil
		end
		local result = { combine = {}, rebel = {} }
		for _, v in ipairs(tbl.combine or {}) do
			local vec = toVector(v)
			if vec then table.insert(result.combine, vec) end
		end
		for _, v in ipairs(tbl.rebel or {}) do
			local vec = toVector(v)
			if vec then table.insert(result.rebel, vec) end
		end
		if #result.combine == 0 and #result.rebel == 0 then return nil end
		return result
	end

	function MuR.Mode54SaveSpawns(combine, rebel)
		local path = string.format(MODE54_SPAWNS_PATH, game.GetMap())
		local function vecToTbl(v)
			return { x = v.x, y = v.y, z = v.z }
		end
		local data = {
			combine = {},
			rebel = {}
		}
		for _, v in ipairs(combine or {}) do
			table.insert(data.combine, vecToTbl(v))
		end
		for _, v in ipairs(rebel or {}) do
			table.insert(data.rebel, vecToTbl(v))
		end
		file.Write(path, util.TableToJSON(data, false))
	end
end

MuR.RegisterMode(54, {
	name = "Combine vs Rebel",
	chance = 20,
	need_players = 4,
	disables = true,
	disables_police = true,
	no_guilt = true,
	timer = 300,
	countdown_on_start = true,
	custom_spawning = true,
	spawn_type = "tdm",
	win_condition = "tdm",
	tdm_end_logic = true,
	win_screen_team1 = "combine_win",
	win_screen_team2 = "rebels_win",
	kteam = "Combine",
	dteam = "Rebel",

	OnModeStarted = function(mode)
		if SERVER then
			local pos1, pos2
			local savedSpawns = MuR.Mode54LoadSpawns and MuR.Mode54LoadSpawns()
			if savedSpawns and ((savedSpawns.combine and #savedSpawns.combine > 0) or (savedSpawns.rebel and #savedSpawns.rebel > 0)) then

				if savedSpawns.combine and #savedSpawns.combine > 0 then
					pos1 = savedSpawns.combine
				end
				if savedSpawns.rebel and #savedSpawns.rebel > 0 then
					pos2 = savedSpawns.rebel
				end
			end

			local dyn1, dyn2
			if not pos1 or not pos2 then
				dyn1, dyn2 = MuR:FindTwoDistantSpawnLocations(2000, 50)
				if not dyn1 or not dyn2 then
					dyn1, dyn2 = MuR:FindTwoDistantSpawnLocations(1000, 50)
				end
				if not dyn1 or not dyn2 then
					dyn1, dyn2 = MuR:FindTwoDistantSpawnLocations(500, 100)
				end
				if not dyn1 then dyn1 = MuR:GetRandomPos(false) end
				if not dyn2 then dyn2 = MuR:GetRandomPos(false, dyn1, 300, 3000, true) or MuR:GetRandomPos(false) end
			end
			if not pos1 then pos1 = dyn1 or Vector(0, 0, 0) end
			if not pos2 then pos2 = dyn2 or Vector(0, 0, 0) end

			local base1 = isvector(pos1) and pos1 or (istable(pos1) and pos1[1]) or pos1
			local base2 = isvector(pos2) and pos2 or (istable(pos2) and pos2[1]) or pos2
			local actual1 = (isvector(base1) and base1 ~= Vector(0, 0, 0) and MuR.FindNearbySpawnPosition) and MuR:FindNearbySpawnPosition(base1, 120) or base1
			local actual2 = (isvector(base2) and base2 ~= Vector(0, 0, 0) and MuR.FindNearbySpawnPosition) and MuR:FindNearbySpawnPosition(base2, 120) or base2
			local deathSounds = {}
			for i = 1, 10 do
				local snd = "murdered/player/combine soldier/combine death/die_" .. string.format("%02d", i) .. ".wav"
				if file.Exists("sound/" .. snd, "GAME") then
					table.insert(deathSounds, snd)
				end
			end
			MuR.Mode54 = {
				SpawnTeam1 = pos1 or Vector(0, 0, 0),
				SpawnTeam2 = pos2 or Vector(0, 0, 0),
				ActualSpawnTeam1 = isvector(actual1) and actual1 or Vector(0, 0, 0),
				ActualSpawnTeam2 = isvector(actual2) and actual2 or Vector(0, 0, 0),
				DefenderTeam = math.random(1, 2),
				DeathSounds = deathSounds
			}
			MuR.Mode54Defender = MuR.Mode54.DefenderTeam
		end
	end,

	OnModeEnded = function(mode)
		if SERVER then
			MuR:SendDataToClient("Mode54Defender", 0)
			MuR.Mode54 = nil
			MuR.Mode54Defender = nil
		end
	end,

	OnModePrecache = function(mode)
		if CLIENT then
			Material("murdered/modes/gamemodess5.png")
			Material("murdered/modes/gamemodess5h.png")
			sound.PlayFile("sound/murdered/theme/gamemodess5.wav", "noplay", function(station)
				if IsValid(station) then
					station:Stop()
				end
			end)
		end
		if SERVER then
			for i = 1, 10 do
				util.PrecacheSound("murdered/player/combine soldier/combine death/die_" .. string.format("%02d", i) .. ".wav")
			end
			for i = 1, 6 do
				util.PrecacheSound("murdered/player/combine soldier/combine death/gear" .. i .. ".wav")
			end
		end
	end
})

if SERVER then
	hook.Add("PlayerSpawn", "MuR_Mode54_Spawn", function(ply)
		if MuR.Gamemode == 54 and MuR.Mode54 then
			timer.Simple(0.1, function()
				if not IsValid(ply) or not MuR.Mode54 then return end

				local class = ply:GetNW2String("Class", "")
				local actualBase = (class == "Combine" and MuR.Mode54.ActualSpawnTeam1) or (class == "Rebel" and MuR.Mode54.ActualSpawnTeam2)

				if isvector(actualBase) and actualBase ~= Vector(0, 0, 0) then
					local offset = VectorRand() * 50
					offset.z = 0
					ply:SetPos(actualBase + offset + Vector(0, 0, 10))
				end
			end)
		end
	end)

	hook.Add("PlayerFootstep", "MuR_Mode54CombineFootsteps", function(ply, pos, foot, sound, volume, rf)
		if not IsValid(ply) or not ply:Alive() then return end
		if MuR.Gamemode ~= 54 then return end

		if ply:GetNW2String("Class") == "Combine" then
			local soundNum = math.random(1, 6)
			local footstepSound = "murdered/player/combine soldier/combine death/gear" .. soundNum .. ".wav"
			if file.Exists("sound/" .. footstepSound, "GAME") then
				ply:EmitSound(footstepSound, 75, math.random(95, 105), 0.6, CHAN_AUTO)
			else
				footstepSound = "npc/combine_soldier/gear" .. soundNum .. ".wav"
				if file.Exists("sound/" .. footstepSound, "GAME") then
					ply:EmitSound(footstepSound, 75, math.random(95, 105), 0.6, CHAN_AUTO)
				end
			end
			return true
		end
	end)

	hook.Add("PlayerDeath", "MuR_Mode54CombineDeathSound", function(victim, inflictor, attacker)
		if MuR.Gamemode ~= 54 then return end
		if not IsValid(victim) then return end
		if victim:GetNW2String("Class") ~= "Combine" then return end
		if not MuR.Mode54 or not MuR.Mode54.DeathSounds or #MuR.Mode54.DeathSounds == 0 then return end

		local chosen = table.Random(MuR.Mode54.DeathSounds)
		local pos = victim:GetPos() + Vector(0, 0, 32)
		local pitch = math.random(95, 105)

		timer.Simple(0.02, function()
			EmitSound(chosen, pos, 0, CHAN_AUTO, 0.8, 75, 0, pitch)
		end)
	end)
end
