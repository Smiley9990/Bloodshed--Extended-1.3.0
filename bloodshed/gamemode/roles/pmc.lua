local ROLE = {}

ROLE.name = "PMC"
ROLE.team = 2
ROLE.health = 100
ROLE.flashlight = true
ROLE.models = {"models/murdered/pm/ct_spetsnaz.mdl"}
ROLE.male = true

ROLE.langName = "pmc"
ROLE.color = Color(50, 100, 200)
ROLE.desc = "pmc_desc"

ROLE.onSpawn = function(ply)
	ply:SetModelScale(1.0, 0)
	

	if MuR.Gamemode == 56 then
		timer.Simple(0.05, function()
			if not IsValid(ply) then return end
			ply:EquipArmor("classIII_armor")
			local headOpts = {"cap_bear_black", "cap_boss", "cap_bear_green", "helmet_ulach"}
			ply:EquipArmor(headOpts[math.random(#headOpts)])
			local facecoverOpts = {"facecover_nomex", "facecover_skull", "facecover_gray", "facecover_black", "facecover_smoke", "facecover_zryachii"}
			ply:EquipArmor(facecoverOpts[math.random(#facecoverOpts)])
			local faceOpts = {"face_aviator", "face_gaswelder", "face_tactical", "face_raybench", "face_roundglasses", "face_6b34"}
			ply:EquipArmor(faceOpts[math.random(#faceOpts)])
			local earsOpts = {"ears_xcel", "ears_tactical_sport", "ears_razor", "ears_sordin", "ears_m32"}
			ply:EquipArmor(earsOpts[math.random(#earsOpts)])
		end)
	end
	

	if MuR.Gamemode != 53 and MuR.Gamemode != 55 then
		ply:GiveWeapon("tfa_bs_ak12", true)
		ply:GiveWeapon("tfa_bs_glock", true)
		ply:GiveWeapon("mur_loot_medkit", true)
		ply:GiveWeapon("mur_loot_bandage", true)
		ply:GiveWeapon("mur_scanner", true)
		ply:GiveAmmo(120, "AR2", true)
		ply:GiveAmmo(51, "Pistol", true)
	end
	
	ply:SetArmor(100)
	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(280)
end

MuR:RegisterRole(ROLE)
