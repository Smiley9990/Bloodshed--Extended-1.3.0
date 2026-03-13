
AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.AutomaticFrameAdvance = false

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:OnRemove()
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate( physobj )
end

if ( CLIENT ) then

	function ENT:Draw( flags )

		self:DrawModel( flags )

	end

	function ENT:DrawTranslucent( flags )

		self:Draw( flags )

	end

end

if ( SERVER ) then

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

	function ENT:PhysicsSimulate( phys, deltatime )
		return SIM_NOTHING
	end

end
