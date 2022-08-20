function print(output)
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ffff[%s]|r %s", "MongiBG", output), 1, 1, 1)
end

MongiBG_Defaults = {
	version = "1.0.1",
	debug = false,
	autoleave = true,
	autoqueue = true,
	autoaccept = true,
	autojoin = true,
	autoresurrect = true,
	wsg = true,
	ab = true,
	av = false,
}

function initialize()
	if MongiBG == nil then
		MongiBG = MongiBG_Defaults
		MongiBGFrame:Show()
	end
	print(string.format("%s loaded. |cffffff00/mbg show|r to open settings.", MongiBG.version))
	MongiBGFrameVersion:SetText(string.format("v. %s",MongiBG.version))
	checkChecks()
end

function checkChecks()
	if MongiBG.autoqueue then MongiBGCheckbuttonQueue:SetChecked(true) else MongiBGCheckbuttonQueue:SetChecked(false) end
	if MongiBG.autoleave then MongiBGCheckbuttonLeave:SetChecked(true) else MongiBGCheckbuttonLeave:SetChecked(false) end
	if MongiBG.autoaccept then MongiBGCheckbuttonAccept:SetChecked(true) else MongiBGCheckbuttonAccept:SetChecked(false) end
	if MongiBG.autojoin then MongiBGCheckbuttonJoin:SetChecked(true) else MongiBGCheckbuttonJoin:SetChecked(false) end
	if MongiBG.autoresurrect then MongiBGCheckbuttonResurrect:SetChecked(true) else MongiBGCheckbuttonResurrect:SetChecked(false) end
	if MongiBG.wsg then MongiBGCheckbuttonWSG:SetChecked(true) else MongiBGCheckbuttonWSG:SetChecked(false) end
	if MongiBG.ab then MongiBGCheckbuttonAB:SetChecked(true) else MongiBGCheckbuttonAB:SetChecked(false) end
	if MongiBG.av then MongiBGCheckbuttonAV:SetChecked(true) else MongiBGCheckbuttonAV:SetChecked(false) end
end

function leave()
	if GetBattlefieldWinner() ~= nil then
		LeaveBattlefield()
	end
end

function queue()
	if MongiBG.wsg then SendChatMessage(".join wsg", "say") end
	if MongiBG.ab then SendChatMessage(".join ab", "say") end
	if MongiBG.av then SendChatMessage(".join av", "say") end
end

function autojoin()
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		if GetBattlefieldStatus(i) == "confirm" then
			AcceptBattlefieldPort(i, 1)
			StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
		end
	end
end

function accept()
	JoinBattlefield(0)
	HideUIPanel(BattlefieldFrame)
end

function npcaccept()
	local _, gossip = GetGossipOptions()
	if gossip == "battlemaster" then
		SelectGossipOption(1)
	end
end

function resurrect()
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		if GetBattlefieldStatus(i) == "active" and not HasSoulstone() then
		RepopMe()
		end
	end
end

function help()
	for k, v in pairs(MongiBG) do
		if v then print(string.format("/mbg %s [|cff00ff00%s|r]", k, tostring(v)))
		elseif not v then print(string.format("/mbg %s [|cffff0000%s|r]", k, tostring(v)))
		else print(string.format("/mbg%s [|cffffffff%s|r]", k, tostring(v)))
		end
	end
	print("/mbg show for gui")
end

eventframe = CreateFrame("frame")
eventframe:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
eventframe:RegisterEvent("BATTLEFIELDS_SHOW")
eventframe:RegisterEvent("PLAYER_DEAD")
eventframe:RegisterEvent("GOSSIP_SHOW")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:SetScript("OnEvent", function()
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		if MongiBG.autoleave then leave() end
		if MongiBG.autoqueue then queue() end
		if MongiBG.autojoin then autojoin() end
	end
	if event == "BATTLEFIELDS_SHOW" then
		if MongiBG.autoaccept then accept() end
	end
	if event == "PLAYER_DEAD" then
		if MongiBG.autoresurrect then resurrect() end
	end
	if event == "GOSSIP_SHOW" then
		if MongiBG.autoaccept then npcaccept() end
	end
	if event == "ADDON_LOADED" then
		initialize()
		eventframe:UnregisterEvent("ADDON_LOADED")
	end
	if MongiBG.debug then print(event) end
end)

SLASH_MONGIBG1 = "/mbg"
SLASH_MONGIBG2 = "/mongibg"
SlashCmdList["MONGIBG"] = function(cmd)
	cmd = strlower(cmd)
	if cmd == "help" then help()
	elseif cmd == "reset" then reset()
	elseif cmd == "show" then MongiBGFrame:Show() checkChecks()
	elseif MongiBG[cmd] == nil then print("Unknown command.")
	elseif MongiBG[cmd] then MongiBG[cmd] = false checkChecks() print(string.format("%s turned off", cmd))
	elseif not MongiBG[cmd] then MongiBG[cmd] = true checkChecks() print(string.format("%s turned on", cmd)) end
end
