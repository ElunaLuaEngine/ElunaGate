-- Project: 		GateObjects - New Life Update
-- Code: 		Kenuvis
-- Base Update: 	20.05.2012 (Kenuvis)
-- Last Update: 	29.07.2012 (Kenuvis)

-------------------------------------------------------------------
---------------- Objects - Events ------------------------------
-------------------------------------------------------------------

-- Objectevents
local gEvents = {}
gEvents[0] = {Name = "NoEvents"}
gEvents[10] = {Name = "OnClick", Type = "standard"}
gEvents[11] = {Name = "OnDoubleClick", Type = "standard"}
gEvents[12] = {Name = "OnHide", Type = "standard"}
gEvents[13] = {Name = "OnEnter", Type = "standard"}
gEvents[14] = {Name = "OnEnterPressed", Type = "special", regfunc = function(Element, Object)
		Element:SetScript("OnEnterPressed", function(obj, arg)
			Object:Buffer("e")
			Object:Buffer(Object.oName)
			Object:Buffer("OnEnterPressed") 
			Object:Buffer(obj:GetText())
			Object:Buffer(obj.StatusSend)
			Object:SendBuffer() 
		end)
	end}
gEvents[15] = {Name = "OnKeyDown", Type = "standard"}

-- Wird ein Object damit "behandelt", tr?gt es sich in eine Liste eines anderen Objektes ein, welcher beim Benutzen die StatusCheck function aufruft und mitsendet
local function gSetStatusCheck(Object)
	for _,StatusLink in ipairs(Object.StatusLink) do
		assert(_G[StatusLink], "GateObjects: Fehler in der Registrierung des StatusChecks. StatusLink ("..StatusLink..") nicht gefunden.")
		assert(Object.Name, "GateObjects: Fehler in der Registrierung des StatusChecks. Namenloses Objekt kann kein StatusLink ("..StatusLink..") werden.")
		assert(_G[StatusLink].StatusSend, "GateObjects: Fehler in der Registrierung des StatusChecks. Ung¨¹ltiges Objekt f¨¹r StatusLink. ("..StatusLink..")")

		_G[StatusLink].StatusSend[Object.Name] =  function()
				debugprint(">!"..Object.Type)
				Object:Buffer(Object.oName)
				
				if Object.Type == "CheckButton" then
					Object:Buffer((_G[Object.Name]:GetChecked()==1))
				elseif Object.Type == "EditBox" then
					Object:Buffer(_G[Object.Name]:GetText())
				elseif Object.Type == "StatusBar" or Object.Type == "Slider"then
					Object:Buffer(_G[Object.Name]:GetValue())
				elseif Object.Template == "UIDropDownMenuTemplate" then
					Object:Buffer(UIDropDownMenu_GetText(_G[Object.Name]))
				else
					Object:Buffer((_G[Object.Name]:IsVisible()==1))
				end
			end
	end
end

local function gSetEvent(Element, Object, Event)
	Element:SetScript(gEvents[Event].Name, function(obj, arg)
		Object:Buffer("e")
		Object:Buffer(Object.oName)
		Object:Buffer(gEvents[Event].Name) 
		Object:Buffer(arg or "")
		Object:Buffer(obj.StatusSend)
		Object:SendBuffer()
		
		if gEvents[Event].Name == "OnEnter" and Element.Tooltip then
			--print(Event)
			GameTooltip:SetOwner(Element, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(Object.Tooltip)
			GameTooltip:Show()
		end
	end)
end

-------------------------------------------------------------------
---------------- Objects - Modify ------------------------------
-------------------------------------------------------------------

local function gShow(Object)
	if _G[Object.Name] then
		if Object.Hidden then
			_G[Object.Name]:Hide()
			Gate_OpenFrames[Object.Name] = nil
		else
			_G[Object.Name]:Show()
		end
	end
end

local function gStandardChange(Object, Event)
    if type(Object) ~= "table" then return end

	if _G[Object.Name] and Object[Event]  then
		_G[Object.Name]["Set"..Event](_G[Object.Name], Object[Event])
	end
end

local function gAlpha(Object)		gStandardChange(Object, "Alpha") end
local function gText(Object)		gStandardChange(Object, "Text") end
local function gWidth(Object)		gStandardChange(Object, "Width") end
local function gHeight(Object)	gStandardChange(Object, "Height") end
local function gParent(Object)	gStandardChange(Object, "Parent") end
local function gValue(Object)		gStandardChange(Object, "Value") end

local function gColor(Object)		
	if _G[Object.Name] then
		local red = Object.Red or 1
		local green = Object.Green or 1
		local blue = Object.Blue or 1
		if red > 1 then red = red/100 end
		if green > 1 then green = green/100 end
		if blue > 1 then blue = blue/100 end
		
		if Object.Template == "UIPanelDialogTemplate" then
			_G[Object.Name.."TitleBG"]:SetVertexColor(red, green, blue)
			_G[Object.Name.."DialogBG"]:SetVertexColor(red, green, blue)
		elseif Object.Type == "Button" or Object.Type == "EditBox" then		
			_G[Object.Name.."Left"]:SetVertexColor(red, green, blue)
			_G[Object.Name.."Middle"]:SetVertexColor(red, green, blue)
			_G[Object.Name.."Right"]:SetVertexColor(red, green, blue)
		elseif Object.Type == "CheckButton" then
			_G[Object.Name]:GetNormalTexture():SetVertexColor(red, green, blue)
			if Object.Template ~= "UIRadioButtonTemplate" then
				_G[Object.Name]:GetPushedTexture():SetVertexColor(red, green, blue)
			end
			_G[Object.Name]:GetCheckedTexture():SetVertexColor(red, green, blue)
		end
		
		if Object.Type == "Button" or Object.Type == "CheckButton" then 
			_G[Object.Name]:GetHighlightTexture():SetVertexColor(red, green, blue)
		end
	end
end

local function gSys(Object)
	SendSystemMessage(Object.Text)
end

local function gOffset(Object)
	if _G[Object.Name] then
		local point, relativeTo, relativePoint, xOfs, yOfs = _G[Object.Name]:GetPoint(1)

		point = point or "CENTER"
		relativePoint = relativePoint or "CENTER"
		relativeTo = relativeTo or Object.Parent
		xOfs = Object.XOffset or xOfs or 0
		yOfs = Object.YOffset or yOfs or 0
		
		_G[Object.Name]:ClearAllPoints()
		_G[Object.Name]:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
	end
end

--[[local function gEvent(Object)	
	if _G[Object.Name] then
		if Object.Events == 0 then 
			_G[Object.Name]:UnregisterAllEvents() 
		elseif gEvents[Object.Events].Type == "standard" then
			_G[Object.Name]:RegisterEvent(gEvents[Object.Events].Name, Object.SendEvent)
		elseif gEvents[Object.Events].Type == "standard2" then
			_G[Object.Name]:RegisterEvent(gEvents[Object.Events].Name, gEvents[Object.Events].regfunc)
		elseif gEvents[Object.Events].Type == "special" then
			gEvents[Object.Events].regfunc(Object, _G[Object.Name])
		end
	end
end]]

local function gChecked(Object)
	if _G[Object.Name] then
		if Object.Checked then
			_G[Object.Name]:SetChecked(true)
		else
			_G[Object.Name]:SetChecked(false)
		end
	end
end

local function gGetStatus(Object)
	if _G[Object.Name] then
		Object:Buffer("Get"..Object.GetType.."from"..Object.oName)
		Object:Buffer(Object.oName)
		
		local Status = (_G[Object.Name]["Get"..Object.GetType] and _G[Object.Name]["Get"..Object.GetType]()) or (_G[Object.Name]:IsVisible() ~= 1)
		Object:Buffer(Status)
		Object:SendBuffer()
	end
end	

local function gMinMaxValue(Object)
	if _G[Object.Name] then
		local minValue, maxValue = _G[Object.Name]:GetMinMaxValues()
		minValue = Object.Min or minValue
		maxValue = Object.Max or maxValue	
		_G[Object.Name]:SetMinMaxValues(minValue, maxValue)
	end
end

local function gTooltip(Object)
	if _G[Object.Name] and Object.Tooltip then
		if not _G[Object.Name]:GetScript("OnEnter") then
			_G[Object.Name]:SetScript("OnEnter", function()
				GameTooltip:SetOwner(_G[Object.Name], "ANCHOR_TOPLEFT")
				GameTooltip:SetText(Object.Tooltip)
				GameTooltip:Show()
			end)
		end 
		_G[Object.Name]:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end
end

local function gFadeOut(Object)
	if _G[Object.Name] and Object.FadeOut then
		UIFrameFadeOut(_G[Object.Name], Object.FadeOut, 1, 0)
	end
end

local function gFadeIn(Object)
	if _G[Object.Name] and Object.FadeIn then
 		UIFrameFadeIn(_G[Object.Name], Object.FadeIn, 0, 1)
	end
end

--das sind mal alle Cursor
local cursors = { "NORMAL_CURSOR", "ATTACK_CURSOR", "ATTACK_ERROR_CURSOR", "BUY_CURSOR", "BUY_ERROR_CURSOR", "CAST_CURSOR", "CAST_ERROR_CURSOR", "GATHER_CURSOR", "GATHER_ERROR_CURSOR", "INNKEEPER_CURSOR", "INNKEEPER_ERROR_CURSOR", "INSPECT_CURSOR", "INSPECT_ERROR_CURSOR", "INTERACT_CURSOR", "INTERACT_ERROR_CURSOR", "ITEM_CURSOR", "ITEM_ERROR_CURSOR", "LOCK_CURSOR", "LOCK_ERROR_CURSOR", "LOOT_ALL_CURSOR", "LOOT_ALL_ERROR_CURSOR", "MAIL_CURSOR", "MAIL_ERROR_CURSOR", "MINE_CURSOR", "MINE_ERROR_CURSOR", "PICKUP_CURSOR", "PICKUP_ERROR_CURSOR", "POINT_CURSOR", "POINT_ERROR_CURSOR", "QUEST_CURSOR", "QUEST_ERROR_CURSOR", "REPAIRNPC_CURSOR", "REPAIRNPC_ERROR_CURSOR", "REPAIR_CURSOR", "REPAIR_ERROR_CURSOR", "SKIN_ALLIANCE_CURSOR", "SKIN_ALLIANCE_ERROR_CURSOR", "SKIN_CURSOR", "SKIN_ERROR_CURSOR", "SKIN_HORDE_CURSOR", "SKIN_HORDE_ERROR_CURSOR", "SPEAK_CURSOR", "SPEAK_ERROR_CURSOR", "TAXI_CURSOR", "TAXI_ERROR_CURSOR", "TRAINER_CURSOR", "TRAINER_ERROR_CURSOR" }
local function gCursor(Object)
	if _G[Object.Name] and Object.Cursor then
 		if _G[Object.Name]:GetScript("OnEnter") or _G[Object.Name]:GetScript("OnLeave") then
			return
		else
			_G[Object.Name]:SetScript("OnEnter", function() SetCursor(cursors[Object.Cursor]) end)
			_G[Object.Name]:SetScript("OnLeave", function() SetCursor(nil) end)
		end
	end
end

-------------------------------------------------------------------
---------------- Objects - Build --------------------------------
-------------------------------------------------------------------

local function gCreateObject(Object)
	--debugprint(Object)
	local o --o like object
	
	if _G[Object.Name] then
		_G[Object.Name]:Show()
		o = _G[Object.Name]
	else
		o = CreateFrame(Object.Type, Object.Name, _G[Object.Parent], Object.Template)
		-- Objekte k?nnen sich dort eintragen und werden beim Benutzen aufgerufen
		o.StatusSend = {}
	end	

	-- durch inherits kann das OnEnter schon reserviert sein, daher weg damit
	o:SetScript("OnEnter", nil)
	o:SetScript("OnLeave", nil)
	
	-- Alle Events werden nun hier registriert
	for _,event in ipairs(Object.Event) do
		if event == 0 then 
			o:UnregisterAllEvents() 
			break
		elseif gEvents[event].Type == "standard" then
			gSetEvent(o, Object, event)
		elseif gEvents[event].Type == "standard2" then
			o:SetScript(gEvents[event].Name, gEvents[event].regfunc)
		elseif gEvents[event].Type == "special" then
			gEvents[event].regfunc(o, Object)
		end
	end
	
	o:EnableMouse(true)
	gOffset(Object)
	gWidth(Object)
	gHeight(Object)
	gColor(Object)
	gAlpha(Object)
	gShow(Object)	
	gTooltip(Object)
	gSetStatusCheck(Object)
	gFadeIn(Object)
	gFadeOut(Object)
	gCursor(Object)
	o._Object = Object
	
	return o
end

local function gCreateDummyObject(Object, Text)
	local Textbox = _G[Object.Name.."Text"] or _G[Object.Name]:CreateFontString(Object.Name.."Text")
	Textbox:SetFontObject("GameFontNormal")
	Textbox:SetText(Text)

	return Textbox
end

-------------------------------------------------------------------
---------------- Objects - Specify -----------------------------
-------------------------------------------------------------------

local function gTextBox(Object) --Textbox
	local Textbox = _G[Object.Name] or _G[Object.Parent]:CreateFontString(Object.Name)
	Textbox:SetFontObject(Object.Font)
	
	gOffset(Object)
	gWidth(Object)
	gHeight(Object)
	gShow(Object)	
	gText(Object)
	gFadeIn(Object)
	gFadeOut(Object)

	if Object.TextHeight then
		Textbox:SetTextHeight(Object.TextHeight)
	end

	return Textbox
end
-- For GateBuilder
Gate.ScriptingInterface.gTextBox = gTextBox

-- Makrotest: /run SendAddonMessage("Gate", "$#frame#nTest", "WHISPER", UnitName("player"))
local function gFrame(Object)
	local Frame = gCreateObject(Object)
	Frame:SetClampedToScreen(true) 
	
	-- Cannot close the Frame with a Closebutton
	if Object.CantClose then
		_G[Frame:GetName().."Close"]:Disable()
	else
		_G[Frame:GetName().."Close"]:Enable()
		_G[Frame:GetName().."Close"]:SetScript("OnClick", 
		function()
			this:GetParent():Hide()
			Gate_OpenFrames[this:GetParent():GetName()] = nil
		end)
	end
	
	-- Cannot move the Frame
	if Object.CantMove then
		Frame:SetMovable(false)
	else
		Frame:SetMovable(true)
		Frame:SetScript("OnMouseDown",function()
			this:StartMoving()
		end)
		Frame:SetScript("OnMouseUp",function()
			this:StopMovingOrSizing()
		end)
	end
	
	if Object.DisableMouse then
		Frame:EnableMouse(false)
	end
	
	if Object.Front then
		Frame:SetFrameStrata("DIALOG")
	end
	
	if Object.Texture then
		_G[Object.Name.."DialogBG"]:SetTexture(Gate.bgFiles[Object.Texture] or Object.Texture)
	end
	
	if Object.Text then
		gCreateDummyObject(Object, Object.Text):SetPoint("TOPLEFT", Frame, "TOPLEFT", 15,-8)
	end	
	
	if Object.InfoText then
		local infobtn = CreateFrame("Button", Object.Name.."InfoBtn", Frame)
		infobtn:SetPoint("RIGHT", _G[Frame:GetName().."Close"], "LEFT")
		infobtn:SetWidth(16)
		infobtn:SetHeight(16)
		infobtn:SetNormalTexture("Interface/FriendsFrame/InformationIcon")
		infobtn:SetHighlightTexture("Interface/FriendsFrame/InformationIcon-Highlight")
		infobtn:SetScript("OnClick", function() 
			if GameTooltip:GetOwner() == this and GameTooltip:GetAlpha() > 0 then 
				GameTooltip:Hide()
			else
				GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(Object.InfoText)
				GameTooltip:AddLine("-"..Gate.Prefix.." Build: "..Gate.Version.." (Kenuvis)-")
				GameTooltip:Show()
				infobtn:SetScript("OnLeave", function() UIFrameFadeOut(GameTooltip, 2, 1, 0) infobtn:SetScript("OnLeave", nil) end)
				--UIFrameFadeOut(GameTooltip, 5)
			end
			end)	
		
		infobtn:Show()
	end	

	return Frame
end
-- For GateBuilder
Gate.ScriptingInterface.gFrame = gFrame

local function gTabbedFrame(Object)
	if not Object.Tabs then return end
	local TabbedFrame = gCreateObject(Object)
	
	--TabbedFrame = _G[Object.Name] or CreateFrame(Object.Type, Object.Name, _G[Object.Parent])
	--[[TabbedFrame:SetPoint("TOPLEFT", Object.Parent, "TOPLEFT", 10, -20)
	TabbedFrame:SetPoint("BOTTOMRIGHT", Object.Parent)]]
	
	
	if type(Object.Tabs) ~= "table" then
		Object.Tabs = {Object.Tabs}
	end
	
	TabbedFrame.numTabs = #Object.Tabs
	TabbedFrame.selectedTab = Object.SelectedTab

	for k,v in ipairs(Object.Tabs) do
		local TabButton = CreateFrame("Button", Object.Name.."Tab"..k, TabbedFrame, Object.TabButtonTemplate)
		local TabFrame = CreateFrame("Frame", Object.Name.."TabFrame"..k, TabbedFrame, "HybridScrollFrameTemplate")
		TabButton:SetID(k)
		TabButton:SetFrameLevel(2)
		TabFrame:SetFrameLevel(1)
		TabFrame:SetPoint("TOPLEFT", TabbedFrame, "TOPLEFT", 0, -TabButton:GetHeight())
		TabFrame:SetPoint("BOTTOMRIGHT", TabbedFrame)
		
		-- Because, I didnt find a template, I have to do it by myself -.-		
		TabFrame:SetBackdrop({edgeFile="Interface/FriendsFrame/UI-Toast-Border", edgeSize = 10,
						bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, tileSize = 100,  
						insets = {
							left = 6,
							right = 6
						}
				})
		
		TabFrame:Hide()
		
		if k == 1 then -- the first one
			TabButton:SetPoint("TOPLEFT", TabbedFrame, 5, 0)
		else
			TabButton:SetPoint("TOPLEFT", Object.Name.."Tab"..(k-1), "TOPRIGHT")
		end
		TabButton:SetText(v)
		PanelTemplates_TabResize(TabButton,-10,nil, (TabbedFrame:GetWidth()/TabbedFrame.numTabs)-26)
		TabButton:SetScript("OnClick", function(self) 
			PanelTemplates_SetTab(self:GetParent(), self:GetID())
			for c = 1, TabbedFrame.numTabs do
				if c == TabbedFrame.selectedTab then
					_G[self:GetParent():GetName().."TabFrame"..c]:Show()
				else
					_G[self:GetParent():GetName().."TabFrame"..c]:Hide()
				end
			end
			
		end)
	end
	
	PanelTemplates_UpdateTabs(TabbedFrame)
	for c = 1, TabbedFrame.numTabs do
		if c == TabbedFrame.selectedTab then
			_G[TabbedFrame:GetName().."TabFrame"..c]:Show()
		else
			_G[TabbedFrame:GetName().."TabFrame"..c]:Hide()
		end
	end
	
	return TabbedFrame
end					
	
local function gPanel(Object)
	local Panel = gCreateObject(Object)

	local eFile = (type(Object.Border) == "number" and Gate.edgeFiles[Object.Border]) or Object.Border
	local bFile = Gate.bgFiles[Object.Background] or Object.Background
	
	if eFile and string.sub(eFile, 1, 10) ~= "Interface/" then
		eFile = "Interface/"..eFile
	end
	if bFile and string.sub(bFile, 1, 10) ~= "Interface/" then
		bFile = "Interface/"..bFile
	end
	
	debugprint(eFile, "Border:")
	debugprint(bFile, "Background:")
	
	Panel:SetBackdrop({	edgeFile = eFile , edgeSize = 10,
					bgFile = bFile, tile=true, tileSize = 100,  
					insets = {
						left = 6,
						right = 6
					}
				})
	return Panel
end
-- For GateBuilder
Gate.ScriptingInterface.gPanel = gPanel

-- Makrotest: /run SendAddonMessage("Gate", "$#btn#nBTest#tTest#pTest", "WHISPER", UnitName("player"))
local function gButton(Object)
	local Button = gCreateObject(Object)
	
	gText(Object)
	
	if Object.Texture then
		Button:SetNormalTexture(Gate.bgFiles[Object.Texture] or Object.Texture)
		Button:SetPushedTexture(Gate.bgFiles[Object.Texture] or Object.Texture)
		Button:SetHighlightTexture("Interface/BUTTONS/UI-Panel-Button-Highlight2")
		
--[[		local PushedTex = Button:GetPushedTexture()
		PushedTex:SetAlpha(0.2)
		Button:SetPushedTexture(PushedTex)	]]	
	end
	-- Standard ist der Button auf das "OnClick" registriert, weil ein Button ohne dies sinnlos w?re
	-- Au?er ein 0 Event wurde ¨¹bergeben
--[[	if Object.Events ~= "0" then
		gSetEvent(Button, Object, 10)
	end]]
		
	return Button
end
-- For GateBuilder
Gate.ScriptingInterface.gButton = gButton

-- Makrotest: /run SendAddonMessage("Gate", "$#cb#nCBTest#pTest#tTest#y-20#lBTest", "WHISPER", UnitName("player"))
local function gCheckBox(Object) --CheckBox
	local Checkbox = gCreateObject(Object)
	
	gChecked(Object)
	
	if Object.Text then
		local tb = gCreateDummyObject(Object, Object.Text)
		tb:SetPoint("LEFT", Checkbox, "RIGHT")
		Checkbox:SetHitRectInsets(0, -tb:GetWidth(), 0, 0)
	end	
	
	return Checkbox
end
-- For GateBuilder
Gate.ScriptingInterface.gCheckBox = gCheckBox

local function gRadioBox(Object)
	local RadioBox = gCreateObject(Object)
	
	gChecked(Object)
	
	if Object.Text then
		local tb = gCreateDummyObject(Object, Object.Text)
		tb:SetPoint("LEFT", RadioBox, "RIGHT")
		RadioBox:SetHitRectInsets(0, -tb:GetWidth(), 0, 0)
	end	
	
	if RadioBox:GetParent() then
		local p = RadioBox:GetParent()
		if not p.RadioBoxes then
			p.RadioBoxes = {}
		end
		table.insert(p.RadioBoxes, RadioBox)
	end
	
	RadioBox:SetScript("PostClick", 
		function() 
			if RadioBox:GetChecked() and RadioBox:GetParent() and RadioBox:GetParent().RadioBoxes then
				for _,rb in ipairs(RadioBox:GetParent().RadioBoxes) do
					if rb ~= RadioBox then
						rb:SetChecked(false)
					end
				end
			end		
		end)
	
	return RadioBox
end
-- For GateBuilder
Gate.ScriptingInterface.gRadioBox = gRadioBox

-- Makrotest: /run SendAddonMessage("Gate", "$#eb#nETest#tTest", "WHISPER", UnitName("player"))
local function gEditBox(Object)
	local EditBox = gCreateObject(Object)
	
	gText(Object)
	
	if Object.InfoText then
		gCreateDummyObject(Object, Object.InfoText):SetPoint("BOTTOMLEFT", EditBox, "TOPLEFT", -5, 0)
	end

	if (Object.Max or Object.Min) and not _G[Object.Name.."UpKey"] then
		EditBox:SetNumeric(true)
		local Up = CreateFrame("Button", Object.Name.."UpKey", EditBox)
		local Down = CreateFrame("Button", Object.Name.."DownKey", EditBox)
		
		Up:SetHeight(Object.Height / 2) Down:SetHeight(Object.Height / 2)
		Up:SetWidth(20) Down:SetWidth(20)
		Up:SetPoint("TOPRIGHT") Down:SetPoint("BOTTOMRIGHT")
		
		local UpNormalTex = Up:CreateTexture(nil)
		UpNormalTex:SetTexture("Interface/BUTTONS/UI-TotemBar")
		UpNormalTex:SetAllPoints()
		UpNormalTex:SetTexCoord(0.77, 1, 0.33, 0.38)
		Up:SetNormalTexture(UpNormalTex)

		local UpHighTex = Up:CreateTexture(nil)
		UpHighTex:SetTexture("Interface/BUTTONS/UI-TotemBar")
		UpHighTex:SetAllPoints()		
		UpHighTex:SetTexCoord(0.5625, 0.71875, 0.33, 0.38)
		Up:SetHighlightTexture(UpHighTex)
		
		local UpClickTex = Up:CreateTexture(nil)
		UpClickTex:SetTexture("Interface/BUTTONS/UI-TotemBar")
		UpClickTex:SetAllPoints()
		UpClickTex:SetTexCoord(0.77, 1, 0.33, 0.38)
		UpClickTex:SetAlpha(0.2)
		Up:SetPushedTexture(UpClickTex)

		local DownNormalTex = Down:CreateTexture(nil)
		DownNormalTex:SetTexture("Interface/BUTTONS/UI-TotemBar")		
		DownNormalTex:SetTexCoord(0.77, 1, 0.27, 0.32)
		DownNormalTex:SetAllPoints()
		Down:SetNormalTexture(DownNormalTex)
		
		local DownHighTex = Down:CreateTexture(nil)
		DownHighTex:SetTexture("Interface/BUTTONS/UI-TotemBar")		
		DownHighTex:SetTexCoord(0.5625, 0.71875, 0.27, 0.32)
		DownHighTex:SetAllPoints()
		Down:SetHighlightTexture(DownHighTex)
		
		local DownClickTex = Up:CreateTexture(nil)
		DownClickTex:SetTexture("Interface/BUTTONS/UI-TotemBar")
		DownClickTex:SetAllPoints()
		DownClickTex:SetTexCoord(0.77, 1, 0.27, 0.32)
		DownClickTex:SetAlpha(0.2)
		Down:SetPushedTexture(DownClickTex)

		Up:SetScript("OnClick", function(self) 
			local value = tonumber(self:GetParent():GetText()) or 0
			if (Object.Max and value + 1 <= Object.Max) or not Object.Max then
				self:GetParent():SetText(value + 1)
			end
		end)
		Down:SetScript("OnClick", function(self) 
			local value = tonumber(self:GetParent():GetText()) or 0
			if (Object.Min and value - 1 >= Object.Min) or not Object.Min then
				self:GetParent():SetText(value - 1)
			end
		end)
	end
		

	if Object.MultiLines then
		EditBox:SetMultiLine(true) 
	end
    
    if not Object.AutoFocus then
        EditBox:SetAutoFocus(false)
        EditBox:SetScript("OnEnterPressed", function() EditBox:ClearFocus() end)
        EditBox:SetScript("OnEscapePressed", function() EditBox:ClearFocus() end)
    end
	
	return EditBox
end
-- For GateBuilder
Gate.ScriptingInterface.gEditBox = gEditBox

local function gStatusBar(Object)
	local StatusBar = gCreateObject(Object)
	StatusBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
	StatusBar:SetStatusBarColor(Object.Red or 1, Object.Green or 1, Object.Blue or 1) 
	
	gMinMaxValue(Object)
	gValue(Object)
	
	local SetValue = function(value)
		if Object.Flow then
			StatusBar:SetValue(value)
		else
			StatusBar:SetValue(math.floor(value))
		end
	end
	
	if Object.Text then
		gCreateDummyObject(Object, Object.Text):SetPoint("CENTER")
	end	
	
	if Object.Vertical then
		StatusBar:SetRotatesTexture(true)
		StatusBar:SetOrientation("VERTICAL")
	else
		StatusBar:SetRotatesTexture(false)
		StatusBar:SetOrientation("HORIZONTAL")
	end

	if Object.Countdown then
		StatusBar.CountdownEnd = GetTime() + Object.Countdown
		StatusBar:SetMinMaxValues(0,Object.Countdown)
		StatusBar:SetScript("OnUpdate", function()
			if Object.RunBack then
				SetValue(StatusBar.CountdownEnd - GetTime())
			else
				StatusBar:SetValue(Object.Countdown - (StatusBar.CountdownEnd - GetTime()))
			end
			if GetTime() >= StatusBar.CountdownEnd then
				StatusBar:SetScript("OnUpdate", nil)
			end
		end)
	end

	if Object.AutoReset then
		if Object.AutoReset == 0 then
			StatusBar:SetScript("OnUpdate", nil)
			return
		end
		debugprint(Object, nil, true)
		-- ist der countdown code, nur mit kleinen änderungen
		StatusBar.CountdownEnd = GetTime() + Object.Max
		StatusBar:SetMinMaxValues(0,Object.Max)
		StatusBar:SetScript("OnUpdate", function()
			if not StatusBar:IsVisible() then return StatusBar:SetScript("OnUpdate", nil) end
			if Object.AutoReset == 1 or (Object.AutoReset == 2 and not Object.RunBack) then
				SetValue(Object.Max - (StatusBar.CountdownEnd - GetTime()))
			else
				SetValue(StatusBar.CountdownEnd - GetTime())
			end
			if GetTime() >= StatusBar.CountdownEnd then
				StatusBar.CountdownEnd = GetTime() + Object.Max
				StatusBar:SetValue(0)
				if Object.AutoReset == 2 then if Object.RunBack ==  1 then Object.RunBack = nil else Object.RunBack = 1 end end
			end
		end)
	end
		
	
	return StatusBar
end
-- For GateBuilder
Gate.ScriptingInterface.gStatusBar = gStatusBar

local function gSlider(Object)
	local Slider = gCreateObject(Object)
	
	gMinMaxValue(Object)	
	gStandardChange(Object, "ValueStep")	
	gValue(Object)
	
	if Object.Text then
		_G[Slider:GetName().."Text"]:SetText(Object.Text)
	end
	
	if Object.LowText then
		_G[Slider:GetName().."Low"]:SetText(Object.LowText)
	end	

	if Object.HighText then
		_G[Slider:GetName().."High"]:SetText(Object.HighText)
	end	
	
	return Slider
end
-- For GateBuilder
Gate.ScriptingInterface.gSlider = gSlider

-- Special Frames

-- Makrotest: /run SendAddonMessage("Gate", "$#of#nOKTest#tTest", "WHISPER", UnitName("player"))
local function gOKFrame(Object)
	if Object.Text then
		message(Object.Text)
	end
end
-- For GateBuilder
Gate.ScriptingInterface.gOKFrame = gOKFrame

-- Makrotest: /run SendAddonMessage("Gate", "$#df#nDFTest#tTest", "WHISPER", UnitName("player"))
local function gDialogFrame(Object)
	local db = gCreateObject(Object)
	
	if Object.Text then
		_G[Object.Name.."Button"]:SetText(Object.Text)
	end

	if Object.Events ~= 0 then
		_G[Object.Name.."Button"]:RegisterEvent("OnClick", function(self)		
			Object:Buffer("e")
			Object:Buffer(Object.oName)
			Object:Buffer("OnClick") 
			Object:SendBuffer()
			self:GetParent():Hide()
		end)
	end
end
-- For GateBuilder
Gate.ScriptingInterface.gDialogFrame = gDialogFrame
	
-- Makrotest: /run SendAddonMessage("Gate", "$#yn#nYesNoTest#tTest", "WHISPER", UnitName("player"))
local function gYesNoFrame(Object)
	local FrameObject = Gate_Create_New_Object("frame")
	FrameObject = table.combine(FrameObject, Object)
	FrameObject.Height = 70
	FrameObject.Width = 200
	FrameObject.Event = {}
	FrameObject = gFrame(FrameObject)		
	
	local YesButton = Gate_Create_New_Object("btn", {Name=Object.Name.."YesButton", Parent=Object.Name, XOffset=-45, YOffset=-10, Width=85, Text=Object.Yes or YES})
	local NoButton = Gate_Create_New_Object("btn", {Name=Object.Name.."NoButton", Parent=Object.Name, XOffset=45, YOffset=-10, Width=85, Text=Object.No or NO}) 

	YesButton = gButton(YesButton)
	NoButton = gButton(NoButton)
	
	YesButton:SetScript("OnClick", function(self, event)
			Object:Buffer("e")
			Object:Buffer(Object.oName)
			Object:Buffer("OnClick") 
			Object:Buffer(true)
			Object:SendBuffer()
			self:GetParent():Hide()
		end)
	NoButton:SetScript("OnClick", function(self, event)
			Object:Buffer("e")
			Object:Buffer(Object.oName)
			Object:Buffer("OnClick") 
			Object:Buffer(false)
			Object:SendBuffer()
			self:GetParent():Hide()
		end)	
end
-- For GateBuilder
Gate.ScriptingInterface.gYesNoFrame = gYesNoFrame

-- Makrotest: /run SendAddonMessage("Gate", "$#if#nIfTest#tTest", "WHISPER", UnitName("player"))
local function gInputFrame(Object)
	if Object.Width then
		-- Der Frame darf nicht zu klein sein!
		if Object.Width < 100 then
			Object.Width = 100
		end
	else
		-- Sonderfall !
		Object.Width = 100
	end
	
	local FrameObject = Gate_Create_New_Object("frame")
	FrameObject = table.combine(FrameObject, Object)
	FrameObject.Height = 70
	FrameObject.Width = Object.Width+40
	FrameObject.Text = Object.FrameText
	FrameObject.Event = {}
	FrameObject = gFrame(FrameObject)	
	
	local InputObject = Gate_Create_New_Object("eb")
	InputObject = table.combine(InputObject, Object)
	InputObject.Name = Object.Name.."InputBox"
	InputObject.Parent = Object.Name
	InputObject.Width = Object.Width
	InputObject.YOffset = -10
	InputObject.XOffset = 0
	InputObject.Event = {}
	InputObject = gEditBox(InputObject)
	
	for _,Event in ipairs(Object.Event) do
		if Event == 10 then			
			local ButtonObject = Gate_Create_New_Object("btn")
			ButtonObject.Name = Object.Name.."Button"
			ButtonObject.Text = Object.ButtonText or "OK"
			ButtonObject.Width = string.len(ButtonObject.Text)*5+30
			ButtonObject.Height = InputObject.Height
			ButtonObject.Parent = Object.Name			
	
			FrameObject:SetWidth(Object.Width + ButtonObject.Width + 40)			
			InputObject:ClearAllPoints()
			InputObject:SetPoint("CENTER", FrameObject, "CENTER", -(ButtonObject.Width/2)+5, -10)
	
			ButtonObject = gButton(ButtonObject)
			ButtonObject:ClearAllPoints()
			ButtonObject:SetPoint("LEFT", InputObject, "RIGHT")

			ButtonObject:SetScript("OnClick", function()
					Object:Buffer("e")
					Object:Buffer(Object.oName)
					Object:Buffer("OnClick") 
					Object:Buffer(InputObject:GetText())
					Object:SendBuffer()
					if not Object.DontCloseAfterSend then
						FrameObject:Hide()
					end
				end)	
		elseif Event == 14 then	
			InputObject:SetScript("OnEnterPressed", function()
					Object:Buffer("e")
					Object:Buffer(Object.oName)
					Object:Buffer("OnEnterPressed") 
					Object:Buffer(InputObject:GetText())
					Object:SendBuffer()
					if not Object.DontCloseAfterSend then
						FrameObject:Hide()
					end
				end)	
		end
	end
	return InputObject
end	
-- For GateBuilder
Gate.ScriptingInterface.gInputFrame = gInputFrame


local function gCursorKeys(Object)
	local function GetRotatedTexture(_obj, _rot, _type)
		local tex = _obj:CreateTexture(_obj:GetName().."Tex")
		tex:SetTexture("Interface/BUTTONS/UI-ScrollBar-ScrollUpButton-".._type)
		tex:SetRotation(_rot)
		tex:SetWidth(_obj:GetWidth()*1.25)
		tex:SetHeight(_obj:GetHeight()*1.25)
		tex:SetPoint("CENTER")
		--tex:SetAllPoints()
		return tex
	end	
	
	local function EventFunc(_type)
		Object:Buffer("e")
		Object:Buffer(Object.oName)
		Object:Buffer("OnClick") 
		Object:Buffer(_type)
		Object:SendBuffer()
	end
		
	local H = Object.Height
	local W = Object.Width
		
	local UpKey = CreateFrame("Button", Object.Name.."UpKey", _G[Object.Parent])
	UpKey:SetHeight(H) UpKey:SetWidth(W)
	UpKey:SetPoint("CENTER", Object.XOffset, Object.YOffset)
	UpKey:SetHitRectInsets(W/5, W/5, H/5, H/5)
	UpKey:SetNormalTexture("Interface/BUTTONS/UI-ScrollBar-ScrollUpButton-Up.png")
	UpKey:SetPushedTexture("Interface/BUTTONS/UI-ScrollBar-ScrollUpButton-Down.png")
        UpKey:SetHighlightTexture("Interface/BUTTONS/UI-ScrollBar-ScrollUpButton-Highlight.png")
	
	local DownKey = CreateFrame("Button", Object.Name.."DownKey", _G[Object.Parent])
	DownKey:SetHeight(H) DownKey:SetWidth(W)
	DownKey:SetPoint("CENTER", Object.XOffset, Object.YOffset-H/2)
	DownKey:SetHitRectInsets(W/5, W/5, H/5, H/5)
	DownKey:SetNormalTexture("Interface/BUTTONS/UI-ScrollBar-ScrollDownButton-Up.png")
	DownKey:SetPushedTexture("Interface/BUTTONS/UI-ScrollBar-ScrollDownButton-Down.png")
        DownKey:SetHighlightTexture("Interface/BUTTONS/UI-ScrollBar-ScrollDownButton-Highlight.png")		
	
	local LeftKey = CreateFrame("Button", Object.Name.."LeftKey", _G[Object.Parent])
	LeftKey:SetHeight(H) LeftKey:SetWidth(W)
	LeftKey:SetPoint("CENTER", Object.XOffset-W/2, Object.YOffset-H/2)
	LeftKey:SetHitRectInsets(W/5, W/5, H/5, H/5)
	LeftKey:SetNormalTexture(GetRotatedTexture(LeftKey, math.pi/2, "Up"))
	LeftKey:SetHighlightTexture(GetRotatedTexture(LeftKey, math.pi/2, "Highlight"))
	LeftKey:SetPushedTexture(GetRotatedTexture(LeftKey, math.pi/2, "Down"))
	
	local RightKey = CreateFrame("Button", Object.Name.."RightKey", _G[Object.Parent])
	RightKey:SetHeight(H) RightKey:SetWidth(W)
	RightKey:SetPoint("CENTER", Object.XOffset+W/2, Object.YOffset-H/2)
	RightKey:SetHitRectInsets(W/5, W/5, H/5, H/5)
	RightKey:SetNormalTexture(GetRotatedTexture(RightKey, -math.pi/2, "Up"))
	RightKey:SetHighlightTexture(GetRotatedTexture(RightKey, -math.pi/2, "Highlight"))
	RightKey:SetPushedTexture(GetRotatedTexture(RightKey, -math.pi/2, "Down"))
	
	for _,Event in ipairs(Object.Event) do
		if Event == 10 then
			UpKey:SetScript("OnClick", function() EventFunc("Up") end)
			DownKey:SetScript("OnClick", function() EventFunc("Down") end)
			LeftKey:SetScript("OnClick", function() EventFunc("Left") end)
			RightKey:SetScript("OnClick", function() EventFunc("Right") end)
		end
	end				
end
Gate.ScriptingInterface.gCursorKeys = gCursorKeys

-- StaticPopup - Standardframes von Blizzard
local function gStaticPopup(Object)
	StaticPopup_Show(string.upper(Object.Name), Object["1"], Object["2"])
end
-- For GateBuilder
Gate.ScriptingInterface.gStaticPopup = gStaticPopup

local DDIcons = {	"Interface/GossipFrame/ActiveQuestIcon",		--1
			"Interface/GossipFrame/AvailableQuestIcon",		--2
			"Interface/GossipFrame/BankerGossipIcon",		--3
			"Interface/GossipFrame/BattleMasterGossipIcon",	--4
			"Interface/GossipFrame/BinderGossipIcon",		--5
			"Interface/GossipFrame/DailyActiveQuestIcon",		--6
			"Interface/GossipFrame/DailyQuestIcon",			--7
			"Interface/GossipFrame/GossipGossipIcon",		--8
			"Interface/GossipFrame/HealerGossipIcon",		--9
			"Interface/GossipFrame/IncompleteQuestIcon",		--10
			"Interface/GossipFrame/PetitionGossipIcon",		--11
			"Interface/GossipFrame/TabardGossipIcon",		--12
			"Interface/GossipFrame/TaxiGossipIcon",			--13
			"Interface/GossipFrame/TrainerGossipIcon",		--14
			"Interface/GossipFrame/UnlearnGossipIcon",		--15
			"Interface/GossipFrame/VendorGossipIcon",		--16
			"Interface/FriendsFrame/InformationIcon.blp"}		--17
			
local function gDropDownMenu(Object)
	local DDMenu 
 	
	if type(Object.DropDownItems) ~= "table" then
		local temp = Object.DropDownItems
		Object.DropDownItems = {}
		table.insert(Object.DropDownItems, temp)
	end
	
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(DDMenu, self:GetID())
		if self.value == "00" then
			if Object.Event[1] == 10 then
				Object:Buffer("e")
				Object:Buffer(Object.oName)
				Object:Buffer(gEvents[10].Name) 
				Object:Buffer(UIDropDownMenu_GetText(DDMenu))
				Object:Buffer(obj.StatusSend)
				Object:SendBuffer()
			end
		else
			Object:Buffer("dde")
			Object:Buffer(Object.oName)
			Object:Buffer(gEvents[10].Name) 
			Object:Buffer(self.value)
			Object:Buffer(obj.StatusSend)
			Object:SendBuffer()
		end			
	end
	
	local function initialize(self, level)		
		local info
		for _,v in ipairs(self.MenuList) do
			info = UIDropDownMenu_CreateInfo()
			local value, icon, text = string.gmatch(v, "(%d%d)(%d%d)(.+)")()
			info.text = text
			info.value = value
			info.func = OnClick
			--info.keepShownOnClick = 1
			if icon ~= "00" then
				info.icon = DDIcons[tonumber(icon)]
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	 
	if _G[Object.Name] then
		DDMenu = _G[Object.Name]
		DDMenu:Show()
		DDMenu.MenuList = Object.DropDownItems
	else
		DDMenu = CreateFrame(Object.Type, Object.Name, _G[Object.Parent], Object.Template)
		-- Objekte k?nnen sich dort eintragen und werden beim Benutzen aufgerufen
		DDMenu.StatusSend = {}
		DDMenu.MenuList = Object.DropDownItems
		
		 -- simple style = UIDropDownMenu_Initialize(DDMenu, initialize, "MENU")
		UIDropDownMenu_Initialize(DDMenu, initialize)
		UIDropDownMenu_SetWidth(DDMenu, Object.Width)
		UIDropDownMenu_SetButtonWidth(DDMenu, Object.Width)
		UIDropDownMenu_JustifyText(DDMenu, "LEFT")
	end	
	
	gOffset(Object)
	gAlpha(Object)
	gShow(Object)	
	gSetStatusCheck(Object)
	gFadeIn(Object)
	gFadeOut(Object)
	DDMenu._Object = Object	

	if not UIDropDownMenu_GetSelectedID(DDMenu) then
		UIDropDownMenu_SetSelectedID(DDMenu, Object.SelectedItem)
	end
	if Object.Text then
		UIDropDownMenu_SetText(DDMenu, Object.Text)
	end
end
-- For GateBuilder
Gate.ScriptingInterface.gDropDownMenu = gDropDownMenu

local function gListBox(Object)
	if type(Object.ListBoxItems) ~= "table" then
		local temp = Object.ListBoxItems
		Object.ListBoxItems = {}
		table.insert(Object.ListBoxItems, temp)
	end
	
	local Events = Object.Event
	Object.Event = {}
	
	local ScrollListBox = gCreateObject(Object)--CreateFrame("ScrollFrame", Object.Name, _G[Object.Parent], "UIPanelScrollFrameTemplate")
	ScrollListBox.Child = CreateFrame("Frame")
	ScrollListBox:SetScrollChild(ScrollListBox.Child)
	
	ScrollListBox:ClearAllPoints()
	ScrollListBox:SetPoint("CENTER")
	ScrollListBox:SetSize(Object.Width, Object.Height)
	
	ScrollListBox.Child:SetWidth(ScrollListBox:GetWidth())
	ScrollListBox.Child:SetHeight(#Object.ListBoxItems*30)
	
	if ScrollListBox.Child:GetHeight() < Object.Height then
		_G[Object.Name.."ScrollBar"]:Hide()
	else
		_G[Object.Name.."ScrollBar"]:Show()
	end
	
	local LastIndex = 0
	for k,v in ipairs(Object.ListBoxItems) do
		local btn = CreateFrame("Button", Object.Name.."Item"..k, ScrollListBox.Child, "UIPanelButtonTemplate2")
		btn:SetText(v)
		btn:SetSize(Object.Width,30)
		btn:SetPoint("TOPRIGHT", ScrollListBox.Child, "TOPRIGHT", 0, -((k-1)*30))
		for _,Event in ipairs(Events) do
			if Event == 10 then
				btn:SetScript("OnClick", function(self) 
					debugprint("Listbox Event fired")
					Object:Buffer("e")
					Object:Buffer(Object.oName)
					Object:Buffer(gEvents[10].Name) 
					Object:Buffer(self:GetText())
					Object:SendBuffer()
				end)
			end
		end
		LastIndex = k
	end
	
	-- remove all other (old) buttons
	while _G[Object.Name.."Item"..LastIndex+1] do
		_G[Object.Name.."Item"..LastIndex+1]:Hide()
		LastIndex = LastIndex + 1
	end
	
	return ScrollListBox
end
-- For GateBuilder
Gate.ScriptingInterface.gListBox = gListBox	


--------------------------------------------------------------------
---------------- Regs - Objects ---------------------------------
-------------------------------------------------------------------

Gate_Reg_Comm("lb", gListBox)
	Gate_Reg_ShortCut("lb", "lbi", "ListBoxItems")
	Gate_Reg_Object("lb", {Type = "ScrollFrame", Width = 100, Height = 100, Template = "UIPanelScrollFrameTemplate"})
Gate_Reg_Comm("ddm", gDropDownMenu)
	Gate_Reg_ShortCut("ddm", "ddi", "DropDownItems")
	Gate_Reg_ShortCut("ddm", "si", "SelectedItem")
	Gate_Reg_Object("ddm", {Type = "Button", Width = 100, Template = "UIDropDownMenuTemplate", SelectedItem = 1})
Gate_Reg_Comm("frame", gFrame)
	Gate_Reg_ShortCut("frame", "cc", "CantClose")
	Gate_Reg_ShortCut("frame", "cm", "CantMove")
	Gate_Reg_ShortCut("frame", "d", "DisableMouse")
	Gate_Reg_ShortCut("frame", "in", "InfoText")
	Gate_Reg_ShortCut("frame", "f", "Front")
	Gate_Reg_ShortCut("frame", "lo", "LeaveOpen")
	Gate_Reg_ShortCut("frame", "tex", "Texture")
	Gate_Reg_Object("frame", {Type = "Frame", Width = 200, Height = 200, Template = "UIPanelDialogTemplate"})
Gate_Reg_Comm("tf", gTabbedFrame)
	Gate_Reg_ShortCut("tf", "tab", "Tabs")
	Gate_Reg_ShortCut("tf", "st", "SelectedTab")
	Gate_Reg_Object("tf", {Type = "Frame", Width = 200, Height = 200, SelectedTab = 1, TabButtonTemplate = "TabButtonTemplate"})--, Template = "UIPanelDialogTemplate"
Gate_Reg_Comm("pl", gPanel)
	Gate_Reg_ShortCut("pl", "br", "Border")
	Gate_Reg_ShortCut("pl", "bg", "Background")
	Gate_Reg_Object("pl", {Type = "Frame", Width = 200, Height = 50})	
Gate_Reg_Comm("btn", gButton)
	Gate_Reg_ShortCut("btn", "tex", "Texture")
	Gate_Reg_Object("btn", {Type = "Button", Width = 100, Height = 30, Template = "UIPanelButtonTemplate2"})
Gate_Reg_Comm("cb", gCheckBox)
	Gate_Reg_ShortCut("cb", "ch", "Checked")
	Gate_Reg_Object("cb", {Type = "CheckButton", Width = 20, Height = 20, Template = "UICheckButtonTemplate"})
Gate_Reg_Comm("rb", gRadioBox)
	Gate_Reg_ShortCut("rb", "ch", "Checked")
	Gate_Reg_Object("rb", {Type = "CheckButton", Template = "UIRadioButtonTemplate"})
Gate_Reg_Comm("eb", gEditBox)
	Gate_Reg_ShortCut("eb", "in", "InfoText")
	Gate_Reg_ShortCut("eb", "ml", "MultiLines")
	Gate_Reg_ShortCut("eb", "min", "Min")
	Gate_Reg_ShortCut("eb", "max", "Max")
	Gate_Reg_ShortCut("eb", "af", "AutoFocus")
	Gate_Reg_Object("eb", {Type = "EditBox", Width = 100, Height = 20, Template = "InputBoxTemplate"})
Gate_Reg_Comm("sb", gStatusBar)
	Gate_Reg_ShortCut("sb", "cd", "Countdown")
	Gate_Reg_ShortCut("sb", "min", "Min")
	Gate_Reg_ShortCut("sb", "max", "Max")
	Gate_Reg_ShortCut("sb", "val", "Value")
	Gate_Reg_ShortCut("sb", "ar", "AutoReset")
	Gate_Reg_ShortCut("sb", "rb", "RunBack")
	Gate_Reg_ShortCut("sb", "fl", "Flow")
	Gate_Reg_ShortCut("sb", "ve", "Vertical")
	Gate_Reg_Object("sb", {Type = "StatusBar", Width = 100, Height = 20, Max = 20, Min = 0, Value = 0})
Gate_Reg_Comm("sl", gSlider)
	Gate_Reg_ShortCut("sl", "min", "Min")
	Gate_Reg_ShortCut("sl", "max", "Max")
	Gate_Reg_ShortCut("sl", "val", "Value")
	Gate_Reg_ShortCut("sl", "stp", "ValueStep")
	Gate_Reg_ShortCut("sl", "lt", "LowText")
	Gate_Reg_ShortCut("sl", "ht", "HighText")
	Gate_Reg_Object("sl", {Type = "Slider", Template = "OptionsSliderTemplate", Min = 0, Max = 20, Value = 10, LowText = "", HighText = ""})
Gate_Reg_Comm("tb", gTextBox)
	Gate_Reg_ShortCut("tb", "th", "TextHeight")
	Gate_Reg_Object("tb", {Type = "TextBox", Font = "GameFontNormal"})
Gate_Reg_Comm("ck", gCursorKeys)
	Gate_Reg_Object("ck", {Type = "Button", Width = 50, Height = 50})
Gate_Reg_Comm("of", gOKFrame)
Gate_Reg_Comm("df", gDialogFrame)
	Gate_Reg_Object("df", {Type = "Frame", Width = 100, Height = 50, Template = "DialogBoxFrame"})
Gate_Reg_Comm("yn", gYesNoFrame)
	Gate_Reg_ShortCut("yn", "yes", "Yes")
	Gate_Reg_ShortCut("yn", "no", "No")
	Gate_Reg_ShortCut("yn", "cc", "CantClose")
	Gate_Reg_ShortCut("yn", "cm", "CantMove")
	Gate_Reg_ShortCut("yn", "in", "InfoText")
	Gate_Reg_ShortCut("yn", "f", "Front")
Gate_Reg_Comm("if", gInputFrame)
	Gate_Reg_ShortCut("if", "cc", "CantClose")
	Gate_Reg_ShortCut("if", "cm", "CantMove")
	Gate_Reg_ShortCut("if", "in", "InfoText")
	Gate_Reg_ShortCut("if", "ft", "FrameText")
	Gate_Reg_ShortCut("if", "bt", "ButtonText")
	Gate_Reg_ShortCut("if", "f", "Front")
	Gate_Reg_ShortCut("if", "dc", "DontCloseAfterSend")
Gate_Reg_Comm("sp", gStaticPopup)
	
Gate_Reg_Comm("getstatus", gGetStatus)
	Gate_Reg_ShortCut("getstatus", "gt", "GetType")