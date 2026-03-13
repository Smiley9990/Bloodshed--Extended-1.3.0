

local cvDebug = CreateClientConVar("mur_armor_debug", "0", true, false, "Armor debug: 1=armor, 2=bones, 3=both, 4=organs, 5=all", 0, 5)
CreateClientConVar("mur_debug_hp", "0", true, false, "Debug: show HP in numbers (bottom left)", 0, 1)

local ARMOR_RADIUS = 3
local BONE_RADIUS = 2.5
local INNER_RADIUS = 0.7
local MAX_DIST_SQ = 600 * 600
local MAX_RAGDOLLS = 5

local HITGROUP_COLORS = {
    [HITGROUP_HEAD] = Color(220, 80, 80, 75),
    [HITGROUP_CHEST] = Color(80, 140, 220, 75),
    [HITGROUP_STOMACH] = Color(80, 200, 100, 75),
    [HITGROUP_LEFTARM] = Color(255, 200, 80, 75),
    [HITGROUP_RIGHTARM] = Color(255, 200, 80, 75),
    [HITGROUP_LEFTLEG] = Color(100, 200, 255, 75),
    [HITGROUP_RIGHTLEG] = Color(100, 200, 255, 75),
    [HITGROUP_GENERIC] = Color(180, 180, 180, 75),
}

local BONE_LABELS = {
    ["ValveBiped.Bip01_Head1"] = "Head",
    ["ValveBiped.Bip01_Neck1"] = "Neck",
    ["ValveBiped.Bip01_R_Clavicle"] = "R_Clavicle",
    ["ValveBiped.Bip01_L_Clavicle"] = "L_Clavicle",
    ["ValveBiped.Bip01_Spine"] = "Spine",
    ["ValveBiped.Bip01_Spine1"] = "Chest",
    ["ValveBiped.Bip01_Spine2"] = "Chest",
    ["ValveBiped.Bip01_Spine4"] = "Chest",
    ["ValveBiped.Bip01_Pelvis"] = "Pelvis",
    ["ValveBiped.Bip01_L_Thigh"] = "L_Thigh",
    ["ValveBiped.Bip01_R_Thigh"] = "R_Thigh",
    ["ValveBiped.Bip01_L_Calf"] = "L_Calf",
    ["ValveBiped.Bip01_R_Calf"] = "R_Calf",
    ["ValveBiped.Bip01_L_Foot"] = "L_Foot",
    ["ValveBiped.Bip01_R_Foot"] = "R_Foot",
    ["ValveBiped.Bip01_L_UpperArm"] = "L_Arm",
    ["ValveBiped.Bip01_R_UpperArm"] = "R_Arm",
    ["ValveBiped.Bip01_L_Forearm"] = "L_Forearm",
    ["ValveBiped.Bip01_R_Forearm"] = "R_Forearm",
    ["ValveBiped.Bip01_L_Hand"] = "L_Hand",
    ["ValveBiped.Bip01_R_Hand"] = "R_Hand",
}

local function GetArmorSource(ent)
    if ent:IsPlayer() and ent:Alive() then return ent end
    if ent:IsRagdoll() then
        local owner = ent.Owner or ent:GetNW2Entity("RD_Owner")
        if IsValid(owner) and owner:IsPlayer() then return owner end
        return ent
    end
    return ent
end

local function GetDamageSource(ent)
    if ent:IsPlayer() then return ent end
    if ent:IsRagdoll() then
        local owner = ent.Owner or ent.owner
        if IsValid(owner) and owner:IsPlayer() and owner:Alive() then return owner end
        return ent
    end
    return ent
end

local debugLabelsToDraw = {}

local function DrawHitbox(pos, outerRadius, fillColor, label, innerPos)
    innerPos = innerPos or pos
    local rOut = Vector(outerRadius, outerRadius, outerRadius)
    local rIn = Vector(INNER_RADIUS, INNER_RADIUS, INNER_RADIUS)

    render.SetColorMaterial()
    render.DrawBox(pos, Angle(0, 0, 0), -rOut, rOut, fillColor)
    render.DrawWireframeBox(pos, Angle(0, 0, 0), -rOut, rOut, Color(255, 255, 255), false)

    render.DrawBox(innerPos, Angle(0, 0, 0), -rIn, rIn, Color(255, 255, 255, 120))
    render.DrawWireframeBox(innerPos, Angle(0, 0, 0), -rIn, rIn, Color(255, 255, 255), false)

    if label and label ~= "" then
        table.insert(debugLabelsToDraw, {pos = pos, label = label})
    end
end

local function DrawArmorHitboxes(ent)
    local source = GetArmorSource(ent)
    if not IsValid(source) then return end

    local bodyParts = MuR.Armor and MuR.Armor.BodyParts
    if not bodyParts then return end
    for bodypart, partData in pairs(bodyParts) do
        local armorId = source:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = source:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId == "" or not isActive then continue end

        local item = MuR.Armor.GetItem(armorId)
        if not item then continue end

        local boneId = ent:LookupBone(partData.bone)
        if not boneId then continue end

        local bonePos, boneAng
        if ent:IsRagdoll() then
            bonePos, boneAng = ent:GetBonePosition(boneId)
        else
            local mtx = ent:GetBoneMatrix(boneId)
            if mtx then
                bonePos = mtx:GetTranslation()
                boneAng = mtx:GetAngles()
            end
        end

        if not bonePos or not boneAng then continue end
        if bonePos.x ~= bonePos.x then continue end

        local offset = item.pos_offset or Vector(0, 0, 0)
        local armorPos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z
        local label = bodypart .. ": " .. armorId

        DrawHitbox(armorPos, ARMOR_RADIUS, Color(0, 200, 120, 80), label, bonePos)
    end
end

local function DrawRagdollBoneHitboxes(ent)
    if not ent:IsRagdoll() and not ent:IsPlayer() then return end
    if ent:IsPlayer() and not ent:Alive() then return end

    local boneToHg = MuR.Armor.BoneToHitgroup or {}
    local dmgEnt = GetDamageSource(ent)
    local dmgTbl = IsValid(dmgEnt) and dmgEnt.LGDamageTable or nil

    for _, boneName in ipairs(MuR.Armor.DamageBones or {}) do
        local boneId = ent:LookupBone(boneName)
        if not boneId then continue end

        local bonePos, boneAng
        if ent:IsRagdoll() then
            bonePos, boneAng = ent:GetBonePosition(boneId)
        else
            local mtx = ent:GetBoneMatrix(boneId)
            if mtx then
                bonePos = mtx:GetTranslation()
                boneAng = mtx:GetAngles()
            end
        end

        if not bonePos then continue end
        if bonePos.x ~= bonePos.x then continue end

        local hg = boneToHg[boneName] or HITGROUP_GENERIC
        local fillColor = HITGROUP_COLORS[hg] or HITGROUP_COLORS[HITGROUP_GENERIC]
        local label = BONE_LABELS[boneName] or boneName

        if dmgTbl and dmgTbl[hg] and dmgTbl[hg].damage and dmgTbl[hg].damage > 0 then
            label = label .. " (" .. math.floor(dmgTbl[hg].damage) .. ")"
        end

        DrawHitbox(bonePos, BONE_RADIUS, fillColor, label)
    end
end

local function DrawOrganHitboxes(ent)
    if not ent:IsRagdoll() and not ent:IsPlayer() then return end
    if ent:IsPlayer() and not ent:Alive() then return end

    if not MuR.Organs then return end

    for _, organ in ipairs(MuR.Organs) do
        local boneId = ent:LookupBone(organ.bone)
        if not boneId then continue end

        local bonePos, boneAng
        if ent:IsRagdoll() then
            bonePos, boneAng = ent:GetBonePosition(boneId)
        else
            local mtx = ent:GetBoneMatrix(boneId)
            if mtx then
                bonePos = mtx:GetTranslation()
                boneAng = mtx:GetAngles()
            end
        end

        if not bonePos or not boneAng then continue end
        if bonePos.x ~= bonePos.x then continue end

        local color = organ.color or Color(255, 255, 255)
        local fillColor = Color(color.r, color.g, color.b, 70)

        render.SetColorMaterial()
        render.DrawBox(bonePos, boneAng, organ.mins, organ.maxs, fillColor)
        render.DrawWireframeBox(bonePos, boneAng, organ.mins, organ.maxs, Color(255, 255, 255), false)

        local center = bonePos + boneAng:Forward() * ((organ.mins.x + organ.maxs.x) / 2) +
            boneAng:Right() * ((organ.mins.y + organ.maxs.y) / 2) +
            boneAng:Up() * ((organ.mins.z + organ.maxs.z) / 2)
        table.insert(debugLabelsToDraw, {pos = center, label = organ.name})
    end
end

hook.Add("PostDrawOpaqueRenderables", "MuR_ArmorDebugHitboxes", function()
    if not LocalPlayer():IsSuperAdmin() then return end
    debugLabelsToDraw = {}
    local mode = cvDebug:GetInt()
    if mode == 0 then return end

    local drawArmor = (mode == 1 or mode == 3 or mode == 5)
    local drawBones = (mode == 2 or mode == 3 or mode == 5)
    local drawOrgans = (mode == 4 or mode == 5)

    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    local lpPos = lp:GetPos()

    local function shouldDraw(ent)
        if not IsValid(ent) then return false end
        return lpPos:DistToSqr(ent:GetPos()) <= MAX_DIST_SQ
    end

    cam.Start3D()

        for _, ply in ipairs(player.GetAll()) do
            if not shouldDraw(ply) then continue end
            if ply == lp and not lp:ShouldDrawLocalPlayer() then continue end
            if ply:IsPlayer() and not ply:Alive() then continue end

            if drawArmor then DrawArmorHitboxes(ply) end
            if drawBones then DrawRagdollBoneHitboxes(ply) end
            if drawOrgans then DrawOrganHitboxes(ply) end
        end

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() then continue end
            local rd = ply:GetNW2Entity("RD_Ent")
            if not IsValid(rd) or not rd:IsRagdoll() then continue end
            if not shouldDraw(rd) then continue end

            if drawArmor then DrawArmorHitboxes(rd) end
            if drawBones then DrawRagdollBoneHitboxes(rd) end
            if drawOrgans then DrawOrganHitboxes(rd) end
        end

        local ragdolls = ents.FindByClass("prop_ragdoll")
        local sorted = {}
        for _, ent in ipairs(ragdolls) do
            if IsValid(ent) and shouldDraw(ent) then
                table.insert(sorted, {ent = ent, distSq = lpPos:DistToSqr(ent:GetPos())})
            end
        end
        table.sort(sorted, function(a, b) return a.distSq < b.distSq end)
        for i = 1, math.min(MAX_RAGDOLLS, #sorted) do
            local ent = sorted[i].ent
            if drawArmor then DrawArmorHitboxes(ent) end
            if drawBones then DrawRagdollBoneHitboxes(ent) end
            if drawOrgans then DrawOrganHitboxes(ent) end
        end
    cam.End3D()
end)

hook.Add("PostDrawHUD", "MuR_ArmorDebugLabels", function()
    if not LocalPlayer():IsSuperAdmin() then return end
    if cvDebug:GetInt() == 0 then return end
    if #debugLabelsToDraw == 0 then return end

    surface.SetFont("DermaDefault")
    for _, data in ipairs(debugLabelsToDraw) do
        local scr = data.pos:ToScreen()
        if scr.visible then
            draw.SimpleText(data.label, "DermaDefault", scr.x, scr.y, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

