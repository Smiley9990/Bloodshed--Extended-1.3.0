

function ENT:BehaveStart()

	self.BehaveThread = coroutine.create( function() self:RunBehaviour() end )

end

function ENT:RunBehaviour()
end

function ENT:BehaveUpdate( fInterval )

	if ( !self.BehaveThread ) then return end

	if ( coroutine.status( self.BehaveThread ) == "dead" ) then

		self.BehaveThread = nil
		Msg( self, " Warning: ENT:RunBehaviour() has finished executing\n" )

		return

	end

	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		ErrorNoHalt( self, " Error: ", message, "\n" )

	end

end

function ENT:BodyUpdate()

	local act = self:GetActivity()

	if ( act == ACT_RUN || act == ACT_WALK ) then

		self:BodyMoveXY()

		return

	end

	self:FrameAdvance()

end

function ENT:OnLeaveGround( ent )

end

function ENT:OnLandOnGround( ent )

end

function ENT:OnStuck()

end

function ENT:OnUnStuck()

end

function ENT:OnInjured( damageinfo )

end

function ENT:OnKilled( dmginfo )

	hook.Run( "OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

	self:BecomeRagdoll( dmginfo )

end

function ENT:OnOtherKilled( victim, info )

end

function ENT:OnContact( ent )

end

function ENT:OnIgnite()

end

function ENT:OnNavAreaChanged( old, new )

end

function ENT:FindSpots( tbl )

	local tbl = tbl or {}

	tbl.pos			= tbl.pos			or self:WorldSpaceCenter()
	tbl.radius		= tbl.radius		or 1000
	tbl.stepdown	= tbl.stepdown		or 20
	tbl.stepup		= tbl.stepup		or 20
	tbl.type		= tbl.type			or 'hiding'

	local path = Path( "Follow" )

	local areas = navmesh.Find( tbl.pos, tbl.radius, tbl.stepdown, tbl.stepup )

	local found = {}

	for _, area in pairs( areas ) do

		local spots

		if ( tbl.type == 'hiding' ) then spots = area:GetHidingSpots() end

		for k, vec in pairs( spots ) do

			path:Invalidate()

			path:Compute( self, vec, 1 )

			table.insert( found, { vector = vec, distance = path:GetLength() } )

		end

	end

	return found

end

function ENT:FindSpot( type, options )

	local spots = self:FindSpots( options )
	if ( !spots || #spots == 0 ) then return end

	if ( type == "near" ) then

		table.SortByMember( spots, "distance", true )
		return spots[1].vector

	end

	if ( type == "far" ) then

		table.SortByMember( spots, "distance", false )
		return spots[1].vector

	end

	return spots[ math.random( 1, #spots ) ].vector

end

function ENT:HandleStuck()

	self.loco:ClearStuck()

end

function ENT:MoveToPos( pos, options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do

		path:Update( self )

		if ( options.draw ) then
			path:Draw()
		end

		if ( self.loco:IsStuck() ) then

			self:HandleStuck()

			return "stuck"

		end

		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:PlaySequenceAndWait( name, speed )

	local len = self:SetSequence( name )
	speed = speed or 1

	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed )

	coroutine.wait( len / speed )

end

function ENT:Use( activator, caller, type, value )
end

function ENT:Think()
end

function ENT:HandleAnimEvent( event, eventtime, cycle, typee, options )
end

function ENT:OnTraceAttack( dmginfo, dir, trace )

	hook.Run( "ScaleNPCDamage", self, trace.HitGroup, dmginfo )

end

function ENT:OnEntitySight( subject )
end

function ENT:OnEntitySightLost( subject )
end
