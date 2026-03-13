

if not CLIENT then return end

local COL1 = Color(255, 50, 200)
local COL2 = Color(0, 140, 255)

local active = false
local startTime = 0
local duration = 0
local senderName = ""
local senderId = "MaSSka"
local mafiaModel = nil
local MAFIA_MODEL = "models/drm/hotline_miami/the_son/the_son.mdl"
local MAFIA_POSES = {"idle_fist", "pose_standing_01", "pose_standing_02", "pose_standing_03", "pose_standing_04"}
local okpcMat = Material("murdered/hotline/okpc.png", "noclamp smooth")
local masskaMat = Material("murdered/hotline/masskahm.png", "noclamp smooth")
local ssmileyMat = Material("murdered/hotline/SSmiley.png", "noclamp smooth")

if okpcMat:IsError() then okpcMat = Material("hotline/okpc.png", "noclamp smooth") end
if masskaMat:IsError() then masskaMat = Material("murdered/masskahm.png", "noclamp smooth") end
local sentences = {}
local currentSentenceIndex = 1
local nextSentenceTime = 0
local sentenceStartTime = 0
local charsPerSec = 40

local function EaseInOut(t)
	return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end

local function GetDisplayName(id)
	if id == "SSmiley" then
		local cv = GetConVar("gmod_language")
		local lang = cv and cv:GetString() or ""
		return (lang == "ru" or lang == "russian") and "Улыбчивый" or "SSmiley"
	end
	if id == "Mafia" then
		local cv = GetConVar("gmod_language")
		local lang = cv and cv:GetString() or ""
		return (lang == "ru" or lang == "russian") and "Босс Русской мафии" or "Russian Mafia Boss"
	end
	if id == "Bravo6" then
		return "Браво-6"
	end
	if id == "PMC" then
		return "ЧВК"
	end
	return "MaSSka"
end

local function ShowMaSSkaMessage(text, fromName, customModel, customDisplayName)
	if not text or text == "" then return end
	senderId = fromName or "MaSSka"
	senderName = ((senderId == "Bravo6" or senderId == "PMC") and customDisplayName and customDisplayName ~= "") and customDisplayName or GetDisplayName(senderId)

	if IsValid(mafiaModel) then mafiaModel:Remove() mafiaModel = nil end

	local modelPath = ((senderId == "Bravo6" or senderId == "PMC") and customModel and customModel ~= "") and customModel or (senderId == "Mafia" and MAFIA_MODEL or nil)
	if modelPath then
		mafiaModel = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
		if IsValid(mafiaModel) then
			mafiaModel:SetNoDraw(true)
			local chosenPose = MAFIA_POSES[math.random(#MAFIA_POSES)]
			local seq = mafiaModel:LookupSequence(chosenPose)
			if not seq or seq < 0 then
				seq = mafiaModel:LookupSequence("idle")
				if not seq or seq < 0 then seq = mafiaModel:LookupSequence("idle_all_01") end
				if not seq or seq < 0 then seq = 0 end
			end
			mafiaModel:ResetSequence(math.max(0, seq))
			mafiaModel:SetCycle(math.Rand(0, 1))
			mafiaModel:SetPlaybackRate(0)
		end
	end

	sentences = {}
	for sentence in string.gmatch(text .. " ", "([^%.%!%?%,]+[%.%!%?%,]?)%s*") do
		sentence = string.Trim(sentence)
		if sentence ~= "" then table.insert(sentences, sentence) end
	end
	if #sentences == 0 then table.insert(sentences, text) end

	currentSentenceIndex = 1
	startTime = CurTime()
	sentenceStartTime = startTime + 0.6
	local firstLen = #sentences[1]
	nextSentenceTime = sentenceStartTime + math.max(0.8, firstLen / charsPerSec + 0.6)

	local totalTypingTime = 0.6
	for _, sent in ipairs(sentences) do
		totalTypingTime = totalTypingTime + math.max(0.8, #sent / charsPerSec + 0.6)
	end
	duration = totalTypingTime + 3
	active = true
end

net.Receive("MuR.Mode56.MaSSkaMessage", function()
	local text = net.ReadString()
	local fromName = net.ReadString()
	local customModel = net.ReadString()
	local customDisplayName = net.ReadString()
	ShowMaSSkaMessage(text, fromName, (customModel and customModel ~= "") and customModel or nil, (customDisplayName and customDisplayName ~= "") and customDisplayName or nil)
end)

local fontCreated = false
local function EnsureFonts()
	if fontCreated then return end
	surface.CreateFont("MuR_Mode56_RetroFont", {
		font = "Retro Computer",
		size = 64,
		weight = 800,
		antialias = true,
		extended = true,
	})
	surface.CreateFont("MuR_Mode56_RetroFont2", {
		font = "Retro Computer",
		size = 32,
		weight = 800,
		antialias = true,
		extended = true,
	})
	surface.CreateFont("MuR_Mode56_RetroFont_FB", {
		font = "Courier New",
		size = 64,
		weight = 800,
		antialias = true,
		extended = true,
	})
	surface.CreateFont("MuR_Mode56_RetroFont2_FB", {
		font = "Courier New",
		size = 32,
		weight = 800,
		antialias = true,
		extended = true,
	})
	fontCreated = true
end

local f1, f2 = "MuR_Mode56_RetroFont", "MuR_Mode56_RetroFont2"

hook.Add("HUDPaint", "MuR_Mode56_MaSSkaMessage", function()
	if not active then return end
	EnsureFonts()

	local elapsed = CurTime() - startTime
	local fadeIn, fadeOut = 0.6, 0.6
	if elapsed > duration then
		active = false
		if IsValid(mafiaModel) then mafiaModel:Remove() mafiaModel = nil end
		return
	end

	local appearFrac = math.Clamp(elapsed / fadeIn, 0, 1)
	local disappearFrac = math.Clamp((duration - elapsed) / fadeOut, 0, 1)
	local overallEase = math.min(EaseInOut(appearFrac), EaseInOut(disappearFrac))

	local w, h = ScrW(), ScrH()
	local barHeight = h * 0.15
	local slideFrac = EaseInOut(appearFrac)

	local topY = Lerp(slideFrac, -barHeight, 0)
	local bottomY = Lerp(slideFrac, h, h - barHeight)

	surface.SetDrawColor(0, 0, 0, 255 * overallEase)
	surface.DrawRect(0, topY, w, barHeight)
	surface.DrawRect(0, bottomY, w, barHeight)

	local imgHeight = h - barHeight * 2 + 20
	local imgWidth = imgHeight * 0.95
	local sideSlide = EaseInOut(appearFrac) * EaseInOut(disappearFrac)
	local imgX = Lerp(sideSlide, w, w - imgWidth)
	local imgY = barHeight - 10

	local t = (math.sin(CurTime() * 2) + 1) / 2
	local col = Color(Lerp(t, COL1.r, COL2.r), Lerp(t, COL1.g, COL2.g), Lerp(t, COL1.b, COL2.b))

	if not okpcMat:IsError() then
		surface.SetMaterial(okpcMat)
		surface.SetDrawColor(col.r, col.g, col.b, 255 * overallEase)
		surface.DrawTexturedRect(imgX, imgY, imgWidth, imgHeight)
	end

	if (senderId == "Mafia" or senderId == "Bravo6" or senderId == "PMC") and IsValid(mafiaModel) then
		cam.Start3D(Vector(30, 0, 25), Angle(0, 180, 0), 70, imgX, imgY, imgWidth, imgHeight)
			render.SuppressEngineLighting(true)
			mafiaModel:SetPos(Vector(0, 0, -35))
			mafiaModel:SetAngles(Angle(0, 330 + math.sin(CurTime() * 1.2) * 10, 0))
			mafiaModel:SetColor(Color(col.r, col.g, col.b))
			mafiaModel:DrawModel()
			render.SuppressEngineLighting(false)
		cam.End3D()
	else
		local avatarMat = (senderId == "SSmiley" and not ssmileyMat:IsError()) and ssmileyMat or masskaMat
		if not avatarMat:IsError() then
			local avatarScale = 0.72
			local avatarOffsetX = 45
			local mw, mh = imgWidth * avatarScale, imgHeight * avatarScale
			local mx = imgX + avatarOffsetX + (imgWidth - mw) / 2
			local my = imgY + (imgHeight - mh) / 2
			local rot = math.sin(CurTime() * 1.5) * 10
			local cx, cy = mx + mw / 2, my + mh / 2
			surface.SetMaterial(avatarMat)
			surface.SetDrawColor(255, 255, 255, 255 * overallEase)
			surface.DrawTexturedRectRotated(cx, cy, mw, mh, rot)
		end
	end

	if CurTime() >= nextSentenceTime and currentSentenceIndex < #sentences then
		currentSentenceIndex = currentSentenceIndex + 1
		sentenceStartTime = CurTime()
		local len = #sentences[currentSentenceIndex]
		nextSentenceTime = sentenceStartTime + math.max(0.8, len / charsPerSec + 0.6)
	end

	local currentText = sentences[currentSentenceIndex] or ""
	if currentText == "" then return end

	local timeSinceSentence = CurTime() - (sentenceStartTime or startTime)
	local visibleChars = math.Clamp(math.floor(timeSinceSentence * charsPerSec), 0, #currentText)
	local textToShow = string.sub(currentText, 1, visibleChars)

	local y = h - barHeight / 2
	surface.SetFont(f1)
	local tw = surface.GetTextSize(textToShow)
	local x = (w - tw) / 2
	local offset = math.sin(CurTime() * 3) * 5

	local SHAKE_WORDS = {{"ПРОЕБИСЬ", "ПРОЕБИСЬ!!!"}, {"ПОНЯЛ", "ПОНЯЛ?"}}
	local hasShake = senderId == "SSmiley" and (string.find(textToShow, "ПРОЕБИСЬ") or string.find(textToShow, "ПОНЯЛ"))
	local shakeX = hasShake and (math.sin(CurTime() * 18) * 4 + math.cos(CurTime() * 13) * 3) or 0
	local shakeY = hasShake and (math.cos(CurTime() * 15) * 4 + math.sin(CurTime() * 11) * 3) or 0
	local shakeX2 = hasShake and (math.sin(CurTime() * 14) * 3 + math.cos(CurTime() * 19) * 2) or 0
	local shakeY2 = hasShake and (math.cos(CurTime() * 12) * 3 + math.sin(CurTime() * 16) * 2) or 0

	local function DrawTextWithShake(txt, baseX, baseY, col1, col2)
		if txt == "" then return baseX end
		if senderId ~= "SSmiley" then
			draw.SimpleText(txt, f1, baseX - offset, baseY - offset, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(txt, f1, baseX, baseY, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			return baseX + surface.GetTextSize(txt)
		end
		local pos = 1
		local curX = baseX
		while pos <= #txt do
			local nextShakeStart, nextShakeFull, idx = nil, nil, nil
			for i, pair in ipairs(SHAKE_WORDS) do
				local searchWord, fullWord = pair[1], pair[2]
				local found = string.find(txt, searchWord, pos, true)
				if found and (not nextShakeStart or found < nextShakeStart) then
					nextShakeStart = found
					nextShakeFull = fullWord
					idx = i
				end
			end
			if nextShakeStart and nextShakeFull then
				if nextShakeStart > pos then
					local normalPart = string.sub(txt, pos, nextShakeStart - 1)
					draw.SimpleText(normalPart, f1, curX - offset, baseY - offset, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(normalPart, f1, curX, baseY, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					curX = curX + surface.GetTextSize(normalPart)
				end
				local shakePart = string.sub(txt, nextShakeStart, math.min(nextShakeStart + #nextShakeFull - 1, #txt))
				local sx = (idx == 2) and shakeX2 or shakeX
				local sy = (idx == 2) and shakeY2 or shakeY
				draw.SimpleText(shakePart, f1, curX + sx - offset, baseY + sy - offset, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(shakePart, f1, curX + sx, baseY + sy, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				curX = curX + surface.GetTextSize(shakePart)
				pos = nextShakeStart + #shakePart
			else
				local rest = string.sub(txt, pos)
				draw.SimpleText(rest, f1, curX - offset, baseY - offset, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(rest, f1, curX, baseY, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				break
			end
		end
		return curX
	end

	DrawTextWithShake(textToShow, x, y, COL1, COL2)

	if senderName ~= "" then
		surface.SetFont(f2)
		local nw = surface.GetTextSize(senderName)
		local nx = (w - nw) / 2
		draw.SimpleText(senderName, f2, nx - offset, y - 60 - offset, Color(COL1.r, COL1.g, COL1.b, 255 * overallEase), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(senderName, f2, nx, y - 60, Color(COL2.r, COL2.g, COL2.b, 255 * overallEase), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end)
