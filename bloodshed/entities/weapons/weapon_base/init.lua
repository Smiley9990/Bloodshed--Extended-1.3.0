
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "ai_translations.lua" )
AddCSLuaFile( "sh_anim.lua" )
AddCSLuaFile( "shared.lua" )

include( "ai_translations.lua" )
include( "sh_anim.lua" )
include( "shared.lua" )

SWEP.Weight			= 5
SWEP.AutoSwitchTo	= true
SWEP.AutoSwitchFrom	= true

function SWEP:OnRestore()
end

function SWEP:AcceptInput( name, activator, caller, data )
	return false
end

function SWEP:KeyValue( key, value )
end

function SWEP:Equip( newOwner )
end

function SWEP:EquipAmmo( newOwner )
end

function SWEP:OnDrop()
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:GetCapabilities()

	return CAP_WEAPON_RANGE_ATTACK1

end

function SWEP:NPCShoot_Secondary( shootPos, shootDir )

	self:SecondaryAttack()

end

function SWEP:NPCShoot_Primary( shootPos, shootDir )

	self:PrimaryAttack()

end

AccessorFunc( SWEP, "fNPCMinBurst",		"NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst",		"NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate",		"NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime",	"NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime",	"NPCMaxRest" )
