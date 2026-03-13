AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Manic Rage"

SWEP.Slot = 5
SWEP.Author = "SSmiley"
SWEP.Description = "SSmiley"

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
	["manicrage"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(200, 50, 50), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["main"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["button"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["cap"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["capup"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.TPIKDisabled = true
function SWEP:DrawWorldModel() end

function SWEP:GetPrintName()
	return MuR and MuR.Language and MuR.Language["mur_loot_ssmanicrage_name"] or "Manic Rage"
end

function SWEP:Deploy( wep )
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
end

local MANICRAGE_DELAY = 30

function SWEP:CustomPrimaryAttack()
	if self.Used then return end
	self.Used = true
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	local ow = self:GetOwner()
	local ind = ow:EntIndex()
	if SERVER then
		MuR:PlaySoundOnClient(self.BandageSound, ow)
		timer.Simple(0.5, function()
			if !IsValid(self) or !IsValid(ow) then return end
			self:Remove()
		end)
		local roundAtInjection = MuR.RoundNumber or 0
		local lifeAtInjection = ow:GetNW2Int("MuR_LifeCount", 0)
		timer.Simple(MANICRAGE_DELAY, function()
			if (MuR.RoundNumber or 0) ~= roundAtInjection then return end
			if ow:GetNW2Int("MuR_LifeCount", 0) ~= lifeAtInjection then return end
			if !IsValid(ow) or !ow:Alive() then return end
			

			local currentBerserk = ow:GetNW2Float("BerserkLevel", 0)
			local newBerserk = math.Clamp(currentBerserk + 2, 0, 10)
			ow:SetNW2Float("BerserkLevel", newBerserk)
			ow:SetNW2Float("BerserkEnd", CurTime() + 120)
			

			ow:EmitSound("buttons/button15.wav", 75, 100)
			timer.Simple(0.1, function()
				if IsValid(ow) then
					ow:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav", 60, math.random(95, 105))
				end
			end)
			

			MuR:GiveMessage("fury13_used", ow)
			

			timer.Simple(3.95, function()
				if !IsValid(ow) or !ow:Alive() then return end
				

				local berserkEnd = ow:GetNW2Float("BerserkEnd", 0)
				local timerReps = math.ceil((berserkEnd - CurTime()) / 0.05)
				timerReps = math.min(timerReps, 2400)
				
				if not timer.Exists("Fury13Stamina"..ind) then
					timer.Create("Fury13Stamina"..ind, 0.05, timerReps, function()
						if !IsValid(ow) or !ow:Alive() then 
							timer.Remove("Fury13Stamina"..ind)
							return
						end
						

						local berserkEnd = ow:GetNW2Float("BerserkEnd", 0)
						if berserkEnd <= CurTime() then
							timer.Remove("Fury13Stamina"..ind)
							return
						end
						

						local currentStamina = ow:GetNW2Float("Stamina", 0)
						if currentStamina < 100 then
							ow:SetNW2Float("Stamina", math.min(currentStamina + 1, 100))
						end
					end)
				end
			end)
			

			if not timer.Exists("BerserkThink"..ind) then
				timer.Create("BerserkThink"..ind, 0.1, 0, function()
					if !IsValid(ow) or !ow:Alive() then 
						timer.Remove("BerserkThink"..ind)

						if timer.Exists("Fury13Stamina"..ind) then
							timer.Remove("Fury13Stamina"..ind)
						end
						return
					end
					
					local berserkEnd = ow:GetNW2Float("BerserkEnd", 0)
					if CurTime() >= berserkEnd then

						local currentBerserk = ow:GetNW2Float("BerserkLevel", 0)
						if currentBerserk > 0 then
							local newBerserk = math.max(currentBerserk - 0.01, 0)
							ow:SetNW2Float("BerserkLevel", newBerserk)
							if newBerserk <= 0 then
								ow:SetNW2Float("BerserkEnd", 0)
								timer.Remove("BerserkThink"..ind)

								if timer.Exists("Fury13Stamina"..ind) then
									timer.Remove("Fury13Stamina"..ind)
								end
							end
						else
							timer.Remove("BerserkThink"..ind)

							if timer.Exists("Fury13Stamina"..ind) then
								timer.Remove("Fury13Stamina"..ind)
							end
						end
					end
				end)
			end
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
			MuR:PlaySoundOnClient(self.BandageSound, ow)
			timer.Simple(0.5, function()
				if !IsValid(self) or !IsValid(ow) then return end
				if !IsValid(tar) or !tar:IsPlayer() then return end
				self:Remove()
			end)
			local roundAtInjection = MuR.RoundNumber or 0
			local lifeAtInjection = tar:GetNW2Int("MuR_LifeCount", 0)
			timer.Simple(MANICRAGE_DELAY, function()
				if (MuR.RoundNumber or 0) ~= roundAtInjection then return end
				if tar:GetNW2Int("MuR_LifeCount", 0) ~= lifeAtInjection then return end
				if !IsValid(tar) or !tar:IsPlayer() or !tar:Alive() then return end
				

				local currentBerserk = tar:GetNW2Float("BerserkLevel", 0)
				local newBerserk = math.Clamp(currentBerserk + 2, 0, 10)
				local berserkEndTime = CurTime() + 120
				tar:SetNW2Float("BerserkLevel", newBerserk)
				tar:SetNW2Float("BerserkEnd", berserkEndTime)
				

				tar:EmitSound("buttons/button15.wav", 75, 100)
				timer.Simple(0.1, function()
					if IsValid(tar) then
						tar:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav", 60, math.random(95, 105))
					end
				end)
				

				MuR:GiveMessage("fury13_used_target", ow)
				MuR:GiveMessage("fury13_received", tar)
				

				timer.Simple(3.95, function()
					if !IsValid(tar) or !tar:Alive() then return end
					

					local berserkEnd = tar:GetNW2Float("BerserkEnd", 0)
					local timerReps = math.ceil((berserkEnd - CurTime()) / 0.05)
					timerReps = math.min(timerReps, 2400)
					
					if not timer.Exists("Fury13Stamina"..ind) then
						timer.Create("Fury13Stamina"..ind, 0.05, timerReps, function()
							if !IsValid(tar) or !tar:Alive() then 
								timer.Remove("Fury13Stamina"..ind)
								return
							end
							

							local berserkEnd = tar:GetNW2Float("BerserkEnd", 0)
							if berserkEnd <= CurTime() then
								timer.Remove("Fury13Stamina"..ind)
								return
							end
							

							local currentStamina = tar:GetNW2Float("Stamina", 0)
							if currentStamina < 100 then
								tar:SetNW2Float("Stamina", math.min(currentStamina + 1, 100))
							end
						end)
					end
				end)
				

				if not timer.Exists("BerserkThink"..ind) then
					timer.Create("BerserkThink"..ind, 0.1, 0, function()
						if !IsValid(tar) or !tar:Alive() then 
							timer.Remove("BerserkThink"..ind)

							if timer.Exists("Fury13Stamina"..ind) then
								timer.Remove("Fury13Stamina"..ind)
							end
							return
						end
						
						local berserkEnd = tar:GetNW2Float("BerserkEnd", 0)
						if CurTime() >= berserkEnd then

							local currentBerserk = tar:GetNW2Float("BerserkLevel", 0)
							if currentBerserk > 0 then
								local newBerserk = math.max(currentBerserk - 0.01, 0)
								tar:SetNW2Float("BerserkLevel", newBerserk)
								if newBerserk <= 0 then
									tar:SetNW2Float("BerserkEnd", 0)
									timer.Remove("BerserkThink"..ind)

									if timer.Exists("Fury13Stamina"..ind) then
										timer.Remove("Fury13Stamina"..ind)
									end
								end
							else
								timer.Remove("BerserkThink"..ind)

								if timer.Exists("Fury13Stamina"..ind) then
									timer.Remove("Fury13Stamina"..ind)
								end
							end
						end
					end)
				end
			end)
		end 
	end 
end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_medic_left"] or "Left Click: Use on yourself", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(MuR.Language["loot_medic_right"] or "Right Click: Use on target", "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Illegal"
SWEP.Spawnable = true
