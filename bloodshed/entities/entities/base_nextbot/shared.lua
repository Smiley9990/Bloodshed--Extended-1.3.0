
AddCSLuaFile()

ENT.Base 			= "base_entity"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.RenderGroup		= RENDERGROUP_OPAQUE

ENT.Type = "nextbot"

function ENT:Initialize()
end

if ( SERVER ) then

	include( "sv_nextbot.lua" )

else

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()

		self:Draw()

	end

	function ENT:FireAnimationEvent( pos, ang, event, options )
	end

end
