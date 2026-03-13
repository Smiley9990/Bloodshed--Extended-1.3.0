local ARMOR_UI_THEME = {
    background = Color(25, 25, 32, 250),
    header = Color(35, 35, 45, 255),
    accent = Color(200, 0, 0),
    panel = Color(45, 45, 55, 255),
    panelHover = Color(60, 60, 70, 255),
    panelBorder = Color(70, 70, 85, 255),
    text = Color(255, 255, 255),
    textDark = Color(160, 160, 170),
    success = Color(100, 200, 100),
    danger = Color(255, 100, 100),
    empty = Color(55, 55, 65, 255),
    silhouette = Color(40, 40, 50, 180)
}

local ARMOR_PROGRESS_THEME = {
    background = Color(20, 20, 30, 200),
    progressBg = Color(30, 30, 40, 255),
    progressFill = Color(180, 60, 60),
    text = Color(255, 255, 255),
    textDark = Color(160, 160, 170),
    cancelBtn = Color(100, 40, 40, 220),
    cancelBtnHover = Color(140, 50, 50, 240)
}

MuR.ArmorActionInProgress = MuR.ArmorActionInProgress or false
local ARMOR_CONFLICT_COOLDOWN = 3
local lastArmorConflictShown = 0

local function ShowArmorConflictMessage(msg)
    if CurTime() - lastArmorConflictShown < ARMOR_CONFLICT_COOLDOWN then return end
    lastArmorConflictShown = CurTime()
    MuR.ShowCenteredMessage(msg, 3, Color(255, 100, 100))
    surface.PlaySound("buttons/button10.wav")
end

local cvArmorShowLabels = CreateClientConVar("mur_armor_show_labels", "1", true, false, "Show protection labels on character in armor panel", 0, 1)

local function GetItemsForBodyPartSafe(bodypart)
    if MuR.Armor and MuR.Armor.GetItemsForBodyPart then
        return MuR.Armor.GetItemsForBodyPart(bodypart)
    end
    local items = {}
    if MuR.Armor and MuR.Armor.Items then
        for id, item in pairs(MuR.Armor.Items) do
            if item and item.bodypart == bodypart then
                items[#items + 1] = id
            end
        end
    end
    return items
end

local ARMOR_EQUIP_DURATION = 2
local ARMOR_UNEQUIP_DURATION = 2

local bodypartOrder = {"head", "facecover", "face", "face2", "ears", "body"}
local bodypartNames = {
    head = MuR.Language["armor_slot_head"] or "Голова",
    facecover = MuR.Language["armor_slot_facecover"] or "Подшлемник",
    face = MuR.Language["armor_slot_face"] or "Лицо 1",
    face2 = MuR.Language["armor_slot_face2"] or "Лицо 2",
    ears = MuR.Language["armor_slot_ears"] or "Уши",
    body = MuR.Language["armor_slot_body"] or "Тело"
}

local function CreateArmorProgressBar(duration, title, onComplete, onCancel, options)
    if IsValid(MuR.ArmorProgressFrame) then MuR.ArmorProgressFrame:Remove() end

    local startTime = CurTime()
    local endTime = startTime + duration
    local cancelled = false

    local function CancelAction()
        if cancelled then return end
        cancelled = true
        if options and options.armorFrame and IsValid(options.armorFrame) then
            options.armorFrame:SetMouseInputEnabled(true)
        end
        if IsValid(MuR.ArmorProgressFrame) then MuR.ArmorProgressFrame:Remove() end
        MuR.ArmorActionInProgress = false
        if onCancel then onCancel() end
        surface.PlaySound("buttons/button10.wav")
    end

    if options and options.armorFrame and IsValid(options.armorFrame) then
        options.armorFrame:SetMouseInputEnabled(false)
    end

    local frame = vgui.Create("DFrame")
    MuR.ArmorProgressFrame = frame
    frame:SetSize(We(550), He(175))
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetZPos(99999)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, ARMOR_PROGRESS_THEME.background)

        surface.SetFont("MuR_Font2")
        local maxTitleW = w - We(40)
        local tw = select(1, surface.GetTextSize(title))
        local displayTitle = title
        if tw > maxTitleW then
            while tw > maxTitleW and #displayTitle > 5 do
                displayTitle = string.sub(displayTitle, 1, -4) .. "..."
                tw = select(1, surface.GetTextSize(displayTitle))
            end
        end
        draw.SimpleText(displayTitle, "MuR_Font2", w/2, He(18), ARMOR_PROGRESS_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        local barX, barY, barW, barH = We(20), He(48), w - We(40), He(28)
        draw.RoundedBox(6, barX, barY, barW, barH, ARMOR_PROGRESS_THEME.progressBg)

        local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
        draw.RoundedBox(6, barX, barY, barW * progress, barH, ARMOR_PROGRESS_THEME.progressFill)

        draw.SimpleText(math.Round(progress * 100) .. "%", "MuR_Font2", w/2, barY + barH/2, ARMOR_PROGRESS_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(MuR.Language["armor_cancel_hint"] or "[ESC] Отменить", "MuR_FontDef", w/2, He(162), ARMOR_PROGRESS_THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetPos(We(150), He(100))
    cancelBtn:SetSize(We(250), He(28))
    cancelBtn:SetText("")
    cancelBtn.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and ARMOR_PROGRESS_THEME.cancelBtnHover or ARMOR_PROGRESS_THEME.cancelBtn
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
        draw.SimpleText(MuR.Language["armor_cancel"] or "Отмена", "MuR_Font2", w/2, h/2, ARMOR_PROGRESS_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancelBtn.DoClick = CancelAction

    frame.Think = function(self)
        self:SetZPos(99999)

        if CurTime() >= endTime then
            if options and options.armorFrame and IsValid(options.armorFrame) then
                options.armorFrame:SetMouseInputEnabled(true)
            end
            self:Remove()
            MuR.ArmorActionInProgress = false
            if onComplete then onComplete() end
        end

        if input.IsKeyDown(KEY_ESCAPE) then
            CancelAction()
        end

        local ply = LocalPlayer()
        if IsValid(ply) and ply:GetVelocity():Length() > 50 then
            CancelAction()
        end

        if options and options.pickupEntity and not IsValid(options.pickupEntity) then
            CancelAction()
        end
    end

    MuR.ArmorActionInProgress = true
end

local function StartUnequipAllChain(armorFrame, ply)
    local toUnequip = {}
    for _, bodypart in ipairs(bodypartOrder) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item and not item.permanent then
                local dur = item.unequip_time or ARMOR_UNEQUIP_DURATION
                toUnequip[#toUnequip + 1] = {bodypart = bodypart, armorId = armorId, item = item, dur = dur}
            end
        end
    end
    if #toUnequip == 0 then return end

    local idx = 1
    local function runNext()
        if idx > #toUnequip then
            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                for _, s in pairs(armorFrame.ArmorSlots) do
                    if IsValid(s) then s:UpdateArmor() end
                end
            end
            MuR.ArmorActionInProgress = false
            return
        end
        local cur = toUnequip[idx]
        local itemName = MuR.Language["armor_item_" .. cur.armorId] or cur.armorId
        local title = string.format(MuR.Language["armor_unequipping"] or "Снимаю \"%s\"", itemName)
        CreateArmorProgressBar(cur.dur, title, function()
            net.Start("MuR_ArmorPickup")
            net.WriteString("toggle_active")
            net.WriteString(cur.bodypart)
            net.WriteBool(false)
            net.SendToServer()
            if cur.item.unequip_sound then
                surface.PlaySound(cur.item.unequip_sound)
            end
            idx = idx + 1
            runNext()
        end, function()
            MuR.ArmorActionInProgress = false
        end, { armorFrame = armorFrame })
    end
    MuR.ArmorActionInProgress = true
    runNext()
end

local function StartEquipAllChain(armorFrame, ply)
    local toEquip = {}
    for _, bodypart in ipairs(bodypartOrder) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" and not isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item and not (MuR.Armor.IsBodyPartBlocked and MuR.Armor.IsBodyPartBlocked(ply, bodypart)) then
                local dur = item.equip_time or ARMOR_EQUIP_DURATION
                toEquip[#toEquip + 1] = {bodypart = bodypart, armorId = armorId, item = item, dur = dur}
            end
        end
    end
    if #toEquip == 0 then return end

    local idx = 1
    local function runNext()
        if idx > #toEquip then
            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                for _, s in pairs(armorFrame.ArmorSlots) do
                    if IsValid(s) then s:UpdateArmor() end
                end
            end
            MuR.ArmorActionInProgress = false
            return
        end
        local cur = toEquip[idx]
        local itemName = MuR.Language["armor_item_" .. cur.armorId] or cur.armorId
        local title = string.format(MuR.Language["armor_equipping"] or "Одеваю \"%s\"", itemName)
        CreateArmorProgressBar(cur.dur, title, function()
            net.Start("MuR_ArmorPickup")
            net.WriteString("toggle_active")
            net.WriteString(cur.bodypart)
            net.WriteBool(true)
            net.SendToServer()
            if cur.item.equip_sound then
                surface.PlaySound(cur.item.equip_sound)
            end
            idx = idx + 1
            runNext()
        end, function()
            MuR.ArmorActionInProgress = false
        end, { armorFrame = armorFrame })
    end
    MuR.ArmorActionInProgress = true
    runNext()
end

hook.Add("OnPauseMenuShow", "MuR_ArmorProgressBlockMenu", function()
    if MuR.ArmorActionInProgress and IsValid(MuR.ArmorProgressFrame) then
        return false
    end

    if MuR.ArmorPanelFrame and IsValid(MuR.ArmorPanelFrame) then
        MuR.ArmorPanelFrame:Remove()
        return false
    end
end)

local function GetPlayerProtectionData(ply)
    if not IsValid(ply) then return nil end
    local organs = {}
    local organOrder = MuR.Armor.OrganDisplayOrder or {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Abdomen"}
    local dmgOrder = MuR.Armor.DamageTypeDisplayOrder or {DMG_BULLET, DMG_SLASH, DMG_CLUB, DMG_BLAST}
    for _, organName in ipairs(organOrder) do
        organs[organName] = {}
        for _, dmgType in ipairs(dmgOrder) do
            local totalReduction = 0
            for _, bodypart in ipairs(bodypartOrder) do
                local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
                local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
                if armorId ~= "" and isActive then
                    if MuR.Armor.IsOrganProtected(armorId, organName, nil) and MuR.Armor.HasDamageType(armorId, dmgType) then
                        local item = MuR.Armor.GetItem(armorId)
                        if item then
                            totalReduction = totalReduction + MuR.Armor.GetArmorReductionForDamageType(item, dmgType)
                        end
                    end
                end
            end
            organs[organName][dmgType] = math.min(totalReduction, 2)
        end
    end
    return { organs = organs, organOrder = organOrder, dmgOrder = dmgOrder }
end

local function GetProtectionByZone(ply)
    if not IsValid(ply) then return nil end
    local data = GetPlayerProtectionData(ply)
    if not data then return nil end
    local organs = data.organs
    local dmgOrder = data.dmgOrder or {DMG_BULLET, DMG_SLASH, DMG_CLUB, DMG_BLAST}
    local headOrgans = {"Brain", "Neck"}
    local bodyOrgans = {"Heart", "Right Lung", "Left Lung", "Abdomen"}
    local head, body = {}, {}
    for _, dmgType in ipairs(dmgOrder) do
        local maxH, maxB = 0, 0
        for _, org in ipairs(headOrgans) do
            local r = (organs[org] or {})[dmgType] or 0
            if r > maxH then maxH = r end
        end
        for _, org in ipairs(bodyOrgans) do
            local r = (organs[org] or {})[dmgType] or 0
            if r > maxB then maxB = r end
        end
        head[dmgType] = maxH
        body[dmgType] = maxB
    end
    return { head = head, body = body, dmgOrder = dmgOrder }
end

local function ProjectToPanel(modelPanel, worldPos)
    local camPos = modelPanel:GetCamPos()
    local lookAt = modelPanel:GetLookAt()
    local fov = modelPanel:GetFOV()
    local sx, sy = modelPanel:LocalToScreen(0, 0)
    local w, h = modelPanel:GetSize()
    local forward = (lookAt - camPos):GetNormalized()
    local right = forward:Cross(Vector(0, 0, 1))
    if right:Length() < 0.01 then right = forward:Cross(Vector(0, 1, 0)) end
    right:Normalize()
    local up = right:Cross(forward):GetNormalized()
    local toPoint = worldPos - camPos
    local zCam = toPoint:Dot(forward)
    if zCam <= 0 then return nil, nil end
    local xCam = toPoint:Dot(right)
    local yCam = toPoint:Dot(up)
    local fovRad = math.rad(fov)
    local aspect = w / math.max(h, 1)
    local ndcX = xCam / (zCam * math.tan(fovRad / 2) * aspect)
    local ndcY = yCam / (zCam * math.tan(fovRad / 2))
    local screenX = sx + (ndcX + 1) / 2 * w
    local screenY = sy + (1 - ndcY) / 2 * h
    return modelPanel:ScreenToLocal(screenX, screenY)
end

local function CollectProtectionLabels(ent, ply, modelPanel)
    if not IsValid(ent) or not IsValid(ply) or not modelPanel then return {} end
    local zoneData = GetProtectionByZone(ply)
    if not zoneData then return {} end
    local dmgOrder = zoneData.dmgOrder
    local zones = {
        { zone = "head", bone = "ValveBiped.Bip01_Head1", offset = Vector(0, 0, 8) },
        { zone = "body", bone = "ValveBiped.Bip01_Spine2", offset = Vector(0, 10, 0) }
    }
    local labels = {}
    for _, z in ipairs(zones) do
        local prot = zoneData[z.zone]
        local hasProt = false
        for _, dt in ipairs(dmgOrder) do
            if (prot[dt] or 0) > 0 then hasProt = true break end
        end
        if not hasProt then continue end
        local boneId = ent:LookupBone(z.bone)
        if not boneId then continue end
        local mtx = ent:GetBoneMatrix(boneId)
        if not mtx then continue end
        local bonePos = mtx:GetTranslation()
        local boneAng = mtx:GetAngles()
        local labelPos = bonePos + boneAng:Forward() * z.offset.x + boneAng:Right() * z.offset.y + boneAng:Up() * z.offset.z
        local lx, ly = ProjectToPanel(modelPanel, labelPos)
        local fromX, fromY = ProjectToPanel(modelPanel, bonePos)
        local lines = {}
        local sumPct, countPct = 0, 0
        for _, dmgType in ipairs(dmgOrder) do
            local r = prot[dmgType] or 0
            if r > 0 then
                local key = "armor_dmgtype_" .. tostring(dmgType) .. "_short"
                local lbl = MuR.Language[key] or MuR.Language["armor_dmgtype_" .. tostring(dmgType)] or tostring(dmgType)
                local pct = math.Round(r * 50)
                lines[#lines + 1] = lbl .. ": " .. pct .. "%"
                sumPct = sumPct + pct
                countPct = countPct + 1
            end
        end
        local avgPct = countPct > 0 and math.Round(sumPct / countPct) or 0
        if #lines > 0 and lx and ly and fromX and fromY then
            labels[#labels + 1] = { zone = z.zone, x = lx, y = ly, fromX = fromX, fromY = fromY, lines = lines, avgPct = avgPct }
        end
    end
    return labels
end

local function GetLabelRect(lbl, offsets, pad, lineH, header, expanded)
    local off = offsets[lbl.zone] or {0, 0}
    local cx, cy = lbl.x + off[1], lbl.y + off[2]
    surface.SetFont("MuR_FontDef")
    local boxW, boxH
    if expanded then
        local maxW = select(1, surface.GetTextSize(header))
        for _, ln in ipairs(lbl.lines) do
            local tw = select(1, surface.GetTextSize(ln))
            if tw > maxW then maxW = tw end
        end
        boxW = maxW + pad * 2
        boxH = pad * 2 + lineH + #lbl.lines * lineH
    else
        local compactText = header .. " " .. (lbl.avgPct or 0) .. "%"
        boxW = select(1, surface.GetTextSize(compactText)) + pad * 2
        boxH = pad * 2 + lineH
    end
    return cx - boxW / 2, cy - boxH - 4, boxW, boxH
end

local function DrawProtectionLabels2D(labels, modelPanel)
    if not labels or #labels == 0 then return end
    local offsets = modelPanel.ProtectionLabelOffsets or {}
    local expanded = modelPanel.ProtectionLabelsExpanded or {}
    local pad, lineH = 8, 14
    local header = MuR.Language["armor_protection"] or "Защита:"
    surface.SetFont("MuR_FontDef")
    for _, lbl in ipairs(labels) do
        local isExpanded = expanded[lbl.zone] == true
        local off = offsets[lbl.zone] or {0, 0}
        local cx, cy = lbl.x + off[1], lbl.y + off[2]
        local boxW, boxH
        if isExpanded then
            local maxW = select(1, surface.GetTextSize(header))
            for _, ln in ipairs(lbl.lines) do
                local tw = select(1, surface.GetTextSize(ln))
                if tw > maxW then maxW = tw end
            end
            boxW = maxW + pad * 2
            boxH = pad * 2 + lineH + #lbl.lines * lineH
        else
            local compactText = header .. " " .. (lbl.avgPct or 0) .. "%"
            boxW = select(1, surface.GetTextSize(compactText)) + pad * 2
            boxH = pad * 2 + lineH
        end
        local x = cx - boxW / 2
        local y = cy - boxH - 4
        local w, h = modelPanel:GetSize()
        if not modelPanel.DraggingLabel or modelPanel.DraggingLabel ~= lbl.zone then
            x = math.Clamp(x, 4, w - boxW - 4)
            y = math.Clamp(y, 4, h - boxH - 4)
        end
        local toX, toY = x + boxW / 2, y + boxH
        if lbl.fromX and lbl.fromY then
            surface.SetDrawColor(ARMOR_UI_THEME.accent)
            surface.DrawLine(lbl.fromX, lbl.fromY, toX, toY)
            surface.DrawLine(lbl.fromX + 1, lbl.fromY, toX + 1, toY)
        end
        draw.RoundedBox(4, x, y, boxW, boxH, Color(60, 60, 70, 255))
        surface.SetDrawColor(ARMOR_UI_THEME.accent)
        surface.DrawOutlinedRect(x, y, boxW, boxH)
        if isExpanded then
            local expandChar = " \226\150\188"
            draw.SimpleText(header .. expandChar, "MuR_FontDef", x + pad, y + pad, ARMOR_UI_THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            for i, ln in ipairs(lbl.lines) do
                draw.SimpleText(ln, "MuR_FontDef", x + pad, y + pad + lineH * i, ARMOR_UI_THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        else
            local expandChar = " \226\150\178"
            draw.SimpleText(header .. " " .. (lbl.avgPct or 0) .. "%" .. expandChar, "MuR_FontDef", x + pad, y + pad, ARMOR_UI_THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
end

local function DrawArmorOnPreviewEntity(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return end
    local bodyParts = MuR.Armor and MuR.Armor.BodyParts
    if not bodyParts then return end
    for bodypart, partData in pairs(bodyParts) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        local isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        if armorId ~= "" and isActive then
            local item = MuR.Armor.GetItem(armorId)
            if item then
                local mdl = nil
                if ent.ArmorPreviewModels then
                    mdl = ent.ArmorPreviewModels[bodypart .. "_" .. armorId]
                end
                if not IsValid(mdl) and item.model then
                    mdl = ClientsideModel(item.model, RENDERGROUP_OPAQUE)
                    if IsValid(mdl) then
                        mdl:SetNoDraw(true)
                        mdl:SetModelScale(item.scale or 1)
                        if not ent.ArmorPreviewModels then ent.ArmorPreviewModels = {} end
                        ent.ArmorPreviewModels[bodypart .. "_" .. armorId] = mdl
                    end
                end
                if IsValid(mdl) then
                    local boneId = ent:LookupBone(partData.bone)
                    if boneId then
                        local mtx = ent:GetBoneMatrix(boneId)
                        if mtx then
                            local bonePos = mtx:GetTranslation()
                            local boneAng = mtx:GetAngles()
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

local function CreateArmorSlot(parent, bodypart, x, y, width, height)
    local slot = vgui.Create("DButton", parent)
    slot:SetPos(x, y)
    slot:SetSize(width, height)
    slot:SetText("")
    slot.bodypart = bodypart

    function slot:UpdateArmor()
        local ply = LocalPlayer()
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        self.armorId = armorId
        self.isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        self.item = armorId ~= "" and MuR.Armor.GetItem(armorId) or nil
        self.isBlocked = MuR.Armor.IsBodyPartBlocked and MuR.Armor.IsBodyPartBlocked(ply, bodypart) or false
    end

    slot:UpdateArmor()

    function slot:Paint(w, h)
        local bgColor = self.item and ARMOR_UI_THEME.panel or ARMOR_UI_THEME.empty
        if self.isBlocked then
            bgColor = Color(40, 40, 48, 200)
        elseif self:IsHovered() then
            bgColor = ARMOR_UI_THEME.panelHover
        end
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
        surface.SetDrawColor(ARMOR_UI_THEME.panelBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
        if self:IsHovered() and not self.isBlocked then
            if self.item then
                surface.SetDrawColor(ARMOR_UI_THEME.accent)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            elseif LocalPlayer():IsSuperAdmin() then
                surface.SetDrawColor(ARMOR_UI_THEME.success)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end
        local slotName = bodypartNames[self.bodypart] or self.bodypart
        draw.SimpleText(slotName:upper(), "MuR_Font1", w/2, He(8), ARMOR_UI_THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        if self.item then
            local icon = self.item.icon
            if icon then
                local mat = Material(icon)
                if mat and not mat:IsError() then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(mat)
                    local iconSize = math.min(w, h) * 0.55
                    surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2 + He(5), iconSize, iconSize)
                end
            end
            local statusText = self.isActive and (MuR.Language["armor_active"] or "Активна") or (MuR.Language["armor_inactive"] or "В сумке")
            local statusColor = self.isActive and ARMOR_UI_THEME.success or ARMOR_UI_THEME.danger
            draw.SimpleText(statusText, "MuR_Font1", w/2, h - He(10), statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif self.isBlocked then
            local crossSize = math.min(w, h) * 0.5
            local crossMat = Material("icon16/cancel.png")
            if crossMat and not crossMat:IsError() then
                surface.SetDrawColor(255, 80, 80, 220)
                surface.SetMaterial(crossMat)
                surface.DrawTexturedRect(w/2 - crossSize/2, h/2 - crossSize/2 + He(5), crossSize, crossSize)
            end
        else
            draw.SimpleText(MuR.Language["armor_empty"] or "Пусто", "MuR_Font2", w/2, h/2, ARMOR_UI_THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function slot:DoClick()
        if self.isBlocked then return end
        if MuR.ArmorActionInProgress then return end
        if self.item then
            local itemName = MuR.Language["armor_item_" .. self.armorId] or self.armorId
            local armorEquipDur = self.item.equip_time or ARMOR_EQUIP_DURATION
            local armorUnequipDur = self.item.unequip_time or ARMOR_UNEQUIP_DURATION

            local menu = DermaMenu()
            local isPermanent = self.item.permanent
            if not isPermanent then
            local toggleText = self.isActive and (MuR.Language["armor_take"] or "Снять") or (MuR.Language["armor_put_on"] or "Одеть")
            local toggleIcon = self.isActive and "icon16/arrow_undo.png" or "icon16/tick.png"
            menu:AddOption(toggleText, function()
                local armorFrame = self:GetParent()
                if self.isActive then
                    local title = string.format(MuR.Language["armor_unequipping"] or "Снимаю \"%s\"", itemName)
                    CreateArmorProgressBar(armorUnequipDur, title, function()
                        net.Start("MuR_ArmorPickup")
                        net.WriteString("toggle_active")
                        net.WriteString(bodypart)
                        net.WriteBool(false)
                        net.SendToServer()
                        if self.item and self.item.unequip_sound then
                            surface.PlaySound(self.item.unequip_sound)
                        end
                        timer.Simple(0.1, function()
                            local armorFrame = self:GetParent()
                            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                                for _, s in pairs(armorFrame.ArmorSlots) do
                                    if IsValid(s) then s:UpdateArmor() end
                                end
                            end
                        end)
                    end, nil, { armorFrame = armorFrame })
                else
                    local title = string.format(MuR.Language["armor_equipping"] or "Одеваю \"%s\"", itemName)
                    CreateArmorProgressBar(armorEquipDur, title, function()
                        net.Start("MuR_ArmorPickup")
                        net.WriteString("toggle_active")
                        net.WriteString(bodypart)
                        net.WriteBool(true)
                        net.SendToServer()
                        if self.item and self.item.equip_sound then
                            surface.PlaySound(self.item.equip_sound)
                        end
                        timer.Simple(0.1, function()
                            local armorFrame = self:GetParent()
                            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                                for _, s in pairs(armorFrame.ArmorSlots) do
                                    if IsValid(s) then s:UpdateArmor() end
                                end
                            end
                        end)
                    end, nil, { armorFrame = armorFrame })
                end
            end):SetIcon(toggleIcon)
            menu:AddOption(MuR.Language["armor_drop"] or "Выбросить", function()
                if self.isActive then
                    local armorFrame = self:GetParent()
                    local title = string.format(MuR.Language["armor_unequipping"] or "Снимаю \"%s\"", itemName)
                    CreateArmorProgressBar(armorUnequipDur, title, function()
                        net.Start("MuR_ArmorPickup")
                        net.WriteString("unequip")
                        net.WriteString(bodypart)
                        net.SendToServer()
                        if self.item and self.item.unequip_sound then
                            surface.PlaySound(self.item.unequip_sound)
                        end
                        timer.Simple(0.1, function()
                            local armorFrame = self:GetParent()
                            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                                for _, s in pairs(armorFrame.ArmorSlots) do
                                    if IsValid(s) then s:UpdateArmor() end
                                end
                            end
                        end)
                    end, nil, { armorFrame = armorFrame })
                else
                    net.Start("MuR_ArmorPickup")
                    net.WriteString("unequip")
                    net.WriteString(bodypart)
                    net.SendToServer()
                    timer.Simple(0.1, function()
                        local armorFrame = self:GetParent()
                        if IsValid(armorFrame) and armorFrame.ArmorSlots then
                            for _, s in pairs(armorFrame.ArmorSlots) do
                                if IsValid(s) then s:UpdateArmor() end
                            end
                        end
                    end)
                end
            end):SetIcon("icon16/arrow_out.png")
            end
            local descLabel = MuR.Language["armor_desc_" .. self.armorId] or "..."
            local info = menu:AddSubMenu(MuR.Language["armor_desc"] or "Описание")
            info:AddOption(descLabel, function() end):SetIcon("icon16/information.png")
            menu:Open()
        elseif LocalPlayer():IsSuperAdmin() then

            local items = GetItemsForBodyPartSafe(bodypart)
            if #items == 0 then return end
            local menu = DermaMenu()
            local selectSub = menu:AddSubMenu(MuR.Language["armor_admin_select"] or "Выбрать броню")
            for _, armorId in ipairs(items) do
                local item = MuR.Armor.GetItem(armorId)
                if item then
                    local name = MuR.Language["armor_item_" .. armorId] or armorId
                    local opt = selectSub:AddOption(name, function()
                        net.Start("MuR_ArmorPickup")
                        net.WriteString("admin_equip")
                        net.WriteString(bodypart)
                        net.WriteString(armorId)
                        net.SendToServer()
                        timer.Simple(0.1, function()
                            local armorFrame = self:GetParent()
                            if IsValid(armorFrame) and armorFrame.ArmorSlots then
                                for _, s in pairs(armorFrame.ArmorSlots) do
                                    if IsValid(s) then s:UpdateArmor() end
                                end
                            end
                        end)
                    end)
                    opt:SetIcon(item.icon or "icon16/tag_green.png")
                end
            end
            menu:Open()
        end
    end
    return slot
end

local function OpenArmorPanel()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if MuR.ArmorActionInProgress then return end

    local frameW, frameH = We(650), He(790)
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, ARMOR_UI_THEME.background)
        draw.RoundedBox(12, 0, 0, w, He(50), ARMOR_UI_THEME.header)
        surface.SetDrawColor(ARMOR_UI_THEME.accent)
        surface.DrawRect(0, He(50), w, 2)
    end
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE or key == KEY_Q then
            self:Remove()
        end
    end

    frame.OnRemove = function()
        if MuR.ArmorPanelFrame == frame then
            MuR.ArmorPanelFrame = nil
        end
        if frame.modelPanel and IsValid(frame.modelPanel.Entity) and frame.modelPanel.Entity.ArmorPreviewModels then
            for _, mdl in pairs(frame.modelPanel.Entity.ArmorPreviewModels) do
                if IsValid(mdl) then mdl:Remove() end
            end
        end
    end

    local title = vgui.Create("DLabel", frame)
    title:SetText(MuR.Language["armor_title"] or "Броня")
    title:SetFont("MuR_Font4")
    title:SetTextColor(ARMOR_UI_THEME.text)
    title:SizeToContents()
    title:SetPos((frameW - title:GetWide()) / 2, He(8))

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - We(40), He(12))
    closeBtn:SetSize(We(26), He(26))
    closeBtn:SetText("✕")
    closeBtn:SetFont("MuR_Font3")
    closeBtn:SetTextColor(ARMOR_UI_THEME.text)
    closeBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, ARMOR_UI_THEME.danger)
        end
    end
    closeBtn.DoClick = function()
        if frame.modelPanel and IsValid(frame.modelPanel.Entity) and frame.modelPanel.Entity.ArmorPreviewModels then
            for _, mdl in pairs(frame.modelPanel.Entity.ArmorPreviewModels) do
                if IsValid(mdl) then mdl:Remove() end
            end
        end
        frame:Remove()
    end

    MuR.ArmorPanelFrame = frame

    local modelPanelW, modelPanelH = We(300), He(380)
    local modelPanelX = (frameW - modelPanelW) / 2
    local modelPanelY = He(60)

    local modelBg = vgui.Create("DPanel", frame)
    modelBg:SetPos(modelPanelX, modelPanelY)
    modelBg:SetSize(modelPanelW, modelPanelH)
    modelBg:SetMouseInputEnabled(false)
    modelBg.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, ARMOR_UI_THEME.silhouette)
        surface.SetDrawColor(ARMOR_UI_THEME.panelBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local modelPanel = vgui.Create("DModelPanel", frame)
    modelPanel:SetPos(modelPanelX, modelPanelY)
    modelPanel:SetSize(modelPanelW, modelPanelH)
    modelPanel:SetModel(ply:GetModel() or "models/player/Group01/male_07.mdl")
    modelPanel:SetFOV(45)

    modelPanel:SetLookAt(Vector(0, 0, 38))
    modelPanel:SetCamPos(Vector(90, 0, 38))
    modelPanel:SetAmbientLight(Color(80, 80, 80))
    modelPanel:SetDirectionalLight(BOX_TOP, Color(180, 180, 180))
    modelPanel:SetDirectionalLight(BOX_FRONT, Color(120, 120, 120))
    frame.modelPanel = modelPanel

    if modelPanel.Entity and IsValid(modelPanel.Entity) then
        modelPanel.Entity:SetSkin(ply:GetSkin())
        for i = 0, (modelPanel.Entity:GetNumBodyGroups() or 1) - 1 do
            modelPanel.Entity:SetBodygroup(i, ply:GetBodygroup(i))
        end
    end

    modelPanel.CamAngles = {yaw = 0, pitch = 10}
    modelPanel.CamRadius = 90
    modelPanel.LastLookAtZ = 38
    modelPanel.IsMouseDown = false
    modelPanel.LastMouseX = 0
    modelPanel.LastMouseY = 0

    local function GetLookAtZFromMouse(pnl)
        local w, h = pnl:GetSize()
        local mx, my = pnl:ScreenToLocal(gui.MousePos())
        if mx >= 0 and mx <= w and my >= 0 and my <= h then
            return 5 + (1 - my / h) * 63
        end
        return pnl.LastLookAtZ
    end

    local function UpdateModelPanelCamera(pnl)
        local lookAtZ = pnl.LastLookAtZ
        local origin = Vector(0, 0, lookAtZ)
        local rad = math.rad(pnl.CamAngles.yaw)
        local pitchRad = math.rad(pnl.CamAngles.pitch)
        local camPos = Vector(
            math.sin(rad) * math.cos(pitchRad) * pnl.CamRadius,
            math.cos(rad) * math.cos(pitchRad) * pnl.CamRadius,
            origin.z + math.sin(pitchRad) * pnl.CamRadius
        )
        pnl:SetCamPos(camPos)
        pnl:SetLookAt(origin)
    end

    function modelPanel:LayoutEntity(ent)
        if not IsValid(ent) then return end
        ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
        ent:SetPlaybackRate(0.5)
        ent:FrameAdvance(FrameTime())

        if self.IsMouseDown then
            local x, y = gui.MousePos()
            local dx = x - self.LastMouseX
            local dy = y - self.LastMouseY
            self.LastMouseX = x
            self.LastMouseY = y
            self.CamAngles.yaw = self.CamAngles.yaw - dx * 0.5
            self.CamAngles.pitch = math.Clamp(self.CamAngles.pitch - dy * 0.5, -30, 30)
        end
        UpdateModelPanelCamera(self)
    end

    modelPanel.OnMouseWheeled = function(pnl, delta)
        if not pnl:IsHovered() then return end
        pnl.LastLookAtZ = GetLookAtZFromMouse(pnl)
        pnl.CamRadius = math.Clamp(pnl.CamRadius - delta * 12, 40, 180)
    end

    modelPanel.ProtectionLabelOffsets = modelPanel.ProtectionLabelOffsets or {}
    modelPanel.ProtectionLabelsExpanded = modelPanel.ProtectionLabelsExpanded or {}

    modelPanel.OnMousePressed = function(pnl, keyCode)
        if keyCode == MOUSE_LEFT then
            local mx, my = pnl:ScreenToLocal(gui.MousePos())
            local labels = pnl.LastProtectionLabels
            local offsets = pnl.ProtectionLabelOffsets
            local expanded = pnl.ProtectionLabelsExpanded
            local pad, lineH = 8, 14
            local header = MuR.Language["armor_protection"] or "Защита:"
            surface.SetFont("MuR_FontDef")
            if labels then
                for _, lbl in ipairs(labels) do
                    local isExp = expanded[lbl.zone] == true
                    local rx, ry, rw, rh = GetLabelRect(lbl, offsets, pad, lineH, header, isExp)
                    if mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh then
                        pnl.DraggingLabel = lbl.zone
                        pnl.DragStartMouse = {mx, my}
                        pnl.DragStartOffset = {(offsets[lbl.zone] or {0, 0})[1], (offsets[lbl.zone] or {0, 0})[2]}
                        return
                    end
                end
            end
            pnl.IsMouseDown = true
            local x, y = gui.MousePos()
            pnl.LastMouseX = x
            pnl.LastMouseY = y
        end
    end

    modelPanel.OnMouseReleased = function(pnl, keyCode)
        if keyCode == MOUSE_LEFT then
            if pnl.DraggingLabel then
                local mx, my = pnl:ScreenToLocal(gui.MousePos())
                local start = pnl.DragStartMouse
                local moved = start and (math.abs(mx - start[1]) > 5 or math.abs(my - start[2]) > 5)
                if not moved then
                    pnl.ProtectionLabelsExpanded[pnl.DraggingLabel] = not pnl.ProtectionLabelsExpanded[pnl.DraggingLabel]
                    surface.PlaySound("buttons/button14.wav")
                end
            end
            pnl.DraggingLabel = nil
            pnl.IsMouseDown = false
        end
    end

    local oldModelPanelPaint = modelPanel.Paint
    modelPanel.Paint = function(self, w, h)
        oldModelPanelPaint(self, w, h)
        if not IsValid(self.Entity) or w < 10 or h < 10 then return end
        self.Entity:SetupBones()
        local sx, sy = self:LocalToScreen(0, 0)
        cam.Start3D(self:GetCamPos(), (self:GetLookAt() - self:GetCamPos()):Angle(), self:GetFOV(), sx, sy, w, h, 5, 4096)

        render.SuppressEngineLighting(true)
        render.SetLightingOrigin(self.Entity:GetPos())
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        render.ResetModelLighting(1, 1, 1)
        render.SetModelLighting(BOX_TOP, 1.5, 1.5, 1.5)
        render.SetModelLighting(BOX_FRONT, 1.2, 1.2, 1.2)
        render.SetModelLighting(BOX_BACK, 0.8, 0.8, 0.8)
        render.SetModelLighting(BOX_LEFT, 1, 1, 1)
        render.SetModelLighting(BOX_RIGHT, 1, 1, 1)
        render.SetModelLighting(BOX_BOTTOM, 0.6, 0.6, 0.6)
        DrawArmorOnPreviewEntity(self.Entity, ply)
        local protectionLabels = {}
        if cvArmorShowLabels:GetBool() then
            protectionLabels = CollectProtectionLabels(self.Entity, ply, self)
            self.LastProtectionLabels = protectionLabels
        else
            self.LastProtectionLabels = nil
        end
        if self.DraggingLabel then
            local mx, my = self:ScreenToLocal(gui.MousePos())
            local start = self.DragStartMouse
            if start then
                local so = self.DragStartOffset
                self.ProtectionLabelOffsets[self.DraggingLabel] = {so[1] + mx - start[1], so[2] + my - start[2]}
            end
        end
        render.SuppressEngineLighting(false)
        cam.End3D()
        if cvArmorShowLabels:GetBool() then
            DrawProtectionLabels2D(protectionLabels, self)
        end
    end

    local labelToggleY = modelPanelY + modelPanelH + He(6)
    local labelTogglePanel = vgui.Create("DPanel", frame)
    labelTogglePanel:SetPos(modelPanelX, labelToggleY)
    labelTogglePanel:SetSize(modelPanelW, He(22))
    labelTogglePanel:SetMouseInputEnabled(true)
    labelTogglePanel.Paint = function() end
    local labelToggleBox = vgui.Create("DCheckBox", labelTogglePanel)
    labelToggleBox:SetPos(0, He(4))
    labelToggleBox:SetSize(He(14), He(14))
    labelToggleBox:SetChecked(cvArmorShowLabels:GetBool())
    labelToggleBox.OnChange = function(self, val)
        RunConsoleCommand("mur_armor_show_labels", val and "1" or "0")
    end
    labelToggleBox.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ARMOR_UI_THEME.silhouette)
        if self:GetChecked() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, ARMOR_UI_THEME.accent)
        end
    end
    labelToggleBox.Think = function(self)
        if self:GetChecked() ~= cvArmorShowLabels:GetBool() then
            self:SetChecked(cvArmorShowLabels:GetBool())
        end
    end
    local labelToggleLabel = vgui.Create("DButton", labelTogglePanel)
    labelToggleLabel:SetPos(He(20), 0)
    labelToggleLabel:SetSize(modelPanelW - He(20), He(22))
    labelToggleLabel:SetText(MuR.Language["armor_show_labels_on_model"] or "Отображение защиты на персонаже")
    labelToggleLabel:SetFont("MuR_FontDef")
    labelToggleLabel:SetTextColor(ARMOR_UI_THEME.text)
    labelToggleLabel:SetContentAlignment(4)
    labelToggleLabel.Paint = function() end
    labelToggleLabel.DoClick = function()
        labelToggleBox:Toggle()
        RunConsoleCommand("mur_armor_show_labels", labelToggleBox:GetChecked() and "1" or "0")
    end

    local HEAD_ORGANS = {"Brain", "Neck"}
    local TORSO_ORGANS = {"Heart", "Right Lung", "Left Lung", "Abdomen"}
    local protectionPanelW = frameW - We(40)
    local protectionPanelX = We(20)
    local protectionPanelY = modelPanelY + modelPanelH + He(95)
    local lineH = He(18)
    local organOrder = MuR.Armor.OrganDisplayOrder or {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Abdomen"}
    local dmgOrder = MuR.Armor.DamageTypeDisplayOrder or {DMG_BULLET, DMG_SLASH, DMG_CLUB, DMG_BLAST}

    local protectionPanel = vgui.Create("DPanel", frame)
    protectionPanel:SetPos(protectionPanelX, protectionPanelY)
    protectionPanel:SetSize(protectionPanelW, He(165))
    protectionPanel:SetMouseInputEnabled(true)
    protectionPanel.expandedHead = false
    protectionPanel.expandedTorso = false
    protectionPanel.headRowY = -1
    protectionPanel.headRowH = 0
    protectionPanel.torsoRowY = -1
    protectionPanel.torsoRowH = 0

    local function getDmgParts(organData, dmgOrder)
        local parts = {}
        for _, dmgType in ipairs(dmgOrder) do
            local reduction = organData[dmgType] or 0
            if reduction > 0 then
                local shortKey = "armor_dmgtype_" .. tostring(dmgType) .. "_short"
                local dmgLabel = MuR.Language[shortKey] or MuR.Language["armor_dmgtype_" .. tostring(dmgType)] or tostring(dmgType)
                parts[#parts + 1] = dmgLabel .. " " .. math.Round(reduction * 50) .. "%"
            end
        end
        return parts
    end

    protectionPanel.Paint = function(self, w, h)
        local data = GetPlayerProtectionData(ply)
        if not data then return end

        draw.RoundedBox(6, 0, 0, w, h, ARMOR_UI_THEME.silhouette)
        surface.SetDrawColor(ARMOR_UI_THEME.panelBorder)
        surface.DrawOutlinedRect(0, 0, w, h)

        local headerLabel = MuR.Language["armor_protected_now"] or "Текущая защита"
        draw.SimpleText(headerLabel, "MuR_Font2", w/2, He(6), ARMOR_UI_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        local y = He(28)
        local hasAny = false
        surface.SetFont("MuR_FontDef")
        local pad = We(10)

        local gasLevel = ply.GetGasProtectionLevel and ply:GetGasProtectionLevel() or 0
        local pepperLevel = ply.GetPepperProtectionLevel and ply:GetPepperProtectionLevel() or 0
        if gasLevel > 0 then
            local gasLabel = MuR.Language["armor_gas"] or "Газ: "
            draw.SimpleText(gasLabel .. math.Round(gasLevel * 100) .. "%", "MuR_FontDef", pad, y, ARMOR_UI_THEME.success, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            y = y + lineH
        end
        if pepperLevel > 0 then
            local pepperLabel = MuR.Language["armor_pepper"] or "Перец: "
            draw.SimpleText(pepperLabel .. math.Round(pepperLevel * 100) .. "%", "MuR_FontDef", pad, y, ARMOR_UI_THEME.success, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            y = y + lineH
        end
        local maxTextW = w - pad * 2
        local organs = data.organs
        local dmgOrd = data.dmgOrder or dmgOrder

        local headAggr = {}
        for _, dmgType in ipairs(dmgOrd) do
            local maxR = 0
            for _, org in ipairs(HEAD_ORGANS) do
                local r = (organs[org] or {})[dmgType] or 0
                if r > maxR then maxR = r end
            end
            headAggr[dmgType] = maxR
        end
        local headParts = getDmgParts(headAggr, dmgOrd)
        if #headParts > 0 then
            hasAny = true
            local headLabel = MuR.Language["armor_organ_Head"] or "Head"
            local expandChar = self.expandedHead and " \226\150\178" or " \226\150\188"
            local lineText = headLabel .. expandChar .. ": " .. table.concat(headParts, ", ")
            local mx, my = self:ScreenToLocal(gui.MousePos())
            local isHover = mx >= 0 and mx <= w and my >= y and my < y + lineH
            if isHover then
                draw.RoundedBox(4, 0, y - 2, w, lineH + 4, Color(255, 255, 255, 25))
            end
            draw.SimpleText(lineText, "MuR_FontDef", pad, y, ARMOR_UI_THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            self.headRowY = y
            self.headRowH = lineH
            y = y + lineH

            if self.expandedHead then
                for _, orgName in ipairs(HEAD_ORGANS) do
                    local orgData = organs[orgName] or {}
                    local parts = getDmgParts(orgData, dmgOrd)
                    if #parts > 0 then
                        local organLabel = MuR.Language["armor_organ_" .. orgName] or orgName
                        local subText = "  " .. organLabel .. ": " .. table.concat(parts, ", ")
                        draw.SimpleText(subText, "MuR_FontDef", pad, y, ARMOR_UI_THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        y = y + He(14)
                    end
                end
            end
        else
            self.headRowY = -1
        end

        local torsoAggr = {}
        for _, dmgType in ipairs(dmgOrd) do
            local maxR = 0
            for _, org in ipairs(TORSO_ORGANS) do
                local r = (organs[org] or {})[dmgType] or 0
                if r > maxR then maxR = r end
            end
            torsoAggr[dmgType] = maxR
        end
        local torsoParts = getDmgParts(torsoAggr, dmgOrd)
        if #torsoParts > 0 then
            hasAny = true
            local torsoLabel = MuR.Language["armor_organ_Torso"] or "Torso"
            local expandChar = self.expandedTorso and " \226\150\178" or " \226\150\188"
            local lineText = torsoLabel .. expandChar .. ": " .. table.concat(torsoParts, ", ")
            local mx, my = self:ScreenToLocal(gui.MousePos())
            local isHover = mx >= 0 and mx <= w and my >= y and my < y + lineH
            if isHover then
                draw.RoundedBox(4, 0, y - 2, w, lineH + 4, Color(255, 255, 255, 25))
            end
            draw.SimpleText(lineText, "MuR_FontDef", pad, y, ARMOR_UI_THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            self.torsoRowY = y
            self.torsoRowH = lineH
            y = y + lineH

            if self.expandedTorso then
                for _, orgName in ipairs(TORSO_ORGANS) do
                    local orgData = organs[orgName] or {}
                    local parts = getDmgParts(orgData, dmgOrd)
                    if #parts > 0 then
                        local organLabel = MuR.Language["armor_organ_" .. orgName] or orgName
                        local subText = "  " .. organLabel .. ": " .. table.concat(parts, ", ")
                        draw.SimpleText(subText, "MuR_FontDef", pad, y, ARMOR_UI_THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        y = y + He(14)
                    end
                end
            end
        else
            self.torsoRowY = -1
        end

        if not hasAny then
            draw.SimpleText("—", "MuR_FontDef", pad, y, ARMOR_UI_THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    protectionPanel.OnMousePressed = function(self, key)
        if key ~= MOUSE_LEFT then return end
        local mx, my = self:ScreenToLocal(gui.MousePos())
        local extraH = 0
        if self.headRowY >= 0 and my >= self.headRowY and my < self.headRowY + self.headRowH then
            self.expandedHead = not self.expandedHead
            extraH = self.expandedHead and He(50) or -He(50)
            surface.PlaySound("buttons/button14.wav")
        elseif self.torsoRowY >= 0 and my >= self.torsoRowY and my < self.torsoRowY + self.torsoRowH then
            self.expandedTorso = not self.expandedTorso
            extraH = self.expandedTorso and He(75) or -He(75)
            surface.PlaySound("buttons/button14.wav")
        end
        if extraH ~= 0 then
            local baseH = He(165)
            local addH = (self.expandedHead and He(50) or 0) + (self.expandedTorso and He(75) or 0)
            self:SetSize(protectionPanelW, baseH + addH)
        end
    end

    local slotW, slotH = We(95), He(95)
    local slotSpacing = He(8)
    local leftX = We(20)
    local rightX = frameW - slotW - We(20)
    local rightSlotsTop = modelPanelY + He(12)

    local slots = {}
    slots["ears"] = CreateArmorSlot(frame, "ears", leftX, modelPanelY + modelPanelH/2 - slotH/2 - (slotH + slotSpacing), slotW, slotH)
    slots["body"] = CreateArmorSlot(frame, "body", leftX, modelPanelY + modelPanelH/2 - slotH/2, slotW, slotH)
    slots["head"] = CreateArmorSlot(frame, "head", rightX, rightSlotsTop, slotW, slotH)
    slots["facecover"] = CreateArmorSlot(frame, "facecover", rightX, rightSlotsTop + (slotH + slotSpacing) * 1, slotW, slotH)
    slots["face"] = CreateArmorSlot(frame, "face", rightX, rightSlotsTop + (slotH + slotSpacing) * 2, slotW, slotH)
    slots["face2"] = CreateArmorSlot(frame, "face2", rightX, rightSlotsTop + (slotH + slotSpacing) * 3, slotW, slotH)

    frame.ArmorSlots = slots

    local bodySlotBottom = modelPanelY + modelPanelH/2 + slotH/2
    local btnY = bodySlotBottom + slotSpacing
    local btnW = slotW
    local btnH = He(26)

    local removeAllBtn = vgui.Create("DButton", frame)
    removeAllBtn:SetPos(leftX, btnY)
    removeAllBtn:SetSize(btnW, btnH)
    removeAllBtn:SetText(MuR.Language["armor_remove_all"] or "Снять всё")
    removeAllBtn:SetFont("MuR_FontDef")
    removeAllBtn:SetTextColor(ARMOR_UI_THEME.text)
    removeAllBtn.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and ARMOR_UI_THEME.danger or ARMOR_UI_THEME.panel
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        surface.SetDrawColor(ARMOR_UI_THEME.panelBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    removeAllBtn.DoClick = function()
        if MuR.ArmorActionInProgress then return end
        StartUnequipAllChain(frame, ply)
    end

    local equipAllBtn = vgui.Create("DButton", frame)
    equipAllBtn:SetPos(leftX, btnY + btnH + slotSpacing)
    equipAllBtn:SetSize(btnW, btnH)
    equipAllBtn:SetText(MuR.Language["armor_equip_all"] or "Одеть всё")
    equipAllBtn:SetFont("MuR_FontDef")
    equipAllBtn:SetTextColor(ARMOR_UI_THEME.text)
    equipAllBtn.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and ARMOR_UI_THEME.success or ARMOR_UI_THEME.panel
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        surface.SetDrawColor(ARMOR_UI_THEME.panelBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    equipAllBtn.DoClick = function()
        if MuR.ArmorActionInProgress then return end
        StartEquipAllChain(frame, ply)
    end

    local hintsLabel = vgui.Create("DLabel", frame)
    hintsLabel:SetPos(We(20), frameH - He(22))
    hintsLabel:SetSize(frameW - We(40), He(18))
    hintsLabel:SetText((MuR.Language["armor_hint_close"] or "ESC / Q — закрыть") .. "  |  " .. (MuR.Language["armor_hint_click"] or "ЛКМ — меню") .. "  |  " .. (MuR.Language["armor_hint_alt_e"] or "Alt+E — подобрать в сумку мгновенно"))
    hintsLabel:SetFont("MuR_FontDef")
    hintsLabel:SetTextColor(ARMOR_UI_THEME.textDark)
    hintsLabel:SetContentAlignment(5)

    timer.Create("MuR_ArmorUIUpdate", 0.5, 0, function()
        if not IsValid(frame) then
            timer.Remove("MuR_ArmorUIUpdate")
            return
        end
        for bodypart, slot in pairs(slots) do
            if IsValid(slot) then
                slot:UpdateArmor()
            end
        end
    end)
end

concommand.Add("mur_armor_panel", function()
    OpenArmorPanel()
end)

MuR.OpenArmorPanel = OpenArmorPanel

net.Receive("MuR_ArmorPickupStart", function()
    local ent = net.ReadEntity()
    local armorId = net.ReadString()
    local duration = net.ReadFloat()
    if not IsValid(ent) or armorId == "" then return end
    local item = MuR.Armor.GetItem(armorId)
    if not item then return end
    if MuR.ArmorActionInProgress then return end

    local ply = LocalPlayer()

    if item.blocks_bodyparts then
        for _, blockedPart in ipairs(item.blocks_bodyparts) do
            local existingId = ply:GetNW2String("MuR_Armor_" .. blockedPart, "")
            if existingId and existingId ~= "" then
                local allowed = item.allows_on_blocked and item.allows_on_blocked[blockedPart]
                if not (allowed and table.HasValue(allowed, existingId)) then
                    local blockingName = MuR.Language["armor_item_" .. existingId] or existingId
                    local msg = MuR.Language["armor_conflict_with"] and string.format(MuR.Language["armor_conflict_with"], blockingName) or ("Предмет конфликтует с " .. blockingName)
                    ShowArmorConflictMessage(msg)
                    return
                end
            end
        end
    end

    if MuR.Armor.BodyParts and MuR.Armor.BodyParts[item.bodypart] then
        for otherPart, _ in pairs(MuR.Armor.BodyParts) do
            local otherId = ply:GetNW2String("MuR_Armor_" .. otherPart, "")
            if otherId and otherId ~= "" then
                local otherItem = MuR.Armor.GetItem(otherId)
                if otherItem and otherItem.blocks_bodyparts then
                    for _, blockedPart in ipairs(otherItem.blocks_bodyparts) do
                        if blockedPart == item.bodypart then
                            local allowed = otherItem.allows_on_blocked and otherItem.allows_on_blocked[item.bodypart]
                            if allowed and table.HasValue(allowed, armorId) then

                            else
                                local blockingName = MuR.Language["armor_item_" .. otherId] or otherId
                                local msg = MuR.Language["armor_conflict_with"] and string.format(MuR.Language["armor_conflict_with"], blockingName) or ("Предмет конфликтует с " .. blockingName)
                                ShowArmorConflictMessage(msg)
                                return
                            end
                        end
                    end
                end
            end
        end
    end

    if input.IsKeyDown(KEY_LALT) then
        local ply = LocalPlayer()
        local existingArmorId = ply:GetNW2String("MuR_Armor_" .. item.bodypart, "")
        if existingArmorId and existingArmorId ~= "" then

            local existingItem = MuR.Armor.GetItem(existingArmorId)
            local unequipDur = existingItem and (existingItem.unequip_time or ARMOR_UNEQUIP_DURATION) or ARMOR_UNEQUIP_DURATION
            local existingName = MuR.Language["armor_item_" .. existingArmorId] or existingArmorId
            local title = string.format(MuR.Language["armor_unequipping"] or "Снимаю \"%s\"", existingName)
            CreateArmorProgressBar(unequipDur, title, function()
                net.Start("MuR_ArmorPickupToBag")
                net.WriteEntity(ent)
                net.SendToServer()
            end, nil, { pickupEntity = ent })
        else

            MuR.ArmorActionInProgress = true
            net.Start("MuR_ArmorPickupToBag")
            net.WriteEntity(ent)
            net.SendToServer()
            timer.Simple(0.5, function()
                MuR.ArmorActionInProgress = false
            end)
        end
        return
    end

    local itemName = MuR.Language["armor_item_" .. armorId] or armorId
    local title = string.format(MuR.Language["armor_equipping"] or "Одеваю \"%s\"", itemName)
    CreateArmorProgressBar(duration, title, function()
        net.Start("MuR_ArmorPickupComplete")
        net.WriteEntity(ent)
        net.SendToServer()
    end, nil, { pickupEntity = ent })
end)

net.Receive("MuR_ArmorConflict", function()
    local blockingArmorId = net.ReadString()
    if blockingArmorId == "" then return end
    local blockingName = MuR.Language["armor_item_" .. blockingArmorId] or blockingArmorId
    local msg = MuR.Language["armor_conflict_with"] and string.format(MuR.Language["armor_conflict_with"], blockingName) or ("Предмет конфликтует с " .. blockingName)
    ShowArmorConflictMessage(msg)
end)
