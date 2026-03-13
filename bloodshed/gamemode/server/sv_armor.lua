local plyMeta = FindMetaTable("Player")

util.AddNetworkString("MuR_ArmorPickup")
util.AddNetworkString("MuR_ArmorPickupStart")
util.AddNetworkString("MuR_ArmorPickupComplete")
util.AddNetworkString("MuR_ArmorPickupToBag")
util.AddNetworkString("MuR_ArmorConflict")
util.AddNetworkString("MuR_GetRagdollArmor")
util.AddNetworkString("MuR_ArmorHUD")

local boneToHitgroup = {
    ["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
    ["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD,
    ["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
    ["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Pelvis"] = HITGROUP_STOMACH,
    ["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
    ["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
    ["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
}

MuR.Armor.ImpactSounds = {}
MuR.Armor.BarrierHitSounds = {
	"weapons/physcannon/superphys_small_zap1.wav",
	"weapons/physcannon/superphys_small_zap2.wav",
	"weapons/physcannon/superphys_small_zap3.wav",
	"weapons/physcannon/superphys_small_zap4.wav"
}

function MuR.Armor.CreateHEVShield(ply, fromRegen, silent)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if IsValid(ply.MuR_HEVShield) then return end
	local shield = ents.Create("hev_shld_effect_npc")
	if not IsValid(shield) then return end
	shield:SetModel(ply:GetModel())
	shield:SetModelScale(ply:GetModelScale() * 1.01, 0)
	shield:SetPos(ply:GetPos())
	shield:SetAngles(ply:GetAngles())
	shield:SetOwner(ply)
	shield:SetParent(ply)
	shield:Spawn()
	if fromRegen then
		shield:SetNWFloat("shld.regenCreate", CurTime())
	end
	if not silent then
		ply:EmitSound("items/suitchargeok1.wav", 70, 90)
		if ply.MuR_HEVCurrentVoice then ply:StopSound(ply.MuR_HEVCurrentVoice) end
		ply.MuR_HEVCurrentVoice = "hl1/fvox/power_restored.wav"
		ply:EmitSound(ply.MuR_HEVCurrentVoice, 65, 100)
		ply.MuR_HEVVoiceCooldown = CurTime() + 4
	end
	ply:SetNWFloat("shld.health", ply.MuR_BarrierHealth or 100)
	ply:SetNWFloat("shld.lastHit", CurTime())
	ply.MuR_HEVShield = shield
end

function MuR.Armor.RemoveHEVShield(ply)
	if not IsValid(ply) then return end
	if IsValid(ply.MuR_HEVShield) then
		ply.MuR_HEVShield:Remove()
		ply.MuR_HEVShield = nil
	end
end

function MuR.Armor.GetImpactSound(sndFolder)
    if not MuR.Armor.ImpactSounds[sndFolder] then
        local files, _ = file.Find("sound/murdered/armor/impact/" .. sndFolder .. "/*.wav", "GAME")
        MuR.Armor.ImpactSounds[sndFolder] = files
    end
    local tab = MuR.Armor.ImpactSounds[sndFolder]
    if istable(tab) and #tab > 0 then
        return "murdered/armor/impact/" .. sndFolder .. "/" .. table.Random(tab)
    end
    return nil
end

local function GetHitgroupFromBone(ent, boneName)
    if not boneName then return nil end
    return boneToHitgroup[boneName] or HITGROUP_GENERIC
end

local function GetArmorReductionValue(item, dmginfo)
    local reduction = item.damage_reduction or 0
    if dmginfo and item.damage_reduction_by_type then
        local best = 0
        for dmgType, val in pairs(item.damage_reduction_by_type) do
            if dmginfo:IsDamageType(dmgType) and isnumber(val) and val > best then
                best = val
            end
        end
        if best > 0 then
            reduction = best
        end
    elseif dmginfo and dmginfo:IsDamageType(DMG_BULLET) and item.ammo_scaling then
        local ammoType = dmginfo:GetAmmoType()
        local ammoName = game.GetAmmoName(ammoType)
        if ammoName then
            ammoName = string.lower(ammoName)
            if item.ammo_scaling[ammoName] then
                reduction = item.ammo_scaling[ammoName]
            elseif item.ammo_scaling["others"] then
                reduction = item.ammo_scaling["others"]
            end
        end
    end
    return reduction
end

function plyMeta:InitArmorData()
    self.MuR_Armor = self.MuR_Armor or {}
    self.MuR_ArmorActive = self.MuR_ArmorActive or {}
end

function plyMeta:IsArmorActive(bodypart)
    self:InitArmorData()
    return self:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
end

function plyMeta:EquipArmor(armorId, active)
    local item = MuR.Armor.GetItem(armorId)
    if not item then return false, nil end

    self:InitArmorData()
    if active == nil then active = true end

    if item.blocks_bodyparts then
        for _, blockedPart in ipairs(item.blocks_bodyparts) do
            local existing = self:GetArmorOnPart(blockedPart)
            if existing and existing ~= "" then

                local allowed = item.allows_on_blocked and item.allows_on_blocked[blockedPart]
                if not (allowed and table.HasValue(allowed, existing)) then
                    return false, existing
                end
            end
        end
    end

    if MuR.Armor.BodyParts[item.bodypart] then
        for otherPart, otherId in pairs(self.MuR_Armor or {}) do
            if otherId and otherId ~= "" then
                local otherItem = MuR.Armor.GetItem(otherId)
                if otherItem and otherItem.blocks_bodyparts then
                    for _, blockedPart in ipairs(otherItem.blocks_bodyparts) do
                        if blockedPart == item.bodypart then

                            local allowed = otherItem.allows_on_blocked and otherItem.allows_on_blocked[item.bodypart]
                            if allowed and table.HasValue(allowed, armorId) then

                            else
                                return false, otherId
                            end
                        end
                    end
                end
            end
        end
    end

    self:RemoveArmor(item.bodypart)

    self.MuR_Armor[item.bodypart] = armorId
    self.MuR_ArmorActive[item.bodypart] = active

    self:SetNW2String("MuR_Armor_" .. item.bodypart, armorId)
    self:SetNW2Bool("MuR_Armor_Active_" .. item.bodypart, active)

    local rd = self:GetRD()
    if IsValid(rd) then
        MuR:TransferArmorToRagdoll(self, rd)
    end

    if self.UpdateBloodMovementSpeed then
        self:UpdateBloodMovementSpeed()
    end

    if armorId == "hev_tors" then
        self.MuR_BarrierHealth = 100
        self.MuR_BarrierLastDamage = 0
        MuR.Armor.CreateHEVShield(self, false)
    end

    return true
end

function plyMeta:SetArmorActive(bodypart, active)
    self:InitArmorData()
    if not self.MuR_Armor[bodypart] then return end

    self.MuR_ArmorActive[bodypart] = active
    self:SetNW2Bool("MuR_Armor_Active_" .. bodypart, active)

    local item = MuR.Armor.GetItem(self.MuR_Armor[bodypart])
    if item then
        local snd = active and item.equip_sound or item.unequip_sound
        if snd then
            self:EmitSound(snd, 60, 100)
        end
    end

    local rd = self:GetRD()
    if IsValid(rd) then
        rd:SetNW2Bool("MuR_Armor_Active_" .. bodypart, active)
    end
end

function plyMeta:RemoveArmor(bodypart)
    self:InitArmorData()

    local removedArmorId = self.MuR_Armor[bodypart]
    self.MuR_Armor[bodypart] = nil
    self.MuR_ArmorActive[bodypart] = false
    self:SetNW2String("MuR_Armor_" .. bodypart, "")
    self:SetNW2Bool("MuR_Armor_Active_" .. bodypart, false)

    local rd = self:GetRD()
    if IsValid(rd) then
        rd:SetNW2String("MuR_Armor_" .. bodypart, "")
        if rd.MuR_Armor then
            rd.MuR_Armor[bodypart] = nil
        end
    end

    if removedArmorId == "hev_tors" then
        MuR.Armor.RemoveHEVShield(self)
    end

    if self.UpdateBloodMovementSpeed then
        self:UpdateBloodMovementSpeed()
    end
end

function plyMeta:GetEquippedArmor()
    self:InitArmorData()
    return self.MuR_Armor
end

function plyMeta:GetArmorOnPart(bodypart)
    self:InitArmorData()
    return self.MuR_Armor[bodypart]
end

function plyMeta:HasGasProtection()
    self:InitArmorData()

    local totalProtection = 0
    for bodypart, armorId in pairs(self.MuR_Armor) do
        if not self:IsArmorActive(bodypart) then continue end

        local item = MuR.Armor.GetItem(armorId)
        if item and item.gas_protection then
            totalProtection = totalProtection + item.gas_protection
        end
    end

    return totalProtection >= 1.0
end

function plyMeta:GetGasProtectionLevel()
    self:InitArmorData()

    local totalProtection = 0
    for bodypart, armorId in pairs(self.MuR_Armor) do
        if not self:IsArmorActive(bodypart) then continue end

        local item = MuR.Armor.GetItem(armorId)
        if item and item.gas_protection then
            totalProtection = totalProtection + item.gas_protection
        end
    end

    return math.min(totalProtection, 1.0)
end

function plyMeta:GetPepperProtectionLevel()
    self:InitArmorData()

    local totalProtection = 0
    for bodypart, armorId in pairs(self.MuR_Armor) do
        if not self:IsArmorActive(bodypart) then continue end

        local item = MuR.Armor.GetItem(armorId)
        if item then
            totalProtection = totalProtection + (item.pepper_protection or 0)
        end
    end

    return math.min(totalProtection, 1.0)
end

function plyMeta:GetArmorDamageReduction(organName, dmginfo)
    self:InitArmorData()

    local totalReduction = 0
    for bodypart, armorId in pairs(self.MuR_Armor) do
        if not self:IsArmorActive(bodypart) then continue end

        local item = MuR.Armor.GetItem(armorId)
        if item and MuR.Armor.IsOrganProtected(armorId, organName, dmginfo) then
            totalReduction = totalReduction + GetArmorReductionValue(item, dmginfo)
        end
    end

    return math.min(totalReduction, 1)
end

function plyMeta:GetArmorDamageReductionByHitgroup(hitgroup, dmginfo)
    self:InitArmorData()

    local totalReduction = 0
    local firstBodypart = nil
    for bodypart, armorId in pairs(self.MuR_Armor) do
        if not self:IsArmorActive(bodypart) then continue end

        local item = MuR.Armor.GetItem(armorId)
        if item and MuR.Armor.IsHitgroupProtected(bodypart, hitgroup, armorId) then
            if not dmginfo or MuR.Armor.IsDamageTypeProtected(armorId, dmginfo) then
                totalReduction = totalReduction + GetArmorReductionValue(item, dmginfo)
                if not firstBodypart then firstBodypart = bodypart end
            end
        end
    end

    return math.min(totalReduction, 2), firstBodypart
end

function plyMeta:ClearAllArmor()
    self:InitArmorData()

    if self.MuR_Armor and self.MuR_Armor.body == "hev_tors" then
        MuR.Armor.RemoveHEVShield(self)
    end

    for bodypart, _ in pairs(self.MuR_Armor) do
        self:SetNW2String("MuR_Armor_" .. bodypart, "")
    end

    self.MuR_Armor = {}
end

function MuR:TransferArmorToRagdoll(ply, ragdoll)
    if not IsValid(ply) or not IsValid(ragdoll) then return end

    ply:InitArmorData()

    ragdoll.MuR_Armor = table.Copy(ply.MuR_Armor)

    if not ragdoll.Inventory then ragdoll.Inventory = {} end
    for bodypart, armorId in pairs(ply.MuR_Armor) do
        if armorId and armorId ~= "" then
            local item = MuR.Armor.GetItem(armorId)
            if not item or not item.permanent then
                local itemStr = "mur_armor_" .. armorId
                if not table.HasValue(ragdoll.Inventory, itemStr) then
                    table.insert(ragdoll.Inventory, itemStr)
                end
            end
        end
    end

    local bodypartOrder = {"head", "facecover", "face", "face2", "ears", "body"}
    for _, bodypart in ipairs(bodypartOrder) do
        local armorId = ply.MuR_Armor[bodypart] or ""
        ragdoll:SetNW2String("MuR_Armor_" .. bodypart, armorId)
        ragdoll:SetNW2Bool("MuR_Armor_Active_" .. bodypart, armorId ~= "" and ply:IsArmorActive(bodypart))
    end
    timer.Simple(0.1, function()
        if not IsValid(ragdoll) or not IsValid(ply) then return end
        ply:InitArmorData()
        for _, bodypart in ipairs(bodypartOrder) do
            local armorId = ply.MuR_Armor[bodypart] or ""
            ragdoll:SetNW2String("MuR_Armor_" .. bodypart, armorId)
            ragdoll:SetNW2Bool("MuR_Armor_Active_" .. bodypart, armorId ~= "" and ply:IsArmorActive(bodypart))
        end
    end)

    ragdoll.HasTransferredArmor = true
end

hook.Add("PlayerDeath", "MuR_ArmorDeathRagdoll", function(ply)
    if not IsValid(ply) then return end
    local rd = ply:GetRD() or ply:GetNW2Entity("RD_EntCam")
    if IsValid(rd) then
        MuR:TransferArmorToRagdoll(ply, rd)
    end
end)

local MuR_HEVBarrierRegenNext = 0
hook.Add("Think", "MuR_HEVBarrierRegen", function()
	if CurTime() < MuR_HEVBarrierRegenNext then return end
	MuR_HEVBarrierRegenNext = CurTime() + 0.5

	for _, ply in player.Iterator() do
		if not IsValid(ply) or not ply:Alive() then continue end
		if ply:GetArmorOnPart("body") ~= "hev_tors" then continue end

		local item = MuR.Armor.GetItem("hev_tors")
		if not item or not item.barrier_health then continue end

		ply.MuR_BarrierHealth = ply.MuR_BarrierHealth or 0
		ply.MuR_BarrierLastDamage = ply.MuR_BarrierLastDamage or 0
		local regenDelay = item.barrier_regen_delay or 5

		if ply.MuR_BarrierHealth < item.barrier_health and CurTime() - ply.MuR_BarrierLastDamage >= regenDelay then
			ply.MuR_BarrierHealth = item.barrier_health
			ply:SetNWFloat("shld.health", ply.MuR_BarrierHealth)
			ply:SetNWFloat("shld.lastHit", CurTime())
			MuR.Armor.CreateHEVShield(ply, true)
		end
	end
end)

local MuR_ArmorRagdollSyncNext = 0
hook.Add("Think", "MuR_ArmorRagdollSync", function()
    if CurTime() < MuR_ArmorRagdollSyncNext then return end
    MuR_ArmorRagdollSyncNext = CurTime() + 0.15

    for _, ply in player.Iterator() do
        if not ply.MuR_Armor or table.IsEmpty(ply.MuR_Armor) then continue end

        local rd = ply:GetRD()
        if IsValid(rd) then
            MuR:TransferArmorToRagdoll(ply, rd)
        end

        if ply:GetArmorOnPart("body") == "hev_tors" then
            if IsValid(rd) then
                if IsValid(ply.MuR_HEVShield) then
                    local target = rd
                    if ply.MuR_HEVShield:GetParent() ~= target then
                        ply.MuR_HEVShield:SetParent(target)
                        ply.MuR_HEVShield:SetModel(rd:GetModel())
                    end
                end
            else
                if ply:GetNoDraw() then
                    MuR.Armor.RemoveHEVShield(ply)
                elseif ply.MuR_BarrierHealth and ply.MuR_BarrierHealth > 0 then
                    if not IsValid(ply.MuR_HEVShield) then
                        MuR.Armor.CreateHEVShield(ply, false, true)
                    elseif ply.MuR_HEVShield:GetParent() ~= ply then
                        ply.MuR_HEVShield:SetParent(ply)
                        ply.MuR_HEVShield:SetModel(ply:GetModel())
                    end
                end
            end
        end
    end
end)

local MuR_ArmorCorpseSyncNext = 0
hook.Add("Think", "MuR_ArmorCorpseSync", function()
    if CurTime() < MuR_ArmorCorpseSyncNext then return end
    MuR_ArmorCorpseSyncNext = CurTime() + 2

    local bodypartOrder = {"head", "facecover", "face", "face2", "ears", "body"}
    for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
        if not IsValid(rag) or not rag.HasTransferredArmor or not rag.MuR_Armor then continue end
        for _, bodypart in ipairs(bodypartOrder) do
            local armorId = rag.MuR_Armor[bodypart] or ""
            rag:SetNW2String("MuR_Armor_" .. bodypart, armorId)
            rag:SetNW2Bool("MuR_Armor_Active_" .. bodypart, armorId ~= "")
        end
    end
end)

net.Receive("MuR_ArmorPickup", function(len, ply)
    local action = net.ReadString()

    if action == "drop_from_ragdoll" then
        local ragdoll = net.ReadEntity()
        local bodypart = net.ReadString()

        if not IsValid(ragdoll) or not ragdoll:IsRagdoll() then return end
        if not MuR.Armor.BodyParts[bodypart] then return end
        if ply:GetPos():DistToSqr(ragdoll:GetPos()) > 40000 then return end

        MuR:DropArmorFromRagdoll(ragdoll, bodypart)
    elseif action == "unequip" then
        local bodypart = net.ReadString()
        if not MuR.Armor.BodyParts[bodypart] then return end
        if not ply:Alive() then return end

        local armorId = ply:GetArmorOnPart(bodypart)
        local item = MuR.Armor.GetItem(armorId)
        if item and item.permanent then return end
        if armorId and armorId ~= "" then
            local isActive = ply:IsArmorActive(bodypart)

            local tr = util.TraceLine({
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:GetForward() * 40,
                filter = ply
            })

            local dropPos = tr.HitPos + tr.HitNormal * 5
            local pickup = MuR:SpawnArmorPickup(dropPos, armorId)

            if IsValid(pickup) then
                local phys = pickup:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(ply:GetForward() * 50 + Vector(0, 0, 20))
                end
            end

            ply:RemoveArmor(bodypart)

            if isActive and item and item.unequip_sound then
                ply:EmitSound(item.unequip_sound, 60, 100)
            end
        end
    elseif action == "toggle_active" then
        local bodypart = net.ReadString()
        local active = net.ReadBool()
        if not MuR.Armor.BodyParts[bodypart] then return end
        if not ply:Alive() then return end

        if not active then
            local armorId = ply:GetArmorOnPart(bodypart)
            local item = MuR.Armor.GetItem(armorId)
            if item and item.permanent then return end
        end

        ply:SetArmorActive(bodypart, active)
    elseif action == "admin_equip" then
        if not ply:IsSuperAdmin() then return end
        local bodypart = net.ReadString()
        local armorId = net.ReadString()
        if not MuR.Armor.BodyParts[bodypart] then return end
        if not ply:Alive() then return end

        local item = MuR.Armor.GetItem(armorId)
        if not item or item.bodypart ~= bodypart then return end

        ply:EquipArmor(armorId)
    end
end)

net.Receive("MuR_ArmorPickupToBag", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "mur_armor_pickup" then return end
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 40000 then return end

    local armorId = ent:GetArmorId()
    if armorId == "" then return end

    local item = MuR.Armor.GetItem(armorId)
    if not item then return end

    ent:Remove()

    local existingArmor = ply:GetArmorOnPart(item.bodypart)
    if existingArmor and existingArmor ~= "" then
        MuR:SpawnArmorPickup(ply:GetPos() + Vector(0, 0, 20), existingArmor)
    end

    local ok, blockingArmorId = ply:EquipArmor(armorId, false)
    if ok then
        if item.equip_sound then
            ply:EmitSound(item.equip_sound, 60, 100)
        else
            ply:EmitSound("items/ammo_pickup.wav", 50)
        end
    else
        MuR:SpawnArmorPickup(ply:GetPos() + Vector(0, 0, 20), armorId)
        if blockingArmorId then
            net.Start("MuR_ArmorConflict")
            net.WriteString(blockingArmorId)
            net.Send(ply)
        end
    end
end)

net.Receive("MuR_ArmorPickupComplete", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "mur_armor_pickup" then return end
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 40000 then return end

    local armorId = ent:GetArmorId()
    if armorId == "" then return end

    local item = MuR.Armor.GetItem(armorId)
    if not item then return end

    ent:Remove()

    local existingArmor = ply:GetArmorOnPart(item.bodypart)
    if existingArmor and existingArmor ~= "" then
        MuR:SpawnArmorPickup(ply:GetPos() + Vector(0, 0, 20), existingArmor)
    end

    local ok, blockingArmorId = ply:EquipArmor(armorId)
    if ok then
        if item.equip_sound then
            ply:EmitSound(item.equip_sound, 60, 100)
        else
            ply:EmitSound("items/ammo_pickup.wav", 50)
        end
    else
        MuR:SpawnArmorPickup(ply:GetPos() + Vector(0, 0, 20), armorId)
        if blockingArmorId then
            net.Start("MuR_ArmorConflict")
            net.WriteString(blockingArmorId)
            net.Send(ply)
        end
    end
end)

net.Receive("MuR_GetRagdollArmor", function(len, ply)
    local ragdoll = net.ReadEntity()
    if not IsValid(ragdoll) or not ragdoll:IsRagdoll() then return end

    local armorList = {}
    if ragdoll.MuR_Armor then
        for bodypart, armorId in pairs(ragdoll.MuR_Armor) do
            if armorId and armorId ~= "" then
                local item = MuR.Armor.GetItem(armorId)
                if not item or not item.permanent then
                    table.insert(armorList, {bodypart = bodypart, armorId = armorId})
                end
            end
        end
    end

    net.Start("MuR_GetRagdollArmor")
    net.WriteEntity(ragdoll)
    net.WriteTable(armorList)
    net.Send(ply)
end)

local HEAD_ARMOR_SLOTS = {"head", "facecover", "face", "face2", "ears"}
local BODY_ARMOR_SLOTS = {"body"}

hook.Add("MuR_OnHeadGibbed", "MuR_ArmorDropOnHeadGib", function(ragdoll, headPos)
    if not IsValid(ragdoll) or not ragdoll.MuR_Armor or table.IsEmpty(ragdoll.MuR_Armor) then return end

    local owner = ragdoll.Owner
    local armorToDrop = {}
    for _, bodypart in ipairs(HEAD_ARMOR_SLOTS) do
        local armorId = ragdoll.MuR_Armor[bodypart]
        if armorId and armorId ~= "" then
            local item = MuR.Armor.GetItem(armorId)
            if not item or not item.permanent then
                armorToDrop[#armorToDrop + 1] = {bodypart = bodypart, armorId = armorId}
            end
        end
    end
    if #armorToDrop == 0 then return end

    for _, data in ipairs(armorToDrop) do
        local offset = Vector(math.Rand(-12, 12), math.Rand(-12, 12), math.Rand(0, 8))
        local pickup = MuR:SpawnArmorPickup(headPos + offset, data.armorId)
        if IsValid(pickup) then
            local phys = pickup:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(Vector(math.Rand(-80, 80), math.Rand(-80, 80), 80))
            end
        end
    end

    timer.Simple(0.15, function()
        if not IsValid(ragdoll) then return end

        for _, data in ipairs(armorToDrop) do
            ragdoll.MuR_Armor[data.bodypart] = nil
            ragdoll:SetNW2String("MuR_Armor_" .. data.bodypart, "")

            if ragdoll.Inventory then
                for i = #ragdoll.Inventory, 1, -1 do
                    if ragdoll.Inventory[i] == "mur_armor_" .. data.armorId then
                        table.remove(ragdoll.Inventory, i)
                        break
                    end
                end
            end

            if IsValid(owner) and owner:IsPlayer() then
                owner:RemoveArmor(data.bodypart)
            end
        end
    end)
end)

hook.Add("MuR_OnTorsoGibbed", "MuR_ArmorDropOnTorsoGib", function(ragdoll, torsoPos)
    if not IsValid(ragdoll) or not ragdoll.MuR_Armor or table.IsEmpty(ragdoll.MuR_Armor) then return end

    local owner = ragdoll.Owner
    local armorToDrop = {}
    for _, bodypart in ipairs(BODY_ARMOR_SLOTS) do
        local armorId = ragdoll.MuR_Armor[bodypart]
        if armorId and armorId ~= "" then
            local item = MuR.Armor.GetItem(armorId)
            if not item or not item.permanent then
                armorToDrop[#armorToDrop + 1] = {bodypart = bodypart, armorId = armorId}
            end
        end
    end
    if #armorToDrop == 0 then return end

    for _, data in ipairs(armorToDrop) do
        local offset = Vector(math.Rand(-12, 12), math.Rand(-12, 12), math.Rand(0, 8))
        local pickup = MuR:SpawnArmorPickup(torsoPos + offset, data.armorId)
        if IsValid(pickup) then
            local phys = pickup:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(Vector(math.Rand(-80, 80), math.Rand(-80, 80), 80))
            end
        end
    end

    timer.Simple(0.15, function()
        if not IsValid(ragdoll) then return end

        for _, data in ipairs(armorToDrop) do
            ragdoll.MuR_Armor[data.bodypart] = nil
            ragdoll:SetNW2String("MuR_Armor_" .. data.bodypart, "")

            if ragdoll.Inventory then
                for i = #ragdoll.Inventory, 1, -1 do
                    if ragdoll.Inventory[i] == "mur_armor_" .. data.armorId then
                        table.remove(ragdoll.Inventory, i)
                        break
                    end
                end
            end

            if IsValid(owner) and owner:IsPlayer() then
                owner:RemoveArmor(data.bodypart)
            end
        end
    end)
end)

function MuR:DropArmorFromRagdoll(ragdoll, bodypart)
    if not IsValid(ragdoll) or not ragdoll.MuR_Armor then return end

    local armorId = ragdoll.MuR_Armor[bodypart]
    if not armorId or armorId == "" then return end

    local item = MuR.Armor.GetItem(armorId)
    if item and item.permanent then return end

    local pos = ragdoll:GetPos() + Vector(0, 0, 30)
    local pickup = MuR:SpawnArmorPickup(pos, armorId)

    ragdoll.MuR_Armor[bodypart] = nil
    ragdoll:SetNW2String("MuR_Armor_" .. bodypart, "")

    if ragdoll.Inventory then
        table.RemoveByValue(ragdoll.Inventory, "mur_armor_" .. armorId)
    end

    return pickup
end

local HEV_VOICE_COOLDOWN = 3

hook.Add("EntityTakeDamage", "MuR_HEVBarrier", function(ent, dmg)
	local ply = nil
	if ent:IsPlayer() then
		ply = ent
	elseif ent.isRDRag and IsValid(ent.Owner) and ent.Owner:IsPlayer() and ent.Owner:Alive() then
		ply = ent.Owner
	end
	if not IsValid(ply) or not ply:Alive() then return end
	if ply:GetArmorOnPart("body") ~= "hev_tors" then return end

	local item = MuR.Armor.GetItem("hev_tors")
	if not item or not item.barrier_health then return end

	ply.MuR_BarrierHealth = ply.MuR_BarrierHealth or item.barrier_health

	if ply.MuR_BarrierHealth <= 0 then return end

	local dm = dmg:GetDamage()
	if dm <= 0 then return end

	ply.MuR_BarrierLastDamage = CurTime()
	local absorb = math.min(dm, ply.MuR_BarrierHealth)
	ply.MuR_BarrierHealth = ply.MuR_BarrierHealth - absorb
	ply:SetNWFloat("shld.health", ply.MuR_BarrierHealth)
	ply:SetNWFloat("shld.lastHit", CurTime())

	ply:EmitSound(table.Random(MuR.Armor.BarrierHitSounds), 75, 150)

	if (ply.MuR_HEVVoiceCooldown or 0) <= CurTime() then
		if ply.MuR_HEVCurrentVoice then
			ply:StopSound(ply.MuR_HEVCurrentVoice)
		end
		ply.MuR_HEVVoiceCooldown = CurTime() + HEV_VOICE_COOLDOWN
		ply.MuR_HEVCurrentVoice = "hl1/fvox/hev_damage.wav"
		ply:EmitSound(ply.MuR_HEVCurrentVoice, 65, 100)
	end

	dmg:ScaleDamage(0)

	if ply.MuR_BarrierHealth <= 0 then
		ply.MuR_BarrierHealth = 0
		ply:SetNWFloat("shld.health", 0)
		MuR.Armor.RemoveHEVShield(ply)
		ply:EmitSound("ambient/levels/labs/electric_explosion5.wav", 85, 150)
		ply:EmitSound("weapons/gauss/fire1.wav", 85, math.random(90, 110))
		ply:EmitSound("items/suitchargeno1.wav", 100, 100)
		timer.Simple(0.5, function()
			if IsValid(ply) then
				if ply.MuR_HEVCurrentVoice then
					ply:StopSound(ply.MuR_HEVCurrentVoice)
				end
				ply.MuR_HEVVoiceCooldown = CurTime() + 4
				ply.MuR_HEVCurrentVoice = "hl1/fvox/armor_gone.wav"
				ply:EmitSound(ply.MuR_HEVCurrentVoice, 65, 100)
			end
		end)
	end
end)

hook.Add("EntityTakeDamage", "MuR_ArmorDamageReduction", function(ent, dmg)
    local ply = nil
    local hitgroup = nil

    if ent:IsPlayer() then
        ply = ent
        hitgroup = ent.LastDamageHitgroup

        if (not hitgroup or hitgroup == 0) and ply.MuR_LastRagdollHitgroup then
            hitgroup = ply.MuR_LastRagdollHitgroup
            ply.MuR_LastRagdollHitgroup = nil
        end
    end

    if ent.isRDRag and IsValid(ent.Owner) and ent.Owner:IsPlayer() and ent.Owner:Alive() then
        ply = ent.Owner
        local pos = dmg:GetDamagePosition()
        local dir = dmg:GetDamageForce()
        local boneName = ent:GetNearestBoneFromPos(pos, dir)
        hitgroup = GetHitgroupFromBone(ent, boneName)
        ply.MuR_LastRagdollHitgroup = hitgroup
    end

    if not IsValid(ply) or not ply.MuR_Armor or table.IsEmpty(ply.MuR_Armor) then return end
    if not hitgroup or hitgroup == 0 then return end

    local reduction, bodypart = ply:GetArmorDamageReductionByHitgroup(hitgroup, dmg)
    if reduction > 0 then
        dmg:ScaleDamage(1 - reduction*0.5)
        local pos = dmg:GetDamagePosition()
        local dir = dmg:GetDamageForce()

        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetNormal((dir:GetNormalized() * -1))
        effectdata:SetMagnitude(1)
        effectdata:SetScale(0.5)
        util.Effect("ManhackSparks", effectdata, true, true)

        local sndFolder = "other"
        if bodypart == "head" then
            sndFolder = "helmet"
        elseif bodypart == "body" then
            sndFolder = "armor"
        end

        local snd = MuR.Armor.GetImpactSound(sndFolder)
        if snd then
            ent:EmitSound(snd, 75, 100)
        end
    end
end)

hook.Add("EntityTakeDamage", "MuR_CorpseArmorSparks", function(ent, dmg)
    if not ent:IsRagdoll() then return end
    if not ent.MuR_Armor or table.IsEmpty(ent.MuR_Armor) then return end
    if IsValid(ent.Owner) and ent.Owner:IsPlayer() and ent.Owner:Alive() then return end

    local pos = dmg:GetDamagePosition()
    local dir = dmg:GetDamageForce()
    local boneName = ent.GetNearestBoneFromPos and ent:GetNearestBoneFromPos(pos, dir)

    local hitgroup = HITGROUP_GENERIC
    if boneName then
        if string.find(boneName, "Head") or string.find(boneName, "Neck") then
            hitgroup = HITGROUP_HEAD
        elseif string.find(boneName, "Spine") then
            hitgroup = HITGROUP_CHEST
        end
    end

    for bodypart, armorId in pairs(ent.MuR_Armor) do
        local item = MuR.Armor.GetItem(armorId)
        if item and MuR.Armor.IsHitgroupProtected(bodypart, hitgroup, armorId) then
            if MuR.Armor.IsDamageTypeProtected(armorId, dmg) then
                local effectdata = EffectData()
                effectdata:SetOrigin(pos)
                effectdata:SetNormal((dir:GetNormalized() * -1))
                effectdata:SetMagnitude(1)
                effectdata:SetScale(0.5)
                util.Effect("ManhackSparks", effectdata, true, true)

                local sndFolder = "other"
                if bodypart == "head" then
                    sndFolder = "helmet"
                elseif bodypart == "body" then
                    sndFolder = "armor"
                end

                local snd = MuR.Armor.GetImpactSound(sndFolder)
                if snd then
                    ent:EmitSound(snd, 75, 100)
                end
                break
            end
        end
    end
end)

hook.Add("MuR.HandleCustomHitgroup", "MuR_ArmorOrganProtection", function(victim, owner, organ, dmginfo)

end)

hook.Add("MuR.Drug.PreApply", "MuR_ArmorGasProtection", function(ply, substanceId, substanceData)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not substanceData then return end
    local isGas = false
    for _, cat in ipairs(MuR.Armor.GasCategories) do
        if substanceData.cat == cat then
            isGas = true
            break
        end
    end
    if not isGas then return end
    local protection = ply:GetGasProtectionLevel()
    if protection >= 1.0 then
        return true
    elseif protection > 0 then
        return false, 1 - protection
    end
end)

hook.Add("PlayerSpawn", "MuR_ArmorClearOnSpawn", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            ply:ClearAllArmor()
        end
    end)
end)

hook.Add("PlayerDeath", "MuR_ArmorTransferOnDeath", function(ply)
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        local rd = ply:GetNW2Entity("RD_EntCam")
        if IsValid(rd) then
            MuR:TransferArmorToRagdoll(ply, rd)
        end
    end)
end)

concommand.Add("mur_give_armor", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local armorId = args[1]
    if not armorId then return end
    ply:EquipArmor(armorId)
end)

concommand.Add("mur_equip_armor", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local namePart = args[1]
    local armorId = args[2]
    if not namePart or not armorId then
        if IsValid(ply) then
            ply:ChatPrint("mur_equip_armor <имя> <armor_id> — пример: mur_equip_armor Player helmet_ulach")
        end
        return
    end

    local item = MuR.Armor.GetItem(armorId)
    if not item then
        if IsValid(ply) then ply:ChatPrint("Неизвестный armor_id: " .. armorId) end
        return
    end

    local target = nil
    namePart = string.lower(namePart)
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and string.find(string.lower(p:Nick() or ""), namePart, 1, true) then
            target = p
            break
        end
    end

    if not IsValid(target) then
        if IsValid(ply) then ply:ChatPrint("Игрок не найден: " .. namePart) end
        return
    end

    target:EquipArmor(armorId)
    if IsValid(ply) then
        ply:ChatPrint("Одел " .. (MuR.Language["armor_item_" .. armorId] or armorId) .. " на " .. target:Nick())
    end
end)

concommand.Add("mur_armor_list", function(ply, cmd, args)
    local list = {}
    for armorId, item in pairs(MuR.Armor.Items or {}) do
        if item.bodypart then
            list[#list + 1] = armorId .. " (" .. (item.bodypart or "?") .. ")"
        end
    end
    table.sort(list)
    local msg = table.concat(list, ", ")
    if IsValid(ply) then
        ply:ChatPrint("Броня: " .. msg)
    else
        print("mur_armor_list: " .. msg)
    end
end)

concommand.Add("mur_remove_armor", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local bodypart = args[1]
    if not bodypart then return end
    ply:RemoveArmor(bodypart)
end)

concommand.Add("mur_clear_armor", function(ply, cmd, args)
    if not IsValid(ply) then return end
    ply:ClearAllArmor()
end)
