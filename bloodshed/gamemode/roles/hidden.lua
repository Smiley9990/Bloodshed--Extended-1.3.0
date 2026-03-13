local ROLE = {}

ROLE.name = "Hidden"
ROLE.team = 1
ROLE.health = 150
ROLE.flashlight = false
ROLE.killer = true

ROLE.langName = "hidden"
ROLE.color = Color(180, 80, 20)
ROLE.desc = "hidden_desc"

ROLE.models = {"models/murdered/pm/jason_v.mdl"}
ROLE.male = true

ROLE.onSpawn = function(ply)
	if MuR.Gamemode != 55 then return end

	ply:StripWeapons()
	ply:GiveWeapon("tfa_bs_combk", true)
	ply:SetWalkSpeed(150)
	ply:SetRunSpeed(350)
	ply:SetJumpPower(300)
end

MuR:RegisterRole(ROLE)
