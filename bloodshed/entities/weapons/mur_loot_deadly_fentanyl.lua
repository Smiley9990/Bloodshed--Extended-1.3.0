AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Deadly Fentanyl"
SWEP.Slot = 5
SWEP.Author = "SSmiley"

SWEP.WorldModel = "models/murdered/heroin/syringe_out/syringe_out.mdl"
SWEP.ViewModel = "models/murdered/heroin/darky_m/c_syringe_v2.mdl"
SWEP.BandageSound = "murdered/medicals/syringe_heroin.wav"

SWEP.WorldModelPosition = Vector(4, -2, -2)
SWEP.WorldModelAngle =  Angle(-90, 0, 0)

SWEP.ViewModelPos = Vector(0, 0, -2)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "slam"

SWEP.VElements = {
	["deadly_fentanyl"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["main"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["button"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["cap"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["capup"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(-4, 0, 2)

local function RipTargetApart(target, attacker)
	if not IsValid(target) or not target:Alive() then return end
	
	if SERVER then

		local rag = target:GetRD()
		if not IsValid(rag) then
			rag = target:StartRagdolling(0, 0)
		end
		

		timer.Simple(0.15, function()
			if not IsValid(target) then return end
			
			local rag = target:GetRD()
			if IsValid(rag) then

				local bonesToBreak = {
					"ValveBiped.Bip01_Head1",
					"ValveBiped.Bip01_Spine4",
					"ValveBiped.Bip01_Spine2",
					"ValveBiped.Bip01_L_UpperArm",
					"ValveBiped.Bip01_R_UpperArm",
					"ValveBiped.Bip01_L_Thigh",
					"ValveBiped.Bip01_R_Thigh"
				}
				
				for _, boneName in ipairs(bonesToBreak) do
					local bone = rag:LookupBone(boneName)
					if bone and bone > 0 then
						local physBone = rag:TranslateBoneToPhysBone(bone)
						if isnumber(physBone) and physBone > 0 then
							rag:ZippyGoreMod3_BreakPhysBone(physBone, {
								damage = 1000,
								forceVec = Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(0, 1000)),
								dismember = true
							})
						end
					end
				end
				

				timer.Simple(0.1, function()
					if IsValid(target) then
						target:TakeDamage(target:Health() + 1000, IsValid(attacker) and attacker or target)
					end
				end)
			else

				local headPos = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Head1") or 0)
				if headPos == vector_origin then
					headPos = target:EyePos()
				end
				
				local dmg = DamageInfo()
				dmg:SetDamage(1000)
				dmg:SetAttacker(IsValid(attacker) and attacker or target)
				local inflictor = Entity(0)
				if IsValid(attacker) and IsValid(attacker:GetActiveWeapon()) then
					inflictor = attacker:GetActiveWeapon()
				end
				dmg:SetInflictor(inflictor)
				dmg:SetDamageType(DMG_ALWAYSGIB)
				dmg:SetDamageForce(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(500, 1500)))
				dmg:SetDamagePosition(headPos)
				target:TakeDamageInfo(dmg)
			end
		end)
	end
end

function SWEP:Deploy( wep )
    self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
end

function SWEP:CustomPrimaryAttack()
	if self.Used then return end
	self.Used = true
	self:SendWeaponAnim(ACT_VM_THROW)
	local ow = self:GetOwner()
	local ind = ow:EntIndex()
    if SERVER then
		ow:EmitSound(self.BandageSound)
		timer.Simple(1.2, function()
            if !IsValid(self) or !IsValid(ow) then return end

			RipTargetApart(ow, ow)
			self:Remove()
        end)
	end 
end

function SWEP:OnDrop()
    if self.Used then
        self:Remove()
    end
end

function SWEP:CustomInit() 
	self.Used = false
end

function SWEP:CustomSecondaryAttack() 
	if self.Used then return end
	local ow = self:GetOwner()
	local tr = util.TraceLine({
		start = ow:GetShootPos(),
		endpos = ow:GetShootPos() + ow:GetAimVector() * 64,
		filter = ow,
		mask = MASK_SHOT_HULL
	})
	local tar = tr.Entity
	if tar.isRDRag and IsValid(tar.Owner) then
		tar = tar.Owner
	end
	if IsValid(tar) and tar:IsPlayer() then
		local ind = tar:EntIndex()
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			ow:EmitSound(self.BandageSound)
			timer.Simple(1.2, function()
				if !IsValid(self) or !IsValid(ow) then return end

				if IsValid(tar) and tar:Alive() then
					RipTargetApart(tar, ow)
				end
				self:Remove()
			end)
		end 
	end 
end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_medic_left"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(MuR.Language["loot_medic_right"], "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
SWEP.Category = "Bloodshed - Illegal"
SWEP.Spawnable = true
