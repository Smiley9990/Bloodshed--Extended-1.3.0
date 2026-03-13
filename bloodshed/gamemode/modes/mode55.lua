

MuR.RegisterMode(55, {
	name = "The Hidden",
	chance = 15,
	need_players = 4,
	spawn_type = "tdm",
	kteam = "Hidden",
	dteam = "I.R.I.S",
	kteam_count = 1,
	timer = 300,
	countdown_on_start = true,
	win_condition = "tdm",
	tdm_end_logic = true,
	win_screen_team1 = "hidden_win",
	win_screen_team2 = "iris_win",
	disables = true,
	disables_police = true,
	no_guilt = true,
	disable_loot = true,

	OnModeStarted = function(mode)

	end,

	OnModeEnded = function(mode)
		if SERVER then
			for _, ply in player.Iterator() do
				if IsValid(ply) then
					ply:SetRenderMode(RENDERMODE_NORMAL)
					ply:SetColor(Color(255, 255, 255, 255))
					ply:DrawShadow(true)
					ply:SetMaterial("")
				end
			end
		end
	end,

	OnModeThink = function(mode)
		if SERVER then
			for _, ply in player.Iterator() do
				if IsValid(ply) and ply:GetNW2String("Class") == "Hidden" and ply:Alive() then
					ply:DrawShadow(false)
					ply:SetRenderMode(RENDERMODE_TRANSALPHA)

					ply:SetMaterial("thehidden/view/viewmodels/viewmodel/a_viewmodel/stop/i_promise/sv_pure/617_invis_dynamic")
					ply:SetColor(Color(255, 255, 255, 28))
				end
			end
		end
	end,

	OnModePrecache = function(mode)
		if CLIENT then
			Material("thehidden/trails/laser_beam")
			Material("thehidden/hud_ui/laser_dot")
		end
	end
})

if SERVER then
	local MODE55_IRIS_WEAPONS = {
		"tfa_bs_ak12", "tfa_bs_mp7", "tfa_bs_mp5a5", "tfa_bs_vector",
		"tfa_bs_val", "tfa_bs_aug", "tfa_bs_hk416", "tfa_bs_nova", "tfa_bs_m1014"
	}
	local MODE55_IRIS_PISTOLS = {"tfa_bs_glock", "tfa_bs_m9", "tfa_bs_usp", "tfa_bs_colt"}

	hook.Add("PlayerSpawn", "MuR_Mode55_IRISWeapons", function(ply)
		if MuR.Gamemode ~= 55 then return end
		if ply:GetNW2String("Class") ~= "I.R.I.S" then return end
		if not ply:Alive() then return end

		timer.Simple(0.2, function()
			if not IsValid(ply) or not ply:Alive() or MuR.Gamemode ~= 55 then return end
			if ply:GetNW2String("Class") ~= "I.R.I.S" then return end

			ply:StripWeapons()
			ply:StripAmmo()

			local primary = MODE55_IRIS_WEAPONS[math.random(#MODE55_IRIS_WEAPONS)]
			local pistol = MODE55_IRIS_PISTOLS[math.random(#MODE55_IRIS_PISTOLS)]

			ply:GiveWeapon(primary, true)
			ply:GiveWeapon(pistol, true)
			ply:GiveWeapon("mur_loot_medkit", true)
			ply:GiveWeapon("mur_loot_bandage", true)

			timer.Simple(0.3, function()
				if not IsValid(ply) or not ply:Alive() then return end
				local pw = ply:GetWeapon(primary)
				if IsValid(pw) then
					local at = pw:GetPrimaryAmmoType()
					if at and at > 0 then
						ply:GiveAmmo(math.max((pw:GetMaxClip1() or 30) * 4, 120), at, true)
					end
				end
				local pst = ply:GetWeapon(pistol)
				if IsValid(pst) then
					local at = pst:GetPrimaryAmmoType()
					if at and at > 0 then
						ply:GiveAmmo(math.max((pst:GetMaxClip1() or 15) * 4, 60), at, true)
					end
				end
			end)

			ply:SetArmor(100)
			ply:SetWalkSpeed(100)
			ply:SetRunSpeed(280)
		end)
	end)
end

if CLIENT then
	local MAT_LASER_BEAM = Material("thehidden/trails/laser_beam")
	local MAT_LASER_DOT = Material("thehidden/hud_ui/laser_dot")

	hook.Add("PostDrawTranslucentRenderables", "MuR_Mode55_Lasers", function()
		if MuR.GamemodeCount ~= 55 then return end
		if MAT_LASER_BEAM:IsError() or MAT_LASER_DOT:IsError() then return end

		local lp = LocalPlayer()
		local flicker = math.Rand(0.85, 1.05)

		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end
			if ply:GetNW2String("Class") ~= "I.R.I.S" then continue end
			if ply:GetNoDraw() then continue end

			local wep = ply:GetActiveWeapon()
			if not IsValid(wep) or wep:GetClass() == "mur_hands" then continue end

			local isLocal = ply == lp

			local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
			local pos
			if bone then
				pos = ply:GetBonePosition(bone) + ply:GetForward() * 2 + ply:GetUp() * 4 + ply:GetRight() * 10
			else
				pos = ply:EyePos() + ply:GetRight() * 10 - ply:GetUp() * 10
			end
			if isLocal then
				pos = ply:EyePos() + ply:GetRight() * 10 - ply:GetUp() * 10
			end

			local tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:GetAimVector() * 3164,
				filter = {ply, wep}
			})

			local beamCol = isLocal and Color(0, 255, 0, 100) or Color(255, 0, 0, 200)
			local dotCol = isLocal and Color(0, 255, 0, 255) or Color(255, 0, 0, 200)
			local beamWidth = isLocal and 1.2 or 0.8
			local dotSize = (isLocal and 20 or 15) * flicker

			render.SetMaterial(MAT_LASER_BEAM)
			render.DrawBeam(pos, tr.HitPos, beamWidth, 0.01, 1, beamCol)
			render.SetMaterial(MAT_LASER_DOT)
			render.DrawQuadEasy(tr.HitPos, (pos - tr.HitPos):GetNormal(), dotSize, dotSize, dotCol, 0)
		end
	end)
end
