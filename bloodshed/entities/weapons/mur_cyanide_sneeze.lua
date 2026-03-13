AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Sneezecetin"
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

SWEP.HoldType = "normal"

SWEP.VElements = {
	["cyanide_sneeze"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(150, 255, 150), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["main"] = { scale = Vector(0.007, 0.007, 0.007), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["button"] = { scale = Vector(0.007, 0.007, 0.007), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["cap"] = { scale = Vector(0.007, 0.007, 0.007), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["capup"] = { scale = Vector(0.007, 0.007, 0.007), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

function SWEP:Deploy( wep )
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
end

function SWEP:OnDrop()
	if self.Used then
		self:Remove()
	end
end

function SWEP:CustomInit() 
	self.Used = false
end

local function StartSneezeSequence(attacker, target)
	if not IsValid(target) or not target:IsPlayer() then return end

	local ind = target:EntIndex()
	local baseName = "MuR_SneezePoison_" .. ind
	

	if timer.Exists(baseName) then
		timer.Remove(baseName)
	end

	local incubationTime = 30
	local coughDuration = 60
	local totalTime = incubationTime + coughDuration
	
	local coughStartTime = CurTime() + incubationTime
	local coughEndTime = coughStartTime + coughDuration
	

	local function DoCough()
		if not IsValid(target) or not target:Alive() then
			timer.Remove(baseName)
			return
		end
		
		local currentTime = CurTime()
		

		if currentTime >= coughEndTime then
			return
		end
		

		local progress = (currentTime - coughStartTime) / coughDuration
		progress = math.Clamp(progress, 0, 1)
		

		local isCough = progress < 0.5
		

		local minInterval = 0.5
		local maxInterval = 7
		local currentInterval = maxInterval - (progress * (maxInterval - minInterval))
		

		if target.MakeRandomSound then
			target.RandomPlayerSound = 0
			target:MakeRandomSound(isCough)
		end
		

		timer.Simple(currentInterval, DoCough)
	end
	

	timer.Simple(incubationTime, function()
		if not IsValid(target) or not target:Alive() then return end
		DoCough()
	end)

	timer.Simple(totalTime + 0.1, function()
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

					local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
					if headBone and headBone > 0 then
						local headPhysBone = rag:TranslateBoneToPhysBone(headBone)
						if isnumber(headPhysBone) and headPhysBone > 0 then
							rag:ZippyGoreMod3_BreakPhysBone(headPhysBone, {
								damage = 1000,
								forceVec = Vector(0, 0, 0),
								dismember = true
							})
						end
					end
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
					dmg:SetDamageForce(Vector(0, 0, 500))
					dmg:SetDamagePosition(headPos)
					target:TakeDamageInfo(dmg)
				end
			end)
		end
	end)
end

function SWEP:CustomPrimaryAttack() 
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

	if IsValid(tar) and tar:IsPlayer() and tar ~= ow then
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			MuR:PlaySoundOnClient(self.BandageSound, ow)
			timer.Simple(0.5, function()
				if not IsValid(self) or not IsValid(ow) or not IsValid(tar) then return end
				MuR:GiveMessage("cyanide_use_target", ow)
				StartSneezeSequence(ow, tar)
				self:Remove()
			end)
		end 
	end 
end

function SWEP:DrawWorldModel() end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_cyanide"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Illegal"
SWEP.Spawnable = true

