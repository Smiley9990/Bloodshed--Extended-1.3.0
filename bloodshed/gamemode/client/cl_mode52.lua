if CLIENT then
	local styleSelectionOpen = false
	local selectionTime = 0
	local selectedStyle = 0
	local hoveredStyle = 0
	local lastHoveredStyle = 0
	local lastClickTime = 0
	local lastHoverSoundPlayed = 0

	local THEME = {
		background = Color(15, 15, 20, 250),
		accent = Color(180, 40, 40),
		panel = Color(25, 25, 30, 255),
		text = Color(255, 255, 255),
		textDark = Color(200, 200, 200),
		success = Color(40, 180, 120),
		danger = Color(220, 50, 50)
	}

	local function We(x)
		return x / 1920 * ScrW()
	end

	local function He(y)
		return y / 1080 * ScrH()
	end

	local function WrapText(font, text, maxWidth)
		surface.SetFont(font)
		local lines = {}
		local words = string.Explode(" ", text)
		local currentLine = ""

		for _, word in ipairs(words) do
			local testLine = currentLine == "" and word or (currentLine .. " " .. word)
			local w = surface.GetTextSize(testLine)

			if w > maxWidth and currentLine ~= "" then
				table.insert(lines, currentLine)
				currentLine = word
			else
				currentLine = testLine
			end
		end

		if currentLine ~= "" then
			table.insert(lines, currentLine)
		end

		return lines
	end

	local function SelectStyle(style)
		if not styleSelectionOpen then return end
		if style < 1 or style > 6 then return end

		selectedStyle = style
		styleSelectionOpen = false
		gui.EnableScreenClicker(false)

		net.Start("MuR.Mode52StyleSelected")
		net.WriteInt(style, 8)
		net.SendToServer()

		surface.PlaySound("murdered/vgui/ui_click.wav")
	end

	net.Receive("MuR.Mode52StyleSelection", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local playerClass = ply:GetNW2String("Class", "")
		if playerClass != "Traitor" and playerClass != "Killer" then
			return
		end

		styleSelectionOpen = true
		selectionTime = CurTime() + 10
		selectedStyle = 0
		hoveredStyle = 0
		lastHoveredStyle = 0
		lastClickTime = 0
		lastHoverSoundPlayed = 0

		gui.EnableScreenClicker(true)

		timer.Simple(10, function()
			if styleSelectionOpen then
				styleSelectionOpen = false
				gui.EnableScreenClicker(false)
				if selectedStyle == 0 then
					local randomChoice = math.random(1, 6)
					net.Start("MuR.Mode52StyleSelected")
					net.WriteInt(randomChoice, 8)
					net.SendToServer()
				end
			end
		end)
	end)

	hook.Add("HUDPaint", "MuR.Mode52StyleSelection", function()
		if not styleSelectionOpen then
			return
		end

		local ply = LocalPlayer()
		if not IsValid(ply) then
			styleSelectionOpen = false
			gui.EnableScreenClicker(false)
			return
		end

		local timeLeft = math.max(0, math.ceil(selectionTime - CurTime()))

		if timeLeft <= 0 then
			styleSelectionOpen = false
			gui.EnableScreenClicker(false)
			return
		end

		local scrW, scrH = ScrW(), ScrH()

		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, scrW, scrH)

		local menuW, menuH = We(700), He(800)
		local menuX = (scrW - menuW) / 2
		local menuY = (scrH - menuH) / 2

		draw.RoundedBox(8, menuX, menuY, menuW, menuH, THEME.background)
		draw.RoundedBox(8, menuX, menuY, menuW, He(80), THEME.panel)

		surface.SetDrawColor(THEME.accent)
		surface.DrawRect(menuX, menuY + He(80), menuW, He(2))

		local title = MuR.Language["mode52_select_style"] or "Select Playstyle"
		draw.SimpleText(title, "MuR_Font3", menuX + We(30), menuY + He(40), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local timerColor = timeLeft <= 3 and THEME.danger or Color(255, 200, 0)
		local timerText = string.format(MuR.Language["mode52_time_left"] or "Time left: %d sec", timeLeft)
		draw.SimpleText(timerText, "MuR_Font2", menuX + menuW - We(30), menuY + He(40), timerColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local progressW = menuW - We(60)
		local progressX = menuX + We(30)
		local progressY = menuY + He(90)
		local progressH = He(6)
		local progress = (10 - timeLeft) / 10

		draw.RoundedBox(4, progressX, progressY, progressW, progressH, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
		draw.RoundedBox(4, progressX, progressY, progressW * progress, progressH, timerColor)

		local styles = {
			{name = MuR.Language["mode52_style_classic"] or "Classic", desc = MuR.Language["mode52_style_classic_desc"] or "Glock, knife, grenade and cyanide.", key = "1"},
			{name = MuR.Language["mode52_style_demolition"] or "Demolition", desc = MuR.Language["mode52_style_demolition_desc"] or "Fire and explosives.", key = "2"},
			{name = MuR.Language["mode52_style_chemist"] or "Chemist", desc = MuR.Language["mode52_style_chemist_desc"] or "Syringes and poisons.", key = "3"},
			{name = MuR.Language["mode52_style_trapper"] or "Trapper", desc = MuR.Language["mode52_style_trapper_desc"] or "Traps and drone.", key = "4"},
			{name = MuR.Language["mode52_style_manipulator"] or "Manipulator", desc = MuR.Language["mode52_style_manipulator_desc"] or "Mind control serum.", key = "5"},
			{name = MuR.Language["mode52_style_ballistarius"] or "Ballistarius", desc = MuR.Language["mode52_style_ballistarius_desc"] or "Crossbow and traps.", key = "6"}
		}

		local optionY = menuY + He(110)
		local optionH = He(100)
		local optionSpacing = He(8)
		local mouseX, mouseY = gui.MousePos()

		hoveredStyle = 0

		for i, style in ipairs(styles) do
			local optionX = menuX + We(30)
			local optionW = menuW - We(60)
			local optionYPos = optionY + (i - 1) * (optionH + optionSpacing)

			local isHovered = mouseX >= optionX and mouseX <= optionX + optionW and
				mouseY >= optionYPos and mouseY <= optionYPos + optionH

			if isHovered then
				hoveredStyle = i
				if lastHoveredStyle ~= hoveredStyle then
					if CurTime() - lastHoverSoundPlayed > 0.2 then
						surface.PlaySound("garrysmod/ui_click.wav")
						lastHoverSoundPlayed = CurTime()
					end
					lastHoveredStyle = hoveredStyle
				end
			end

			local isSelected = selectedStyle == i
			local isHoveredNow = hoveredStyle == i

			local bgColor = THEME.panel
			if isSelected then
				bgColor = Color(THEME.accent.r/4, THEME.accent.g/4, THEME.accent.b/4)
			elseif isHoveredNow then
				bgColor = Color(THEME.panel.r + 10, THEME.panel.g + 10, THEME.panel.b + 10)
			end

			draw.RoundedBox(8, optionX, optionYPos, optionW, optionH, bgColor)

			if isSelected then
				surface.SetDrawColor(THEME.accent)
				surface.DrawRect(optionX, optionYPos, We(3), optionH)
			end

			if isHoveredNow and not isSelected then
				surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 100)
				surface.DrawOutlinedRect(optionX, optionYPos, optionW, optionH)
			end

			local nameColor = isSelected and THEME.text or (isHoveredNow and THEME.text or THEME.textDark)
			draw.SimpleText(style.name, "MuR_Font3", optionX + We(20), optionYPos + He(12), nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			local descLines = WrapText("MuR_Font1", style.desc, optionW - We(60))
			local descY = optionYPos + He(42)
			for j, line in ipairs(descLines) do
				if descY + (j - 1) * He(12) < optionYPos + optionH - He(10) then
					draw.SimpleText(line, "MuR_Font1", optionX + We(20), descY + (j - 1) * He(12), THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
			end

			draw.SimpleText("[" .. style.key .. "]", "MuR_Font2", optionX + optionW - We(20), optionYPos + optionH / 2, THEME.textDark, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		local instruction = MuR.Language["mode52_press_key"] or "Press 1-6 or click to select"
		draw.SimpleText(instruction, "MuR_Font1", scrW / 2, menuY + menuH - He(20), THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end)

	hook.Add("PlayerButtonDown", "MuR.Mode52StyleSelection", function(ply, button)
		if not styleSelectionOpen then return end
		if ply != LocalPlayer() then return end

		local playerClass = ply:GetNW2String("Class", "")
		if playerClass != "Traitor" and playerClass != "Killer" then return end

		local keyToStyle = {
			[KEY_1] = 1,
			[KEY_2] = 2,
			[KEY_3] = 3,
			[KEY_4] = 4,
			[KEY_5] = 5,
			[KEY_6] = 6
		}

		local style = keyToStyle[button]
		if style and style >= 1 and style <= 6 then
			SelectStyle(style)
		end
	end)

	hook.Add("HUDPaint", "MuR.Mode52StyleSelectionClick", function()
		if not styleSelectionOpen then return end

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local playerClass = ply:GetNW2String("Class", "")
		if playerClass != "Traitor" and playerClass != "Killer" then return end

		if input.IsMouseDown(MOUSE_LEFT) and CurTime() - lastClickTime > 0.2 then
			lastClickTime = CurTime()

			local scrW, scrH = ScrW(), ScrH()
			local menuW, menuH = We(700), He(800)
			local menuX = (scrW - menuW) / 2
			local menuY = (scrH - menuH) / 2

			local optionY = menuY + He(110)
			local optionH = He(100)
			local optionSpacing = He(8)

			local mouseX, mouseY = gui.MousePos()

			for i = 1, 6 do
				local optionX = menuX + We(30)
				local optionW = menuW - We(60)
				local optionYPos = optionY + (i - 1) * (optionH + optionSpacing)

				if mouseX >= optionX and mouseX <= optionX + optionW and
					mouseY >= optionYPos and mouseY <= optionYPos + optionH then
					SelectStyle(i)
					break
				end
			end
		end
	end)
end
