AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ammonia Bomb"
ENT.Author = "Zippy"
ENT.Contact = "http://steamcommunity.com/groups/zippys_map_content"
ENT.Information = "Projectiles for my addons"
ENT.Category = "Projectiles"

ENT.Model = "models/props_junk/metal_paintcan001a.mdl"
ENT.FuseTime = 3

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(5)
	end
	
	if SERVER then
		timer.Simple(self.FuseTime, function()
			if IsValid(self) then
				self:DeathEffects()
			end
		end)
	end
end

function ENT:DeathEffects()
	local pos = self:GetPos()
	

	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	util.Effect("Explosion", effectdata)
	

	local cloud = ents.Create("prop_effect")
	cloud:SetPos(pos)
	cloud:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	cloud:SetNoDraw(true)
	cloud:Spawn()
	

	if MuR.SubstanceSystem then

		local gas = ents.Create("env_smoketrail")
		gas:SetPos(pos)
		gas:SetKeyValue("startsize", "70")
		gas:SetKeyValue("endsize", "100")
		gas:SetKeyValue("spawnradius", "128")
		gas:SetKeyValue("minspeed", "10")
		gas:SetKeyValue("maxspeed", "20")
		gas:SetKeyValue("startcolor", "255 255 255")
		gas:SetKeyValue("endcolor", "200 200 200")
		gas:SetKeyValue("opacity", "0.8")
		gas:SetKeyValue("spawnrate", "20")
		gas:SetKeyValue("lifetime", "5")
		gas:Spawn()
		gas:Fire("Kill", "", 5)
		

		timer.Create("AmmoniaGas_"..self:EntIndex(), 1, 5, function()
			for k, v in pairs(ents.FindInSphere(pos, 250)) do
				if v:IsPlayer() and v:Alive() then
					MuR.Drug:Apply(v, "ammonia")
				end
			end
		end)
	end

	self:Remove()
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 500 then
		self:DeathEffects()
	end
end
