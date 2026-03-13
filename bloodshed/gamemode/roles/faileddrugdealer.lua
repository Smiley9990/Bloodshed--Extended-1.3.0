local ROLE = {}

ROLE.name = "FailedDrugDealer"
ROLE.team = 2
ROLE.health = 100
ROLE.flashlight = true
ROLE.male = true

ROLE.langName = "faileddrugdealer"
ROLE.color = Color(200, 100, 0)
ROLE.desc = "faileddrugdealer_desc"

ROLE.onSpawn = function(ply)
	ply:GiveWeapon("mur_loot_deadly_fentanyl")
	ply:GiveWeapon("mur_loot_fentanyl")
end

MuR:RegisterRole(ROLE)
