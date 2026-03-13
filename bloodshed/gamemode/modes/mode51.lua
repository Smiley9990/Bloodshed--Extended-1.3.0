MuR.RegisterMode(51, {
	name = "INFENTIBLE",
	chance = 100,
	need_players = 2,
	disable_loot = true,
	disables = true,
	no_guilt = true,
	timer = 300,
	kteam = "GeorgeDroidFloyd",
	dteam = "FailedDrugDealer",
	iteam = "FailedDrugDealer",
	OnModePrecache = function(mode)

		if CLIENT then

			Material("murdered/modes/gamemodess2.png")
			Material("murdered/modes/gamemodess2h.png")

			sound.PlayFile("sound/murdered/theme/gamemodess2.wav", "noplay", function(station)
				if IsValid(station) then
					station:Stop()
				end
			end)
		end
	end,
	OnModeStarted = function(mode)

		if SERVER then
			local floyd = nil
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:GetNW2String("Class") == "GeorgeDroidFloyd" then
					floyd = ply
					break
				end
			end

			if IsValid(floyd) then
				local floydSounds = {
					"murdered/player/floyd/floyd1.wav",
					"murdered/player/floyd/floyd2.wav",
					"murdered/player/floyd/floyd3.wav"
				}

				local function PlayFloydSound()
					if not MuR.GameStarted or MuR.Gamemode ~= 51 then
						timer.Remove("MuR.Mode51FloydSound")
						return
					end

					local floyd = nil
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply:GetNW2String("Class") == "GeorgeDroidFloyd" and ply:Alive() then
							floyd = ply
							break
						end
					end

					if not IsValid(floyd) then
						timer.Remove("MuR.Mode51FloydSound")
						return
					end

					local soundToPlay = floydSounds[math.random(#floydSounds)]
					if soundToPlay then
						floyd:EmitSound(soundToPlay, 100, 100, 1)
					end
				end

				timer.Simple(7, function()
					if not MuR.GameStarted or MuR.Gamemode ~= 51 then return end

					PlayFloydSound()

					timer.Create("MuR.Mode51FloydSound", 7, 0, function()
						PlayFloydSound()
					end)
				end)
			end
		end
	end,
	OnModeThink = function(mode)
		if not MuR.GameStarted or MuR.Gamemode ~= 51 then return end

		local floyd = nil
		local dealers = {}

		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() then
				local class = ply:GetNW2String("Class", "")
				if class == "GeorgeDroidFloyd" then
					floyd = ply
				elseif class == "FailedDrugDealer" then
					table.insert(dealers, ply)
				end
			end
		end

		if not IsValid(floyd) or not floyd:Alive() then
			if #dealers > 0 and not MuR.Mode51DealersWon then
				MuR.Mode51DealersWon = true
				for _, dealer in ipairs(dealers) do
					if IsValid(dealer) then
						dealer:AddMoney(100)
						MuR:GiveAnnounce("infentible_dealers_win", dealer)
					end
				end
				MuR.Delay_Before_Lose = CurTime() + 3
			end
			return
		end

		if #dealers == 0 and IsValid(floyd) and not MuR.Mode51FloydWon then
			MuR.Mode51FloydWon = true
			floyd:AddMoney(100)
			MuR:GiveAnnounce("infentible_floyd_win", floyd)
			MuR.Delay_Before_Lose = CurTime() + 3
			return
		end
	end,
	OnModeEnded = function(mode)
		if SERVER then
			timer.Remove("MuR.Mode51FloydSound")

			MuR.Mode51FloydWon = nil
			MuR.Mode51DealersWon = nil
		end
	end
})
