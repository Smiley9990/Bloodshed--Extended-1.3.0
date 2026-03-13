
function ENT:RunAI( strExp )

	if ( self:IsRunningBehavior() ) then
		return true
	end

	if ( self:DoingEngineSchedule() ) then
		return true
	end

	if ( self.CurrentSchedule ) then
		self:DoSchedule( self.CurrentSchedule )
	end

	if ( !self.CurrentSchedule ) then
		self:SelectSchedule()
	end

	self:MaintainActivity()

end

function ENT:SelectSchedule( iNPCState )

	self:SetSchedule( SCHED_IDLE_WANDER )

end

function ENT:StartSchedule( schedule )

	self.CurrentSchedule 	= schedule
	self.CurrentTaskID 		= 1
	self:SetTask( schedule:GetTask( 1 ) )

end

function ENT:DoSchedule( schedule )

	if ( self.CurrentTask ) then
		self:RunTask( self.CurrentTask )
	end

	if ( self:TaskFinished() ) then
		self:NextTask( schedule )
	end

end

function ENT:ScheduleFinished()

	self.CurrentSchedule 	= nil
	self.CurrentTask 		= nil
	self.CurrentTaskID 		= nil

end

function ENT:SetTask( task )

	self.CurrentTask 	= task
	self.bTaskComplete 	= false
	self.TaskStartTime 	= CurTime()

	self:StartTask( self.CurrentTask )

end

function ENT:NextTask( schedule )

	self.CurrentTaskID = self.CurrentTaskID + 1

	if ( self.CurrentTaskID > schedule:NumTasks() ) then

		self:ScheduleFinished( schedule )
		return

	end

	self:SetTask( schedule:GetTask( self.CurrentTaskID ) )

end

function ENT:StartTask( task )
	task:Start( self.Entity )
end

function ENT:RunTask( task )
	task:Run( self.Entity )
end

function ENT:TaskTime()
	return CurTime() - self.TaskStartTime
end

function ENT:OnTaskComplete()

	self.bTaskComplete = true

end

function ENT:TaskFinished()
	return self.bTaskComplete
end

function ENT:StartEngineTask( iTaskID, TaskData )
end

function ENT:RunEngineTask( iTaskID, TaskData )
end

function ENT:StartEngineSchedule( scheduleID ) self:ScheduleFinished() self.bDoingEngineSchedule = true end
function ENT:EngineScheduleFinish() self.bDoingEngineSchedule = nil end
function ENT:DoingEngineSchedule()	return self.bDoingEngineSchedule end

function ENT:OnCondition( iCondition )

end
