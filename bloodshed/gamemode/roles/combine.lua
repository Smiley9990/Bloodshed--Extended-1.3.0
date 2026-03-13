

local ROLE = {}

ROLE.name = "Combine"
ROLE.team = 1
ROLE.flashlight = true
ROLE.models = {"models/player/combine_soldier_prisonguard.mdl", "models/player/combine_soldier.mdl", "models/player/combine_super_soldier.mdl"}
ROLE.male = true

ROLE.langName = "combine"
ROLE.color = Color(25, 25, 255)
ROLE.desc = "combine_desc"
ROLE.other = "combine_var_heavy"

MuR:RegisterRole(ROLE)
