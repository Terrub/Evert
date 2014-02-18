Stamp = CreateFrame("Frame", nil, UIParent);

local this = Stamp;

Stamp.__index = Stamp;

local _default_icon = "Interface/ICONS/INV_Misc_QuestionMark";
local _retirement_list = {};

-- Defaults
this["icon"] = _default_icon;
this["inverted"] = false;
this["height"] = 32;
this["width"] = 32;
this["x_offset"] = 0;
this["y_offset"] = 0;
this["alpha"] = 1.0;

----------------------------------------------------------------
-- CONSTRUCTOR -------------------------------------------------
----------------------------------------------------------------

this.new = function(self, properties)
	
	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	-- Frames are tables, tables are expensive, ration and recycle!
	local _stamp = pop(_retirement_list) or CreateFrame("Frame");
	
	setmetatable(_stamp, self);
	
	-- Default imbue
	_stamp.has_retired = false;
	_stamp:SetFrameStrata("BACKGROUND");
	_stamp:Hide(); -- We're not showing unless told to.
	
	-- Extend our properties with any of the given.
	extend(_stamp, properties);
	
	-- User variable with default
	_stamp:SetHeight(_stamp.height);
	_stamp:SetWidth(_stamp.width);
	_stamp:SetPoint("CENTER", _stamp.x_offset, _stamp.y_offset);
	_stamp:SetAlpha(_stamp.alpha);
	
	_stamp:setIcon(_stamp.icon);
	
	return _stamp;

end;

----------------------------------------------------------------
-- CLASS METHODS -----------------------------------------------
----------------------------------------------------------------

this.retire = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if (self.has_retired) then return end;
		
	self:Hide();
	push(_retirement_list, self);
	self.has_retired = true;
	
end;

--------

this.hasRetired = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	return self.has_retired;

end;

----------------------------------------------------------------

this.getIcon = function(self)
	
	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
	
	return self.icon;

end;

--------

this.setIcon = function(self, icon)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
		
	self.icon = icon;
	
	local iconTexture = self.texture or self:CreateTexture(nil, "BACKGROUND");
	
	iconTexture:SetTexture(self.icon);
	iconTexture:SetAllPoints(self);
	
	self.texture = iconTexture;
	
end;

----------------------------------------------------------------


this.activate = function(self)
	
	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if self.has_retired then return end;
	
	if self.inverted then
	
		self:Hide();
		
	else
	
		self:Show();
		
	end;

end;

--------

this.deactivate = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if self.has_retired then return end;
	
	if self.inverted then
		
		self:Show();
		
	else
		
		self:Hide();
		
	end;

end;

---------------------------------------------------------------

this.getProperties = function(self)

	local _,_,_, x_offset, y_offset = self:GetPoint();

	local properties = {
		["icon"] = self:getIcon(),
		["inverted"] = self.inverted,
		["height"] = self:GetHeight(),
		["width"] = self:GetWidth(),
		["x_offset"] = x_offset,
		["y_offset"] = y_offset,
		["alpha"] = self:GetAlpha()
	};
	
	return properties;

end;

this.getConditions = function(self)

	return self.conditions;

end;