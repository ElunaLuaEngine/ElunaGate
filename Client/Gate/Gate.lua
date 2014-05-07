-- Project: 		Gate Core - New Life Update
-- Code: 		Kenuvis
-- Base Update: 	03.05.2012 (Kenuvis)
-- Last Update: 	29.07.2012 (Kenuvis)

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- Definations ----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
Gate = {}
Gate.ScriptingInterface = {}
Gate.Prefix = "ElunaGate"
Gate.StreamStart = "\129" --"�"
Gate.BlockStart = "\130" --"#"
Gate.BlockIdent = "\131" --"!"
Gate.StreamBlock = "\132" --"~"
Gate.StreamBlockEnd = "\133" --"!"
Gate.True = "\134" --"%"
Gate.False = "\135" --"&"
Gate.Debug = false
Gate.Version = "8"

print("[ElunaGate]: Loaded Client Side Framework!")

-- Saved for each character, so frames leave open after reload
Gate_OpenFrames = {}

Gate.ShortCuts = {	["w"] = "Width", 
				["h"] = "Height", 
				["t"] = "Text", 
				["x"] = "XOffset", 
				["y"] = "YOffset", 
				["e"] = "Event", 
				["l"] = "StatusLink",
				["a"] = "Alpha", 
				["r"] = "Red",
				["g"] = "Green",
				["b"] = "Blue",
				["s"] = "Style",
				["tt"] = "Tooltip",
				["hi"] = "Hidden", 
				["fi"] = "FadeIn",
				["fo"] = "FadeOut",
				["c"] = "Cursor"}

Gate.Objects = {}
Gate.SpecialShortCuts = {}
Gate.Command = {}
Gate.Styles = {	{0.5, 0.5, 0.5}, 
			{1, 0, 0},
			{0, 1, 0},
			{0, 0, 1},
			{1, 0.5, 0.5},
			{0.5, 1, 0.5},
			{0.5, 0.5, 1}}

function debugprint(text,prefix, exception)
	if Gate.Debug or exception then
		prefix = prefix or ""
		if type(text) == "table" then
			for i,k in pairs(text) do
				debugprint(k, prefix.."\194\187["..i.."]", exception)
			end
		else			
			print(prefix.." "..tostring(text))
		end
	end
end

table.combine = function(master,slave)
	master = master or {}
	slave = slave or {}
	for k,v in pairs(slave) do
		master[k] = master[k] or v
	end
	return master
end

math.tohex = function(num)
    local hexstr = "0123456789abcdef"
    local s = ""
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end

    if s == "" then s = "0" end
    return s
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- Income --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

local Gate_IncommingEvent = CreateFrame("Frame")
Gate_IncommingEvent:RegisterEvent("CHAT_MSG_ADDON")
Gate_IncommingEvent:RegisterEvent("ADDON_LOADED")

Gate_IncommingEvent:SetScript("OnEvent", function(self, event, Prefix,Stream,Type,Sender)
		if event == "CHAT_MSG_ADDON" then	
			if Prefix == "S"..Gate.Prefix and Sender == UnitName("player") then
				debugprint("Incoming Addon Message")
				Gate:IncomingStream(Stream)
			end
		elseif event == "ADDON_LOADED" and Prefix == "Gate" then
			for _,v in pairs(Gate_OpenFrames) do
				Gate:IncomingStream(v)
			end
		end
	end)
	
--[[ weil bei den Steuerzeichen die normalen Lua-Methoden versagen, muss eine neue Art und Weise her !
function Gate:DecodeStream(Stream) -- New Life Update
	local StreamStart = math.tohex(string.byte(Gate.StreamStart))
	local BlockStart = math.tohex(string.byte(Gate.BlockStart))
	local BlockIdent = math.tohex(string.byte(Gate.BlockIdent))
	local _true = math.tohex(string.byte(Gate.True))
	local _false = math.tohex(string.byte(Gate.False))
	
	local ByteStream = ""
	
	for a=1,string.len(Stream) do
		local byte = math.tohex(string.byte(Stream, a))
		while string.len(tostring(byte)) < 2 do
			byte = "0"..byte
		end
		
		ByteStream = ByteStream..byte
	end
	
	for event, parameter in string.gmatch(Stream, "%"..Gate.StreamStart.."(.[^"..Gate.BlockStart.."]*)(.[^"..Gate.StreamStart.."]*)") do
		local LeaveOpen, Name = Gate:IncomingMessage(event, parameter)
		
		if LeaveOpen then
			Gate_OpenFrames[Name] = Stream
		end
	end
end]]
	
	
	
function Gate:IncomingStream(Stream)
	debugprint(Stream, "RealStream:")
	
	-- Stream1 Stream2 Stream3 ...
	for event, parameter in string.gmatch(Stream, "%"..Gate.StreamStart.."(.[^"..Gate.BlockStart..Gate.StreamStart.."]+)(.[^"..Gate.StreamStart.."]*)") do
		local LeaveOpen, Name = Gate:IncomingMessage(event, parameter)
		
		if LeaveOpen then
			Gate_OpenFrames[Name] = Stream
		end
	end
end	
	
function Gate:IncomingMessage(Event, Text)
	-- da kam wohl ne falsche Message rein
	if not Event or not Text then return end
	
	-- die Textnachricht wird aufgesplittet und zu einem Table gemacht
	local Message = {}
	for a in string.gmatch(Text, "%"..Gate.BlockStart.."(.[^"..Gate.BlockStart.."]+)") do
		table.insert(Message, a)
	end
	
	debugprint(Event, "Event:")
	debugprint(Text, "Text:")

	-- abarbeiten der verschiedenen "events"
	if Gate.Command[Event] then	
		local Object = Gate_Create_New_Object()		

		-- Hier wird der ganze Kram mal noch weiter aufgesplittet und "leserlich" gemacht
		for k,v in ipairs(Message) do
			local prefix, info = string.match(v, "(%w+)%"..Gate.BlockIdent.."(.*)")
			if prefix == "p" then				-- Parent
				Object.Parent = Gate.Prefix..info
			elseif prefix == "n" then			-- Name
				Object.Name = Gate.Prefix..info
				Object.oName = info 			-- Orginalname ohne Prefix
			elseif prefix == "l" then
				table.insert(Object.StatusLink, Gate.Prefix..info)
			elseif prefix == "s" then
				if Gate.Styles[tonumber(info)] then
					Object.Red = Gate.Styles[tonumber(info)][1]
					Object.Green = Gate.Styles[tonumber(info)][2]
					Object.Blue = Gate.Styles[tonumber(info)][3]
				else
					print(Gate.Prefix..": Style-Information konnte nicht verarbeitet werden.")
				end
			elseif Gate.ShortCuts[prefix] or (Gate.SpecialShortCuts[Event] and Gate.SpecialShortCuts[Event][prefix]) then
				prefix = Gate.ShortCuts[prefix] or Gate.SpecialShortCuts[Event][prefix]
				
				if info == Gate.True then info = true end
				if info == Gate.False then info = false end
				
				-- generell paramater like name, text, offset, ... /  special parameter like cantmove for frames
				-- if parameter already set, add to table
				if type(Object[prefix]) == "table" then
					table.insert(Object[prefix], tonumber(info) or info)
				-- if it is the first one, it can be the only one, so add it at string or number
				elseif type(Object[prefix]) == "nil" then
					Object[prefix] = tonumber(info) or info
				-- or if it set the second time, create a table
				else
					local temp = Object[prefix]
					Object[prefix] = {}
					table.insert(Object[prefix], temp)
					table.insert(Object[prefix], tonumber(info) or info)
				end					
			else
				-- undefin. parameter
				if info == Gate.True then info = true end
				if info == Gate.False then info = false end
				Object[prefix] = tonumber(info) or info
			end
		end
		
		debugprint(Object, "Translated Stream:")
		-- Some standard setting were set here, if it is a Object
		--if Gate.Objects[Event] and not _G[Object.Name] then
			assert(Object.Name, Gate.Prefix..": Cannot create nameless Object")			
			Object = table.combine(Object, Gate.Objects[Event])
		--end
		
		-- Falls die Aufzeichnung l�uft, wird das Object an den Aufzeichner �bergeben
		Gate:Rec(Gate.SFName, Object, Event)
		
		
		Gate.Command[Event](Object, Event)
		debugprint("---")
		
		return Object.LeaveOpen, Object.Name
	else
		print(Gate.Prefix..": Unbehandeltes Event: "..Event..":"..Text)
		return
	end	
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- Buffer ---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- Der Buffer kann bequem nacheinander gef�llt werden, setzt aber ein sauberes scripting voraus!
function Gate:Buffer(Info)	
	if not Gate.SBuffer then
		Gate.SBuffer = Gate.StreamStart
	end
	
	debugprint(Info, "Buffer <<")
	
	-- Die verschiedenen M�glichkeiten, wie man etwas in den Buffer schreiben kann
	if type(Info) == "string" or type(Info) == "number" then	
		Gate.SBuffer = Gate.SBuffer..Gate.BlockStart..tostring(Info)
	elseif type(Info) == "boolean" then
		if Info then Gate:Buffer("+") else Gate:Buffer("-") end
	elseif type(Info) == "table" then
		for _,v in pairs(Info) do
			Gate:Buffer(v)
		end
	elseif type(Info) == "function" then
		Info()
	end
end

-- Nach dem Senden wird der Buffer geleert
function Gate:SendBuffer()
	debugprint(Gate.SBuffer, "Buffer:")
	assert(Gate.SBuffer, Gate.Prefix..": No exsiting buffer to send")
	
	-- Nachrichten k�nnen max 255 Zeichen lang sein. ein bisschen Tolleranz, das Prefix und Tab und ich schneide bei 245
	if string.len(Gate.SBuffer) <= 245 then
		debugprint("C"..Gate.Prefix, "Buffer Send with Prefix")
		SendAddonMessage("C"..Gate.Prefix, Gate.SBuffer, "WHISPER", UnitName("player"))
	else
		while string.len(Gate.SBuffer) > 245 do
			local ToSend = Gate.StreamBlock..string.sub(Gate.SBuffer, 1, 245)
			Gate.SBuffer = string.sub(Gate.SBuffer, 246)
			SendAddonMessage("C"..Gate.Prefix, ToSend, "WHISPER", UnitName("player"))
		end
		local ToSend = Gate.StreamBlock..Gate.StreamBlockEnd..Gate.SBuffer
		SendAddonMessage("C"..Gate.Prefix, ToSend, "WHISPER", UnitName("player"))
	end
	
	Gate.SBuffer = nil
	debugprint("Clear", "Buffer")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- RegFunctions ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function Gate_Reg_Comm(name, func)
	if type(func) == "string" then
		func = _G[func]
	end	
	
	name = string.lower(name)
	
	Gate.SpecialShortCuts[name] = {}
	Gate.Command[name] = func
end

function Gate_Reg_ShortCut(name, shortcut, fullname)
	if Gate.ShortCuts[shortcut] then 
		print(Gate.Prefix..": Parameter-Names-Registrierung fehlgeschlagen. ["..fullname.."]") 
		return 
	end
	Gate.SpecialShortCuts[name][shortcut] = fullname
end

function Gate_Reg_Object(name, setting)
	Gate.Objects[name] = setting
end

function Gate_Get_Objects(Obj)
	return Gate.Objects[Obj]
end

function Gate_Create_New_Object(Type, Parameter)
	local Object = {}
	Object.Event = {}
	Object.StatusLink = {}
	Object.Buffer = Gate.Buffer
	Object.SendBuffer = Gate.SendBuffer
	
	if Type then
		Object = table.combine(Object, Gate_Get_Objects(Type))
	end
	
	if Parameter then
		Object = table.combine(Parameter, Object)
	end
	
	return Object
end
Gate.ScriptingInterface.NewObject = Gate_Create_New_Object

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- StaticFrame handle ---------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

Gate_SF = {}

local function gSFRecStart(Object)
	debugprint(Object.oName.." Rec start")
	
	function Gate:Rec(Name, Object, Event)
		if not Name or Event == "sfstop" then return end
		if not Gate_SF[Name] then
			Gate_SF[Name] = {}
		end
		
		Object.SF_Event = Event
		
		Gate_SF[Name][Object.Name] = Object
	end
	
	Gate.SFName = Object.oName	
end

local function gSFRecStop(Object)
	debugprint(Object.oName.." Rec stop")

	function Gate:Rec()
		return
	end
	
	Gate.SFName = nil
	--Gate.Command["hide"](_, {Name = "GateSFLoading"})
end

function Gate:Rec()
	return
end

local function gSFCall(SFObject)
	-- Falls er die Aufzeichnung nicht hat, so wird es dem Server mitgeteilt
	if not Gate_SF[SFObject.oName] then
		Gate:Buffer("sf")
		Gate:Buffer(SFObject.oName)
		Gate:SendBuffer()
		return
	end
	
	for _,Object in pairs(Gate_SF[SFObject.oName]) do
		--print("##"..Object.SF_Event)
		Gate.Command[Object.SF_Event](Object, Object.SF_Event)
	end
end

Gate_Reg_Comm("sf", gSFCall)
Gate_Reg_Comm("sfstart", gSFRecStart)
	Gate_Reg_ShortCut("sfstart", "ct", "Count")
Gate_Reg_Comm("sfstop", gSFRecStop)

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------- Versionscheck --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

local function gVersion(Object)
	Gate:Buffer("version")
	Gate:Buffer(Object.Command)
	Gate:Buffer(tostring(Object.Version) == tostring(Gate.Version))
	Gate:Buffer((Gate.Command[Object.Command] ~= nil))
	Gate:SendBuffer()
	
	if tostring(Object.Version) ~= tostring(Gate.Version) then
		message(Gate.Prefix..": Version unequal to Server. Please Update! If this is not the first time, this message appear, screen this for your administrator. S"..Object.Version.."C"..Gate.Version)
	end
	
	if Gate.Command[Object.Command] == nil then
		print(Gate.Prefix..": Link does not exist. Please screen this and ask for support in your forum. "..Object.Command)
	end
end

Gate_Reg_Comm("version", gVersion)
	Gate_Reg_ShortCut("version", "v", "Version")
	Gate_Reg_ShortCut("version", "cmd", "Command")