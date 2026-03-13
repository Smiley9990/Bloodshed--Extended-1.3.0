local ROLE = {}

ROLE.name = "Tony"
ROLE.team = 1
ROLE.flashlight = true
ROLE.models = {"models/murdered/pm/tony.mdl"}
ROLE.male = true
ROLE.health = 500

ROLE.langName = "tony"
ROLE.color = Color(255, 0, 0)
ROLE.desc = "tony_desc"

ROLE.onSpawn = function(ply)
    ply:SetPlayerColor(Color(255,0,0):ToVector())

    local primaryList = {"tfa_bs_rpk", "tfa_bs_m249", "tfa_bs_ak12", "tfa_bs_ak74", "tfa_bs_aks74u", "tfa_bs_val", "tfa_bs_aug", "tfa_bs_l1a1", "tfa_bs_g3", "tfa_bs_hk416", "tfa_bs_badger", "tfa_bs_m4a1", "tfa_bs_mk17", "tfa_bs_acr", "tfa_bs_sg552", "tfa_inss_wpn_saiga12"}
    local secondaryList = {"tfa_bs_m9", "tfa_bs_colt", "tfa_bs_glock", "tfa_bs_usp", "tfa_bs_deagle", "tfa_bs_cobra", "tfa_bs_mateba", "tfa_bs_p320", "tfa_bs_ruger", "tfa_bs_walther"}

    local pri = table.Random(primaryList)
    local sec = table.Random(secondaryList)
    ply:GiveWeapon(pri)
    ply:GiveWeapon(sec)

    timer.Simple(0.3, function()
        if not IsValid(ply) or not ply:Alive() then return end
        local pw = ply:GetWeapon(pri)
        if IsValid(pw) then
            local ammo = pw.Primary and pw.Primary.Ammo
            local clip = (pw.Primary and pw.Primary.ClipSize) or pw:GetMaxClip1() or 30
            if ammo and ammo ~= "" then ply:GiveAmmo(clip * 16, ammo, true)
            elseif pw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 16, pw:GetPrimaryAmmoType(), true)
            else ply:GiveAmmo(math.max(clip * 16, 480), string.find(pri, "saiga") and "Buckshot" or "AR2", true) end
        end
        local sw = ply:GetWeapon(sec)
        if IsValid(sw) then
            local ammo = sw.Primary and sw.Primary.Ammo
            local clip = (sw.Primary and sw.Primary.ClipSize) or sw:GetMaxClip1() or 15
            if ammo and ammo ~= "" then ply:GiveAmmo(clip * 8, ammo, true)
            elseif sw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 8, sw:GetPrimaryAmmoType(), true)
            else ply:GiveAmmo(math.max(clip * 8, 120), "Pistol", true) end
        end
    end)

    ply:GiveWeapon("tfa_bs_fireaxe_maniac", true)
    ply:GiveWeapon("mur_loot_medkit")
    ply:GiveWeapon("mur_loot_surgicalkit")
    ply:GiveWeapon("mur_loot_tourniquet")
    ply:GiveWeapon("mur_loot_bandage")
    ply:GiveWeapon("mur_f1")
    timer.Simple(0.05, function()
        if IsValid(ply) then ply:EquipArmor("tony_armor") end
    end)
    ply:SetWalkSpeed(110)
    ply:SetRunSpeed(300)
    ply:SetMaxHealth(500)
end

MuR:RegisterRole(ROLE)