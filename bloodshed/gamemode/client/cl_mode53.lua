if CLIENT then
	local teamSelectionOpen = false
	local selectionTime = 0
	local selectedTeam = 0
	local hoveredTeam = 0
	local voteStats = {
		oneTeam = 0,
		twoTeams = 0,
		total = 0
	}
	
	local THEME = {
		background = Color(15, 15, 20, 250),
		accent = Color(180, 40, 40),
		panel = Color(25, 25, 30, 255),
		text = Color(255, 255, 255),
		textDark = Color(200, 200, 200),
		success = Color(40, 180, 120),
		danger = Color(220, 50, 50),
		pmc = Color(50, 100, 200),
		wilds = Color(200, 100, 50)
	}
	
	local function We(x)
		return x / 1920 * ScrW()
	end
	
	local function He(y)
		return y / 1080 * ScrH()
	end
	
	local function SelectTeam(choice)
		if not teamSelectionOpen then return end
		if choice ~= 1 and choice ~= 2 then return end
		
		selectedTeam = choice
		net.Start("MuR.Mode53TeamSelected")
		net.WriteInt(choice, 8)
		net.SendToServer()
		
		surface.PlaySound("murdered/vgui/ui_click.wav")
	end
	
	net.Receive("MuR.Mode53TeamSelection", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		
		local playerClass = ply:GetNW2String("Class", "")
		if playerClass == "Tagila" then 
			return 
		end
		
		teamSelectionOpen = true
		selectionTime = CurTime() + 21
		selectedTeam = 0
		hoveredTeam = 0
		voteStats = {oneTeam = 0, twoTeams = 0, total = 0}
		
		gui.EnableScreenClicker(true)
		
		timer.Simple(21, function()
			if teamSelectionOpen then
				teamSelectionOpen = false
				gui.EnableScreenClicker(false)
				if selectedTeam == 0 then
					net.Start("MuR.Mode53TeamSelected")
					net.WriteInt(1, 8)
					net.SendToServer()
				end
			end
		end)
	end)
	
	net.Receive("MuR.Mode53VoteStats", function()
		voteStats.oneTeam = net.ReadInt(8)
		voteStats.twoTeams = net.ReadInt(8)
		voteStats.total = net.ReadInt(8)
	end)
	
	net.Receive("MuR.Mode53CloseMenu", function()
		if teamSelectionOpen then
			teamSelectionOpen = false
			gui.EnableScreenClicker(false)
		end
	end)
	
	hook.Add("HUDPaint", "MuR.Mode53TeamSelection", function()
		if not teamSelectionOpen then 
			return 
		end
		
		local ply = LocalPlayer()
		if not IsValid(ply) then 
			teamSelectionOpen = false
			gui.EnableScreenClicker(false)
			return 
		end
		
		local timeLeft = math.max(0, math.ceil(selectionTime - CurTime()))
		
		if timeLeft <= 0 then
			teamSelectionOpen = false
			gui.EnableScreenClicker(false)
			return
		end
		
		local scrW, scrH = ScrW(), ScrH()
		
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
		surface.SetDrawColor(THEME.accent)
		surface.DrawRect(menuX, menuY + He(60), menuW, He(2))
		
		surface.SetFont("MuR_Font3")
		draw.SimpleText("Выбор режима команд", "MuR_Font3", menuX + We(30), menuY + He(30), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetFont("MuR_Font2")
		draw.SimpleText("Осталось: " .. timeLeft .. " сек", "MuR_Font2", menuX + menuW - We(30), menuY + He(30), THEME.textDark, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		
		local contentY = menuY + He(80)
		local optionH = He(120)
		local optionSpacing = He(25)
		
		local opt1Y = contentY
		local opt1Hover = hoveredTeam == 1
		local opt1Selected = selectedTeam == 1
		local opt1BgColor = opt1Selected and Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 50) or (opt1Hover and Color(THEME.panel.r + 10, THEME.panel.g + 10, THEME.panel.b + 10, THEME.panel.a) or THEME.panel)
		draw.RoundedBox(8, menuX + We(20), opt1Y, menuW - We(40), optionH, opt1BgColor)
		
		local textX = menuX + We(40)
		surface.SetFont("MuR_Font3")
		draw.SimpleText("Одна команда", "MuR_Font3", textX, opt1Y + He(25), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		surface.SetFont("MuR_Font2")
		draw.SimpleText("Все игроки становятся ЧВК", "MuR_Font2", textX, opt1Y + He(50), THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Цель: Убить Тагилу", "MuR_Font2", textX, opt1Y + He(75), THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local rightX = menuX + menuW - We(220)
		local oneTeamPercent = (voteStats.total > 0) and math.Round((voteStats.oneTeam / voteStats.total) * 100) or 50
		draw.SimpleText("Процент выбора: " .. oneTeamPercent .. "%", "MuR_Font2", rightX, opt1Y + He(50), THEME.success, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local btn1W, btn1H = We(180), He(40)
		local btn1X = menuX + menuW - We(200)
		local btn1Y = opt1Y + He(85)
		local btn1Color = (opt1Hover or opt1Selected) and THEME.accent or THEME.background
		draw.RoundedBox(4, btn1X, btn1Y, btn1W, btn1H, btn1Color)
		local btn1Text = opt1Selected and "✓ Выбрано" or "Выбрать [1]"
		draw.SimpleText(btn1Text, "MuR_Font1", btn1X + btn1W/2, btn1Y + btn1H/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		local opt2Y = opt1Y + optionH + optionSpacing
		local opt2Hover = hoveredTeam == 2
		local opt2Selected = selectedTeam == 2
		local opt2BgColor = opt2Selected and Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 50) or (opt2Hover and Color(THEME.panel.r + 10, THEME.panel.g + 10, THEME.panel.b + 10, THEME.panel.a) or THEME.panel)
		draw.RoundedBox(8, menuX + We(20), opt2Y, menuW - We(40), optionH, opt2BgColor)
		
		surface.SetFont("MuR_Font3")
		draw.SimpleText("Две команды", "MuR_Font3", textX, opt2Y + He(25), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		surface.SetFont("MuR_Font2")
		draw.SimpleText("ЧВК и Дикие", "MuR_Font2", textX, opt2Y + He(50), THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Каждая команда за себя", "MuR_Font2", textX, opt2Y + He(75), THEME.textDark, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local twoTeamsPercent = (voteStats.total > 0) and math.Round((voteStats.twoTeams / voteStats.total) * 100) or 50
		draw.SimpleText("Процент выбора: " .. twoTeamsPercent .. "%", "MuR_Font2", rightX, opt2Y + He(50), THEME.success, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		local btn2W, btn2H = We(180), He(40)
		local btn2X = menuX + menuW - We(200)
		local btn2Y = opt2Y + He(85)
		local btn2Color = (opt2Hover or opt2Selected) and THEME.accent or THEME.background
		draw.RoundedBox(4, btn2X, btn2Y, btn2W, btn2H, btn2Color)
		local btn2Text = opt2Selected and "✓ Выбрано" or "Выбрать [2]"
		draw.SimpleText(btn2Text, "MuR_Font1", btn2X + btn2W/2, btn2Y + btn2H/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		surface.SetFont("MuR_Font2")
		draw.SimpleText("Нажмите 1 или 2 для выбора, или кликните на кнопку", "MuR_Font2", menuX + menuW / 2, menuY + menuH - He(30), THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
	
	hook.Add("PlayerButtonDown", "MuR.Mode53TeamSelection", function(ply, button)
		if not teamSelectionOpen then return end
		
		if button == KEY_1 then
			SelectTeam(1)
		elseif button == KEY_2 then
			SelectTeam(2)
		end
	end)
	
	hook.Add("HUDPaint", "MuR.Mode53TeamSelectionClick", function()
		if not teamSelectionOpen then return end
		
		local mx, my = gui.MousePos()
		local scrW, scrH = ScrW(), ScrH()
		local menuW, menuH = We(800), He(600)
		local menuX = (scrW - menuW) / 2
		local menuY = (scrH - menuH) / 2
		
		local contentY = menuY + He(80)
		local optionH = He(120)
		local optionSpacing = He(25)
		
		hoveredTeam = 0
		
		local btnW, btnH = We(180), He(40)
		local btnX = menuX + menuW - We(200)
		
		local opt1Y = contentY
		local btn1Y = opt1Y + He(85)
		if (mx >= menuX + We(20) and mx <= menuX + menuW - We(20) and my >= opt1Y and my <= opt1Y + optionH) or
		   (mx >= btnX and mx <= btnX + btnW and my >= btn1Y and my <= btn1Y + btnH) then
			hoveredTeam = 1
			if input.IsMouseDown(MOUSE_LEFT) then
				SelectTeam(1)
			end
		elseif (mx >= menuX + We(20) and mx <= menuX + menuW - We(20) and
			   my >= opt1Y + optionH + optionSpacing and my <= opt1Y + optionH + optionSpacing + optionH) or
			   (mx >= btnX and mx <= btnX + btnW and
				my >= opt1Y + optionH + optionSpacing + He(85) and my <= opt1Y + optionH + optionSpacing + He(85) + btnH) then
			hoveredTeam = 2
			if input.IsMouseDown(MOUSE_LEFT) then
				SelectTeam(2)
			end
		end
	end)
end
