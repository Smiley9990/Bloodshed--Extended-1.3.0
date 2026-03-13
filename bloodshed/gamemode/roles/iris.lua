

local ROLE = {}

ROLE.name = "I.R.I.S"
ROLE.team = 2
ROLE.health = 100
ROLE.flashlight = true
ROLE.models = {"models/murdered/pm/css_swat.mdl", "models/murdered/pm/css_seb.mdl"}
ROLE.male = true

ROLE.langName = "iris"
ROLE.color = Color(100, 50, 255)
ROLE.desc = "iris_desc"

ROLE.onSpawn = function(ply)
	ply:SetModelScale(1.0, 0)

	if MuR.Gamemode ~= 55 then return end

	ply:SetArmor(100)
	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(280)
end

MuR:RegisterRole(ROLE)
