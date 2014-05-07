-- Project: 		Gate Slash'n'Actions - New Life Update
-- Code: 		Kenuvis
-- Base Update: 	04.11.2011
-- Last Update:	29.07.2012

local function gSlash(Object)
	_G["SLASH_"..string.upper(Object.Name).."1"] = "/"..Object.Text
--	local a = 1
--	while _G["SLASH_GATE"..a] do a = a + 1 end
--	_G["SLASH_GATE"..a] = "/"..Object.Text
--	SlashCmdList["GATE"] = function(msg)
	SlashCmdList[string.upper(Object.Name)] = function(msg)	
		Object:Buffer("e")
		Object:Buffer(Object.oName)
		Object:Buffer("Slash") 
		Object:Buffer(msg)
		Object:SendBuffer()
	end
end

local function gAction(Object)
	RunBinding(Object.oName)
end

local function gKeyBinding(Object)
	local KeyBindButton = CreateFrame("Button", Object.Name)
	assert(SetBindingClick(Object.Key, Object.Name), "Fehler bei der Erstellung eines Keybind")
	
	KeyBindButton:SetScript("OnClick", function(self)
		Object:Buffer("e")
		Object:Buffer(Object.oName)
		Object:Buffer("OnKeyDown") 
		Object:SendBuffer()
	end)
end
Gate.ScriptingInterface.gKeyBinding = gKeyBinding	

local HideAll = {}
local function gHideAll(Object)
	debugprint("HideAll")
	for  _,frame in ipairs({UIParent:GetChildren()}) do
		frame:Hide()
		table.insert(HideAll, frame)
	end
end
Gate.ScriptingInterface.gHideAll = gHideAll	

local function gShowAll(Object)
	debugprint("ShowAll")
	for  _,frame in ipairs(HideAll) do
		frame:Show()
	end
	HideAll = {}
end	
Gate.ScriptingInterface.gShowAll = gShowAll	

local function gEvent(Object)
	local dummyframe = CreateFrame("Frame")
	dummyframe:RegisterEvent(Object.oName)
	dummyframe:SetScript("OnEvent", function(self, event, arg)
		Object:Buffer(event)
		Object:Buffer(arg)
		Object:SendBuffer()
	end)
end

Gate_Reg_Comm("slash", gSlash)
Gate_Reg_Comm("action", gAction)
Gate_Reg_Comm("ha", gHideAll)
Gate_Reg_Comm("sa", gShowAll)
Gate_Reg_Comm("kb", gKeyBinding)
	Gate_Reg_ShortCut("kb", "ky", "Key")
Gate_Reg_Comm("ev", gEvent)	