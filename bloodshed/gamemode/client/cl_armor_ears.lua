

local FOOTSTEP_PATTERNS = {
    "footstep",
    "footsteps",
    "/step",
    "combine_soldier/gear",
}

local function IsFootstepSound(soundName)
    if not soundName or soundName == "" then return false end
    local lower = string.lower(soundName)
    for _, pat in ipairs(FOOTSTEP_PATTERNS) do
        if string.find(lower, pat) then return true end
    end

    if string.find(lower, "player/footsteps") then return true end
    if string.find(lower, "npc/footsteps") then return true end
    if string.find(lower, "physics/") and string.find(lower, "footstep") then return true end
    return false
end

local function HasHeadphonesEffect(ply)
    if not IsValid(ply) or not ply:Alive() then return false end
    local armorId = ply:GetNW2String("MuR_Armor_ears", "")
    if armorId == "" then return false end
    local item = MuR.Armor and MuR.Armor.GetItem and MuR.Armor.GetItem(armorId)
    if not item or not item.sound_boost_footsteps then return false end
    local isActive = ply:GetNW2Bool("MuR_Armor_Active_ears", false)
    return isActive
end

local function InstallSoundPlayHook()
    if sound._MuR_OriginalPlay then return end
    sound._MuR_OriginalPlay = sound.Play
    function sound.Play(snd, pos, level, pitch, volume, dsp)
        if IsValid(LocalPlayer()) and HasHeadphonesEffect(LocalPlayer()) and IsFootstepSound(snd or "") then
            volume = math.min(1, (volume or 1) * 1.5)
        end
        return sound._MuR_OriginalPlay(snd, pos, level, pitch, volume, dsp)
    end
end
InstallSoundPlayHook()
timer.Simple(2, InstallSoundPlayHook)

hook.Add("EntityEmitSound", "MuR_ArmorEars_SoundFilter", function(data)
    if not CLIENT then return end
    local ply = LocalPlayer()
    if not IsValid(ply) or not HasHeadphonesEffect(ply) then return end

    local soundName = data.SoundName or data.OriginalSoundName or ""
    local isFootstep = IsFootstepSound(soundName)

    local item = MuR.Armor.GetItem(LocalPlayer():GetNW2String("MuR_Armor_ears", ""))
    local muffle = item and item.sound_muffle_other or 0.35

    if isFootstep then

        data.Volume = math.min(1, (data.Volume or 1) * 1.5)
        return true
    else

        data.Volume = (data.Volume or 1) * muffle
        return true
    end
end)

local cv_soundscape = nil
local lastHeadphonesState = false
local savedSoundscapeVolume = 1

hook.Add("Think", "MuR_ArmorEars_SoundscapeVolume", function()
    if not CLIENT then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local hasHeadphones = HasHeadphonesEffect(ply)
    if hasHeadphones == lastHeadphonesState then return end
    lastHeadphonesState = hasHeadphones

    if cv_soundscape == nil then
        cv_soundscape = GetConVar("snd_soundscape_volume") or false
    end
    if not cv_soundscape then return end

    if hasHeadphones then
        savedSoundscapeVolume = cv_soundscape:GetFloat()
        local item = MuR.Armor and MuR.Armor.GetItem and MuR.Armor.GetItem(ply:GetNW2String("MuR_Armor_ears", ""))
        local muffle = item and item.sound_muffle_other or 0.35
        RunConsoleCommand("snd_soundscape_volume", tostring(muffle))
    else
        RunConsoleCommand("snd_soundscape_volume", tostring(savedSoundscapeVolume))
    end
end)
