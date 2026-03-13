
AddCSLuaFile()

if ( CLIENT ) then
	CreateConVar( "cl_draweffectrings", "1", 0, "Should the effect green rings be visible?" )
end

ENT.Type = "anim"

ENT.Spawnable = false

function ENT:Initialize()

	local Radius = 6
	local mins = Vector( 1, 1, 1 ) * Radius * -0.5
	local maxs = Vector( 1, 1, 1 ) * Radius * 0.5

	if ( SERVER ) then

		self.AttachedEntity = ents.Create( "prop_dynamic" )
		self.AttachedEntity:SetModel( self:GetModel() )
		self.AttachedEntity:SetAngles( self:GetAngles() )
		self.AttachedEntity:SetPos( self:GetPos() )
		self.AttachedEntity:SetSkin( self:GetSkin() )
		self.AttachedEntity:Spawn()
		self.AttachedEntity:SetParent( self )
		self.AttachedEntity:DrawShadow( false )

		self:SetModel( "models/props_junk/watermelon01.mdl" )

		self:DeleteOnRemove( self.AttachedEntity )
		self.AttachedEntity:DeleteOnRemove( self )

		self:PhysicsInitBox( mins, maxs )
		self:SetSolid( SOLID_VPHYSICS )

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
			phys:EnableGravity( false )
			phys:EnableDrag( false )
		end

		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	else

		self.GripMaterial = Material( "sprites/grip" )
		self.GripMaterialHover = Material( "sprites/grip_hover" )

		local tab = ents.FindByClassAndParent( "prop_dynamic", self )
		if ( tab && IsValid( tab[ 1 ] ) ) then self.AttachedEntity = tab[ 1 ] end

	end

	self:SetCollisionBounds( mins, maxs )

end

function ENT:Draw()

	if ( halo.RenderedEntity() == self ) then
		self.AttachedEntity:DrawModel()
		return
	end

	if ( GetConVarNumber( "cl_draweffectrings" ) == 0 ) then return end

	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ( !IsValid( wep ) ) then return end

	local weapon_name = wep:GetClass()

	if ( weapon_name != "weapon_physgun" && weapon_name != "weapon_physcannon" && weapon_name != "gmod_tool" ) then
		return
	end

	if ( self:BeingLookedAtByLocalPlayer() ) then
		render.SetMaterial( self.GripMaterialHover )
	else
		render.SetMaterial( self.GripMaterial )
	end

	render.DrawSprite( self:GetPos(), 16, 16, color_white )

end

ENT.MaxWorldTipDistance = 256
function ENT:BeingLookedAtByLocalPlayer()
	local ply = LocalPlayer()
	if ( !IsValid( ply ) ) then return false end

	local view = ply:GetViewEntity()
	local dist = self.MaxWorldTipDistance
	dist = dist * dist

	if ( view:IsPlayer() ) then
		return view:EyePos():DistToSqr( self:GetPos() ) <= dist && view:GetEyeTrace().Entity == self
	end

	local pos = view:GetPos()

	if ( pos:DistToSqr( self:GetPos() ) <= dist ) then
		return util.TraceLine( {
			start = pos,
			endpos = pos + ( view:GetAngles():Forward() * dist ),
			filter = view
		} ).Entity == self
	end

	return false
end

function ENT:PhysicsUpdate( physobj )

	if ( CLIENT ) then return end

	if ( !self:IsPlayerHolding() && !self:IsConstrained() ) then

		physobj:SetVelocity( vector_origin )
		physobj:Sleep()

	end

end

function ENT:OnEntityCopyTableFinish( tab )

	tab.Model = self.AttachedEntity:GetModel()

	tab.AttachedEntityInfo = table.Copy( duplicator.CopyEntTable( self.AttachedEntity ) )
	tab.AttachedEntityInfo.Pos = nil
	tab.AttachedEntityInfo.Angle = nil

	tab.AttachedEntity = nil

end

function ENT:PostEntityPaste( ply )

	if ( IsValid( self.AttachedEntity ) && self.AttachedEntityInfo ) then

		duplicator.DoGeneric( self.AttachedEntity, self.AttachedEntityInfo )

		if ( self.AttachedEntityInfo.EntityMods ) then
			self.AttachedEntity.EntityMods = table.Copy( self.AttachedEntityInfo.EntityMods )
			duplicator.ApplyEntityModifiers( ply, self.AttachedEntity )
		end

		if ( self.AttachedEntityInfo.BoneMods ) then
			self.AttachedEntity.BoneMods = table.Copy( self.AttachedEntityInfo.BoneMods )
			duplicator.ApplyBoneModifiers( ply, self.AttachedEntity )
		end

		self.AttachedEntityInfo = nil

	end

end
