

CreateClientConVar("mur_debug_spawns", "0", true, false, "Debug: show all possible spawn points", 0, 1)
CreateClientConVar("mur_spawn_debug_mode", "0", true, false, "Spawn debug mode filter: 0=all, 54=Combine vs Rebel", 0, 99)

local spawnPoints = {}
local BOX_SIZE = 20
local LABEL_OFFSET = Vector(0, 0, 45)

local function RequestRefresh()
	if GetConVar("mur_debug_spawns"):GetInt() == 1 then
		net.Start("MuR.SpawnDebug.Request")
		net.WriteUInt(GetConVar("mur_spawn_debug_mode"):GetInt(), 8)
		net.SendToServer()
	end
end

net.Receive("MuR.SpawnDebug.PossiblePoints", function()
	spawnPoints = {}
	local count = net.ReadUInt(16)
	for i = 1, count do
		table.insert(spawnPoints, {
			pos = net.ReadVector(),
			valid = net.ReadBool(),
			source = net.ReadString(),
			blacklisted = net.ReadBool(),
			team = net.ReadString() or ""
		})
	end
end)

cvars.AddChangeCallback("mur_debug_spawns", function(_, _, val)
	if tonumber(val) == 1 then RequestRefresh() end
end)
cvars.AddChangeCallback("mur_spawn_debug_mode", function(_, _, val)
	if GetConVar("mur_debug_spawns"):GetInt() == 1 then RequestRefresh() end
end)

local function GetPointColor(m)
	if m.blacklisted then
		return Color(180, 80, 255, 200)
	end
	if m.team == "combine" then
		return m.valid and Color(80, 150, 255, 200) or Color(255, 100, 100, 200)
	end
	if m.team == "rebel" then
		return m.valid and Color(255, 160, 60, 200) or Color(255, 100, 100, 200)
	end
	if m.team == "neutral" then
		return m.valid and Color(200, 200, 100, 180) or Color(255, 100, 100, 200)
	end

	if not m.valid then
		return Color(255, 80, 80, 200)
	end
	return Color(100, 255, 100, 200)
end

hook.Add("PostDrawOpaqueRenderables", "MuR_SpawnDebug_Draw", function()
	if not LocalPlayer():IsSuperAdmin() then return end
	if GetConVar("mur_debug_spawns"):GetInt() ~= 1 then return end

	for _, m in ipairs(spawnPoints) do
		local col = GetPointColor(m)
		local half = BOX_SIZE / 2
		render.SetColorMaterial()
		render.DrawBox(m.pos, Angle(0, 0, 0), Vector(-half, -half, 0), Vector(half, half, 72), col, false)
		render.DrawWireframeBox(m.pos, Angle(0, 0, 0), Vector(-half, -half, 0), Vector(half, half, 72), Color(255, 255, 255, 150), false)
		debugoverlay.Line(m.pos, m.pos + Vector(0, 0, 60), 0.1, col)
	end
end)

hook.Add("PostDrawHUD", "MuR_SpawnDebug_HUD", function()
	if not LocalPlayer():IsSuperAdmin() then return end
	if GetConVar("mur_debug_spawns"):GetInt() ~= 1 then return end

	local modeId = GetConVar("mur_spawn_debug_mode"):GetInt()
	surface.SetFont("DermaDefault")
	local y = 120
	draw.SimpleText("Spawn Debug: " .. #spawnPoints .. " точек | Режим: " .. (modeId == 54 and "Combine vs Rebel" or "Все"), "DermaDefault", 10, y, Color(200, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("Зелёный=OK Красный=в стене Фиолетовый=заблокирован | Синий=Combine Оранжевый=Rebel", "DermaDefault", 10, y + 14, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	for _, m in ipairs(spawnPoints) do
		local labelPos = m.pos + LABEL_OFFSET
		local scr = labelPos:ToScreen()
		if scr.visible then
			local status = m.blacklisted and "BL" or (m.valid and "OK" or "BAD")
			local teamStr = m.team ~= "" and (" | " .. m.team) or ""
			local label = string.format("%s | %s%s", m.source, status, teamStr)
			draw.SimpleText(label, "DermaDefault", scr.x, scr.y, Color(255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)
