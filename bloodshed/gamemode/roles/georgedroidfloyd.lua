local ROLE = {}

ROLE.name = "GeorgeDroidFloyd"
ROLE.team = 1
ROLE.health = 100
ROLE.flashlight = true
ROLE.killer = true
ROLE.models = {"models/player/floyd/georgedroyd.mdl"}
ROLE.male = true

ROLE.langName = "georgedroidfloyd"
ROLE.color = Color(150, 10, 10)
ROLE.desc = "georgedroidfloyd_desc"

ROLE.onSpawn = function(ply)
	local shotgunsTab = {"tfa_bs_nova", "tfa_bs_m37", "tfa_bs_izh43", "tfa_bs_izh43sw", "tfa_bs_ks23", "tfa_bs_m1014", "tfa_bs_m500", "tfa_bs_m590", "tfa_bs_spas"}
	local randomShotgun = table.Random(shotgunsTab)
	ply:GiveWeapon(randomShotgun)
	ply:GiveAmmo(200, "Buckshot", true)
	ply:GiveWeapon("mur_loot_fentanyl")
	ply:GiveWeapon("mur_scanner", true)
	ply:SetArmor(100)
	ply:SetWalkSpeed(140)
	ply:SetRunSpeed(325)
	ply:SetNW2Float("ArrestState", 1)
end

MuR:RegisterRole(ROLE)
