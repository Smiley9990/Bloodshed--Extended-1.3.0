

hook.Remove("CalcViewModelView", "MuR_Mode55_HiddenKnifePos")
hook.Remove("PostEntityTakeDamage", "MuR_Mode55_HiddenKnifeSounds")

if SERVER then

	local POUNCE_FORCE = 600
	local POUNCE_UP = 210
	local WALL_JUMP_FORCE = 325
	local WALL_JUMP_UP = 210
	local WALL_CLING_DRAIN = 0.5

	hook.Add("SetupMove", "MuR_Mode55_HiddenMovement", function(ply, mv, cmd)
		if MuR.Gamemode ~= 55 then return end
		if ply:GetNW2String("Class") ~= "Hidden" then return end
		if not ply:Alive() then return end

		local ct = CurTime()
		ply.Mode55_HiddenEnergy = ply.Mode55_HiddenEnergy or 100

		if ply:OnGround() then
			ply.Mode55_HiddenEnergy = math.min(100, (ply.Mode55_HiddenEnergy or 100) + FrameTime() * 25)
		end

		if ply.Mode55_WallCling and ply.Mode55_WallCling > 0 and ct < ply.Mode55_WallCling then
			ply.Mode55_HiddenEnergy = math.max(0, (ply.Mode55_HiddenEnergy or 100) - FrameTime() * 50)
			if ply.Mode55_HiddenEnergy <= 0 then
				ply.Mode55_WallCling = 0
			else
				mv:SetVelocity(Vector(0, 0, 0))
				return
			end
		else
			ply.Mode55_WallCling = 0
		end

		if ply.Mode55_DoPounce then
			ply.Mode55_DoPounce = false
			local ang = mv:GetAngles()
			local fwd = ang:Forward()
			fwd.z = fwd.z * 0.75
			local vel = fwd * POUNCE_FORCE + Vector(0, 0, POUNCE_UP)
			vel.z = math.Clamp(vel.z, 250, 700)
			mv:SetVelocity(vel)
			ply:SetGroundEntity(NULL)
		end

		if ply.Mode55_DoWallJump then
			ply.Mode55_DoWallJump = false
			local ang = mv:GetAngles()
			local fwd = ang:Forward()
			fwd.z = fwd.z * 0.75
			local vel = fwd * (ply.Mode55_WallPounce and POUNCE_FORCE or WALL_JUMP_FORCE) + Vector(0, 0, WALL_JUMP_UP)
			vel.z = math.Clamp(vel.z, 180, 700)
			mv:SetVelocity(vel)
			ply:SetGroundEntity(NULL)
			ply.Mode55_WallPounce = false
		end
	end)

	hook.Add("Move", "MuR_Mode55_HiddenMove", function(ply, mv)
		if MuR.Gamemode ~= 55 then return end
		if ply:GetNW2String("Class") ~= "Hidden" then return end
		if not ply:Alive() then return end

		local ct = CurTime()
		local jumpPressed = mv:KeyPressed(IN_JUMP)
		local jumpDown = mv:KeyDown(IN_JUMP)
		local duckDown = mv:KeyDown(IN_DUCK)

		if ply:OnGround() and jumpPressed and duckDown then
			ply.Mode55_DoPounce = true
			return
		end

		if not ply:OnGround() and jumpDown then
			if not ply.Mode55_WallCling or ct >= ply.Mode55_WallCling then
				local pos = mv:GetOrigin() + Vector(0, 0, 20)
				local ang = mv:GetAngles()
				local dirs = {ang:Forward() * 25, ang:Right() * 25, -ang:Right() * 25, -ang:Forward() * 25}
				for _, dir in ipairs(dirs) do
					local tr = util.TraceLine({
						start = pos,
						endpos = pos + dir,
						filter = ply,
						mask = MASK_PLAYERSOLID
					})
					if tr.Hit and not tr.HitSky and (not IsValid(tr.Entity) or not tr.Entity:IsPlayer()) then
						ply.Mode55_WallCling = ct + 0.05
						mv:SetVelocity(Vector(0, 0, 0))
						ply:SetMoveType(MOVETYPE_NONE)
						break
					end
				end
			end
		end

		if ply.Mode55_WallCling and ply.Mode55_WallCling > 0 and ct < ply.Mode55_WallCling then
			if not jumpDown then
				ply.Mode55_DoWallJump = true
				ply.Mode55_WallPounce = duckDown
				ply.Mode55_WallCling = 0
				ply:SetMoveType(MOVETYPE_WALK)
			end
		end
	end)
end

if CLIENT then
	hook.Add("PostDrawTranslucentRenderables", "MuR_Mode55_HiddenSense", function()
		if MuR.GamemodeCount ~= 55 then return end
		local lp = LocalPlayer()
		if not IsValid(lp) or lp:GetNW2String("Class") ~= "Hidden" or not lp:Alive() then return end
		if not input.IsKeyDown(KEY_F) then return end

		local senseCol = Color(255, 80, 80, 180)
		local mat = Material("sprites/light_glow02_add")
		if mat:IsError() then return end

		render.SetMaterial(mat)
		for _, ply in player.Iterator() do
			if not IsValid(ply) or ply == lp or not ply:Alive() then continue end
			if ply:GetNW2String("Class") ~= "I.R.I.S" then continue end

			local pos = ply:GetPos() + Vector(0, 0, 35)
			local toEye = (lp:EyePos() - pos):GetNormal()
			local dist = lp:EyePos():Distance(pos)

			render.DrawSprite(pos, 40, 40, senseCol)
			render.DrawQuadEasy(pos, toEye, 25, 25, senseCol, 0)
		end
	end)
end
