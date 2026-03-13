AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Traitor Syringe"
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
	["traitor_syringe"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(200, 50, 50), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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

	if IsValid(tar) and tar:IsPlayer() and tar ~= ow and tar:Alive() then
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			MuR:PlaySoundOnClient(self.BandageSound, ow)
			timer.Simple(0.5, function()
				if not IsValid(self) or not IsValid(ow) or not IsValid(tar) then return end
				

				if IsValid(ow) then
					MuR:GiveMessage("traitor_syringe_used", ow)
				end

				

				local attacker = ow
				local target = tar
				local targetIndex = tar:EntIndex()
				local timerName = "MuR_TraitorSyringe_" .. targetIndex
				

				if timer.Exists(timerName) then
					timer.Remove(timerName)
				end
				

				timer.Simple(30, function()
					if not IsValid(target) or not target:Alive() then return end
					

					target:SetNW2Bool("FakePoison", true)
					target.PoisonVoiceTime = CurTime() + math.random(15, 60)
					target:SetNW2Bool("Poison", true)
				end)
				

				timer.Simple(60, function()
					if not IsValid(target) or not target:Alive() then return end
					

					if IsValid(target) then
						target:SetNW2Bool("FakePoison", false)
						target:SetNW2Bool("Poison", false)
					end
					

					target:ApplyUnconsciousness(30)
					

					timer.Simple(30, function()
						if not IsValid(target) or not target:Alive() then return end
						

						target:SetNW2String("Class", "Traitor")
						target:SetTeam(1)
						

						target:AllowFlashlight(true)
						

						if not target:HasWeapon("mur_disguise") then
							target:GiveWeapon("mur_disguise", true)
						end
						if not target:HasWeapon("mur_scanner") then
							target:GiveWeapon("mur_scanner", true)
						end
						

						target:SetNW2Float("Stability", 100)
						

						if IsValid(target) then
							MuR:GiveMessage("traitor_syringe_subjugated", target)
							if IsValid(attacker) then
								MuR:GiveMessage("traitor_syringe_subjugated_attacker", attacker)
							end
						end
					end)
				end)
				
				self:Remove()
			end)
		end 
	end 
end

function SWEP:DrawWorldModel() end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_traitor_syringe"] or "Traitor Syringe", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Illegal"
SWEP.Spawnable = true
