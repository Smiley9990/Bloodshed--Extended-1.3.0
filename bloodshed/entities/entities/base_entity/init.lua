
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "outputs.lua" )

function ENT:Initialize()
end

function ENT:KeyValue( key, value )
end

function ENT:OnRestore()
end

function ENT:AcceptInput( name, activator, caller, data )
	return false
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:Think()
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetCreator( ply )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	ent:DropToFloor()

	return ent

end
