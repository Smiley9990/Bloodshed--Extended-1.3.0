
ENT.Base = "base_entity"
ENT.Type = "filter"

function ENT:Initialize()
end

function ENT:KeyValue( key, value )
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:PassesFilter( trigger, ent )
	return true
end

function ENT:PassesDamageFilter( dmg )
	return true
end
