
if CLIENT then
	local classSelectionOpen = false
	local selectionTime = 0
	local selectedClass = 0
	local hoveredClass = 0
	local isCombine = true
	local classCounts = {0, 0, 0, 0, 0}
	local classLimits = nil

	local THEME = {
		background = Color(15, 15, 20, 250),
		accent = Color(50, 100, 200),
		accentRebel = Color(200, 100, 50),
		panel = Color(25, 25, 30, 255),
		text = Color(255, 255, 255),
		textDark = Color(200, 200, 200)
	}

	local COMBINE_CLASSES = {
		{ name = "Wallhammer", desc = "Тяжёлый пехотинец, высокая защита, низкая мобильность", key = "1" },
		{ name = "Suppressor", desc = "Подавитель, высокая защита, высокая огневая мощь", key = "2" },
		{ name = "Combine Sniper Elite", desc = "Элитный Снайпер, низкая защита, высокая дальность", key = "3" },
		{ name = "Ordinal", desc = "Пехотинец, Средняя защита, Средняя мобильность", key = "4" },
		{ name = "Grunt", desc = "Лёгкий пехотинец, Низкая защита, высокая мобильность", key = "5" }
	}

	local REBEL_CLASSES = {
		{ name = "Rebel in H.E.V", desc = "Повстанец в H.E.V, возможно последняя надежда повстанцев", key = "1" },
		{ name = "Rebel with crossbow", desc = "Повстанец с арбалетом, средняя защита, высокая дальность", key = "2" },
		{ name = "Demolitionist Rebel", desc = "Подрывник, имеет РПГ-7", key = "3" },
		{ name = "Heavily armored rebel", desc = "Тяжеловооружённый повстанец, высокая защита, низкая мобильность", key = "4" },
		{ name = "Rebel", desc = "Повстанец, Средняя защита, Средняя мобильность", key = "5" }
	}

	local function We(x)
		return x / 1920 * ScrW()
	end

	local function He(y)
		return y / 1080 * ScrH()
	end

	local lastSelectTime = 0
	local function SelectClass(choice)
		if not classSelectionOpen then return end
		local maxChoice = 5
		if choice < 1 or choice > maxChoice then return end
		if classLimits and classLimits[choice] and (classCounts[choice] or 0) >= classLimits[choice] then return end
		if CurTime() - lastSelectTime < 0.8 then return end

		lastSelectTime = CurTime()
		selectedClass = choice
		net.Start("MuR.Mode54ClassSelected")
		net.WriteInt(choice, 8)
		net.SendToServer()

		surface.PlaySound("murdered/vgui/ui_click.wav")

	end

	local function DrawClassSelectionMenu()
		if not classSelectionOpen then return end

		local ply = LocalPlayer()
		if not IsValid(ply) then
			classSelectionOpen = false
			gui.EnableScreenClicker(false)
			return
		end

		local timeLeft = math.max(0, math.ceil(selectionTime - CurTime()))
		if timeLeft <= 0 then

			classSelectionOpen = false
			gui.EnableScreenClicker(false)
			hook.Remove("PostDrawHUD", "MuR.Mode54ClassSelection")
			hook.Remove("PostDrawHUD", "MuR.Mode54ClassSelectionClick")
			return
		end

		local scrW, scrH = ScrW(), ScrH()
		local classes = isCombine and COMBINE_CLASSES or REBEL_CLASSES
		local accent = isCombine and THEME.accent or THEME.accentRebel
		local title = isCombine and "Выбор класса Combine" or "Выбор класса Повстанцев"

		local blur = Material("pp/blurscreen")
		if blur then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(blur)
			for i = 1, 3 do
				blur:SetFloat("$blur", (i / 3) * 6)
				blur:Recompute()
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, scrW, scrH)
			end
		end

		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(0, 0, scrW, scrH)

		local menuW, menuH = We(800), He(600)
		local menuX = (scrW - menuW) / 2
		local menuY = (scrH - menuH) / 2

		draw.RoundedBox(8, menuX, menuY, menuW, menuH, THEME.background)
		draw.RoundedBox(8, menuX, menuY, menuW, He(60), THEME.panel)
		surface.SetDrawColor(accent)
		surface.DrawRect(menuX, menuY + He(60), menuW, He(2))

		surface.SetFont("MuR_Font3")
		draw.SimpleText(title, "MuR_Font3", menuX + We(30), menuY + He(30), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetFont("MuR_Font2")
		draw.SimpleText("Осталось: " .. timeLeft .. " сек", "MuR_Font2", menuX + menuW - We(30), menuY + He(30), THEME.textDark, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local contentY = menuY + He(80)
		local optionH = He(88)
		local optionSpacing = He(10)
		local textX = menuX + We(40)
		local btnW, btnH = We(160), He(36)
		local btnX = menuX + menuW - We(180)

		for i, cls in ipairs(classes) do
			local optY = contentY + (i - 1) * (optionH + optionSpacing)
			local optHover = hoveredClass == i
			local optSelected = selectedClass == i
			local optDisabled = classLimits and classLimits[i] and (classCounts[i] or 0) >= classLimits[i]
			local optBgColor = optSelected and Color(accent.r, accent.g, accent.b, 50) or (optHover and not optDisabled and Color(THEME.panel.r + 10, THEME.panel.g + 10, THEME.panel.b + 10, THEME.panel.a) or THEME.panel)
			draw.RoundedBox(8, menuX + We(20), optY, menuW - We(40), optionH, optBgColor)

			surface.SetFont("MuR_Font3")
			local limitStr = (classLimits and classLimits[i]) and (" (" .. (classCounts[i] or 0) .. "/" .. classLimits[i] .. ")") or ((classCounts[i] and classCounts[i] > 0) and (" (" .. classCounts[i] .. ")") or "")
			local textColor = optDisabled and Color(120, 120, 120) or THEME.text
			draw.SimpleText(cls.name .. limitStr, "MuR_Font3", textX, optY + He(12), textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			surface.SetFont("MuR_Font2")
			draw.SimpleText(cls.desc, "MuR_Font2", textX, optY + He(38), optDisabled and Color(100, 100, 100) or THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			local btnY = optY + He(58)
			local btnColor = (optHover or optSelected) and not optDisabled and accent or (optDisabled and Color(60, 60, 60) or THEME.background)
			draw.RoundedBox(4, btnX, btnY, btnW, btnH, btnColor)
			local btnText = optSelected and "✓ Выбрано" or (optDisabled and "Занято" or ("Выбрать [" .. cls.key .. "]"))
			draw.SimpleText(btnText, "MuR_Font1", btnX + btnW/2, btnY + btnH/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		surface.SetFont("MuR_Font2")
		draw.SimpleText("Нажмите 1-5 для выбора или кликните на кнопку", "MuR_Font2", menuX + menuW / 2, menuY + menuH - He(25), THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local function DrawClassSelectionClick()
		if not classSelectionOpen then return end

		local mx, my = gui.MousePos()
		local scrW, scrH = ScrW(), ScrH()
		local menuW, menuH = We(800), He(600)
		local menuX = (scrW - menuW) / 2
		local menuY = (scrH - menuH) / 2
		local contentY = menuY + He(80)
		local optionH = He(88)
		local optionSpacing = He(10)
		local btnW, btnH = We(160), He(36)
		local btnX = menuX + menuW - We(180)

		hoveredClass = 0

		local maxOpts = 5
		for i = 1, maxOpts do
			local optY = contentY + (i - 1) * (optionH + optionSpacing)
			local btnY = optY + He(58)
			local optDisabled = classLimits and classLimits[i] and (classCounts[i] or 0) >= classLimits[i]
			local inOpt = (mx >= menuX + We(20) and mx <= menuX + menuW - We(20) and my >= optY and my <= optY + optionH)
			local inBtn = (mx >= btnX and mx <= btnX + btnW and my >= btnY and my <= btnY + btnH)
			if (inOpt or inBtn) and not optDisabled then
				hoveredClass = i
				if input.IsMouseDown(MOUSE_LEFT) then
					SelectClass(i)
				end
				break
			end
		end
	end

	net.Receive("MuR.Mode54ClassSelection", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		isCombine = net.ReadBool()
		local numClasses = 5
		for i = 1, 5 do classCounts[i] = 0 end
		for i = 1, numClasses do
			classCounts[i] = net.ReadUInt(8)
		end
		classLimits = {}
		for i = 1, numClasses do
			local lim = net.ReadUInt(8)
			classLimits[i] = (lim > 0) and lim or nil
		end
		classSelectionOpen = true
		selectionTime = CurTime() + 12
		selectedClass = 0
		hoveredClass = 0

		gui.EnableScreenClicker(true)

		hook.Add("PostDrawHUD", "MuR.Mode54ClassSelection", DrawClassSelectionMenu)
		hook.Add("PostDrawHUD", "MuR.Mode54ClassSelectionClick", DrawClassSelectionClick)
	end)

	net.Receive("MuR.Mode54CloseClassMenu", function()
		if classSelectionOpen then
			classSelectionOpen = false
			gui.EnableScreenClicker(false)
			hook.Remove("PostDrawHUD", "MuR.Mode54ClassSelection")
			hook.Remove("PostDrawHUD", "MuR.Mode54ClassSelectionClick")

		end
	end)

	net.Receive("MuR.Mode54ClassCounts", function()
		for i = 1, 5 do classCounts[i] = 0 end
		for i = 1, 5 do
			classCounts[i] = net.ReadUInt(8)
		end
	end)

	net.Receive("MuR.Mode54ClassRejected", function()
		local reason = net.ReadString()
		if reason and reason ~= "" then
			chat.AddText(Color(255, 100, 100), "[Режим 54] ", color_white, reason)
		end
	end)

	hook.Add("PlayerButtonDown", "MuR.Mode54ClassSelection", function(ply, button)
		if not classSelectionOpen then return end
		if button == KEY_1 or button == KEY_PAD_1 then SelectClass(1)
		elseif button == KEY_2 or button == KEY_PAD_2 then SelectClass(2)
		elseif button == KEY_3 or button == KEY_PAD_3 then SelectClass(3)
		elseif button == KEY_4 or button == KEY_PAD_4 then SelectClass(4)
		elseif button == KEY_5 or button == KEY_PAD_5 then SelectClass(5)
		end
	end)
end
