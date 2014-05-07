-- Project: 		GateMinimapButton
-- Code: 		Kenuvis
-- Last Update: 	09.06.2011

local function gMinimapButton_Create(Object)
	local MMB = _G[Object.Name] or CreateFrame("Button", Object.Name, Minimap, "Gate_MinimapButton_Template")
	
	if Object.Texture then
		_G[Object.Name.."_Icon"]:SetTexture(Object.Texture)
	end
	
	if Object.Degree then
		MMB:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(Object.Degree)),(80*sin(Object.Degree))-52)
	end
	
	if Object.CantMove then
		MMB:SetMovable(false)
	end
	
	if Object.Tooltip then
		MMB:SetScript("OnEnter", function()
			GameTooltip:SetOwner(MMB, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(Object.Tooltip)
			GameTooltip:Show()
		end)
		MMB:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end
	
	MMB:SetScript("OnClick", function(obj, arg)
		Object:Buffer("e")
		Object:Buffer(Object.oName)
		Object:Buffer("OnClick") 
		Object:Buffer(arg)
		Object:SendBuffer()
	end)
	
	if Object.Hidden then
		MMB:Hide()
	else
		MMB:Show()
	end
end

Gate_Reg_Comm("mmb", gMinimapButton_Create)
	Gate_Reg_ShortCut("mmb", "tex", "Texture")
	Gate_Reg_ShortCut("mmb", "deg", "Degree")
	Gate_Reg_ShortCut("mmb", "m", "CantMove")