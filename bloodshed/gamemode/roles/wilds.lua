local ROLE = {}

ROLE.name = "Wilds"
ROLE.team = 3
ROLE.health = 100
ROLE.flashlight = true
ROLE.models = function(ply)
	if MuR.PlayerModels and MuR.PlayerModels["Terrorist_TDM"] and #MuR.PlayerModels["Terrorist_TDM"] > 0 then
		return table.Random(MuR.PlayerModels["Terrorist_TDM"])
	end

	local civModels = MuR.PlayerModels and MuR.PlayerModels["Civilian_Male"]
	if civModels and #civModels > 0 then
		return table.Random(civModels)
	end
	return "models/player/group01/male_01.mdl"
end
ROLE.male = true

ROLE.langName = "wilds"
ROLE.color = Color(200, 100, 50)
ROLE.desc = "wilds_desc"

ROLE.onSpawn = function(ply)
	ply:SetModelScale(1.0, 0)
	

	if MuR.Gamemode != 53 then
		ply:GiveWeapon("tfa_bs_akm", true)
		ply:GiveWeapon("tfa_bs_glock", true)
		ply:GiveWeapon("mur_loot_bandage", true)
		ply:GiveWeapon("mur_scanner", true)
		ply:GiveAmmo(90, "AR2", true)
		ply:GiveAmmo(51, "Pistol", true)
	end
	
	ply:SetArmor(75)
	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(280)
end

MuR:RegisterRole(ROLE)
