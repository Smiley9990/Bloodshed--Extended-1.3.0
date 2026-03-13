hook.Add("InitPostEntity", "MuR.Run", function()
	RunConsoleCommand("zbase_ply_hurt_ally", 1)
	RunConsoleCommand("sv_alltalk", 1)
end)

if SERVER then
	util.AddNetworkString("MuR.ModesStateReq")
	util.AddNetworkString("MuR.ModesState")
	util.AddNetworkString("MuR.ModesStateSave")
end

net.Receive("MuR.VoiceLines", function(len, ply)
	if !ply:Alive() or ply:GetNW2Bool("IsUnconscious", false) then return end
	local num = net.ReadFloat()
	local str = ""
	if num == 1 then
		str = "question"
	elseif num == 2 then
		str = "answer"
	elseif num == 3 then
		str = "help"
	elseif num == 4 then
		str = "hell"
	elseif num == 5 then
		str = "panic"
	elseif num == 6 then
		str = "cops"
	elseif num == 7 then
		str = "trust"
	elseif num == 8 then
		str = "sorry"
	elseif num == 9 then
		str = "happy"
	elseif num == 10 then
		str = "back"
	elseif num == 11 then
		str = "oops"
	elseif num == 12 then
		str = "go"
	elseif num == 13 then
		str = "injured"
	elseif num == 14 then
		str = "hello"
	elseif num == 101 then
		str = "police_surrender"
	elseif num == 102 then
		str = "police_dropgun"
	elseif num == 103 then
		str = "police_havegun"
	elseif num == 104 then
		str = "police_getground"
	elseif num == 105 then
		str = "police_dontmove"
	elseif num == 106 then
		str = "police_shotfired"
	elseif num == 140 then
		str = "ror_police_surrender"
	end
	ply:PlayVoiceLine(str)
end)

net.Receive("MuR.Mode52StyleSelected", function(len, ply)
	if not MuR.GameStarted or MuR.Gamemode ~= 52 then return end
	local selectedStyle = net.ReadInt(8)
	if selectedStyle < 1 or selectedStyle > 6 then return end
	if not ply.Mode52StyleSelectionTime or CurTime() > ply.Mode52StyleSelectionTime then return end
	MuR.Mode52TraitorSelections = MuR.Mode52TraitorSelections or {}
	MuR.Mode52TraitorSelections[ply:SteamID64()] = selectedStyle
end)

net.Receive("MuR.Mode53TeamSelected", function(len, ply)
	if not MuR.GameStarted or MuR.Gamemode ~= 53 then return end
	if not IsValid(ply) then return end
	
	local playerClass = ply:GetNW2String("Class", "")
	if playerClass == "Tagila" then return end
	
	if not ply.Mode53TeamSelectionTime or CurTime() > ply.Mode53TeamSelectionTime then return end
	
	local selectedTeam = net.ReadInt(8)
	if selectedTeam == 1 or selectedTeam == 2 then
		if not MuR.Mode53TeamSelections then
			MuR.Mode53TeamSelections = {}
		end
		MuR.Mode53TeamSelections[ply:SteamID64()] = selectedTeam
		
		local totalVoters = 0
		local votedCount = 0
		
		for _, p in ipairs(player.GetAll()) do
			if IsValid(p) and p:GetNW2String("Class", "") != "Tagila" then
				totalVoters = totalVoters + 1
				if MuR.Mode53TeamSelections[p:SteamID64()] then
					votedCount = votedCount + 1
				end
			end
		end
		
		if totalVoters > 0 and votedCount >= totalVoters then
			net.Start("MuR.Mode53CloseMenu")
			net.Broadcast()
		end
	end
end)

local MODE54_CLASS_LIMITS = {
	Combine = {1, 1, 1, nil, nil},
	Rebel = {1, 1, 1, 2, nil}
}

net.Receive("MuR.Mode54ClassSelected", function(len, ply)
	if not MuR.GameStarted or MuR.Gamemode ~= 54 then return end
	if not IsValid(ply) then return end

	local class = ply:GetNW2String("Class", "")
	if class ~= "Combine" and class ~= "Rebel" then return end

	local selectedClass = net.ReadInt(8)
	local maxClass = 5
	if selectedClass < 1 or selectedClass > maxClass then return end

	local currentType = (class == "Combine") and ply:GetNW2Int("CombineType", 1) or ply:GetNW2Int("RebelType", 1)
	if currentType == selectedClass then return end

	local counts = (class == "Combine") and (MuR.Mode54CombineCounts or {0,0,0,0,0}) or (MuR.Mode54RebelCounts or {0,0,0,0,0})
	local limits = MODE54_CLASS_LIMITS[class]
	if limits and limits[selectedClass] then
		local current = counts[selectedClass] or 0
		if current >= limits[selectedClass] then
			net.Start("MuR.Mode54ClassRejected")
			net.WriteString("Этот класс уже занят (лимит " .. limits[selectedClass] .. ").")
			net.Send(ply)
			return
		end
	end

	if counts[currentType] and counts[currentType] > 0 then
		counts[currentType] = counts[currentType] - 1
	end
	counts[selectedClass] = (counts[selectedClass] or 0) + 1

		for _, p in ipairs(player.GetAll()) do
			if IsValid(p) and p:GetNW2String("Class") == class then
				net.Start("MuR.Mode54ClassCounts")
				for i = 1, 5 do net.WriteUInt(counts[i] or 0, 8) end
				net.Send(p)
			end
		end

	ply.Mode54HasChosen = true

	if class == "Combine" then
		ply:SetNW2Int("CombineType", selectedClass)
	else
		ply:SetNW2Int("RebelType", selectedClass)
	end

	ply:KillSilent()
	timer.Simple(0.1, function()
		if IsValid(ply) then
			ply:Spawn()
			ply:Freeze(true)
			ply:GodEnable()
			local remain = math.max(0, 12 - (CurTime() - (MuR.TimeCount or CurTime())))
			timer.Simple(remain, function()
				if IsValid(ply) then
					ply:Freeze(false)
					ply:GodDisable()
				end
			end)
		end
	end)
end)

local police_voicelines = {
	["surrender"] = {
		")murdered/player/police/surrender (1).mp3",
		")murdered/player/police/surrender (9).mp3",
		")murdered/player/police/surrender (11).mp3",
		")murdered/player/police/surrender (12).mp3",
		")murdered/player/police/surrender (13).mp3",
		")murdered/player/police/surrender (17).mp3",
		")murdered/player/police/surrender (18).mp3",
		")murdered/player/police/surrender (19).mp3",
		")murdered/player/police/surrender (20).mp3",
		")murdered/player/police/surrender (21).mp3",
		")murdered/player/police/surrender (23).mp3",
		")murdered/player/police/surrender (24).mp3",
		")murdered/player/police/surrender (25).mp3",
	},
	["havegun"] = {
		")murdered/player/police/surrender (4).mp3",
		")murdered/player/police/surrender (7).mp3",
		")murdered/player/police/surrender (29).mp3",
	},
	["dropgun"] = {
		")murdered/player/police/surrender (2).mp3",
		")murdered/player/police/surrender (3).mp3",
		")murdered/player/police/surrender (5).mp3",
		")murdered/player/police/surrender (6).mp3",
		")murdered/player/police/surrender (8).mp3",
		")murdered/player/police/surrender (10).mp3",
		")murdered/player/police/surrender (28).mp3",
		")murdered/player/police/surrender (30).mp3",
		")murdered/player/police/surrender (31).mp3",
	},
	["dontmove"] = {
		")murdered/player/police/surrender (14).mp3",
		")murdered/player/police/surrender (16).mp3",
		")murdered/player/police/surrender (26).mp3",
	},
	["getground"] = {
		")murdered/player/police/surrender (15).mp3",
		")murdered/player/police/surrender (20).mp3",
		")murdered/player/police/surrender (22).mp3",
	},
}

local meta = FindMetaTable("Player")
function meta:PlayVoiceLine(str, force)
	if self:GetNW2Bool("IsUnconscious", false) then
		if isstring(self.LastVoiceLine) then
			if IsValid(self:GetRD()) then
				self:GetRD():StopSound(self.LastVoiceLine)
			end
			self:StopSound(self.LastVoiceLine)
		end
		return
	end

	if force or isstring(self.LastVoiceLineType) and self.LastVoiceLineType == "death_fly" and str ~= "death_fly" then
		self.VoiceDelay = 0
	end

	local cls = self:GetNW2String("Class")
	if self.VoiceDelay > CurTime() or str == "" or cls == "Zombie" or cls == "CombineSoldier" or cls == "Combine" or cls == "Maniac" or cls == "Entity" then return end
	if isstring(self.LastVoiceLine) then
		if IsValid(self:GetRD()) then
			self:GetRD():StopSound(self.LastVoiceLine)
		end
		self:StopSound(self.LastVoiceLine)
	end

	local snd = ""
	local dur = 0
	local decibel = 70
	if str == "police_shotfired" then
		snd = ")murdered/player/police/shotfired (" .. math.random(1,4) .. ").mp3"
		decibel = 80
	elseif str == "police_surrender" then
		snd = table.Random(police_voicelines["surrender"])
		decibel = 80
	elseif str == "ror_police_surrender" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/yelltarget (" .. math.random(1,64) .. ").wav"
		decibel = 80
	elseif str == "ror_police_arrestingsuspect" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/arresting (" .. math.random(1,15) .. ").wav"
		decibel = 65
	elseif str == "ror_police_reportarrestedsuspect" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/reportarrestedsuspect (" .. math.random(1,16) .. ").wav"
		decibel = 70
	elseif str == "ror_police_reportcivilianarrested" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/reportcivilianarrested (" .. math.random(1,15) .. ").wav"
		decibel = 70
	elseif str == "ror_police_deadciv" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/deadciv (" .. math.random(1,11) .. ").wav"
		decibel = 70
	elseif str == "ror_police_deadsus" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/deadsus (" .. math.random(1,12) .. ").wav"
		decibel = 70
	elseif str == "ror_police_deadswat" then
		if MuR.Gamemode != 14 then return end
		snd = ")murdered/player/swat/deadswat (" .. math.random(1,12) .. ").wav"
		decibel = 70
	elseif str == "police_dropgun" then
		snd = table.Random(police_voicelines["dropgun"])
		decibel = 80
	elseif str == "police_havegun" then
		snd = table.Random(police_voicelines["havegun"])
		decibel = 80
	elseif str == "police_dontmove" then
		snd = table.Random(police_voicelines["dontmove"])
		decibel = 80
	elseif str == "police_getground" then
		snd = table.Random(police_voicelines["getground"])
		decibel = 80
	elseif str == "death_default" then
		if self:GetNW2String("Class") == "Shooter" then return end
		if self.Male then
			snd = ")murdered/player/deathmale/bullet/death_bullet" .. math.random(1,104) .. ".ogg"
		else
			snd = ")murdered/player/deathfemale/bullet/death_bullet" .. math.random(1,50) .. ".ogg"
		end
		if MuR.Gamemode == 14 then
			snd = ")murdered/player/swat/pain (" .. math.random(1,24) .. ").wav"
		end
		if math.random(1,8) == 1 then return end
		decibel = 60
	elseif str == "death_blunt" then
		if self:GetNW2String("Class") == "Shooter" then return end
		if self.Male then
			snd = ")murdered/player/deathmale/blunt/death_blunt"..math.random(1,38)..".ogg"
		else
			snd = ")murdered/player/deathfemale/blunt/death_blunt"..math.random(1,13)..".ogg"
		end
		snd = ")murdered/player/swat/pain (" .. math.random(1,24) .. ").wav"
		if math.random(1,8) == 1 then return end
		decibel = 60
	elseif str == "death_fly" then
		if self:GetNW2String("Class") == "Shooter" then return end
		if self.Male then
			snd = ")murdered/player/deathmale/flying/death_fly"..math.random(1,6)..".ogg"
		else
			snd = ")murdered/player/deathfemale/flying/death_fly"..math.random(1,4)..".ogg"
		end
		dur = dur + 4
		decibel = 75
	elseif str == "question" then
		if self.Male then
			local rnd = math.random(1,31)
			if rnd < 10 then
				rnd = "0"..rnd
			end
			snd = "vo/npc/male01/question"..rnd..".wav"
		else
			local rnd = math.random(1,31)
			if rnd < 10 then
				rnd = "0"..rnd
			end
			snd = "vo/npc/female01/question"..rnd..".wav"
		end
	elseif str == "answer" then
		if self.Male then
			local rnd = math.random(1,40)
			if rnd < 10 then
				rnd = "0"..rnd
			end
			snd = "vo/npc/male01/answer"..rnd..".wav"
		else
			local rnd = math.random(1,40)
			if rnd < 10 then
				rnd = "0"..rnd
			end
			snd = "vo/npc/female01/answer"..rnd..".wav"
		end
	elseif str == "help" then
		if self.Male then
			snd = "vo/npc/male01/help01.wav"
		else
			snd = "vo/npc/female01/help01.wav"
		end
	elseif str == "hell" then
		if self.Male then
			snd = "vo/npc/male01/gethellout.wav"
		else
			snd = "vo/npc/female01/gethellout.wav"
		end
	elseif str == "panic" then
		if self.Male then
			snd = "vo/npc/male01/runforyourlife0"..math.random(1,3)..".wav"
		else
			snd = "vo/npc/female01/runforyourlife0"..math.random(1,2)..".wav"
		end
	elseif str == "cops" then
		if self.Male then
			snd = "vo/npc/male01/civilprotection0"..math.random(1,2)..".wav"
		else
			snd = "vo/npc/female01/civilprotection0"..math.random(1,2)..".wav"
		end
	elseif str == "trust" then
		if self.Male then
			snd = "vo/npc/male01/wetrustedyou0"..math.random(1,2)..".wav"
		else
			snd = "vo/npc/female01/wetrustedyou0"..math.random(1,2)..".wav"
		end
	elseif str == "sorry" then
		if self.Male then
			snd = "vo/npc/male01/sorry0"..math.random(1,3)..".wav"
		else
			snd = "vo/npc/female01/sorry0"..math.random(1,3)..".wav"
		end
	elseif str == "happy" then
		local tabm = {"vo/npc/male01/yeah02.wav", "vo/npc/male01/nice.wav", "vo/npc/male01/finally.wav", "vo/npc/male01/fantastic01.wav", "vo/npc/male01/fantastic02.wav"}
		local tabf = {"vo/npc/female01/yeah02.wav", "vo/npc/female01/nice.wav", "vo/npc/female01/finally.wav", "vo/npc/female01/fantastic01.wav", "vo/npc/female01/fantastic02.wav"}
		if self.Male then
			snd = table.Random(tabm)
		else
			snd = table.Random(tabf)
		end
	elseif str == "back" then
		local tabm = {"vo/npc/male01/watchout.wav", "vo/npc/male01/behindyou01.wav", "vo/npc/male01/behindyou02.wav"}
		local tabf = {"vo/npc/female01/watchout.wav", "vo/npc/female01/behindyou01.wav", "vo/npc/female01/behindyou02.wav"}
		if self.Male then
			snd = table.Random(tabm)
		else
			snd = table.Random(tabf)
		end
	elseif str == "oops" then
		local tabm = {"vo/npc/male01/uhoh.wav", "vo/npc/male01/whoops01.wav"}
		local tabf = {"vo/npc/female01/uhoh.wav", "vo/npc/female01/whoops01.wav"}
		if self.Male then
			snd = table.Random(tabm)
		else
			snd = table.Random(tabf)
		end
	elseif str == "go" then
		if self.Male then
			snd = "vo/npc/male01/letsgo0"..math.random(1,2)..".wav"
		else
			snd = "vo/npc/female01/letsgo0"..math.random(1,2)..".wav"
		end
	elseif str == "injured" then
		local tabm = {"vo/npc/male01/imhurt01.wav", "vo/npc/male01/imhurt02.wav", "vo/npc/male01/mygut02.wav", "vo/npc/male01/myleg01.wav", "vo/npc/male01/myleg02.wav", "vo/npc/male01/myarm01.wav", "vo/npc/male01/myarm02.wav"}
		local tabf = {"vo/npc/female01/imhurt01.wav", "vo/npc/female01/imhurt02.wav", "vo/npc/female01/mygut02.wav", "vo/npc/female01/myleg01.wav", "vo/npc/female01/myleg02.wav", "vo/npc/female01/myarm01.wav", "vo/npc/female01/myarm02.wav"}
		if self.Male then
			snd = table.Random(tabm)
		else
			snd = table.Random(tabf)
		end
	elseif str == "hello" then
		if self.Male then
			snd = "vo/npc/male01/hi0"..math.random(1,2)..".wav"
		else
			snd = "vo/npc/female01/hi0"..math.random(1,2)..".wav"
		end
	elseif str == "execution_mercy" then
		if self.Male then
			snd = ")murdered/player/executions/mexec ("..math.random(1,46)..").mp3"
		else
			snd = ")murdered/player/executions/fexec ("..math.random(1,14)..").mp3"
		end
		decibel = 55
	elseif str == "execution_kill" then
		if self:GetNW2String("Class") != "Shooter" then return end
		snd = ")murdered/player/executions/aexec ("..math.random(1,29)..").mp3"
		decibel = 55
	elseif str == "shooter_intro" then
		if self:GetNW2String("Class") != "Shooter" then return end
		snd = ")murdered/player/executions/shooter_intro.mp3"
		decibel = 70
	elseif str == "floyd1" then
		if self:GetNW2String("Class") != "GeorgeDroidFloyd" then return end
		snd = "murdered/player/floyd/floyd1.wav"
		decibel = 70
	elseif str == "floyd2" then
		if self:GetNW2String("Class") != "GeorgeDroidFloyd" then return end
		snd = "murdered/player/floyd/floyd2.wav"
		decibel = 70
	elseif str == "floyd3" then
		if self:GetNW2String("Class") != "GeorgeDroidFloyd" then return end
		snd = "murdered/player/floyd/floyd3.wav"
		decibel = 70
	end

	dur = dur+SoundDuration(snd)
	if dur < 1 then
		dur = 1
	elseif dur > 6 then
		dur = 6
	end
	self.VoiceDelay = CurTime()+dur
	self.LastVoiceLineType = str
	self.LastVoiceLine = snd
	local pitch = self.PitchVoice or 100
	timer.Simple(0.01, function()
		if IsValid(self:GetRD()) then
			self:GetRD():EmitSound(snd, decibel, pitch)
		elseif IsValid(self) then
			self:EmitSound(snd, decibel, pitch)
		end
	end)
end

concommand.Add("mur_ragdoll", function(ply)
	if MuR.Gamemode == 55 and ply:GetNW2String("Class") == "Hidden" then return end
	if ply:Alive() and not ply:GetNW2Bool("IsUnconscious", false) then
		local rag = ply:GetRD()
		if IsValid(rag) then

			local pos = MuR:BoneData(rag, "ValveBiped.Bip01_Pelvis")
			if ply:TimeGetUp(true) and MuR:CheckHeight(rag, pos) < 72 and ply:CanGetUp() and not rag.Gibbed and not rag.IsNailed then
				if MuR:CheckHeight(rag, pos) < 16 then
					ply:StopRagdolling(false, true)
				else
					ply:StopRagdolling(false)
				end
			end
		else
			ply:StartRagdolling()
		end
	end
end)

concommand.Add("mur_wep_drop", function(ply)
	local wep = ply:GetActiveWeapon()
	if timer.Exists("MindControl_" .. ply:EntIndex()) or not ply:Alive() or not IsValid(wep) or wep.CantDrop then return end
	ply:SelectWeapon("mur_hands")
	ply:DropWeapon(wep)
end)

concommand.Add("mur_wep_unload", function(ply)
	local wep = ply:GetActiveWeapon()
	if timer.Exists("MindControl_" .. ply:EntIndex()) or not ply:Alive() or not IsValid(wep) or wep:GetMaxClip1() < 1 then return end

	if wep:Clip1() > 0 then
		ply:EmitSound("items/ammocrate_open.wav", 60)
		ply:GiveAmmo(wep:Clip1(), wep:GetPrimaryAmmoType(), true)
		wep:SetClip1(0)
	end
end)

concommand.Add("mur_surrender", function(ply)
	if not ply:Alive() then return end
	ply:Surrender()
end)

concommand.Add("mur_give", function(ply, cmd, args)
	if ply:IsSuperAdmin() and args[1] then
		ply:GiveWeapon(args[1])
	end
end)

concommand.Add("mur_restartround", function(ply)
	if ply:IsSuperAdmin() and !MuR.EnableDebug then
		if MuR.GameStarted and MuR.TimeCount < CurTime() - 12 then
			MuR:ChangeStateOfGame(false)
		end
	end
end)

concommand.Add("mur_resetguilt", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		ply:SetNW2Float("Guilt", 0)
	end
end)

concommand.Add("mur_nextgamemode", function(ply, cmd, args)
	if ply:IsSuperAdmin() and args[1] then
		local num = tonumber(args[1])

		if num and MuR.Modes and MuR.Modes[num] then
			MuR.NextGamemode = num
		end
	end
end)

concommand.Add("mur_disablemode", function(ply, cmd, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local id = tonumber(args[1] or -1)
	local val = tonumber(args[2] or 0)
	if not id or not MuR.Modes[id] then return end
	MuR.Modes[id].enabled = (val == 0)
	if MuR.RebuildGamemodeChances then
		MuR:RebuildGamemodeChances()
	end
end)

net.Receive("MuR.ModesStateReq", function(_, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local disabled = {}
	for id, def in pairs(MuR.Modes or {}) do
		if def.enabled == false then disabled[id] = true end
	end
	net.Start("MuR.ModesState")
	net.WriteTable(disabled)
	net.Send(ply)
end)

local MODES_STATE_PATH = "bloodshed/modes_state.json"
local function ApplyDisabledSet(disabledSet)
	for id, def in pairs(MuR.Modes or {}) do
		def.enabled = not (disabledSet and disabledSet[id] == true)
	end
	if MuR.RebuildGamemodeChances then
		MuR:RebuildGamemodeChances()
	end
end

local function SaveDisabledSet(disabledSet)
	if not istable(disabledSet) then return end
	local json = util.TableToJSON(disabledSet, false)
	if json then
		file.CreateDir("bloodshed")
		file.Write(MODES_STATE_PATH, json)
	end
end

net.Receive("MuR.ModesStateSave", function(_, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local payload = net.ReadTable() or {}
	local set = {}
	if istable(payload) then
		if istable(payload._asSet) then
			for k, v in pairs(payload._asSet) do
				local id = tonumber(k)
				if id and MuR.Modes[id] and v == true then set[id] = true end
			end
		else
			for _, v in ipairs(payload) do
				local id = tonumber(v)
				if id and MuR.Modes[id] then set[id] = true end
			end
		end
	end
	ApplyDisabledSet(set)
	SaveDisabledSet(set)
	local disabled = {}
	for id, def in pairs(MuR.Modes or {}) do if def.enabled == false then disabled[id] = true end end
	net.Start("MuR.ModesState")
	net.WriteTable(disabled)
	net.Send(ply)
end)

do
	if file.Exists(MODES_STATE_PATH, "DATA") then
		local txt = file.Read(MODES_STATE_PATH, "DATA")
		local ok, tbl = pcall(util.JSONToTable, txt or "")
		if ok and istable(tbl) then
			local set = {}
			for k, v in pairs(tbl) do
				local id = tonumber(k) or tonumber(v)
				if id and MuR.Modes and MuR.Modes[id] and (v == true or tonumber(v) ~= nil) then
					set[id] = true
				end
			end
			ApplyDisabledSet(set)
		end
	end
end

concommand.Add("mur_nexttraitor", function(ply, cmd, args)
	if ply:IsSuperAdmin() and args[1] then
		for _, ply in player.Iterator() do
			if args[1] and string.match(ply:Name(), args[1]) then
				MuR.NextTraitor = ply
			end
			if args[2] and string.match(ply:Name(), args[2]) then
				MuR.NextTraitor2 = ply
			end
		end
	end
end)

net.Receive("MuR.NextModeRoleAssign", function(len, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local modeId = net.ReadUInt(16)
	local roleClass = net.ReadString()
	local playerId = net.ReadString()
	if not modeId or not MuR.Modes or not MuR.Modes[modeId] then return end
	MuR.NextModeRoleAssignments = MuR.NextModeRoleAssignments or {}
	if not MuR.NextModeRoleAssignments[modeId] then
		MuR.NextModeRoleAssignments[modeId] = {}
	end
	if playerId == "" or not playerId then
		MuR.NextModeRoleAssignments[modeId][roleClass] = nil
	else
		MuR.NextModeRoleAssignments[modeId][roleClass] = playerId
	end
end)

net.Receive("MuR.NextMode56Settings", function(len, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local initialSender = net.ReadString()
	local reinforcementType = net.ReadString()
	MuR.NextMode56InitialSender = (initialSender == "SSmiley" or initialSender == "MaSSka") and initialSender or nil
	MuR.NextMode56ReinforcementType = (reinforcementType == "RussianMafia" or reinforcementType == "Bravo6" or reinforcementType == "PMC") and reinforcementType or nil
end)

concommand.Add("mur_forcespawn", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local plys = nil

		for k, ply2 in player.Iterator() do
			if string.match(ply2:Nick(), args[1]) then
				plys = ply2
				break
			end
		end

		plys.ForceSpawn = true

		if args[2] then
			plys:SetNW2String("Class", args[2])
		end

		plys:StopRagdolling()
		plys:Spawn()
	end
end)

concommand.Add("mur_resetguilt_ply", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local plys = nil

		for k, ply2 in player.Iterator() do
			if string.match(ply2:Nick(), args[1]) then
				plys = ply2
				break
			end
		end

		plys:SetNW2Float("Guilt", 0)
	end
end)

concommand.Add("mur_explode", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local plys = nil

		for k, ply2 in player.Iterator() do
			if string.match(ply2:Nick(), args[1]) then
				plys = ply2
				break
			end
		end

		local snd = ""
		if plys.Male then
			snd = "murdered/player/sneeze_m.wav"
		else
			snd = "murdered/player/sneeze_f.wav"
		end
		plys:EmitSound(snd, 60, plys.PitchVoice or 100)
		timer.Simple(1, function()
			if not IsValid(plys) then return end
			plys:ViewPunch(Angle(8, 0, 0))
			plys:SetVelocity(Vector(0,0,1000))
		end)
		timer.Simple(1.05, function()
			if not IsValid(plys) then return end
			util.BlastDamage(game.GetWorld(), game.GetWorld(), plys:GetPos(), 10, 9999)
		end)
	end
end)

concommand.Add("mur_grenadethrow", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local gr = ents.Create("murwep_grenade")
		gr:SetPos(ply:EyePos()+ply:GetForward()*32)
		gr:Spawn()
		local phys = gr:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ply:GetAimVector()*512)
		end
	end
end)

concommand.Add("mur_bomj", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		ply:AddMoney(1000000)
	end
end)

concommand.Add("mur_playersinfo", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local players = player.GetAll()
		local output = "=== PLAYER LIST AND THEIR ROLES ===\n"
		output = output .. string.format("PLAYER COUNT: %d\n", #players)
		output = output .. string.format("MODE: %d\n", MuR.Gamemode or 0)
		output = output .. "==============================\n"

		for i, p in ipairs(players) do
			local name = p:Nick()
			local class = p:GetNW2String("Class", "Unknown")
			local team = p:Team()
			local alive = p:Alive() and "ALIVE" or "DEAD"
			local guilt = p:GetNW2Float("Guilt", 0)

			output = output .. string.format("[%d] %s\n", i, name)
			output = output .. string.format("    Role: %s | Team: %d | %s\n", class, team, alive)
			output = output .. string.format("    Guilt: %.2f\n", guilt)
			output = output .. "------------------------------\n"
		end

		print(output)
	end
end)

concommand.Add("mur_sandboxtoggle", function(ply)
	if ply:IsSuperAdmin() then
		if !MuR.EnableDebug then MuR.NextGamemode = 5 end
		local newvalue = !MuR.EnableDebug
		MuR.EnableDebug = newvalue
		MuR:SendDataToClient("EnableDebug", newvalue)
		timer.Simple(1, function()
			MuR:ChangeStateOfGame(false)
		end)
	end
end)

concommand.Add("mur_killnpcs", function(ply)
	if ply:IsSuperAdmin() then
		local count = 0
		for _, npc in ents.Iterator() do
			if npc:IsNPC() or npc:IsNextBot() then
				npc:Remove()
				count = count + 1
			end
		end
		ply:ChatPrint("[MuR] Removed " .. count .. " NPCs")
	end
end)

concommand.Add("mur_npc_debug", function(ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local aiCount = MuR.AI_Nodes and #MuR.AI_Nodes or 0
	local pos1 = MuR:GetRandomPos(true)
	local pos2 = MuR:GetRandomPos(false)
	local mode = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
	local vjExists = VJ_Nodegraph ~= nil
	local navCount = 0
	if navmesh and navmesh.GetAllNavAreas then
		local areas = navmesh.GetAllNavAreas()
		navCount = areas and #areas or 0
	end
	ply:ChatPrint("[MuR NPC Debug] AI_Nodes: " .. aiCount .. " | VJ_Nodegraph: " .. (vjExists and "yes" or "no") .. " | NavAreas: " .. navCount)
	ply:ChatPrint("[MuR NPC Debug] GetRandomPos(true): " .. (isvector(pos1) and "OK" or "nil") .. " | GetRandomPos(false): " .. (isvector(pos2) and "OK" or "nil"))
	ply:ChatPrint("[MuR NPC Debug] Gamemode: " .. tostring(MuR.Gamemode) .. " | no_npc_police_spawn: " .. tostring(mode.no_npc_police_spawn) .. " | PoliceState: " .. tostring(MuR.PoliceState) .. " | NPC_To_Spawn: " .. tostring(MuR.NPC_To_Spawn))
	if MuR.Gamemode == 14 and MuR.Mode14 then
		ply:ChatPrint("[MuR NPC Debug] Mode14: NPCSpawned=" .. MuR.Mode14.NPCSpawned .. " NPCToSpawn=" .. MuR.Mode14.NPCToSpawn .. " MaxActive=" .. MuR.Mode14.MaxActiveNPCs .. " SpawnDelay<CurTime=" .. tostring(MuR.Mode14.SpawnDelay < CurTime()))
	end
end)

concommand.Add("mur_spawnbot", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		local bot = player.CreateNextBot("bot")
		if IsValid(bot) then
			bot.ForceSpawn = true
			bot:Spawn()
			bot:SetPos(ply:GetEyeTrace().HitPos + Vector(0,0,16))
			bot.KickAfterDeath = true
		end
	end
end)

concommand.Add("mur_mode54_spawn", function(ply, cmd, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	local action = (args[1] or ""):lower()
	if action == "" then
		ply:ChatPrint("[Mode54] Использование: mur_mode54_spawn <combine|rebel|clear|list>")
		return
	end

	if action == "clear" then
		local path = "bloodshed/mode54_spawns_" .. game.GetMap() .. ".json"
		if file.Exists(path, "DATA") then
			file.Delete(path)
			ply:ChatPrint("[Mode54] Точки спавна для карты " .. game.GetMap() .. " очищены.")
		else
			ply:ChatPrint("[Mode54] Нет сохранённых точек для этой карты.")
		end
		return
	end

	if action == "list" then
		local saved = MuR.Mode54LoadSpawns and MuR.Mode54LoadSpawns()
		if not saved or (#(saved.combine or {}) == 0 and #(saved.rebel or {}) == 0) then
			ply:ChatPrint("[Mode54] Нет сохранённых точек для карты " .. game.GetMap())
		else
			local c = saved.combine or {}
			local r = saved.rebel or {}
			ply:ChatPrint("[Mode54] Combine: " .. #c .. " точек, Rebel: " .. #r .. " точек")
		end
		return
	end

	if action == "combine" or action == "rebel" then
		local saved = MuR.Mode54LoadSpawns and MuR.Mode54LoadSpawns()
		saved = saved or { combine = {}, rebel = {} }
		saved.combine = saved.combine or {}
		saved.rebel = saved.rebel or {}

		local pos = ply:GetPos()
		if action == "combine" then
			table.insert(saved.combine, pos)
		else
			table.insert(saved.rebel, pos)
		end

		MuR.Mode54SaveSpawns(saved.combine, saved.rebel)
		ply:ChatPrint("[Mode54] Добавлена точка спавна " .. action .. " (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")")
		return
	end

	ply:ChatPrint("[Mode54] Неизвестная команда. Используйте: combine, rebel, clear, list")
end)