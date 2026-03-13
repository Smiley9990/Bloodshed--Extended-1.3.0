local ROLE = {}

ROLE.name = "Bravo6"
ROLE.team = 2
ROLE.flashlight = true
ROLE.models = {
	"models/murdered/pm/swat/male_01.mdl",
	"models/murdered/pm/swat/male_02.mdl",
	"models/murdered/pm/swat/male_03.mdl",
	"models/murdered/pm/swat/male_04.mdl",
	"models/murdered/pm/swat/male_05.mdl",
	"models/murdered/pm/swat/male_06.mdl",
	"models/murdered/pm/swat/male_07.mdl",
	"models/murdered/pm/swat/male_08.mdl",
	"models/murdered/pm/swat/male_09.mdl"
}
ROLE.male = true

ROLE.langName = "bravo6"
ROLE.color = Color(0, 0, 139)
ROLE.desc = "bravo6_desc"

ROLE.onSpawn = function(ply)
	ply:SetPlayerColor(Color(50, 50, 50):ToVector())
	timer.Simple(0.05, function()
		if IsValid(ply) then
			ply:EquipArmor("classIII_police")
			ply:EquipArmor("helmet_ulach")
		end
	end)

	local primaryList = {"tfa_bs_sr25", "tfa_bs_aug", "tfa_bs_car15", "tfa_bs_l1a1", "tfa_bs_g3", "tfa_bs_hk416", "tfa_bs_badger", "tfa_bs_m16", "tfa_bs_m4a1", "tfa_bs_mk17", "tfa_bs_acr", "tfa_bs_sg552", "tfa_bs_nova", "tfa_bs_m1014", "tfa_bs_m500", "tfa_bs_m590", "tfa_bs_spas", "tfa_bs_ump", "tfa_bs_vector", "tfa_bs_mp5a5", "tfa_bs_mp7"}

	local pri = table.Random(primaryList)
	ply:GiveWeapon(pri)
	ply:GiveWeapon("tfa_bs_m9")

	timer.Simple(0.3, function()
		if not IsValid(ply) or not ply:Alive() then return end
		local pw = ply:GetWeapon(pri)
		if IsValid(pw) then
			local ammo = pw.Primary and pw.Primary.Ammo
			local clip = (pw.Primary and pw.Primary.ClipSize) or pw:GetMaxClip1() or 30
			if ammo and ammo ~= "" then ply:GiveAmmo(clip * 2, ammo, true)
			elseif pw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 2, pw:GetPrimaryAmmoType(), true)
			else ply:GiveAmmo(math.max(clip * 2, 60), (string.find(pri, "nova") or string.find(pri, "m1014") or string.find(pri, "m500") or string.find(pri, "m590") or string.find(pri, "spas")) and "Buckshot" or "AR2", true) end
		end
		local sw = ply:GetWeapon("tfa_bs_m9")
		if IsValid(sw) then
			local ammo = sw.Primary and sw.Primary.Ammo
			local clip = (sw.Primary and sw.Primary.ClipSize) or sw:GetMaxClip1() or 15
			if ammo and ammo ~= "" then ply:GiveAmmo(clip * 2, ammo, true)
			elseif sw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 2, sw:GetPrimaryAmmoType(), true)
			else ply:GiveAmmo(math.max(clip * 2, 30), "Pistol", true) end
		end
	end)

	ply:GiveWeapon("mur_loot_bandage")
	ply:GiveWeapon("mur_radio")
	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(280)
end

MuR:RegisterRole(ROLE)
