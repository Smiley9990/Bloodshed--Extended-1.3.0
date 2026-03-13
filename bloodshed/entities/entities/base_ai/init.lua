
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "schedules.lua" )
include( "tasks.lua" )

ENT.m_fMaxYawSpeed = 200
ENT.m_iClass = CLASS_CITIZEN_REBEL

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

function ENT:Initialize()

	self:SetModel( "models/alyx.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_OPEN_DOORS, CAP_ANIMATEDFACE, CAP_SQUAD, CAP_USE_WEAPONS, CAP_DUCK, CAP_MOVE_SHOOT, CAP_TURN_HEAD, CAP_USE_SHOT_REGULATOR, CAP_AIM_GUN ) )

	self:SetHealth( 100 )

end

function ENT:OnTakeDamage( dmginfo )

end

function ENT:Use( activator, caller, type, value )
end

function ENT:StartTouch( entity )
end

function ENT:EndTouch( entity )
end

function ENT:Touch( entity )
end

function ENT:GetRelationship( entity )

end

function ENT:ExpressionFinished( strExp )

end

function ENT:OnChangeActivity( act )

end

function ENT:Think()

end

function ENT:OnMovementFailed()
end

function ENT:OnMovementComplete()
end

function ENT:OnActiveWeaponChanged( old, new )
end

function ENT:GetAttackSpread( Weapon, Target )
	return 0.1
end
