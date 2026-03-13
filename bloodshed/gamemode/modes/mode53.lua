MuR.RegisterMode(53, {
	name = "Maniac",
	chance = 40,
	need_players = 2,
	disable_loot = true,
	disables_police = true,
	no_guilt = true,
	timer = 300,
	kteam = "Tagila",
	dteam = "PMC",
	iteam = "Wilds",
	roles = {},
	OnModePrecache = function(mode)

		if CLIENT then

			Material("murdered/modes/gamemodess4.png")
			Material("murdered/modes/gamemodess4h.png")

			sound.PlayFile("sound/murdered/theme/gamemodess4.wav", "noplay", function(station)
				if IsValid(station) then
					station:Stop()
				end
			end)
		end
	end,
	OnModeStarted = function(mode)

		if not MuR.Mode53TeamSelections then
			MuR.Mode53TeamSelections = {}
		end
		

		local tagilaPlayer = nil
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply:GetNW2String("Class") == "Tagila" then
				tagilaPlayer = ply
				break
			end
		end
		

		if not IsValid(tagilaPlayer) then
			local allPlayers = player.GetAll()
			if #allPlayers > 0 then
				tagilaPlayer = table.Random(allPlayers)
				tagilaPlayer:SetNW2String("Class", "Tagila")
				tagilaPlayer:Spawn()
				tagilaPlayer:Freeze(true)
				tagilaPlayer:GodEnable()
				
				timer.Simple(12, function()
					if IsValid(tagilaPlayer) then
						tagilaPlayer:Freeze(false)
						tagilaPlayer:GodDisable()
					end
				end)
			end
		end
		

		if IsValid(tagilaPlayer) then

			MuR.Mode53TagilaBadworkPlayed = false
			

			local tagilaNormalSounds = {
				"murdered/player/tagilla/tagilla_enemy_01.wav",
				"murdered/player/tagilla/tagilla_enemy_02.wav",
				"murdered/player/tagilla/tagilla_enemy_03.wav",
				"murdered/player/tagilla/tagilla_enemy_bear_01.wav",
				"murdered/player/tagilla/tagilla_enemy_bear_02.wav",
				"murdered/player/tagilla/tagilla_enemy_bear_03.wav",
				"murdered/player/tagilla/tagilla_fight_start_01.wav",
				"murdered/player/tagilla/tagilla_fight_start_02.wav",
				"murdered/player/tagilla/tagilla_fight_start_03.wav",
				"murdered/player/tagilla/tagilla_fight_start_04.wav",
				"murdered/player/tagilla/tagilla_fight_start_05.wav",
				"murdered/player/tagilla/tagilla_fight_start_06.wav",
				"murdered/player/tagilla/tagilla_fight_start_07.wav",
				"murdered/player/tagilla/tagilla_fight_start_08.wav",
				"murdered/player/tagilla/tagilla_lost_visual_n_01.wav",
				"murdered/player/tagilla/tagilla_lost_visual_n_02.wav",
				"murdered/player/tagilla/tagilla_lost_visual_n_03.wav"
			}
			

			local tagilaBadworkSounds = {
				"murdered/player/tagilla/tagilla_badwork_01.wav",
				"murdered/player/tagilla/tagilla_badwork_02.wav"
			}
			

			local function PlayTagilaSound()
				if not MuR.GameStarted or MuR.Gamemode ~= 53 then 
					timer.Remove("MuR.Mode53TagilaSound")
					return 
				end
				

				local tagila = nil
				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) and ply:GetNW2String("Class") == "Tagila" and ply:Alive() then
						tagila = ply
						break
					end
				end
				
				if not IsValid(tagila) then 
					timer.Remove("MuR.Mode53TagilaSound")
					return 
				end
				

				local maxHealth = tagila:GetMaxHealth()
				local currentHealth = tagila:Health()
				local healthPercent = (currentHealth / maxHealth) * 100
				
				local soundToPlay = nil
				

				if healthPercent < 50 and not MuR.Mode53TagilaBadworkPlayed then
					soundToPlay = tagilaBadworkSounds[math.random(#tagilaBadworkSounds)]
					MuR.Mode53TagilaBadworkPlayed = true
				elseif healthPercent >= 50 then

					MuR.Mode53TagilaBadworkPlayed = false
					soundToPlay = tagilaNormalSounds[math.random(#tagilaNormalSounds)]
				else

					soundToPlay = tagilaNormalSounds[math.random(#tagilaNormalSounds)]
				end
				

				if soundToPlay then

					tagila:EmitSound(soundToPlay, 100, 100, 1)
				end
			end
			

			timer.Simple(10, function()
				if not MuR.GameStarted or MuR.Gamemode ~= 53 then return end
				

				PlayTagilaSound()
				

				timer.Create("MuR.Mode53TagilaSound", 10, 0, function()
					PlayTagilaSound()
				end)
			end)
		end
		

		timer.Simple(3, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 53 then return end
			
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then
					local playerClass = ply:GetNW2String("Class", "")

					if playerClass != "Tagila" then

						net.Start("MuR.Mode53TeamSelection")
						net.Send(ply)
						

						ply.Mode53TeamSelectionTime = CurTime() + 21
					end
				end
			end
			

			local voteUpdateTimer = timer.Create("MuR.Mode53VoteUpdate", 1, 0, function()
				if not MuR.GameStarted or MuR.Gamemode ~= 53 then 
					timer.Remove("MuR.Mode53VoteUpdate")
					return 
				end
				

				local oneTeamVotes = 0
				local twoTeamsVotes = 0
				local totalVoters = 0
				
				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) and ply:GetNW2String("Class") != "Tagila" then
						totalVoters = totalVoters + 1
						local choice = MuR.Mode53TeamSelections[ply:SteamID64()]
						if choice == 1 then
							oneTeamVotes = oneTeamVotes + 1
						elseif choice == 2 then
							twoTeamsVotes = twoTeamsVotes + 1
						end
					end
				end
				

				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) and ply:Alive() and ply:GetNW2String("Class") != "Tagila" then
						net.Start("MuR.Mode53VoteStats")
						net.WriteInt(oneTeamVotes, 8)
						net.WriteInt(twoTeamsVotes, 8)
						net.WriteInt(totalVoters, 8)
						net.Send(ply)
					end
				end
			end)
			

			timer.Simple(21, function()
			if not MuR.GameStarted or MuR.Gamemode ~= 53 then return end
			

			local oneTeamVotes = 0
			local twoTeamsVotes = 0
			
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:GetNW2String("Class") != "Tagila" then
					local choice = MuR.Mode53TeamSelections[ply:SteamID64()]
					if choice == 1 then
						oneTeamVotes = oneTeamVotes + 1
					elseif choice == 2 then
						twoTeamsVotes = twoTeamsVotes + 1
					end
				end
			end
			

			local useTwoTeams = twoTeamsVotes > oneTeamVotes
			

			MuR.Mode53UseTwoTeams = useTwoTeams
			

			local function GiveMode53Loadout(ply, isPMC)
				if not IsValid(ply) or not ply:Alive() then return end
				

				local pmcPrimaryWeapons = {
					"tfa_bs_rpk",
					"tfa_bs_nova",
					"tfa_bs_m1014",
					"tfa_bs_mp7",
					"tfa_bs_mp5a5",
					"tfa_bs_vector",
					"tfa_bs_ak12",
					"tfa_bs_val",
					"tfa_bs_aug",
					"tfa_bs_hk416",
					"tfa_bs_badger"
				}
				
				local pmcPistols = {
					"tfa_bs_m9",
					"tfa_bs_colt",
					"tfa_bs_usp",
					"tfa_bs_walther"
				}
				
				local wildsPrimaryWeapons = {
					"tfa_bs_pkm",
					"tfa_bs_m500",
					"tfa_bs_spas",
					"tfa_bs_mac11",
					"tfa_bs_uzi",
					"tfa_bs_ump",
					"tfa_bs_ak74",
					"tfa_bs_akm",
					"tfa_bs_aks74u",
					"tfa_bs_l1a1",
					"tfa_bs_g3",
					"tfa_bs_sg552"
				}
				
				local wildsPistols = {
					"tfa_bs_glock",
					"tfa_bs_deagle",
					"tfa_bs_pm",
					"tfa_bs_p320"
				}
				

				local primaryWeapon = nil
				local pistol = nil
				
				if isPMC then
					primaryWeapon = pmcPrimaryWeapons[math.random(#pmcPrimaryWeapons)]
					pistol = pmcPistols[math.random(#pmcPistols)]
				else
					primaryWeapon = wildsPrimaryWeapons[math.random(#wildsPrimaryWeapons)]
					pistol = wildsPistols[math.random(#wildsPistols)]
				end
				

				local savedPrimaryWeapon = primaryWeapon
				local savedPistol = pistol
				

				ply:StripWeapons()
				ply:StripAmmo()
				

				timer.Simple(0.1, function()
					if not IsValid(ply) or not ply:Alive() then return end
					

					if savedPrimaryWeapon then
						ply:GiveWeapon(savedPrimaryWeapon)
					end
					if savedPistol then
						ply:GiveWeapon(savedPistol)
					end
					

					ply:GiveWeapon("mur_loot_medkit")
					

					timer.Simple(0.4, function()
						if not IsValid(ply) or not ply:Alive() then return end
						

						local primaryWep = ply:GetWeapon(savedPrimaryWeapon)
						if IsValid(primaryWep) then
							local ammoType = primaryWep:GetPrimaryAmmoType()
							if ammoType and ammoType > 0 then
								local clipSize = primaryWep:GetMaxClip1() or 30
								local ammoToGive = math.max(clipSize * 3, 90)
								ply:GiveAmmo(ammoToGive, ammoType, true)
							end
						end
						

						local pistolWep = ply:GetWeapon(savedPistol)
						if IsValid(pistolWep) then
							local ammoType = pistolWep:GetPrimaryAmmoType()
							if ammoType and ammoType > 0 then
								local clipSize = pistolWep:GetMaxClip1() or 15
								local ammoToGive = math.max(clipSize * 3, 45)
								ply:GiveAmmo(ammoToGive, ammoType, true)
							end
						end
					end)
				end)
				

				ply:SetMaxHealth(100)
				ply:SetHealth(100)
				ply:SetWalkSpeed(100)
				ply:SetRunSpeed(280)
			end
			

			local remainingPlayers = {}
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:GetNW2String("Class") != "Tagila" then
					table.insert(remainingPlayers, ply)
				end
			end
			
			if useTwoTeams then

				local pmcCount = math.floor(#remainingPlayers / 2)
				local shuffled = {}
				for _, ply in ipairs(remainingPlayers) do
					table.insert(shuffled, ply)
				end
				

				for i = #shuffled, 2, -1 do
					local j = math.random(i)
					shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
				end
				

				local pmcPlayers = {}
				local wildsPlayers = {}
				
				for i, ply in ipairs(shuffled) do
					if IsValid(ply) then
						if i <= pmcCount then
							table.insert(pmcPlayers, ply)
						else
							table.insert(wildsPlayers, ply)
						end
					end
				end
				

				local function GetSpawnPoints()
					local spawnPoints = {}
					local spawnClasses = {
						"info_player_start", "info_player_deathmatch", "info_player_combine",
						"info_player_rebel", "info_player_counterterrorist", "info_player_terrorist",
						"info_player_axis", "info_player_allies", "gmod_player_start",
						"info_player_teamspawn"
					}
					for _, classname in ipairs(spawnClasses) do
						for _, ent in ipairs(ents.FindByClass(classname)) do
							if IsValid(ent) then
								table.insert(spawnPoints, ent)
							end
						end
					end
					if #spawnPoints == 0 then
						for _, ent in ipairs(ents.FindByClass("info_player_start")) do
							if IsValid(ent) then
								table.insert(spawnPoints, ent)
							end
						end
					end
					return spawnPoints
				end
				

				local function FindTeamSpawnPoint(allSpawnPoints, avoidPos, minDistance)
					if #allSpawnPoints == 0 then return nil end
					

					local shuffledSpawns = {}
					for _, sp in ipairs(allSpawnPoints) do
						table.insert(shuffledSpawns, sp)
					end
					for i = #shuffledSpawns, 2, -1 do
						local j = math.random(i)
						shuffledSpawns[i], shuffledSpawns[j] = shuffledSpawns[j], shuffledSpawns[i]
					end
					

					if avoidPos and minDistance then
						local validSpawns = {}
						for _, spawn in ipairs(shuffledSpawns) do
							if IsValid(spawn) then
								local spawnPos = spawn:GetPos()
								local dist = spawnPos:Distance(avoidPos)
								if dist >= minDistance then
									table.insert(validSpawns, spawn)
								end
							end
						end
						

						if #validSpawns > 0 then
							return validSpawns[math.random(#validSpawns)]
						end
						

						local bestSpawn = nil
						local maxDist = 0
						for _, spawn in ipairs(shuffledSpawns) do
							if IsValid(spawn) then
								local dist = spawn:GetPos():Distance(avoidPos)
								if dist > maxDist then
									maxDist = dist
									bestSpawn = spawn
								end
							end
						end
						return bestSpawn
					end
					

					return shuffledSpawns[math.random(#shuffledSpawns)]
				end
				

				local function GetValidSpawnPosition(centerPos, radius, attempt)
					attempt = attempt or 1
					if attempt > 10 then
						return centerPos
					end
					
					local angle = math.random() * math.pi * 2
					local distance = math.random() * radius
					local offset = Vector(
						math.cos(angle) * distance,
						math.sin(angle) * distance,
						0
					)
					local newPos = centerPos + offset
					
					local trace = util.TraceLine({
						start = newPos + Vector(0, 0, 50),
						endpos = newPos - Vector(0, 0, 200),
						mask = MASK_SOLID_BRUSHONLY
					})
					
					if trace.Hit then
						local finalPos = trace.HitPos + Vector(0, 0, 10)
						local traceUp = util.TraceLine({
							start = finalPos,
							endpos = finalPos + Vector(0, 0, 100),
							mask = MASK_SOLID_BRUSHONLY
						})
						if not traceUp.Hit then
							return finalPos
						end
					end
					
					return GetValidSpawnPosition(centerPos, radius, attempt + 1)
				end
				

				local allSpawnPoints = GetSpawnPoints()
				

				local pmcSpawnPoint = FindTeamSpawnPoint(allSpawnPoints, nil, nil)
				local pmcSpawnPos = pmcSpawnPoint and pmcSpawnPoint:GetPos() or Vector(0, 0, 0)
				local pmcSpawnRadius = 200
				

				for i, ply in ipairs(pmcPlayers) do
					if IsValid(ply) then
						local savedHealth = ply:Alive() and ply:Health() or 100
						ply:GodEnable()
						ply:SetNW2String("Class", "PMC")
						ply:Spawn()
						ply:Freeze(true)
						local spawnPos = GetValidSpawnPosition(pmcSpawnPos, pmcSpawnRadius)
						ply:SetPos(spawnPos)
						timer.Simple(0.5, function()
							if IsValid(ply) and ply:Alive() then
								GiveMode53Loadout(ply, true)
								ply:SetMaxHealth(100)
								ply:SetHealth(100)
								ply:SetWalkSpeed(100)
								ply:SetRunSpeed(280)
							end
						end)
						timer.Simple(0.1, function()
							if IsValid(ply) then
								if not ply:Alive() then
									ply:GodEnable()
									ply:Spawn()
									ply:Freeze(true)
									local respawnPos = GetValidSpawnPosition(pmcSpawnPos, pmcSpawnRadius)
									ply:SetPos(respawnPos)
									timer.Simple(0.5, function()
										if IsValid(ply) and ply:Alive() then
											GiveMode53Loadout(ply, true)
											ply:SetMaxHealth(100)
											ply:SetHealth(100)
											ply:SetWalkSpeed(100)
											ply:SetRunSpeed(280)
										end
									end)
								end
								ply:SetHealth(math.max(savedHealth, 100))
							end
						end)
					end
				end
				

				local wildsSpawnPoint = FindTeamSpawnPoint(allSpawnPoints, pmcSpawnPos, 500)
				local wildsSpawnPos = wildsSpawnPoint and wildsSpawnPoint:GetPos() or (pmcSpawnPos + Vector(500, 0, 0))
				local wildsSpawnRadius = 200
				

				for i, ply in ipairs(wildsPlayers) do
					if IsValid(ply) then
						local savedHealth = ply:Alive() and ply:Health() or 100
						ply:GodEnable()
						ply:SetNW2String("Class", "Wilds")
						ply:Spawn()
						ply:Freeze(true)
						local spawnPos = GetValidSpawnPosition(wildsSpawnPos, wildsSpawnRadius)
						ply:SetPos(spawnPos)
						timer.Simple(0.5, function()
							if IsValid(ply) and ply:Alive() then
								GiveMode53Loadout(ply, false)
								ply:SetMaxHealth(100)
								ply:SetHealth(100)
								ply:SetWalkSpeed(100)
								ply:SetRunSpeed(280)
							end
						end)
						timer.Simple(0.1, function()
							if IsValid(ply) then
								if not ply:Alive() then
									ply:GodEnable()
									ply:Spawn()
									ply:Freeze(true)
									local respawnPos = GetValidSpawnPosition(wildsSpawnPos, wildsSpawnRadius)
									ply:SetPos(respawnPos)
									timer.Simple(0.5, function()
										if IsValid(ply) and ply:Alive() then
											GiveMode53Loadout(ply, false)
											ply:SetMaxHealth(100)
											ply:SetHealth(100)
											ply:SetWalkSpeed(100)
											ply:SetRunSpeed(280)
										end
									end)
								end
								ply:SetHealth(math.max(savedHealth, 100))
							end
						end)
					end
				end
			else

				local function GetSpawnPoints()
					local spawnPoints = {}
					local spawnClasses = {
						"info_player_start", "info_player_deathmatch", "info_player_combine",
						"info_player_rebel", "info_player_counterterrorist", "info_player_terrorist",
						"info_player_axis", "info_player_allies", "gmod_player_start",
						"info_player_teamspawn"
					}
					for _, classname in ipairs(spawnClasses) do
						for _, ent in ipairs(ents.FindByClass(classname)) do
							if IsValid(ent) then
								table.insert(spawnPoints, ent)
							end
						end
					end
					if #spawnPoints == 0 then
						for _, ent in ipairs(ents.FindByClass("info_player_start")) do
							if IsValid(ent) then
								table.insert(spawnPoints, ent)
							end
						end
					end
					return spawnPoints
				end
				
				local function GetValidSpawnPosition(centerPos, radius, attempt)
					attempt = attempt or 1
					if attempt > 10 then return centerPos end
					local angle = math.random() * math.pi * 2
					local distance = math.random() * radius
					local offset = Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)
					local newPos = centerPos + offset
					local trace = util.TraceLine({
						start = newPos + Vector(0, 0, 50),
						endpos = newPos - Vector(0, 0, 200),
						mask = MASK_SOLID_BRUSHONLY
					})
					if trace.Hit then
						local finalPos = trace.HitPos + Vector(0, 0, 10)
						local traceUp = util.TraceLine({
							start = finalPos,
							endpos = finalPos + Vector(0, 0, 100),
							mask = MASK_SOLID_BRUSHONLY
						})
						if not traceUp.Hit then return finalPos end
					end
					return GetValidSpawnPosition(centerPos, radius, attempt + 1)
				end
				
				local allSpawnPoints = GetSpawnPoints()
				local teamSpawnPoint = (#allSpawnPoints > 0) and allSpawnPoints[math.random(#allSpawnPoints)] or nil
				local teamSpawnPos = teamSpawnPoint and teamSpawnPoint:GetPos() or Vector(0, 0, 0)
				local teamSpawnRadius = 200
				
				for _, ply in ipairs(remainingPlayers) do
					if IsValid(ply) then
						local savedHealth = ply:Alive() and ply:Health() or 100
						ply:GodEnable()
						ply:SetNW2String("Class", "PMC")
						ply:Spawn()
						ply:Freeze(true)
						local spawnPos = GetValidSpawnPosition(teamSpawnPos, teamSpawnRadius)
						ply:SetPos(spawnPos)
						timer.Simple(0.5, function()
							if IsValid(ply) and ply:Alive() then
								GiveMode53Loadout(ply, true)
								ply:SetMaxHealth(100)
								ply:SetHealth(100)
								ply:SetWalkSpeed(100)
								ply:SetRunSpeed(280)
							end
						end)
						timer.Simple(0.1, function()
							if IsValid(ply) then
								if not ply:Alive() then
									ply:GodEnable()
									ply:Spawn()
									ply:Freeze(true)
									local respawnPos = GetValidSpawnPosition(teamSpawnPos, teamSpawnRadius)
									ply:SetPos(respawnPos)
									timer.Simple(0.5, function()
										if IsValid(ply) and ply:Alive() then
											GiveMode53Loadout(ply, true)
											ply:SetMaxHealth(100)
											ply:SetHealth(100)
											ply:SetWalkSpeed(100)
											ply:SetRunSpeed(280)
										end
									end)
								end
								ply:SetHealth(math.max(savedHealth, 100))
							end
						end)
					end
				end
			end
			

			timer.Remove("MuR.Mode53VoteUpdate")
			
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) then
					ply.Mode53TeamSelectionTime = nil
				end
			end
			

			timer.Simple(1, function()
				for _, ply in ipairs(player.GetAll()) do
					if IsValid(ply) then
						net.Start("MuR.Mode53CloseStartScreen")
						net.Send(ply)
					end
				end
				
				timer.Simple(0.1, function()
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply:Alive() then
							local playerClass = ply:GetNW2String("Class", "")
							if playerClass == "PMC" or playerClass == "Wilds" or playerClass == "Tagila" then
								ply:Freeze(false)
								timer.Simple(0.5, function()
									if IsValid(ply) then
										ply:GodDisable()
									end
								end)
							end
						end
					end
				end)
			end)
			end)
		end)
	end,
	OnModeEnded = function(mode)
		timer.Remove("MuR.Mode53VoteUpdate")
		timer.Remove("MuR.Mode53TagilaSound")
		MuR.Mode53TeamSelections = {}
		MuR.Mode53UseTwoTeams = nil
		MuR.Mode53TagilaBadworkPlayed = nil
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) then
				ply.Mode53TeamSelectionTime = nil

				if ply:GetNW2String("Class") == "Tagila" then
					ply:SetModelScale(1, 0)
				end
			end
		end
	end
})
