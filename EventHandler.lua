EventHandler = {};

EventHandler.__index = EventHandler;

local this = EventHandler;

-- Does this work? Could be useful.
--local super = getmetatable(this).__index;

local _retirement_list = {};

local _default_callFunction = function(self, event, ...)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if not isClass(EventHandler, self) then
		error(ERR_DISAPPOINTED_CLASS_EXPECTATION.." EventHandler");
	end;

	log("EventHandler: default function was called by: ", self);

end;

----------------------------------------------------------------
-- CONSTRUCTOR -------------------------------------------------
----------------------------------------------------------------

this.new = function(self, event, call_func)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	local eventHandler = pop(_retirement_list) or {};
	
	setmetatable(eventHandler, self);
	
	eventHandler:setCallFunction(call_func or _default_callFunction);
	eventHandler.event = event;
	eventHandler.has_retired = false;
	
	return eventHandler;
	
end;

----------------------------------------------------------------
-- CLASS METHODS -----------------------------------------------
----------------------------------------------------------------

this.retire = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if (self.has_retired) then return end;
	
	if (isFunction(self.call)) then
		self.call = nil;
	end;
	
	push(_retirement_list, self);
	self.has_retired = true;
	
end;

--------

this.setCallFunction = function(self, call_function)
	
	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	if not isClass(EventHandler, self) then
		error(ERR_DISAPPOINTED_CLASS_EXPECTATION.." EventHandler");
	end;
	
	if call_function == nil then
		self:retire();
	end;
	
	if not isFunction(call_function) then
		error(ERR_DISAPPOINTED_FUNCTION_EXPECTATION);
	end;
	
	if self.call == call_function then return end;
	
	self.call = call_function;
	
end;

--------

this.getCallFunction = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
	
	if not isClass(EventHandler, self) then
		error(ERR_DISAPPOINTED_CLASS_EXPECTATION.." EventHandler");
	end;
	
	return self.call;

end;

----------------------------------------------------------------