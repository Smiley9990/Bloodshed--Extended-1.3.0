MuR.RegisterMode(50, {
	name = "Legion Battle", 
	chance = 200,
	need_players = 2,
	enabled = true,
	disables = true,
	disables_police = true,
	no_guilt = true, 
	timer = 300,

	kteam = "Legionnaire",
	dteam = "Legionnaire",
	iteam = "Legionnaire",
	win_condition = "survivor",
	no_win_screen = true,
	OnModePrecache = function(mode)

		if CLIENT then

			Material("murdered/modes/gamemodess1.png")
			Material("murdered/modes/gamemodess1h.png")

			sound.PlayFile("sound/murdered/theme/gamemodess1.wav", "noplay", function(station)
				if IsValid(station) then
					station:Stop()
				end
			end)
		end
	end,
	OnModeStarted = function(mode)

		local legionModels = {
			"models/gore/we_are_legion/prime_decanus_pm.mdl",
			"models/gore/we_are_legion/explorer_pm.mdl",
			"models/gore/we_are_legion/frumentarius_head_new_pm.mdl",
			"models/gore/we_are_legion/alexus_pm.mdl",
			"models/gore/we_are_legion/optio_new.mdl"
		}
		

		local legionWeapons = {
			"tfa_bs_bat",
			"tfa_bs_fireaxe",
			"tfa_bs_fubar",
			"tfa_bs_hatchet",
			"tfa_bs_machete",
			"tfa_bs_pickaxe",
			"tfa_bs_sledge"
		}
		

		timer.Simple(0.5, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 50 then return end
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then

					local playerClass = ply:GetNW2String("Class", "")
					if playerClass != "Legionnaire" then
						ply:SetNW2String("Class", "Legionnaire")
					end
					

					ply:SetTeam(2)
					ply:SetNW2Float("ArrestState", 0)
					

					local randomModel = table.Random(legionModels)
					if randomModel then
						ply:SetModel(randomModel)
					end
					

					for _, wep in ipairs(ply:GetWeapons()) do
						if IsValid(wep) and wep:GetClass() != "mur_hands" then
							ply:StripWeapon(wep:GetClass())
						end
					end
					

					local randomWeapon = table.Random(legionWeapons)
					if randomWeapon then
						ply:GiveWeapon(randomWeapon)
					end
					

					ply:GiveWeapon("mur_loot_ducttape")
				end
			end
		end)
		

		timer.Simple(13, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 50 then return end
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then

					if ply:GetNW2String("Class", "") != "Legionnaire" then
						ply:SetNW2String("Class", "Legionnaire")
					end
					

					ply:SetTeam(2)
					ply:SetNW2Float("ArrestState", 0)
					

					local hasLegionWeapon = false
					for _, wep in ipairs(ply:GetWeapons()) do
						if IsValid(wep) then
							local wepClass = wep:GetClass()
							for _, allowedWep in ipairs(legionWeapons) do
								if wepClass == allowedWep or wepClass == "mur_loot_ducttape" or wepClass == "mur_hands" then
									hasLegionWeapon = true
									break
								end
							end
						end
					end
					

					if not hasLegionWeapon then
						local randomWeapon = table.Random(legionWeapons)
						if randomWeapon then
							ply:GiveWeapon(randomWeapon)
						end
						ply:GiveWeapon("mur_loot_ducttape")
					end
				end
			end
		end)
	end,
	OnModeThink = function(mode)

		if not MuR.GameStarted or MuR.Gamemode ~= 50 then return end
		
		local legionWeapons = {
			"tfa_bs_bat",
			"tfa_bs_fireaxe",
			"tfa_bs_fubar",
			"tfa_bs_hatchet",
			"tfa_bs_machete",
			"tfa_bs_pickaxe",
			"tfa_bs_sledge",
			"mur_loot_ducttape"
		}
		
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() then
				for _, wep in ipairs(ply:GetWeapons()) do
					if IsValid(wep) then
						local allowed = false
						local wepClass = wep:GetClass()
						

						for _, allowedWep in ipairs(legionWeapons) do
							if wepClass == allowedWep then
								allowed = true
								break
							end
						end
						

						if wepClass == "mur_hands" then
							allowed = true
						end
						
						if not allowed then
							ply:StripWeapon(wepClass)
						end
					end
				end
			end
		end
		

		local alivePlayers = MuR:GetAlivePlayers()
		if #alivePlayers == 1 and IsValid(alivePlayers[1]) then
			local winner = alivePlayers[1]
			if not winner.Mode50Rewarded then
				winner.Mode50Rewarded = true
				winner:AddMoney(100)
				MuR:GiveAnnounce("legion_victory", winner)
			end
		end
	end,
	OnModeEnded = function(mode)

		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) then
				ply.Mode50Rewarded = nil
			end
		end
	end
})
