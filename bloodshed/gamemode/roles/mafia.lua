local ROLE = {}

ROLE.name = "Mafia"
ROLE.team = 2
ROLE.flashlight = true
ROLE.models = {"models/murdered/pm/gangs/gang_groove_chem.mdl", "models/murdered/pm/gangs/gang_1.mdl", "models/murdered/pm/gangs/gang_2.mdl"}
ROLE.male = true

ROLE.langName = "mafia"
ROLE.color = Color(100, 100, 100)
ROLE.desc = "mafia_desc"

ROLE.onSpawn = function(ply)
    ply:SetPlayerColor(Color(50,50,50):ToVector())

    local primaryList = {"tfa_bs_draco", "tfa_bs_aks74u", "tfa_bs_izh43", "tfa_bs_izh43sw", "tfa_bs_nova", "tfa_bs_m37", "tfa_bs_m500", "tfa_bs_m590", "tfa_bs_uzi", "tfa_bs_mac11"}
    local secondaryList = {"tfa_bs_m9", "tfa_bs_colt", "tfa_bs_glock", "tfa_bs_usp", "tfa_bs_deagle", "tfa_bs_cobra", "tfa_bs_mateba", "tfa_bs_p320", "tfa_bs_ruger", "tfa_bs_walther", "tfa_bs_pm"}

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
            if ammo and ammo ~= "" then ply:GiveAmmo(clip * 2, ammo, true)
            elseif pw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 2, pw:GetPrimaryAmmoType(), true)
            else ply:GiveAmmo(math.max(clip * 2, 60), (string.find(pri, "izh") or string.find(pri, "nova") or string.find(pri, "m37") or string.find(pri, "m500") or string.find(pri, "m590")) and "Buckshot" or "AR2", true) end
        end
        local sw = ply:GetWeapon(sec)
        if IsValid(sw) then
            local ammo = sw.Primary and sw.Primary.Ammo
            local clip = (sw.Primary and sw.Primary.ClipSize) or sw:GetMaxClip1() or 15
            if ammo and ammo ~= "" then ply:GiveAmmo(clip * 2, ammo, true)
            elseif sw:GetPrimaryAmmoType() > 0 then ply:GiveAmmo(clip * 2, sw:GetPrimaryAmmoType(), true)
            else ply:GiveAmmo(math.max(clip * 2, 30), "Pistol", true) end
        end
    end)

    ply:SetWalkSpeed(100)
    ply:SetRunSpeed(280)
end

MuR:RegisterRole(ROLE)