MuR = MuR or {}
MuR.Armor = MuR.Armor or {}
MuR.Armor.ClientModels = MuR.Armor.ClientModels or {}

local function GetArmorModel(ent, bodypart, armorId)
    if not IsValid(ent) then return nil end
    local entIndex = ent:EntIndex()
    MuR.Armor.ClientModels[entIndex] = MuR.Armor.ClientModels[entIndex] or {}
    local key = bodypart .. "_" .. armorId
    local existing = MuR.Armor.ClientModels[entIndex][key]
    if IsValid(existing) then return existing end
    local item = MuR.Armor.GetItem(armorId)
    if not item or not item.model then return nil end
    local mdl = ClientsideModel(item.model, RENDERGROUP_OPAQUE)
    if not IsValid(mdl) then return nil end
    mdl:SetNoDraw(true)
    mdl:SetModelScale(item.scale or 1)
    MuR.Armor.ClientModels[entIndex][key] = mdl
    return mdl
end

local function CleanupArmorModels(entIndex)
    if not MuR.Armor.ClientModels[entIndex] then return end
    for key, mdl in pairs(MuR.Armor.ClientModels[entIndex]) do
        if IsValid(mdl) then mdl:Remove() end
    end
    MuR.Armor.ClientModels[entIndex] = nil
end

local function GetArmorDataFromEntity(ent, bodypart, plySource)

    if plySource and IsValid(plySource) and plySource:IsPlayer() then
        local armorId = plySource:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = plySource:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" then
            return armorId, isActive
        end
    end
    local armorId = ent:GetNW2String("MuR_Armor_" .. bodypart, "")
    local isActive = ent:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
    return armorId, isActive
end

local BODY_FALLBACK_BONES = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Pelvis"}

local function GetBonePosAng(ent, boneName, isRagdoll)
    local boneId = ent:LookupBone(boneName)
    if not boneId then return nil, nil end
    if isRagdoll then
        return ent:GetBonePosition(boneId)
    end
    local mtx = ent:GetBoneMatrix(boneId)
    if mtx then
        return mtx:GetTranslation(), mtx:GetAngles()
    end
    return nil, nil
end

local function IsValidBonePos(bonePos)
    return bonePos and bonePos.x == bonePos.x and bonePos:LengthSqr() > 0.01
end

local function DrawArmorOnEntity(ent, plySource)
    if not IsValid(ent) then return end
    local bodyParts = MuR.Armor and MuR.Armor.BodyParts
    if not bodyParts then return end
    local isRagdoll = ent:IsRagdoll()
    for bodypart, partData in pairs(bodyParts) do
        local armorId, isActive = GetArmorDataFromEntity(ent, bodypart, plySource)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item then
                local mdl = GetArmorModel(ent, bodypart, armorId)
                if IsValid(mdl) then
                    local bonePos, boneAng
                    local bonesToTry = (bodypart == "body" and isRagdoll) and BODY_FALLBACK_BONES or {partData.bone}
                    for _, boneName in ipairs(bonesToTry) do
                        bonePos, boneAng = GetBonePosAng(ent, boneName, isRagdoll)
                        if IsValidBonePos(bonePos) and boneAng then break end
                    end

                    if not IsValidBonePos(bonePos) or not boneAng then continue end

                    if isRagdoll and bodypart == "body" then
                        local spine2Id = ent:LookupBone("ValveBiped.Bip01_Spine2")
                        if spine2Id and spine2Id >= 0 then
                            local scale = ent:GetManipulateBoneScale(spine2Id)
                            if scale and scale:Length() < 0.01 then continue end
                        end
                    end

                    if not isRagdoll then
                        local boneId = ent:LookupBone(partData.bone)
                        if boneId then
                            local boneScale = ent:GetManipulateBoneScale(boneId)
                            if boneScale and boneScale:Length() < 0.01 then continue end
                        end
                    end

                    local offset = item.pos_offset or Vector(0, 0, 0)
                    local angOffset = item.ang_offset or Angle(0, 0, 0)
                    local pos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z
                    boneAng:RotateAroundAxis(boneAng:Up(), angOffset.y)
                    boneAng:RotateAroundAxis(boneAng:Right(), angOffset.p)
                    boneAng:RotateAroundAxis(boneAng:Forward(), angOffset.r)
                    mdl:SetPos(pos)
                    mdl:SetAngles(boneAng)
                    mdl:SetupBones()
                    mdl:DrawModel()
                end
            end
        end
    end
end

local function DrawArmorOnEntitySkipHead(ent, skipHead, plySource)
    if not IsValid(ent) then return end
    local bodyParts = MuR.Armor and MuR.Armor.BodyParts
    if not bodyParts then return end
    for bodypart, partData in pairs(bodyParts) do
        if skipHead and (bodypart == "head" or bodypart == "face" or bodypart == "face2" or bodypart == "facecover" or bodypart == "ears") then continue end
        local armorId, isActive = GetArmorDataFromEntity(ent, bodypart, plySource)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item then
                local mdl = GetArmorModel(ent, bodypart, armorId)
                if IsValid(mdl) then
                    local boneId = ent:LookupBone(partData.bone)
                    if boneId then
                        local bonePos, boneAng = ent:GetBonePosition(boneId)
                        if bonePos and boneAng then
                            if bonePos.x ~= bonePos.x then continue end
                            local offset = item.pos_offset or Vector(0, 0, 0)
                            local angOffset = item.ang_offset or Angle(0, 0, 0)
                            local pos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z
                            boneAng:RotateAroundAxis(boneAng:Up(), angOffset.y)
                            boneAng:RotateAroundAxis(boneAng:Right(), angOffset.p)
                            boneAng:RotateAroundAxis(boneAng:Forward(), angOffset.r)
                            mdl:SetPos(pos)
                            mdl:SetAngles(boneAng)
                            mdl:SetupBones()
                            mdl:DrawModel()
                        end
                    end
                end
            end
        end
    end
end

hook.Add("PostPlayerDraw", "MuR_ArmorRenderPlayer", function(ply)
    if not IsValid(ply) then return end
    if ply == LocalPlayer() then
        local mode = MuR:GetClient("blsd_viewperson")
        if mode == 2 then
            DrawArmorOnEntity(ply)
        elseif mode == 1 then
            DrawArmorOnEntitySkipHead(ply, true)
        end
        return
    end
    DrawArmorOnEntity(ply)
end)

hook.Add("PostDrawOpaqueRenderables", "MuR_ArmorRenderRagdolls", function(depth, skybox)
    local lp = LocalPlayer()
    local drawnRagdolls = {}
    local ragdollOwners = {}

    for _, ply in player.Iterator() do
        if not IsValid(ply) then continue end
        local rd = ply:GetNW2Entity("RD_Ent")
        if IsValid(rd) and rd:IsRagdoll() then
            ragdollOwners[rd] = ply
        end
        local rdCam = ply:GetNW2Entity("RD_EntCam")
        if IsValid(rdCam) and rdCam:IsRagdoll() and not rdCam:IsPlayer() then
            ragdollOwners[rdCam] = ragdollOwners[rdCam] or ply
        end
    end

    for _, ply in player.Iterator() do
        if not IsValid(ply) or not ply:Alive() then continue end
        local rd = ply:GetNW2Entity("RD_Ent")
        if IsValid(rd) and rd:IsRagdoll() then
            drawnRagdolls[rd] = true
            local isLocalPlayerRagdoll = (ply == lp)
            local skipHead = isLocalPlayerRagdoll and (MuR:GetClient("blsd_viewperson") ~= 2)
            DrawArmorOnEntitySkipHead(rd, skipHead, ply)
        end
    end

    local ragdolls = ents.FindByClass("prop_ragdoll")
    if ragdolls then
        for _, ent in ipairs(ragdolls) do
            if not IsValid(ent) then continue end
            if drawnRagdolls[ent] then continue end
            DrawArmorOnEntity(ent, ragdollOwners[ent])
        end
    end
end)

hook.Add("PostDrawBody", "MuR_ArmorRenderFirstPerson", function(body)
    if not IsValid(body) then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if MuR:GetClient("blsd_viewperson") == 0 then return end
    local bodyParts = MuR.Armor and MuR.Armor.BodyParts
    if not bodyParts then return end
    for bodypart, partData in pairs(bodyParts) do
        if bodypart == "head" or bodypart == "face" or bodypart == "face2" or bodypart == "facecover" or bodypart == "ears" then continue end
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item then
                local mdl = GetArmorModel(ply, bodypart .. "_fp", armorId)
                if IsValid(mdl) then
                    local boneId = body:LookupBone(partData.bone)
                    if boneId then
                        local bonePos, boneAng = body:GetBonePosition(boneId)
                        if bonePos and boneAng then
                            local offset = item.pos_offset or Vector(0, 0, 0)
                            local angOffset = item.ang_offset or Angle(0, 0, 0)
                            local pos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z
                            local ang = boneAng + angOffset
                            mdl:SetPos(pos)
                            mdl:SetAngles(ang)
                            mdl:SetupBones()
                            mdl:DrawModel()
                        end
                    end
                end
            end
        end
    end
end)

hook.Add("EntityRemoved", "MuR_ArmorCleanup", function(ent)
    if not IsValid(ent) then return end
    CleanupArmorModels(ent:EntIndex())
end)

hook.Add("OnReloaded", "MuR_ArmorCleanupOnReload", function()
    for entIndex, models in pairs(MuR.Armor.ClientModels) do
        for key, mdl in pairs(models) do
            if IsValid(mdl) then mdl:Remove() end
        end
    end
    MuR.Armor.ClientModels = {}
end)

local overlayMaterials = {}
local function GetOverlayMaterial(matPath)
    if not matPath then return nil end
    if overlayMaterials[matPath] then return overlayMaterials[matPath] end
    local mat = Material(matPath)
    if mat and not mat:IsError() then
        overlayMaterials[matPath] = mat
        return mat
    end
    return nil
end

hook.Add("HUDPaintBackground", "MuR_ArmorOverlay", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if MuR:GetClient("blsd_viewperson") == 2 then return end

    for _, bodypart in ipairs({"face", "face2", "facecover", "head", "ears"}) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item and item.overlay then
                local mat = GetOverlayMaterial(item.overlay)
                if mat then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
                end
            end
        end
    end
end)
