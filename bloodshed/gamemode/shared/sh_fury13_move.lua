

hook.Add("SetupMove", "MuR.Fury13BerserkSpeed", function(ply, mv, cmd)

	local furyLevel = ply:GetNW2Float("BerserkLevel", 0)
	if furyLevel > 0 then
		local furyEnd = ply:GetNW2Float("BerserkEnd", 0)
		if CurTime() < furyEnd then
			local timeLeft = furyEnd - CurTime()
			local speedMultiplier

			if timeLeft <= 30 then

				speedMultiplier = 0.85 + 0.15 * (timeLeft / 30)
			else

				speedMultiplier = 1 + (furyLevel / 10) * 0.25
			end

			local currentMaxSpeed = mv:GetMaxSpeed()
			mv:SetMaxSpeed(currentMaxSpeed * speedMultiplier)
			mv:SetMaxClientSpeed(currentMaxSpeed * speedMultiplier)
		end
	end
end)
