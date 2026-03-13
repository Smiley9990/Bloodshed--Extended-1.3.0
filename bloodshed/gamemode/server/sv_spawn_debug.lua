

util.AddNetworkString("MuR.SpawnDebug.PossiblePoints")
util.AddNetworkString("MuR.SpawnDebug.Request")

local BLACKLIST_PATH = "bloodshed/spawn_blacklist_%s.json"
local BLACKLIST_RADIUS = 100

MuR.SpawnBlacklist = MuR.SpawnBlacklist or {}

local function LoadBlacklist()
	local path = string.format(BLACKLIST_PATH, game.GetMap())
	if not file.Exists(path, "DATA") then
		MuR.SpawnBlacklist = {}
		return
	end
	local data = file.Read(path, "DATA")
	if not data or data == "" then
		MuR.SpawnBlacklist = {}
		return
	end
	local ok, tbl = pcall(util.JSONToTable, data)
	if not ok or not istable(tbl) then
		MuR.SpawnBlacklist = {}
		return
	end
	MuR.SpawnBlacklist = {}
	for _, v in ipairs(tbl) do
		if v and v.x and v.y and v.z then
			table.insert(MuR.SpawnBlacklist, Vector(v.x, v.y, v.z))
		end
	end
end

local function SaveBlacklist()
	local path = string.format(BLACKLIST_PATH, game.GetMap())
	file.CreateDir("bloodshed")
	local tbl = {}
	for _, v in ipairs(MuR.SpawnBlacklist) do
		table.insert(tbl, { x = v.x, y = v.y, z = v.z })
	end
	file.Write(path, util.TableToJSON(tbl, false))
end

function MuR.IsPositionBlacklisted(pos)
	if not isvector(pos) then return false end
	for _, bl in ipairs(MuR.SpawnBlacklist) do
		if pos:DistToSqr(bl) <= BLACKLIST_RADIUS * BLACKLIST_RADIUS then
			return true
		end
	end
	return false
end

LoadBlacklist()
hook.Add("InitPostEntity", "MuR_SpawnDebug_LoadBlacklist", LoadBlacklist)
hook.Add("PostCleanupMap", "MuR_SpawnDebug_LoadBlacklistMap", LoadBlacklist)

local function CollectPossibleSpawnPoints(modeFilter)
	local points = {}
	local tab = MuR.AI_Nodes or {}

	local combineBases, rebelBases = {}, {}
	if modeFilter == 54 and MuR.Mode54LoadSpawns then
		local saved = MuR.Mode54LoadSpawns()
		if saved then
			for _, v in ipairs(saved.combine or {}) do
				if isvector(v) then table.insert(combineBases, v) end
			end
			for _, v in ipairs(saved.rebel or {}) do
				if isvector(v) then table.insert(rebelBases, v) end
			end
		end

		if #combineBases == 0 and #rebelBases == 0 then
			local p1, p2 = MuR:FindTwoDistantSpawnLocations(1500, 50)
			if isvector(p1) then table.insert(combineBases, p1) end
			if isvector(p2) then table.insert(rebelBases, p2) end
		end
	end

	local function getTeamForPos(pos)
		if modeFilter ~= 54 then return "" end
		local nearCombine, nearRebel = false, false
		for _, b in ipairs(combineBases) do
			if pos:DistToSqr(b) <= 120 * 120 then nearCombine = true break end
		end
		for _, b in ipairs(rebelBases) do
			if pos:DistToSqr(b) <= 120 * 120 then nearRebel = true break end
		end
		if nearCombine and nearRebel then return "neutral" end
		if nearCombine then return "combine" end
		if nearRebel then return "rebel" end
		return ""
	end

	for i = 1, #tab do
		local pos = tab[i].pos
		local tr2 = util.TraceHull({
			start = pos + Vector(0, 0, 2),
			endpos = pos + Vector(0, 0, 2),
			filter = function(ent) return true end,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
			mask = MASK_SHOT_HULL,
		})
		table.insert(points, {
			pos = pos,
			valid = not tr2.Hit,
			source = "ai_node",
			blacklisted = MuR.IsPositionBlacklisted(pos),
			team = getTeamForPos(pos)
		})
	end

	local spawnClasses = {
		"info_player_start", "info_player_deathmatch", "info_player_combine",
		"info_player_rebel", "info_player_counterterrorist", "info_player_terrorist",
		"info_player_axis", "info_player_allies", "gmod_player_start",
		"info_player_teamspawn"
	}
	for _, classname in ipairs(spawnClasses) do
		local list = ents.FindByClass(classname)
		if list then
			for _, ent in ipairs(list) do
				if IsValid(ent) then
					local pos = ent:GetPos()
					table.insert(points, {
						pos = pos,
						valid = true,
						source = classname,
						blacklisted = MuR.IsPositionBlacklisted(pos),
						team = getTeamForPos(pos)
					})
				end
			end
		end
	end

	local allAreas = navmesh.GetAllNavAreas()
	if allAreas and #allAreas > 0 then
		local count = 0
		for _, area in ipairs(allAreas) do
			if IsValid(area) and count < 60 then
				local pos = area:GetCenter()
				table.insert(points, {
					pos = pos,
					valid = true,
					source = "navmesh",
					blacklisted = MuR.IsPositionBlacklisted(pos),
					team = getTeamForPos(pos)
				})
				count = count + 1
			end
		end
	end

	if MuR.Mode54LoadSpawns then
		local saved = MuR.Mode54LoadSpawns()
		if saved then
			for _, v in ipairs(saved.combine or {}) do
				if isvector(v) then
					table.insert(points, {
						pos = v,
						valid = true,
						source = "mode54_combine",
						blacklisted = MuR.IsPositionBlacklisted(v),
						team = "combine"
					})
				end
			end
			for _, v in ipairs(saved.rebel or {}) do
				if isvector(v) then
					table.insert(points, {
						pos = v,
						valid = true,
						source = "mode54_rebel",
						blacklisted = MuR.IsPositionBlacklisted(v),
						team = "rebel"
					})
				end
			end
		end
	end

	if MuR.Mode56ReinforcementSpawnPos and isvector(MuR.Mode56ReinforcementSpawnPos) then
		table.insert(points, {
			pos = MuR.Mode56ReinforcementSpawnPos,
			valid = true,
			source = "mode56_reinforcement",
			blacklisted = MuR.IsPositionBlacklisted(MuR.Mode56ReinforcementSpawnPos),
			team = ""
		})
	end

	return points
end

net.Receive("MuR.SpawnDebug.Request", function(len, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local modeFilter = net.ReadUInt(8)
	ply.MuR_SpawnDebugModeFilter = modeFilter
	LoadBlacklist()
	local points = CollectPossibleSpawnPoints(modeFilter)
	net.Start("MuR.SpawnDebug.PossiblePoints")
	net.WriteUInt(#points, 16)
	for _, p in ipairs(points) do
		net.WriteVector(p.pos)
		net.WriteBool(p.valid)
		net.WriteString(p.source)
		net.WriteBool(p.blacklisted)
		net.WriteString(p.team or "")
	end
	net.Send(ply)
	ply:ChatPrint("[MuR Spawn Debug] Загружено " .. #points .. " возможных точек спавна.")
end)

local function SendPointsToPly(ply)
	local modeFilter = ply.MuR_SpawnDebugModeFilter or 0
	local points = CollectPossibleSpawnPoints(modeFilter)
	net.Start("MuR.SpawnDebug.PossiblePoints")
	net.WriteUInt(#points, 16)
	for _, p in ipairs(points) do
		net.WriteVector(p.pos)
		net.WriteBool(p.valid)
		net.WriteString(p.source)
		net.WriteBool(p.blacklisted)
		net.WriteString(p.team or "")
	end
	net.Send(ply)
end

concommand.Add("mur_spawn_debug_blacklist_add", function(ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	LoadBlacklist()
	local pos = ply:GetPos()
	table.insert(MuR.SpawnBlacklist, pos)
	SaveBlacklist()
	ply:ChatPrint("[MuR Spawn Debug] Точка добавлена в чёрный список. Всего: " .. #MuR.SpawnBlacklist)
	if ply:GetInfoNum("mur_debug_spawns", 0) == 1 then
		SendPointsToPly(ply)
	end
end)

concommand.Add("mur_spawn_debug_blacklist_remove", function(ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	LoadBlacklist()
	local myPos = ply:GetPos()
	local bestIdx, bestDist = nil, math.huge
	for i, bl in ipairs(MuR.SpawnBlacklist) do
		local d = myPos:DistToSqr(bl)
		if d < bestDist then
			bestDist = d
			bestIdx = i
		end
	end
	if bestIdx then
		table.remove(MuR.SpawnBlacklist, bestIdx)
		SaveBlacklist()
		ply:ChatPrint("[MuR Spawn Debug] Ближайшая точка убрана из чёрного списка.")
		if ply:GetInfoNum("mur_debug_spawns", 0) == 1 then
			SendPointsToPly(ply)
		end
	else
		ply:ChatPrint("[MuR Spawn Debug] Чёрный список пуст.")
	end
end)

concommand.Add("mur_spawn_debug_blacklist_clear", function(ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	MuR.SpawnBlacklist = {}
	SaveBlacklist()
	ply:ChatPrint("[MuR Spawn Debug] Чёрный список очищен.")
	if ply:GetInfoNum("mur_debug_spawns", 0) == 1 then
		SendPointsToPly(ply)
	end
end)
