local ROLE = {}

ROLE.name = "Tagila"
ROLE.team = 1
ROLE.health = 700
ROLE.flashlight = true
ROLE.killer = true
ROLE.models = {"models/player/eft/tagilla/eft_tagilla/models/eft_tagilla_pm.mdl"}
ROLE.male = true

ROLE.langName = "tagila"
ROLE.color = Color(200, 0, 0)
ROLE.desc = "tagila_desc"

ROLE.onSpawn = function(ply)
	ply:SetModelScale(1.2, 0)
	
	timer.Simple(0.1, function()
		if IsValid(ply) then
			for i = 0, ply:GetNumBodyGroups() - 1 do
				local name = ply:GetBodygroupName(i)
				if name and string.lower(name) == "welding" then
					ply:SetBodygroup(i, 1)
					break
				end
			end
		end
	end)
	
	ply:GiveWeapon("tfa_inss_wpn_saiga12", true)
	ply:GiveWeapon("tfa_bs_sledge", true)
	ply:GiveWeapon("mur_scanner", true)
	
	timer.Simple(0.2, function()
		if IsValid(ply) then
			ply:GiveAmmo(80, "Buckshot", true)
		end
	end)
	
	ply:SetArmor(200)
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(350)
	ply:SetNW2Float("ArrestState", 1)
end

MuR:RegisterRole(ROLE)
