

MuR_Fury13_phase1 = MuR_Fury13_phase1 or false
MuR_Fury13_phase2 = MuR_Fury13_phase2 or false
MuR_Fury13_startTime = MuR_Fury13_startTime or 0
MuR_Fury13_musicChannel = MuR_Fury13_musicChannel or nil
MuR_Fury13_intensity = MuR_Fury13_intensity or 0
MuR_Fury13_effectEnd = MuR_Fury13_effectEnd or 0
MuR_Fury13_killMessagesList = MuR_Fury13_killMessagesList or {}
MuR_Fury13_vignetteAlpha = MuR_Fury13_vignetteAlpha or 0
MuR_Fury13_vignetteRadius = MuR_Fury13_vignetteRadius or 0
MuR_Fury13_vignetteCenterX = MuR_Fury13_vignetteCenterX or 0
MuR_Fury13_vignetteCenterY = MuR_Fury13_vignetteCenterY or 0
MuR_Fury13_heartbeatNext = MuR_Fury13_heartbeatNext or 0
MuR_Fury13_jerkNext = MuR_Fury13_jerkNext or 0

local offset = CreateClientConVar("fury13_offset", "0.85", true, false, "Set berserk music offset from start", 0, 5)
local bpm = CreateClientConVar("fury13_bpm", "70", true, false, "Set berserk effect bpm", 1, 280)
local path = CreateClientConVar("fury13_path", "sound/murdered/berserk/pharmacia.mp3", true, false, "Set berserk effect music path")

MuR_Fury13_notifications = MuR_Fury13_notifications or {}
MuR_Fury13_currentNotification = MuR_Fury13_currentNotification or nil

local function CreateNotificationBerserk(msg, showTimer, clr)
	clr = clr or Color(255, 0, 0, 255)
	showTimer = showTimer or 3
	
	MuR_Fury13_currentNotification = nil
	MuR_Fury13_notifications = {}
	
	table.insert(MuR_Fury13_notifications, {msg, showTimer, clr})
end

local function ActivateFury13Effect(ent)
	if not IsValid(ent) or not ent:IsPlayer() then 
		return 
	end
	if MuR_Fury13_phase1 or MuR_Fury13_phase2 then 
		return 
	end
	
	MuR_Fury13_phase1 = true
	MuR_Fury13_startTime = SysTime()

	local nwEnd = ent:GetNW2Float("BerserkEnd", 0)
	if nwEnd > CurTime() then
		MuR_Fury13_effectEnd = nwEnd
	else
		MuR_Fury13_effectEnd = CurTime() + 120
	end
	

	if file.Exists("sound/murdered/berserk/deathsample.ogg", "GAME") then
		surface.PlaySound("murdered/berserk/deathsample.ogg")
	else
		ent:EmitSound("buttons/button15.wav", 75, 100)
	end
	

	local part = nil
	local success, partResult = pcall(function()
		return CreateParticleSystem(ent, "[2]sparkle1", PATTACH_POINT_FOLLOW, 1)
	end)
	if success and IsValid(partResult) then
		part = partResult
	end
	

	CreateNotificationBerserk("Я чувствую себя...", 4, Color(255, 200, 0, 255))
	

	timer.Simple(3.95, function()
		if not IsValid(ent) or not ent:Alive() then return end
		

		if IsValid(part) then
			part:StopEmission(false, true, false)
		end
		

		for i = 1, 30 do
			timer.Simple(i/120, function()
				if IsValid(ent) and ent:Alive() then
					local randAng = Angle(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-3, 3))
					if ent.ViewPunchClient then
						ent:ViewPunchClient(randAng)
					else
						LocalPlayer():ViewPunch(randAng)
					end
				end
			end)
		end
		

		MuR_Fury13_phase1 = false
		MuR_Fury13_phase2 = true
		MuR_Fury13_jerkNext = CurTime() + 10
		

		local musicPath = path:GetString()
		if not file.Exists(musicPath, "GAME") then
			if file.Exists("sound/murdered/berserk/pharmacia.mp3", "GAME") then
				musicPath = "sound/murdered/berserk/pharmacia.mp3"
			elseif file.Exists("sound/zbattle/pharmacia.mp3", "GAME") then
				musicPath = "sound/zbattle/pharmacia.mp3"
			elseif file.Exists("sound/murdered/theme/gamemodess1.wav", "GAME") then
				musicPath = "sound/murdered/theme/gamemodess1.wav"
			else
				musicPath = nil
			end
		end
		
		if musicPath then
			sound.PlayFile(musicPath, "noblock", function(channel, err, errname)
				if err then
					return
				end
				if IsValid(channel) then
					MuR_Fury13_musicChannel = channel
					channel:EnableLooping(true)
					channel:SetVolume(0.7)
				end
			end)
		end
		

		CreateNotificationBerserk("ЗАМЕЧАТЕЛЬНО!", 2, Color(255, 0, 0, 255))
		

		local laughFiles = {}
		

		for i = 1, 7 do

			local checkPath1 = "sound/murdered/berserk/laugh/laugh" .. i .. ".wav"
			local soundPath1 = "murdered/berserk/laugh/laugh" .. i .. ".wav"
			

			local checkPath2 = "sound/murdered/berserk/laugh" .. i .. ".wav"
			local soundPath2 = "murdered/berserk/laugh" .. i .. ".wav"
			
			local exists1 = file.Exists(checkPath1, "GAME")
			local exists2 = file.Exists(checkPath2, "GAME")
			
			if exists1 then
				table.insert(laughFiles, soundPath1)
			elseif exists2 then
				table.insert(laughFiles, soundPath2)
			end
		end
		

		for i = 8, 50 do
			local checkPath1 = "sound/murdered/berserk/laugh/laugh" .. i .. ".wav"
			local soundPath1 = "murdered/berserk/laugh/laugh" .. i .. ".wav"
			local checkPath2 = "sound/murdered/berserk/laugh" .. i .. ".wav"
			local soundPath2 = "murdered/berserk/laugh" .. i .. ".wav"
			
			if file.Exists(checkPath1, "GAME") then
				table.insert(laughFiles, soundPath1)
			elseif file.Exists(checkPath2, "GAME") then
				table.insert(laughFiles, soundPath2)
			end
		end
		
		if #laughFiles > 0 then

			local firstLaugh = laughFiles[math.random(1, #laughFiles)]

			net.Start("MuR.Fury13Laugh")
			net.WriteString(firstLaugh)
			net.SendToServer()
			

			MuR_Fury13_laughTimer = timer.Create("MuR_Fury13_Laugh", 7, 0, function()
				if not MuR_Fury13_phase2 or not IsValid(ent) or not ent:Alive() then
					timer.Remove("MuR_Fury13_Laugh")
					return
				end
				

				local randomLaugh = laughFiles[math.random(1, #laughFiles)]
				net.Start("MuR.Fury13Laugh")
				net.WriteString(randomLaugh)
				net.SendToServer()
			end)
		end
		

		MuR_Fury13_killMessages = {
			{text = "УБИВАЙ ВСЕХ", size = "large"},
			{text = "ВСЕХ УБИТЬ", size = "medium"},
			{text = "НУЖНО УБИТЬ", size = "large"},
			{text = "РАСТОПЧИМ ИХ!", size = "small"},
			{text = "РАСПРАВЬСЯ СО ВСЕМИ", size = "small"},
			{text = "ОНИ ПОЗНАЮТ БОЛЬ", size = "large"},
			{text = "УНИЧТОЖЬ", size = "medium"},
			{text = "УНИЧТОЖАЙ СЛАБЫХ", size = "small"},
			{text = "УБЕЙ", size = "large"},
			{text = "РЕЗНЯ", size = "small"},
			{text = "ПОЧЕМУ ОНИ ЕЩЕ ЖИВЫ?", size = "small"},
			{text = "НАКОНЕЦ КРОВЬ!", size = "large"},
			{text = "ПОТРОШИ ИХ! ПОТРОШИ ИХ ВСЕХ!", size = "small"},
			{text = "РУБИ НА ЧАСТИ!", size = "medium"},
			{text = "ЭТИ СЛИЗНЯКИ! ПЫТАЮТЬСЯ СРАЖАТЬСЯ!", size = "small"}
		}
		MuR_Fury13_killMessagesList = MuR_Fury13_killMessagesList or {}
		
		MuR_Fury13_killMessageTimer = timer.Create("MuR_Fury13_KillMessages", 1, 0, function()
			if not MuR_Fury13_phase2 or not IsValid(ent) or not ent:Alive() then
				timer.Remove("MuR_Fury13_KillMessages")
				MuR_Fury13_killMessagesList = {}
				return
			end
			

			local extraMessages = 0
			if MuR_Fury13_effectEnd > 0 then
				local timeLeft = MuR_Fury13_effectEnd - CurTime()
				if timeLeft <= 30 and timeLeft > 0 then

					extraMessages = math.floor(30 - timeLeft)
				end
			end
			

			local function AddKillMessage()
				local randomMsgData = MuR_Fury13_killMessages[math.random(1, #MuR_Fury13_killMessages)]
				local scrw, scrh = ScrW(), ScrH()
				

				local fontName = "MuR_Fury13_KillMessagesFont_Medium"
				if randomMsgData.size == "small" then
					fontName = "MuR_Fury13_KillMessagesFont_Small"
				elseif randomMsgData.size == "large" then
					fontName = "MuR_Fury13_KillMessagesFont_Large"
				end
				
				table.insert(MuR_Fury13_killMessagesList, {
					text = randomMsgData.text,
					font = fontName,
					time = CurTime() + 5,
					x = math.random(ScrW() * 0.1, ScrW() * 0.9),
					y = math.random(ScrH() * 0.1, ScrH() * 0.9),
					velX = math.Rand(-2, 2),
					velY = math.Rand(-2, 2),
					shakeX = 0,
					shakeY = 0
				})
			end
			

			AddKillMessage()
			

			for i = 1, extraMessages do
				AddKillMessage()
			end
		end)
	end)
end

local nextFury13NW2Check = 0
hook.Add("Think", "MuR_Fury13_StartFromNW2", function()
	if CurTime() < nextFury13NW2Check then return end
	nextFury13NW2Check = CurTime() + 0.1

	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then 

		if MuR_Fury13_phase1 or MuR_Fury13_phase2 then
			MuR_Fury13_phase1 = false
			MuR_Fury13_phase2 = false
			MuR_Fury13_effectEnd = 0
			MuR_Fury13_heartbeatNext = 0
			MuR_Fury13_jerkNext = 0
			if IsValid(MuR_Fury13_musicChannel) then
				MuR_Fury13_musicChannel:Stop()
				MuR_Fury13_musicChannel = nil
			end
			if timer.Exists("MuR_Fury13_Laugh") then
				timer.Remove("MuR_Fury13_Laugh")
			end
			if timer.Exists("MuR_Fury13_KillMessages") then
				timer.Remove("MuR_Fury13_KillMessages")
			end
		end
		return 
	end

	local berserkEnd = ply:GetNW2Float("BerserkEnd", 0)
	

	if berserkEnd > CurTime() then
		if not MuR_Fury13_phase1 and not MuR_Fury13_phase2 then
			ActivateFury13Effect(ply)
		end
	else

		if MuR_Fury13_phase1 or MuR_Fury13_phase2 then
			MuR_Fury13_phase1 = false
			MuR_Fury13_phase2 = false
			MuR_Fury13_effectEnd = 0
			MuR_Fury13_heartbeatNext = 0
			MuR_Fury13_jerkNext = 0
			if IsValid(MuR_Fury13_musicChannel) then
				MuR_Fury13_musicChannel:Stop()
				MuR_Fury13_musicChannel = nil
			end
			if timer.Exists("MuR_Fury13_Laugh") then
				timer.Remove("MuR_Fury13_Laugh")
			end
			if timer.Exists("MuR_Fury13_KillMessages") then
				timer.Remove("MuR_Fury13_KillMessages")
			end
		end
	end
end)

hook.Add("Think", "MuR_Fury13_Heartbeat", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	if not MuR_Fury13_phase2 then return end

	local timeLeft = MuR_Fury13_effectEnd - CurTime()
	if timeLeft <= 0 or timeLeft > 30 then return end

	local interval = 0.35 + 1.65 * (timeLeft / 30)
	if CurTime() >= MuR_Fury13_heartbeatNext then
		MuR_Fury13_heartbeatNext = CurTime() + interval
		if file.Exists("sound/murdered/berserk/heartbeat.mp3", "GAME") then
			surface.PlaySound("murdered/berserk/heartbeat.mp3")
		end
	end
end)

hook.Add("Think", "MuR_Fury13_MouseJerk", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	if not MuR_Fury13_phase2 then return end
	
	if CurTime() < MuR_Fury13_jerkNext then return end
	MuR_Fury13_jerkNext = CurTime() + 10
	

	if ply.ViewPunchClient then
		local jerk = Angle(math.Rand(-8, 8), math.Rand(-12, 12), math.Rand(-5, 5))
		ply:ViewPunchClient(jerk)
	end
end)

local fury13ShakeNext = 0
hook.Add("Think", "MuR_Fury13_ContinuousShake", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	
	local berserkEnd = ply:GetNW2Float("BerserkEnd", 0)
	if berserkEnd <= CurTime() then return end
	

	if CurTime() < fury13ShakeNext then return end
	fury13ShakeNext = CurTime() + 0.05
	
	if ply.ViewPunchClient then
		local shake = Angle(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-2, 2))
		ply:ViewPunchClient(shake)
	end
end)

net.Receive("MuR.Fury13LaughClient", function()
	local soundPath = net.ReadString()
	if not soundPath or soundPath == "" then return end
	

	local laughPlayer = net.ReadEntity()
	if not IsValid(laughPlayer) or not laughPlayer:IsPlayer() then return end
	

	laughPlayer:EmitSound(soundPath, 75, 100)
end)

surface.CreateFont("MuR_Fury13_BerserkFont", {
	font = "Arial Black",
	size = ScreenScale(20),
	extended = true,
	weight = 700,
	antialias = true,
})

surface.CreateFont("MuR_Fury13_BerserkFontGreat", {
	font = "Arial Black",
	size = ScreenScale(35),
	extended = true,
	weight = 900,
	antialias = true,
	outline = true,
})

surface.CreateFont("MuR_Fury13_KillMessagesFont_Small", {
	font = "Blood Cyrillic",
	size = ScreenScale(36),
	extended = true,
	weight = 900,
	antialias = true,
	outline = true,
})
surface.CreateFont("MuR_Fury13_KillMessagesFont_Medium", {
	font = "Blood Cyrillic",
	size = ScreenScale(56),
	extended = true,
	weight = 900,
	antialias = true,
	outline = true,
})
surface.CreateFont("MuR_Fury13_KillMessagesFont_Large", {
	font = "Blood Cyrillic",
	size = ScreenScale(80),
	extended = true,
	weight = 900,
	antialias = true,
	outline = true,
})

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local tab2 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local cc = Material("effects/shaders/merc_chromaticaberration")

concommand.Add("fury13_test", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	

	if not MuR_Fury13_phase1 and not MuR_Fury13_phase2 then
		MuR_Fury13_phase1 = true
		MuR_Fury13_startTime = SysTime()
		MuR_Fury13_effectEnd = CurTime() + 120
		

		if file.Exists("sound/zbattle/deathsample.ogg", "GAME") then
			surface.PlaySound("zbattle/deathsample.ogg")
		else
			ply:EmitSound("buttons/button15.wav", 75, 100)
		end
		
		CreateNotificationBerserk("Я чувствую себя...", 4, Color(255, 200, 0, 255))
		

		timer.Simple(3.95, function()
			if not IsValid(ply) or not ply:Alive() then return end
			MuR_Fury13_phase1 = false
			MuR_Fury13_phase2 = true
			CreateNotificationBerserk("ЗАМЕЧАТЕЛЬНО!", 2, Color(255, 0, 0, 255))
		end)
		
	end
end, nil, "Test Manic Rage effect")

hook.Add("HUDPaint", "MuR_Fury13_Notifications", function()

	if MuR_Fury13_notifications and #MuR_Fury13_notifications > 0 then
		local notification = MuR_Fury13_notifications[1]
		if notification then
			local msg, timer, clr = notification[1], notification[2], notification[3]
			
			if timer > 0 then
				local alpha = math.Clamp(timer * 255, 0, 255)
				local scrw, scrh = ScrW(), ScrH()
				

				local fontName = "MuR_Fury13_BerserkFont"
				if string.find(string.upper(msg), "ЗАМЕЧАТЕЛЬНО") then
					fontName = "MuR_Fury13_BerserkFontGreat"
				end
				

				local yPos = scrh - ScreenScale(100)
				
				draw.SimpleText(msg, fontName, scrw / 2, yPos, Color(clr.r, clr.g, clr.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				notification[2] = notification[2] - FrameTime()
			else
				table.remove(MuR_Fury13_notifications, 1)
			end
		end
	end
	

	if MuR_Fury13_killMessagesList and #MuR_Fury13_killMessagesList > 0 and MuR_Fury13_phase2 then
		local function We(x) return x * (ScrW() / 1920) end
		local function He(x) return x * (ScrH() / 1080) end
		
		for i = #MuR_Fury13_killMessagesList, 1, -1 do
			local msgData = MuR_Fury13_killMessagesList[i]
			if CurTime() < msgData.time then
				local timeLeft = msgData.time - CurTime()
				

				msgData.x = msgData.x + msgData.velX
				msgData.y = msgData.y + msgData.velY
				

				msgData.shakeX = math.Rand(-3, 3)
				msgData.shakeY = math.Rand(-3, 3)
				

				msgData.x = math.Clamp(msgData.x, ScrW() * 0.05, ScrW() * 0.95)
				msgData.y = math.Clamp(msgData.y, ScrH() * 0.05, ScrH() * 0.95)
				

				if msgData.x <= ScrW() * 0.05 or msgData.x >= ScrW() * 0.95 then
					msgData.velX = -msgData.velX
				end
				if msgData.y <= ScrH() * 0.05 or msgData.y >= ScrH() * 0.95 then
					msgData.velY = -msgData.velY
				end
				

				local alpha = math.abs(math.sin(CurTime() * 2)) * 255
				if timeLeft < 0.5 then
					alpha = alpha * (timeLeft / 0.5)
				end
				

				local drawX = msgData.x + msgData.shakeX
				local drawY = msgData.y + msgData.shakeY
				local fontToUse = msgData.font or "MuR_Fury13_KillMessagesFont_Medium"
				
				draw.SimpleText(msgData.text, fontToUse, drawX, drawY, Color(200, 20, 20, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else

				table.remove(MuR_Fury13_killMessagesList, i)
			end
		end
	end
	
end)

hook.Add("RenderScreenspaceEffects", "MuR.Fury13BerserkFX", function()
	local ply = LocalPlayer()
	if not ply:Alive() then 
		MuR_Fury13_phase1 = false
		MuR_Fury13_phase2 = false
		MuR_Fury13_heartbeatNext = 0
		MuR_Fury13_jerkNext = 0
		if IsValid(MuR_Fury13_musicChannel) then
			MuR_Fury13_musicChannel:Stop()
			MuR_Fury13_musicChannel = nil
		end
		MuR_Fury13_intensity = 0
		MuR_Fury13_killMessagesList = {}
		

		if timer.Exists("MuR_Fury13_Laugh") then
			timer.Remove("MuR_Fury13_Laugh")
		end
		if timer.Exists("MuR_Fury13_KillMessages") then
			timer.Remove("MuR_Fury13_KillMessages")
		end
		
		return 
	end
	

	local berserkEnd = ply:GetNW2Float("BerserkEnd", 0)
	if MuR_Fury13_effectEnd > 0 and CurTime() >= MuR_Fury13_effectEnd then

		if berserkEnd > 0 and berserkEnd <= CurTime() then

			if IsValid(ply) and ply:Alive() then
				net.Start("MuR.Fury13HeadExplode")
				net.SendToServer()
			end
		end
		

		MuR_Fury13_phase1 = false
		MuR_Fury13_phase2 = false
		MuR_Fury13_heartbeatNext = 0
		MuR_Fury13_jerkNext = 0
		if IsValid(MuR_Fury13_musicChannel) then
			MuR_Fury13_musicChannel:Stop()
			MuR_Fury13_musicChannel = nil
		end
		MuR_Fury13_intensity = 0
		MuR_Fury13_effectEnd = 0
		MuR_Fury13_killMessagesList = {}
		

		if timer.Exists("MuR_Fury13_Laugh") then
			timer.Remove("MuR_Fury13_Laugh")
		end
		if timer.Exists("MuR_Fury13_KillMessages") then
			timer.Remove("MuR_Fury13_KillMessages")
		end
		
		return
	end
	

	if MuR_Fury13_phase1 then
		local intensity = (SysTime() - MuR_Fury13_startTime)
		tab["$pp_colour_contrast"] = intensity / 2
		tab["$pp_colour_addr"] = intensity / 10
		tab["$pp_colour_brightness"] = intensity / 10
		DrawColorModify(tab)
		DrawBloom(0.65, intensity * 4, 9, 9, 1, 1, intensity / 16, 0.2, 0.2)
		

		render.UpdateScreenEffectTexture()
		if IsValid(cc) then
			cc:SetFloat("$c0_x", 3.5 - intensity)
			cc:SetInt("$c0_y", 1)
			render.SetMaterial(cc)
			render.DrawScreenQuad()
		end
	end
	

	if MuR_Fury13_phase2 then

		local intensity = 0.5
		if IsValid(MuR_Fury13_musicChannel) then
			intensity = 1 - ((MuR_Fury13_musicChannel:GetTime() - offset:GetFloat()) / 60 * bpm:GetInt())
			intensity = (intensity - math.Round(intensity)) % 1
			intensity = math.Clamp((intensity * 0.25 + 0.75), 0, 1)
			intensity = math.ease.InExpo(intensity) * 2
		else

			intensity = 1.5
		end
		

		tab2["$pp_colour_mulr"] = 1.5 + (intensity / 5)
		tab2["$pp_colour_addr"] = 0.1 + intensity / 64
		tab2["$pp_colour_colour"] = 1 - math.Clamp(intensity, 0, 0.9)
		tab2["$pp_colour_mulg"] = 0
		tab2["$pp_colour_mulb"] = 0
		

		local timeLeft = MuR_Fury13_effectEnd - CurTime()
		if timeLeft <= 30 and timeLeft > 0 then
			local fadeAmount = (30 - timeLeft) / 30 * 0.5
			tab2["$pp_colour_brightness"] = -fadeAmount
		else
			tab2["$pp_colour_brightness"] = 0
		end
		
		DrawColorModify(tab2)
		DrawBloom(0.65, intensity, 9, 9, 1, 1, intensity / 16, 0.2, 0.2)
		

		DrawMotionBlur(0.1, 0.25, 0.02)
		
		MuR_Fury13_intensity = intensity
	end
	

	if IsValid(MuR_Fury13_musicChannel) then
		local volume = 0.7
		local timeLeft = MuR_Fury13_effectEnd - CurTime()
		if timeLeft <= 30 and timeLeft > 0 then

			volume = 0.2 + 0.5 * (timeLeft / 30)
		end
		MuR_Fury13_musicChannel:SetVolume(volume)
	end
end)

MuR_Fury13_grainMat = MuR_Fury13_grainMat or nil
local grainMatCreated = false

timer.Simple(0.1, function()
	if not grainMatCreated then
		grainMatCreated = true
		

		local success, mat = pcall(function()
			return CreateMaterial("MuR_Fury13_grain_dynamic", "screenspace_general", {
				["$pixshader"] = "zb_grain2_ps20b",
				["$basetexture"] = "_rt_FullFrameFB",
				["$texture1"] = "stickers/steamhappy",
				["$ignorez"] = 1,
				["$vertexcolor"] = 1,
				["$vertextransform"] = 1,
				["$copyalpha"] = 1,
				["$alpha_blend"] = 1,
				["$linearwrite"] = 1,
				["$linearread_basetexture"] = 1,
				["$linearread_texture1"] = 1,
			})
		end)
		
		if success and mat and not mat:IsError() then
			MuR_Fury13_grainMat = mat
		else

			MuR_Fury13_grainMat = CreateMaterial("MuR_Fury13_grain_simple", "UnlitGeneric", {
				["$basetexture"] = "_rt_FullFrameFB",
				["$ignorez"] = 1,
			})
		end
	end
end)

hook.Add("PostPostProcess", "MuR_Fury13_Grain", function()

	if not MuR_Fury13_phase2 then return end
	

	if not MuR_Fury13_grainMat then
		return
	end
	

	if MuR_Fury13_grainMat:IsError() then
		return
	end
	
	render.UpdateScreenEffectTexture()
	render.UpdateFullScreenDepthTexture()
	

	local success, err = pcall(function()

		local pixelizeIntensity = 10
		local lerpIntensity = 0.8
		local redTint = 10
		

		if MuR_Fury13_grainMat.SetFloat then
			MuR_Fury13_grainMat:SetFloat("$c0_x", CurTime())
			MuR_Fury13_grainMat:SetFloat("$c0_y", 0.5)
			MuR_Fury13_grainMat:SetFloat("$c0_z", pixelizeIntensity)
			MuR_Fury13_grainMat:SetFloat("$c1_x", lerpIntensity)
			MuR_Fury13_grainMat:SetFloat("$c1_y", 1.5)
			MuR_Fury13_grainMat:SetFloat("$c1_z", 0.2)
			MuR_Fury13_grainMat:SetFloat("$c2_x", redTint)
			MuR_Fury13_grainMat:SetFloat("$c2_y", 0)
			MuR_Fury13_grainMat:SetFloat("$c2_z", 0)
			MuR_Fury13_grainMat:SetFloat("$c3_x", 0)
		end
		

		if MuR_Fury13_grainMat.SetVector then
			MuR_Fury13_grainMat:SetVector("$c0", Vector(CurTime(), 0.5, pixelizeIntensity))
			MuR_Fury13_grainMat:SetVector("$c1", Vector(lerpIntensity, 1.5, 0.2))
			MuR_Fury13_grainMat:SetVector("$c2", Vector(redTint, 0, 0))
			MuR_Fury13_grainMat:SetVector("$c3", Vector(0, 0, 0))
		end
		

		render.SetMaterial(MuR_Fury13_grainMat)
		render.DrawScreenQuad()
	end)
	

	if not success then
		

		local scrw, scrh = ScrW(), ScrH()
		local pixelSize = 12
		local alpha = 60
		

		surface.SetDrawColor(255, 0, 0, alpha)
		for x = 0, scrw, pixelSize do
			for y = 0, scrh, pixelSize do
				if math.random(5) == 1 then
					surface.DrawRect(x, y, pixelSize, pixelSize)
				end
			end
		end
		

		surface.SetDrawColor(200, 0, 0, alpha * 0.7)
		for i = 1, math.floor(scrw * scrh / (pixelSize * pixelSize * 50)) do
			local px = math.random(0, scrw - pixelSize)
			local py = math.random(0, scrh - pixelSize)
			surface.DrawRect(px, py, pixelSize, pixelSize)
		end
	end
end)

hook.Add("CalcView", "MuR_Fury13_CameraShake", function(ply, origin, angles, fov)
	if not IsValid(ply) or not ply:Alive() then return end
	if not MuR_Fury13_phase2 then return end
	
	local intensity = MuR_Fury13_intensity or 1
	if IsValid(MuR_Fury13_musicChannel) then
		intensity = 1 - ((MuR_Fury13_musicChannel:GetTime() - offset:GetFloat()) / 60 * bpm:GetInt())
		intensity = (intensity - math.Round(intensity)) % 1
		intensity = math.Clamp((intensity * 0.25 + 0.75), 0, 1)
		intensity = math.ease.InExpo(intensity) * 2
	end
	

	angles[1] = angles[1] + math.sin(CurTime() * 8) * intensity * 0.5
	angles[2] = angles[2] + math.cos(CurTime() * 7) * intensity * 0.5
	angles[3] = angles[3] + math.sin(CurTime() * 6) * intensity * 1.5
	local newFov = fov + math.sin(CurTime() * 4) * intensity
	
	return {
		origin = origin,
		angles = angles,
		fov = newFov
	}
end)

hook.Add("ShutDown", "MuR_Fury13_Cleanup", function()
	if IsValid(MuR_Fury13_musicChannel) then
		MuR_Fury13_musicChannel:Stop()
		MuR_Fury13_musicChannel = nil
	end
end)
