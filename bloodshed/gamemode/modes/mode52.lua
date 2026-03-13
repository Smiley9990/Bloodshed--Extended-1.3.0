MuR.RegisterMode(52, {
	name = "ScenarioWithRoleChoice",
	chance = 100,
	need_players = 2,
	kteam = "Killer",
	dteam = "Defender",
	iteam = "Innocent",
	roles = {
		{class = "Medic", odds = 3, min_players = 5},
		{class = "Builder", odds = 3, min_players = 5},
		{class = "HeadHunter", odds = 4, min_players = 6},
		{class = "Criminal", odds = 5, min_players = 6},
		{class = "Security", odds = 3, min_players = 6},
		{class = "Witness", odds = 3, min_players = 6},
		{class = "Officer", odds = 8, min_players = 7},
		{class = "FBI", odds = 8, min_players = 7}
	},
	OnModePrecache = function(mode)
		if CLIENT then
			Material("murdered/modes/gamemodess3.png")
			Material("murdered/modes/gamemodess3h.png")
			sound.PlayFile("sound/murdered/theme/gamemodess3.wav", "noplay", function(station)
				if IsValid(station) then
					station:Stop()
				end
			end)
		end
	end,
	OnModeStarted = function(mode)
		if not MuR.Mode52TraitorSelections then
			MuR.Mode52TraitorSelections = {}
		end

		MuR.Mode52TraitorStyles = {
			{
				name = "classic",
				weapons = {"tfa_bs_combk", "tfa_bs_glock_t", "mur_cyanide", "mur_f1", "mur_disguise", "mur_scanner"},
				ammo = {"Pistol", 34}
			},
			{
				name = "demolition",
				weapons = {"tfa_bs_combk", "mur_f1", "mur_scanner", "mur_disguise", "mur_m67", "tfa_codww2k_molotov_vfire", "mur_gasoline", "mur_ied", "mur_c4"},
				ammo = {}
			},
			{
				name = "chemist",
				weapons = {"mur_tranq", "mur_disguise", "mur_scanner", "mur_cyanide", "mur_bredogen", "mur_cyanide_sneeze", "mur_loot_heroin", "mur_acid", "mur_loot_fentanyl", "mur_loot_deadly_fentanyl", "mur_poisoncanister", "mur_loot_ssmanicrage", "tfa_bs_combk", "mur_loot_adrenaline"},
				ammo = {}
			},
			{
				name = "trapper",
				weapons = {"mur_beartrap", "tfa_bs_combk", "mur_disguise", "mur_scanner", "mur_break_tool", "mur_poisoncanister", "mur_drone", "mur_f1", "mur_loot_hammer", "mur_loot_ducttape", "tfa_codww2_betty"},
				ammo = {}
			},
			{
				name = "manipulator",
				weapons = {"mur_traitor_syringe", "mur_cyanide", "tfa_bs_combk", "mur_scanner", "mur_disguise"},
				ammo = {}
			},
			{
				name = "ballistarius",
				weapons = {"tfa_projecthl2_crossbow", "mur_disguise", "mur_scanner", "mur_cyanide", "mur_poisoncanister", "mur_beartrap", "tfa_bs_combk"},
				ammo = {"XBowBolt", 10}
			}
		}

		timer.Simple(2, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 52 then return end

			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then
					local playerClass = ply:GetNW2String("Class", "")
					if playerClass == "Traitor" or playerClass == "Killer" then
						net.Start("MuR.Mode52StyleSelection")
						net.Send(ply)
						ply.Mode52StyleSelectionTime = CurTime() + 10
					end
				end
			end
		end)

		timer.Simple(12, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 52 then return end

			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then
					local playerClass = ply:GetNW2String("Class", "")
					if playerClass == "Traitor" or playerClass == "Killer" then
						local selectedStyle = MuR.Mode52TraitorSelections[ply:SteamID64()] or math.random(1, 6)

						for _, wep in ipairs(ply:GetWeapons()) do
							if IsValid(wep) and wep:GetClass() != "mur_hands" then
								ply:StripWeapon(wep:GetClass())
							end
						end

						local style = MuR.Mode52TraitorStyles[selectedStyle]
						if style then
							for _, weapon in ipairs(style.weapons) do
								ply:GiveWeapon(weapon)
							end
							for i = 1, #style.ammo, 2 do
								if style.ammo[i] and style.ammo[i+1] then
									ply:GiveAmmo(style.ammo[i+1], style.ammo[i], true)
								end
							end
						end

						ply:SetNW2Int("Mode52SelectedStyle", selectedStyle)
						ply.Mode52StyleSelectionTime = nil
					end
				end
			end
		end)
	end,
	OnModeEnded = function(mode)
		MuR.Mode52TraitorSelections = {}
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) then
				ply.Mode52StyleSelectionTime = nil
			end
		end
	end
})
