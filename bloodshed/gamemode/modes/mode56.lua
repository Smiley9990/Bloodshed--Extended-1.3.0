if SERVER then
	for _, snd in ipairs({"stopmusic.mp3", "bravo6.mp3", "russianmafia.mp3", "pmcraid.mp3", "randomstart1.mp3", "randomstart2.mp3", "randomstart3.mp3", "randomstart4.mp3", "randomstart5.mp3"}) do
		if file.Exists("sound/murdered/hotline/" .. snd, "GAME") then
			resource.AddFile("sound/murdered/hotline/" .. snd)
		end
	end
	if file.Exists("materials/murdered/hotline/okpc.png", "GAME") then
		resource.AddFile("materials/murdered/hotline/okpc.png")
	end
	if file.Exists("materials/murdered/hotline/masskahm.png", "GAME") then
		resource.AddFile("materials/murdered/hotline/masskahm.png")
	end
	if file.Exists("materials/murdered/hotline/SSmiley.png", "GAME") then
		resource.AddFile("materials/murdered/hotline/SSmiley.png")
	end
	if file.Exists("resource/fonts/retro_computer_personal_use.ttf", "GAME") then
		resource.AddFile("resource/fonts/retro_computer_personal_use.ttf")
	end
	if file.Exists("models/drm/hotline_miami/the_son/the_son.mdl", "GAME") then
		resource.AddFile("models/drm/hotline_miami/the_son/the_son.mdl")
	end
	for _, m in ipairs({"mafia02pm", "mafia04pm", "mafia06pm", "mafia07pm", "mafia08pm", "mafia09pm"}) do
		if file.Exists("models/hotlinemiami/russianmafia/" .. m .. ".mdl", "GAME") then
			resource.AddFile("models/hotlinemiami/russianmafia/" .. m .. ".mdl")
		end
	end
	for i = 1, 9 do
		local m = "models/murdered/pm/swat/male_0" .. i .. ".mdl"
		if file.Exists(m, "GAME") then resource.AddFile(m) end
	end
	for i = 1, 9 do
		local m = "models/murdered/pm/pmc/male_0" .. i .. ".mdl"
		if file.Exists(m, "GAME") then resource.AddFile(m) end
	end
end

MuR.RegisterMode(56, {
	name = "Hotline Miami: Extended",
	chance = 10,
	need_players = 2,
	custom_spawning = true,
	kteam = "Tony",
	dteam = "Mafia",
	iteam = "Mafia",
	disables_police = true,
    no_guilt = true,
    disables = true,
    disable_loot = true,
    timer = 600,

	spawn_type = "tdm",
	win_condition = "tdm",
	kteam_count = 1,
	tdm_end_logic = true,
	win_screen_team1 = "tony",
	win_screen_team2 = "mafia",

	OnModeStarted = function(mode)
		if SERVER then
			MuR.Mode56 = {}
			if MuR.NextMode56InitialSender then
				MuR.Mode56.InitialSender = MuR.NextMode56InitialSender
				MuR.NextMode56InitialSender = nil
			else
				MuR.Mode56.InitialSender = math.random() < 0.5 and "SSmiley" or "MaSSka"
			end

			timer.Simple(2, function()
				if not MuR.GameStarted or MuR.Gamemode ~= 56 then return end
				net.Start("MuR.Mode56.StartMusic")
				net.WriteUInt(math.random(1, 5), 3)
				net.Broadcast()
			end)

			timer.Simple(13, function()
				if not MuR.GameStarted or MuR.Gamemode ~= 56 then return end
				local useSSmiley = (MuR.Mode56.InitialSender == "SSmiley")
				for _, ply in player.Iterator() do
					if not IsValid(ply) then continue end
					local cls = ply:GetNW2String("Class")
					if cls ~= "Tony" and cls ~= "Mafia" then continue end
					if cls == "Tony" then
						local text, fromName
						if useSSmiley then
							text = "Отлично, ты на месте " .. ply:Nick() .. ", убей всех, только не ПРОЕБИСЬ!!! ПОНЯЛ?"
							fromName = "SSmiley"
						else
							text = "ЧУВАК! Я БЛЯ НЕНАВИЖУ ЭТУ МАФИЮ, ГРОХНИ ИХ УЖЕ!"
							fromName = "MaSSka"
						end
						net.Start("MuR.Mode56.MaSSkaMessage")
						net.WriteString(text)
						net.WriteString(fromName)
						net.WriteString("")
						net.WriteString("")
						net.Send(ply)
					elseif cls == "Mafia" then

						net.Start("MuR.Mode56.MaSSkaMessage")
						net.WriteString("Алё? Алё алё, ребятки не проебитесь, никто мимо вас не должен пройти! Не допускайте ПРОЁБА!!!")
						net.WriteString("Mafia")
						net.WriteString("")
						net.WriteString("")
						net.Send(ply)
					end
				end
			end)
		end
	end,

	OnModeThink = function(mode)
		if SERVER then
			for _, ply in player.Iterator() do
				if ply:GetNW2String("Class") == "Tony" then
					ply:SetNW2Float("Stamina", 100)
					ply.BleedTime = 0
				end
			end

			if MuR.Mode56 and not MuR.Mode56.ReinforcementsScheduled then
				local team1_alive, team2_alive = 0, 0
				for _, v in player.Iterator() do
					if v:Alive() then
						if v:Team() == 1 then team1_alive = team1_alive + 1 end
						if v:Team() == 2 or v:Team() == 3 then team2_alive = team2_alive + 1 end
					end
				end
				if team1_alive > 0 and team2_alive == 0 then
					MuR.Mode56.ReinforcementsScheduled = true
					MuR.Delay_Before_Lose = CurTime() + 18
					local types = {"RussianMafia", "Bravo6", "PMC"}
					if MuR.NextMode56ReinforcementType then
						MuR.Mode56.ReinforcementType = MuR.NextMode56ReinforcementType
						MuR.NextMode56ReinforcementType = nil
					else
						MuR.Mode56.ReinforcementType = types[math.random(#types)]
					end

					local fromName = MuR.Mode56.InitialSender or "MaSSka"
					local reinfType = MuR.Mode56.ReinforcementType or "RussianMafia"
					local messages = {
						MaSSka = {
							RussianMafia = "Чёрт! Чувак они лично приехали тебя грохнуть! это не к добру, выберайся от туда!",
							Bravo6 = "Твою мать, дружище дела плохи, прибыл спецназ, выберайся от туда как можно скорее!",
							PMC = "Чувак! Тебя нашли! ЧВК уже тут, тебе нужно срочно выбераться от туда!"
						},
						SSmiley = {
							RussianMafia = "Бля, ты так долго работаешь что они уже подкрепление приехало! Ты никчёмный наёмник",
							Bravo6 = "Ты ёбаный дилетант, не справился до прибытия мусоров! Если тебя не станет будет только лучше",
							PMC = "Живой еще? Отлично, я тут решил небольшой гешефт провернуть, со мной связались твои старые \"ДРУЗЬЯ\", и очень хотят снова тебя увидеть, Очень просили передать, что скоро нагрянут с ответным визитом, так что... не мешайся больше"
						}
					}
					local text = messages[fromName] and messages[fromName][reinfType] or "Приготовься!"
					for _, ply in player.Iterator() do
						if IsValid(ply) and ply:Alive() and ply:GetNW2String("Class") == "Tony" then
							net.Start("MuR.Mode56.MaSSkaMessage")
							net.WriteString(text)
							net.WriteString(fromName)
							net.WriteString("")
							net.WriteString("")
							net.Send(ply)
						end
					end

					local RUSSIAN_MAFIA_MODELS = {
						"models/hotlinemiami/russianmafia/mafia02pm.mdl",
						"models/hotlinemiami/russianmafia/mafia04pm.mdl",
						"models/hotlinemiami/russianmafia/mafia06pm.mdl",
						"models/hotlinemiami/russianmafia/mafia07pm.mdl",
						"models/hotlinemiami/russianmafia/mafia08pm.mdl",
						"models/hotlinemiami/russianmafia/mafia09pm.mdl"
					}
					local BRAVO6_MODELS = {
						"models/murdered/pm/swat/male_01.mdl",
						"models/murdered/pm/swat/male_02.mdl",
						"models/murdered/pm/swat/male_03.mdl",
						"models/murdered/pm/swat/male_04.mdl",
						"models/murdered/pm/swat/male_05.mdl",
						"models/murdered/pm/swat/male_06.mdl",
						"models/murdered/pm/swat/male_07.mdl",
						"models/murdered/pm/swat/male_08.mdl",
						"models/murdered/pm/swat/male_09.mdl"
					}
					local PMC_MODELS = {
						"models/murdered/pm/pmc/male_01.mdl",
						"models/murdered/pm/pmc/male_02.mdl",
						"models/murdered/pm/pmc/male_03.mdl",
						"models/murdered/pm/pmc/male_04.mdl",
						"models/murdered/pm/pmc/male_05.mdl",
						"models/murdered/pm/pmc/male_06.mdl",
						"models/murdered/pm/pmc/male_07.mdl",
						"models/murdered/pm/pmc/male_08.mdl",
						"models/murdered/pm/pmc/male_09.mdl"
					}

					timer.Simple(10, function()
						if not MuR.GameStarted or MuR.Gamemode ~= 56 then return end

						net.Start("MuR.Mode56.ReinforcementMusic")
						net.WriteString(MuR.Mode56.ReinforcementType or "RussianMafia")
						net.Broadcast()
						local tonyPos
						for _, p in player.Iterator() do
							if IsValid(p) and p:Alive() and p:GetNW2String("Class") == "Tony" then
								tonyPos = p:GetPos()
								break
							end
						end
						local basePos
						if MuR.Mode56ReinforcementSpawnPos then
							basePos = MuR.Mode56ReinforcementSpawnPos
						else
							basePos = (isvector(tonyPos) and MuR.FindNearbySpawnPosition) and MuR:FindNearbySpawnPosition(tonyPos, 400) or MuR:GetRandomPos()
							if not isvector(basePos) then basePos = MuR:GetRandomPos() end
						end

						local mafiaPlayers = {}
						for _, ply in player.Iterator() do
							if IsValid(ply) and ply:GetNW2String("Class") == "Mafia" then
								table.insert(mafiaPlayers, ply)
							end
						end

						local bravoPly, bravoModel, bravoNick
						if MuR.Mode56.ReinforcementType == "Bravo6" and #mafiaPlayers > 0 then
							bravoPly = mafiaPlayers[math.random(#mafiaPlayers)]
							bravoModel = BRAVO6_MODELS[math.random(#BRAVO6_MODELS)]
							if not util.IsValidModel(bravoModel) then bravoModel = "" end
							bravoNick = IsValid(bravoPly) and bravoPly:Nick() or ""
						end
						local pmcPly, pmcModel, pmcNick
						if MuR.Mode56.ReinforcementType == "PMC" and #mafiaPlayers > 0 then
							pmcPly = mafiaPlayers[math.random(#mafiaPlayers)]
							pmcModel = PMC_MODELS[math.random(#PMC_MODELS)]
							if not util.IsValidModel(pmcModel) then pmcModel = "" end
							pmcNick = IsValid(pmcPly) and pmcPly:Nick() or ""
						end

						local reinfClass = (MuR.Mode56.ReinforcementType == "RussianMafia") and "RussianMafia" or (MuR.Mode56.ReinforcementType == "PMC") and "PMC" or "Bravo6"
						for _, ply in ipairs(mafiaPlayers) do
							ply.ForceSpawn = true
							ply:SetNW2String("Class", reinfClass)
							ply:Spawn()

							if MuR.Mode56.ReinforcementType == "Bravo6" then
								local mdl = BRAVO6_MODELS[math.random(#BRAVO6_MODELS)]
								if util.IsValidModel(mdl) then ply:SetModel(mdl) end
							elseif MuR.Mode56.ReinforcementType == "RussianMafia" then
								local mdl = RUSSIAN_MAFIA_MODELS[math.random(#RUSSIAN_MAFIA_MODELS)]
								if util.IsValidModel(mdl) then ply:SetModel(mdl) end
							elseif MuR.Mode56.ReinforcementType == "PMC" then
								local mdl = PMC_MODELS[math.random(#PMC_MODELS)]
								if util.IsValidModel(mdl) then ply:SetModel(mdl) end
							end
							if isvector(basePos) and MuR.FindNearbySpawnPosition then
								local offset = Vector(math.random(-80, 80), math.random(-80, 80), 0)
								local pos = MuR:FindNearbySpawnPosition(basePos + offset, 80)
								if isvector(pos) then
									timer.Simple(0.05, function()
										if IsValid(ply) and ply:Alive() then
											ply:SetPos(pos)
										end
									end)
								end
							end

							if MuR.Mode56.ReinforcementType == "RussianMafia" then
								net.Start("MuR.Mode56.MaSSkaMessage")
								net.WriteString("УБЕЙТЕ ЭТОГО УЁБКА!!! ЭТО ПРОСТО ПИЗДЕЦ!")
								net.WriteString("Mafia")
								net.WriteString("")
								net.WriteString("")
								net.Send(ply)
							end
						end

						if MuR.Mode56.ReinforcementType == "Bravo6" and bravoPly then
							for _, ply in ipairs(mafiaPlayers) do
								net.Start("MuR.Mode56.MaSSkaMessage")
								net.WriteString("это Браво-6. Мы на позиции, подтверждаю выстрелы. Начинаем штурм объекта")
								net.WriteString("Bravo6")
								net.WriteString(bravoModel)
								net.WriteString(bravoNick)
								net.Send(ply)
							end
						end
						if MuR.Mode56.ReinforcementType == "PMC" and pmcPly then
							for _, ply in ipairs(mafiaPlayers) do
								net.Start("MuR.Mode56.MaSSkaMessage")
								net.WriteString("Этот ублюдок попался, не дайте ему уйти, огонь на поражение!")
								net.WriteString("PMC")
								net.WriteString(pmcModel)
								net.WriteString(pmcNick)
								net.Send(ply)
							end
						end
					end)
				end
			end
		end
	end,

	OnModeEnded = function(mode)
		if SERVER then
			MuR.Mode56 = nil
		end
	end
})

if SERVER then

	concommand.Add("mur_mode56_reinforcementspawn", function(ply, cmd, args)
		if not IsValid(ply) then return end
		if args[1] and string.lower(args[1]) == "clear" then
			MuR.Mode56ReinforcementSpawnPos = nil
			ply:ChatPrint("[Mode56] Точка спавна подкрепления сброшена.")
		else
			MuR.Mode56ReinforcementSpawnPos = ply:GetPos()
			ply:ChatPrint("[Mode56] Точка спавна подкрепления установлена: " .. tostring(ply:GetPos()))
		end
	end)
end

if CLIENT then

	local mode56MusicChannel = nil
	net.Receive("MuR.Mode56.StartMusic", function()
		local idx = net.ReadUInt(3)
		if idx < 1 or idx > 5 then idx = 1 end
		if IsValid(mode56MusicChannel) then
			mode56MusicChannel:Stop()
			mode56MusicChannel = nil
		end
		sound.PlayFile("sound/murdered/hotline/randomstart" .. idx .. ".mp3", "noblock", function(ch, e, en)
			if not e and IsValid(ch) then
				mode56MusicChannel = ch
				ch:Play()
				local vol = math.Clamp((GetConVar("snd_musicvolume"):GetFloat() or 1) + 0.25, 0, 1)
				ch:SetVolume(vol)
			end
		end)
	end)

	net.Receive("MuR.Mode56.ReinforcementMusic", function()
		local reinfType = net.ReadString()
		if IsValid(mode56MusicChannel) then
			mode56MusicChannel:Stop()
			mode56MusicChannel = nil
		end
		sound.PlayFile("sound/murdered/hotline/stopmusic.mp3", "noblock", function(channel, err, errname)
			if IsValid(channel) then channel:Play() end
			timer.Simple(1.5, function()
				local musicFile
				if reinfType == "Bravo6" then
					musicFile = "sound/murdered/hotline/bravo6.mp3"
				elseif reinfType == "PMC" then
					musicFile = "sound/murdered/hotline/pmcraid.mp3"
				else
					musicFile = "sound/murdered/hotline/russianmafia.mp3"
				end
				sound.PlayFile(musicFile, "noblock", function(ch, e, en)
					if not e and IsValid(ch) then
						mode56MusicChannel = ch
						ch:Play()
						local vol = math.Clamp((GetConVar("snd_musicvolume"):GetFloat() or 1) + 0.25, 0, 1)
						ch:SetVolume(vol)
					end
				end)
			end)
		end)
	end)
	hook.Add("MuR.OnFinalScreen", "MuR_Mode56_StopMusic", function()
		if IsValid(mode56MusicChannel) then
			mode56MusicChannel:Stop()
			mode56MusicChannel = nil
		end
	end)
	hook.Add("Think", "MuR_Mode56_MusicVolume", function()
		if IsValid(mode56MusicChannel) then
			local vol = math.Clamp((GetConVar("snd_musicvolume"):GetFloat() or 1) + 0.25, 0, 1)
			mode56MusicChannel:SetVolume(vol)
		end
	end)

	local mode56ShaderEnabled = false
	hook.Add("Think", "MuR_Mode56_Shader", function()
		local shouldEnable = (MuR.GamemodeCount == 56)
		if shouldEnable ~= mode56ShaderEnabled then
			mode56ShaderEnabled = shouldEnable
			RunConsoleCommand("pp_hotlinemiamishader", shouldEnable and "1" or "0")
		end
	end)
	hook.Add("MuR.OnFinalScreen", "MuR_Mode56_ShaderOff", function()
		if MuR.GamemodeCount == 56 then
			mode56ShaderEnabled = false
			RunConsoleCommand("pp_hotlinemiamishader", "0")
		end
	end)

	hook.Add("HUDPaint", "MuR_Mode56_HUD", function()
		if MuR.GamemodeCount == 56 and LocalPlayer():GetNW2String("Class") == "Tony" then
			for _, ply in player.Iterator() do
				if ply != LocalPlayer() and ply:Alive() and ply:GetPos():DistToSqr(LocalPlayer():GetPos()) <= 1000000 then
					local pos = ply:GetPos() + Vector(0,0,40)
					local scr = pos:ToScreen()
					if scr.visible then
						local hp = math.Clamp(ply:Health(), 0, 100)
						local col = Color(255 * (1 - hp/100), 255 * (hp/100), 0)

						surface.SetDrawColor(col)
						local s = 16
						surface.DrawOutlinedRect(scr.x - s/2, scr.y - s/2, s, s)
					end
				end
			end
		end
	end)
end
