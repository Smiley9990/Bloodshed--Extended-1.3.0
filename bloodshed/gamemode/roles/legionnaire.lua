local ROLE = {}

ROLE.name = "Legionnaire"
ROLE.team = 2
ROLE.health = 100
ROLE.flashlight = false
ROLE.models = {
	"models/gore/we_are_legion/prime_decanus_pm.mdl",
	"models/gore/we_are_legion/explorer_pm.mdl",
	"models/gore/we_are_legion/frumentarius_head_new_pm.mdl",
	"models/gore/we_are_legion/alexus_pm.mdl",
	"models/gore/we_are_legion/optio_new.mdl"
}

ROLE.langName = "legionnaire"
ROLE.color = Color(139, 0, 0)
ROLE.desc = "legionnaire_desc"

ROLE.onSpawn = function(ply)

	ply:GiveWeapon("mur_hands", true)
end

MuR:RegisterRole(ROLE)
