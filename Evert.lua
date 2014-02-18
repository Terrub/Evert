
----------------------------------------------------------------
-- TEMPORARILY STORED CONSTANTS N SHIT -------------------------
----------------------------------------------------------------

-- ERRORS
ERR_MISSING_PARAMETER_SELF = "Missing parameter 'self'. Possible use of . where : was expected";
ERR_UNEXPECTED_INITIALISATION = "Unexpected call made to Initialise() while already up and running.";
ERR_UNREGISTERED_EVENT_HANDLER = "call made to unknown or unregistered event handler.";
ERR_ATTEMPT_TO_PRINT_NON_STRING = "Call made to global prt() with a non-string value.";
ERR_DISAPPOINTED_CLASS_EXPECTATION = "Expected a specific class but was disappointed.";
ERR_DISAPPOINTED_NUMBER_EXPECTATION = "Expected a number but was disappointed."
ERR_DISAPPOINTED_STRING_EXPECTATION = "Expected a string but was disappointed."
ERR_DISAPPOINTED_FUNCTION_EXPECTATION = "Expected a function but was disappointed."
ERR_UNEXPECTED_NIL_VALUE = "Expected the following value but got nil."
ERR_WRONG_EVENT_FOR_HANDLER = "Eventhandler was called with different event than it is registered to.";
ERR_MISSING_KV_META_TABLE = 'Missing fundamental constant: "KV_META_TABLE".';
ERR_CORRUPT_KV_META_TABLE = 'Corrupt fundamental constant "KV_META_TABLE".';
ERR_DUPLICATE_EVENT_REGISTER_ATTEMPT = "Attempt to register event already in registry"

-- GLOBAL CONSTANTS
SCRIPTHANDLER_ON_EVENT = "OnEvent";
SCRIPTHANDLER_ON_UPDATE = "OnUpdate";
SCRIPTHANDLER_ON_SHOW = "OnShow";
TARGET_DEBUFFS_MAX = 16;

----------------------------------------------------------------
-- Helper functions --------------------------------------------
----------------------------------------------------------------

local tgetn = table.getn;
local tremove = table.remove;
local tinsert = table.insert;
local math_floor = math.floor;

pop = function(t)
	
	if not t then return end;
	
	local n = tgetn(t);
	
	if (n > 0) then 
		
		local o = t[n];
		
		tremove(t, n)
		
		return o;
		
	end;
	
end;

--------

push = function(t, v)
	
	tinsert(t, v);
	
end;

--------

log = function(...)

	prt("|cff999999 -- LOG -- |r");

	-- 'arg' Is a global variable that is filled when the vararg "..." is used.
	-- It contains a table with all the arguments and a size: "n".
	if (arg.n > 0) then
		
		for k, v in ipairs(arg) do
		
			stringify(v, k);
			
		end
	
	end
	
end

--------

prt = function(message)

	if not isString(message) then
		
		message = tostring(message);
		
		if not isString(message) then
			error(ERR_ATTEMPT_TO_PRINT_NON_STRING);
			return;
		end
		
	end
	
	DEFAULT_CHAT_FRAME:AddMessage(message);

end;

--------

stringify = function(value, key, indent)

	local _key = tostring(key);
	local _val = tostring(value);
	local i = indent or "";
	
	local recursive = false;
	
	if isTable(value) then
	
		if isFunction(value.GetName) and value:GetName() then
			_val = _val .. ' "|cffffffff' .. value:GetName() .. '|r"';
		end
		
		recursive = true;
		
	end
	
	-- Add a white colour to strings
	if isString(value) then
	
		_val = "|cffffffff" .. _val .. "|r";
	
	elseif isNumber(value) then
	
		_val = "|cffffff33" .. _val .. "|r";
	
	elseif isBoolean(value) then
	
		_val = "|cff9999ff" .. _val .. "|r";
	
	end
	
	prt(i .. "[|cff22ff22" .. _key .. "|r] |cff999999" .. _val .. "|r");
	
	if recursive then
		
		for k, v in pairs(value) do
		
			stringify(v, k, i.."   ");
			
		end;
		
	end
	
end

--------

isBoolean = function(bln)

	return (type(bln) == "boolean");

end;

--------

isString = function(str)

	return (type(str) == "string");

end;

--------

isTable = function(tbl)

	return (type(tbl) == "table");

end;

--------

isNumber = function(num)

	return (type(num) == "number");

end;

isFunction = function(fnc)

	return (type(fnc) == "function");
	
end;

isClass = function(class, instance)

	return (getmetatable(instance) == class);

end;

--------

extend = function(base, extension)

	-- 0 + b = b
	if not base then return extension end
	
	-- a + 0 = a
	if not extension then return base end

	-- 0 + 0 = 0
	if not isTable(base) or not isTable(extension) then
		error("Usage: extend(base 'table', extension 'table')");
		return;
	end

	for k, v in pairs(extension) do
		
		base[k] = v or base[k];
	
	end
	
	return base;
	
end

--------

-- Pulled this off the vanilla wowwiki page and edited a bit should probably credit the poor sod who wrote it.
prtTex = function()

	for tabIndex = 1, MAX_SKILLLINE_TABS do
	
		local tabName, tabTexture, tabSpellOffset, tabNumSpells = GetSpellTabInfo(tabIndex);
		
		if not tabName then break end
		
		for spellIndex = tabSpellOffset + 1, tabSpellOffset + tabNumSpells do
		
			local spellName, spellRank = GetSpellName(spellIndex, BOOKTYPE_SPELL);
			local spellTexture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL);

			prt("|cff999999"..spellName.."|r: |cff229922"..spellTexture.."|r");
			
		end;
		
	end;
	
end;

--[[ macro version of the texture printer
/run for ti=1,MAX_SKILLLINE_TABS do local tn,_,so,ns=GetSpellTabInfo(ti);if tn then for si=so+1,so+ns do local sn,st=GetSpellName(si,BOOKTYPE_SPELL),GetSpellTexture(si,BOOKTYPE_SPELL);DEFAULT_CHAT_FRAME:AddMessage(sn..": "..st);end end end
--]]

-- DONT TOUCH THIS UNLESS YOU WANT TO BE TICKLED TO DEATH BY A THOUSAND HAMSTERS!!!
KV_META_TABLE = {__mode = "kv"};

WeakTable = function(...)

	if not KV_META_TABLE then error(ERR_MISSING_KV_META_TABLE); end;
	
	if not isTable(KV_META_TABLE) then error(ERR_CORRUPT_KV_META_TABLE); end;
	
	local t = arg;

	setmetatable(t, KV_META_TABLE);
	
	return t;

end;

----------------------------------------------------------------
----------------------------------------------------------------
--                                                            --
--                     THE ACTUAL ADDON!                      --
--                                                            --
----------------------------------------------------------------
----------------------------------------------------------------

Evert = CreateFrame("Frame", "Evert", UIParent);

local this = Evert;

----------------------------------------------------------------
-- _PRIVATE_CONSTANTS ------------------------------------------
----------------------------------------------------------------

local _ALL_STAMPS = "all_stamps";

local _TARGET_BUFFS = "target_buffs";
local _TARGET_DEBUFFS = "target_debuffs";
local _PLAYER_BUFFS = "player_buffs";
local _PLAYER_DEBUFFS = "player_debuffs";
local _PLAYER_TRACKERS = "player_trackers";
local _PLAYER_POWER = "player_power";

	-- classes --
local _HUNTER = "Hunter";
local _MAGE = "Mage";
local _PALADIN = "Paladin";
local _PRIEST = "Priest";
local _ROGUE = "Rogue";
local _SHAMAN = "Shaman";
local _WARLOCK = "Warlock";
local _WARRIOR = "Warrior";

----------------------------------------------------------------
-- _private_variables ------------------------------------------
----------------------------------------------------------------

--[[ The WOW event the addon will register and listen for. 
	Upon firing the event the addon will start initialising.]]
local _initialisation_event = "ADDON_LOADED";

local _event_handlers = {};

local _stamp_collection;

local _empty_collection = {
	[_PLAYER_BUFFS] = {},
	[_PLAYER_DEBUFFS] = {},
	[_PLAYER_POWER] = {},
	[_PLAYER_TRACKERS] = {},
	[_TARGET_BUFFS] = {},
	[_TARGET_DEBUFFS] = {},
	[_ALL_STAMPS] = {},
};

----------------------------------------------------------------
-- Class Methods -----------------------------------------------
----------------------------------------------------------------

this.errorHandler = function(self, err_code, ...)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;

	-- #TODO# Convert the error code to sensible text from the
	-- error's table in our local strings.
	--log(_local[ERRORS][err_code]);
	
	local err_params = arg; -- arg is an implied table with all the excess parameters ... gives us.
	
	prt("|cffff0000ERROR DETECTED:|r");
	log(err_code, err_params);

end;

----------------------------------------------------------------
-- PRIVATE FUNCTIONS -------------------------------------------
----------------------------------------------------------------

local _refreshTargetDebuffs = function()
	
	if UnitExists("target") then
	
		if not _stamp_collection[_TARGET_DEBUFFS] then return end;
	
		for icon, stamp in pairs(_stamp_collection[_TARGET_DEBUFFS]) do
		
			stamp:activate();
			
		end;
		
		local i = 0;
		local stamp, icon;
		repeat -- Go through all debuffs on the target ...
			
			i = i + 1;
			
			icon, count, isMyDebuff = UnitDebuff("target", i);
			
			if isMyBuff then
				log("UnitDebuff param#3 not null:", isMyDebuff, "icon:", icon);
			end;	
			
			if icon then
				-- ... and check if we have a debuff stamp for it on registry ...
				stamp = _stamp_collection[_TARGET_DEBUFFS][icon];
		
				-- ... and if we do, show it.
				if stamp then
					
					stamp:activate();
					
				end;
				
			end;
			
		until icon == nil or i > TARGET_DEBUFFS_MAX; -- This max could be read from a class "Target"!
		
	end;
	
end;

-- Need to refactor this function with the previous one. We can split on unitID's "player" and "target"
-- As well as distinguish between buffs and debuffs.

local _refreshPlayerBuffs = function()
	
	if not _stamp_collection[_PLAYER_BUFFS] then return end;
	
	for icon, stamp in pairs(_stamp_collection[_PLAYER_BUFFS]) do
		
		stamp:deactivate();
		
	end;
	
	local i = 0;
	local stamp, icon;
	repeat -- Go through all debuffs on the player ...
		
		i = i + 1;
		
		icon, count, isMyBuff = UnitBuff("player", i);
		
		if isMyBuff then
			log("UnitBuff param#3 not null:", isMyBuff, "icon:", icon);
		end;
		
		--if icon and isMyDebuff == 1 then --not sure about this second parameter yet!
		if icon then
			
			-- ... and check if we have a debuff stamp for it on registry ...
			stamp = _stamp_collection[_PLAYER_BUFFS][icon];
			
			-- ... and if we do, show it.
			if stamp then
				
				stamp:activate();
				
			end;
			
		end;
		
	until icon == nil;

end;

----------------------------------------------------------------
-- EVENT HAMSTERS ----------------------------------------------
----------------------------------------------------------------

local unit_power_changedHandler = function(self, UnitId)

	if not self then
		error(ERR_MISSING_PARAMETER_SELF);
	end;

	-- Right now we're only handeling player power changes.
	if UnitId ~= "player" then return end;
	
	local unit_power = UnitMana(UnitId);
	if not isNumber(unit_power) then
		error(ERR_DISAPPOINTED_NUMBER_EXPECTATION);
	end;
	
	local max_power = UnitManaMax(UnitId);
	if not isNumber(max_power) then
		error(ERR_DISAPPOINTED_NUMBER_EXPECTATION);
	end;
	
	for icon, stamp in pairs(_stamp_collection[_PLAYER_POWER]) do
	
		if not stamp then
			error(ERR_UNEXPECTED_NIL_VALUE);
		end;
		
		local threshold = stamp.conditions.threshold or 0;
		local use_percentage = stamp.conditions.use_percentage;
		
		if use_percentage then
			-- Optional: Do some 0 <= threshold <= 100 checking?
			threshold = (threshold / 100) * max_power;
		
		end;
		
		if unit_power > threshold then
		
			stamp:activate();
			
		else
		
			stamp:deactivate();
		
		end;
	
	end;

end;

--------

local player_auras_changedHandler = function(self)
	
	if not self then
		error(ERR_MISSING_PARAMETER_SELF);
	end;

	-- Get all tracker stamps from our collection or exit if empty.
	local tracker_stamps = _stamp_collection[_PLAYER_TRACKERS];
	if not tracker_stamps then return end;
	
	-- Get the current tracking texture or exit if empty.
	local tracking_texture = GetTrackingTexture();
	
	-- Activate the stamp we currently have and deactivate any and all others.
	for icon, stamp in pairs(tracker_stamps) do
		
		if tracking_texture and icon == tracking_texture then
			-- Remember: activate is not Show() it just tells the stamp to go it's active state, that may be Hide()
			stamp:activate();
		
		else
			
			stamp:deactivate();
		
		end;
	
	end;

end;

--------

local unit_aura_changedHandler = function(self, unid_id)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
	
	if unid_id == "target" then
		--_refreshTargetBuffs();
		_refreshTargetDebuffs();
	end;
	
	if unid_id == "player" then
		_refreshPlayerBuffs();
		--_refreshPlayerDebuffs();
	end;
	
end;

--------

local player_target_changedHandler = function(self, change_method)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
	
	-- Technically the unit aura's on our target changed because our target changed.
	unit_aura_changedHandler(self, "target");
	
end;

--------

local player_logoutHandler = function(self)

	if not self then error(ERR_MISSING_PARAMETER_SELF); end;
	
	-- No need to save an empty settings object.
	if not _stamp_collection then return end;
	
	local unit_name = UnitName("player");
	if not unit_name then
		error(ERR_UNEXPECTED_NIL_VALUE);
	end;
	
	if unit_name == UNKNOWNOBJECT then
		error(ERR_LOAD_VARIABLES_FAILED);
	end;
	
	Evert_savedVariables.stamp_collection[unit_name] = {};
	
	for i, stamp in _stamp_collection[_ALL_STAMPS] do
		
		push(
			Evert_savedVariables.stamp_collection[unit_name],
			{
				["properties"] = stamp:getProperties(),
				["conditions"] = stamp:getConditions()
			}
		)
	
	end;
	
end;

--------

local _repopulateCollection = function(collection)

	if not collection then return end;

	for i, stamp_data in ipairs(collection) do
	
		if stamp_data then
		
			local condition_type = stamp_data.conditions.type;
			if condition_type then
			
				local properties = stamp_data.properties;
				if properties then
				
					local stamp = Stamp:new(properties)
					
					stamp.conditions = stamp_data.conditions;
					
					_stamp_collection = _empty_collection;
					
					-- Add our stamp to it's category
					if not _stamp_collection[condition_type] then
						_stamp_collection[condition_type] = {};
					end;
					
					_stamp_collection[condition_type][properties.icon] = stamp;
					
					-- And don't forget to upate our total list for later use.
					if not _stamp_collection[_ALL_STAMPS] then
						_stamp_collection[_ALL_STAMPS] = {};
					end;
				
					_stamp_collection[_ALL_STAMPS][properties.icon] = stamp;
				
				end;
				
			end;
			
		end;
	
	end;

end;

--------

local _loadSavedVariables = function()
	
	local unit_name = UnitName("player");
	if not unit_name then
		error(ERR_UNEXPECTED_NIL_VALUE);
	end;
	
	if unit_name == UNKNOWNOBJECT then
		error(ERR_LOAD_VARIABLES_FAILED);
	end;
	
	if not Evert_savedVariables then return end;
	
	_repopulateCollection(Evert_savedVariables.stamp_collection[unit_name]);
		
	if _stamp_collection then
	
		prt("|cff22ff22Evert|r - |cff999999Loaded profile:|r "..unit_name);
	
	end;

end;

--------

local _addRequiredEvents = function()
	
	-- Only true collectors are admitted! SHOOOO
	if not _stamp_collection then
		
		return;
		
	end;
	
	-- we always need to register this event to store our savedVariables
	this.addEvent("PLAYER_LOGOUT", player_logoutHandler);
	
	if (_stamp_collection[_TARGET_BUFFS]
		or _stamp_collection[_TARGET_DEBUFFS]
		or _stamp_collection[_PLAYER_BUFFS]
		or _stamp_collection[_PLAYER_DEBUFFS]
	) then
		
		this.addEvent("UNIT_AURA", unit_aura_changedHandler);
		this.addEvent("PLAYER_TARGET_CHANGED", player_target_changedHandler);
	
	end;
	
	if (_stamp_collection[_PLAYER_TRACKERS]) then
	
		this.addEvent("PLAYER_AURAS_CHANGED", player_auras_changedHandler);
	
	end;
	
	if (_stamp_collection[_PLAYER_POWER]) then
	
		local u_class = UnitClass("player");
		
		if u_class == _WARRIOR then
		
			this.addEvent("UNIT_RAGE", unit_power_changedHandler);
			return;
			
		end;
		
		if u_class == _ROGUE then
		
			this.addEvent("UNIT_ENERGY", unit_power_changedHandler);
			return;
			
		end;
		
		if (u_class == _HUNTER
			or u_class == _MAGE
			or u_class == _PALADIN
			or u_class == _PRIEST
			or u_class == _SHAMAN
			or u_class == _WARLOCK
		) then
		
			this.addEvent("UNIT_MANA", unit_power_changedHandler);
			return;
		
		end;
		
		-- Druids and any other class we don't expect get all three!
		this.addEvent("UNIT_MANA", unit_power_changedHandler);
		this.addEvent("UNIT_ENERGY", unit_power_changedHandler);
		this.addEvent("UNIT_RAGE", unit_power_changedHandler);
	
	end;
	
end;

--------

local _registerCurrentEvents = function()
	
	for event, eventHandler in pairs(_event_handlers) do
		
		if not isClass(EventHandler, eventHandler) then
			error(ERR_DISAPPOINTED_CLASS_EXPECTATION);
		end;
		
		this:RegisterEvent(event);
		 
	end;
	
end;

----------------------------------------------------------------
--	Coordinator of all event handlers.
--
--	USE WITH CARE!
--
--	KEEP CLEAN!
-- 
--	Has invisible parameters:
--	* [string] 'event' = The event that triggered the call.
--	* [*] 'arg1' [, 'arg2', ..., 'argn'] = All arguments
--		contained within 'arg'. Currently this seems to be
-- 		limited to n=9.
----------------------------------------------------------------
local _eventCoordinator = function()
	
	local eventHandler = _event_handlers[event];
	
	if not eventHandler then
		error(ERR_UNREGISTERED_EVENT_HANDLER);
	end;
	
	if not isClass(EventHandler, eventHandler) then
		error(ERR_DISAPPOINTED_CLASS_EXPECTATION);
	end;
	
	if (eventHandler.event ~= event) then	
		error(ERR_WRONG_EVENT_FOR_HANDLER);
	end;
	
	eventHandler:call(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	
end;

--------

local _slashCmdHandler = function(message, chat_frame)

	--prt("Recognised a slash command:");
	log(message);

end;

--------

local _initialise = function()

	if arg1 ~= "Evert" then return end;
	
	this:UnregisterEvent(_initialisation_event);
	
	-- We already initialised. DAFUQ?!
	if this.initialised then
		error(ERR_UNEXPECTED_INITIALISATION);
	end;
	
	-- Spam error messages to those less fortunate
	--local l={};
	--for k, v in (l) do if UnitName("player") == v then for i=1000, i>0, -1 do error("random error"..i);end;end;end;
	
	-- Get our saved variables.
	_loadSavedVariables();
	
	-- Add all the required events that our current stamp collection requires.
	_addRequiredEvents();
	
	-- Load up our event coordinator
	
	this:SetScript(SCRIPTHANDLER_ON_EVENT, _eventCoordinator);
	
	-- We can stop listening to this event now.
	_registerCurrentEvents();
	
	this.initialised = true;

end;

----------------------------------------------------------------
-- Public functions --------------------------------------------
----------------------------------------------------------------

this.addEvent = function(event, func)
	
	if not isString(event) then
		error(ERR_DISAPPOINTED_STRING_EXPECTATION);
	end;
	
	local eventHandler = _event_handlers[event] or EventHandler:new(event);
	
	eventHandler:setCallFunction(func);
	
	_event_handlers[event] = eventHandler;

end

--------

-- This is just quickly set up now, but should hash all the registers to Evert.
-- Returns the (allocated?) Evert._eventCoordinator for hooking events on.
this.registerForEventCoordinator = function(this)

	return _eventCoordinator;

end

----------------------------------------------------------------

this:SetScript(SCRIPTHANDLER_ON_EVENT, _initialise);
this:RegisterEvent(_initialisation_event);

-- Add a slash command match entry into the global namespace for the client to pick up.
SLASH_EVERT1 = "/evert";

-- And add a handler to react on the above match.
SlashCmdList["EVERT"] = _slashCmdHandler;

----------------------------------------------------------------
-- TESTING AREA ------------------------------------------------
----------------------------------------------------------------

this.logStamps = function()

	log(_stamp_collection);

end;

--------

this.logEventHandlers = function()

	log(_event_handlers);

end;

--------

this.logEvent = function(event, turn_off)

	if not isString(event) then
		error(ERR_DISAPPOINTED_STRING_EXPECTATION);
	end;
	
	if _event_handlers[event] and (not turn_off) then
		error(ERR_DUPLICATE_EVENT_REGISTER_ATTEMPT..": "..tostring(event));
	end;
	
	local _prt_event = function(self)
	
		prt('|cff666666|'..math_floor(GetTime())..'|r |cff22ff22Evert|r - |cff999999Event fired:|r '..self.event);
		
	end;
	
	local eventHandler = EventHandler:new(event);
	
	if not isClass(EventHandler, eventHandler) then
		error(ERR_DISAPPOINTED_CLASS_EXPECTATION..": EventHandler");
	end;
		
	if turn_off then
	
		_event_handlers[event] = nil;
	
		eventHandler:retire();
		
		this:UnregisterEvent(event);
		
		prt('|cff22ff22Evert|r - |cff999999 stopped loggin event:|r '..event);
		
	else
	
		_event_handlers[event] = eventHandler;
	
		eventHandler:setCallFunction(_prt_event);
		
		this:RegisterEvent(event);
		
		prt('|cff22ff22Evert|r - |cff999999Logging event:|r '..event);
		
	end;
	
end;

--------

local tests = {
	{
		fnc = _initialise,
		par = this,
		err = ERR_UNEXPECTED_INITIALISATION
	},
	{
		fnc = this.logEvent,
		par = nil,
		err = ERR_DISAPPOINTED_STRING_EXPECTATION
	}
}

this.test = function()

	local c_tests = 0;
	local max_tests = tgetn(tests) or 0;
	
	log("Starting " .. max_tests .. " test(s)");
	
	for i, test in ipairs(tests) do
		
		if test then
		
			local success, error_message = pcall(this[test["fnc"]], test["par"]);
			
			if (not success and (string.find(error_message, test["err"]))) then
			
				c_tests = c_tests + 1;
			
			else
				
				log("Test on " .. test["fnc"] .. " failed:");
				log("Expected: '" .. test["err"] .. "'");
			
				if success then
				
					log("No error detected");
					
				else
					
					log("Received: '" .. error_message .. "'");
					
				end;
				
			end;
		
		end;
	
	end;
	
	log(c_tests .. "/" .. max_tests .. " tests executed without problems");
	
end;

---------------------------------------------------

--[[ Khyrr's backup
Evert_savedVariables = {
	["stamp_collection"] = {
		["Khyrr"] = {
			[1] = {
				["properties"] = {
					["inverted"] = true,
					["alpha"] = 0.2980392156862745,
					["width"] = 256.0000179938907,
					["y_offset"] = 0,
					["x_offset"] = 0,
					["height"] = 256.0000179938907,
					["icon"] = "Interface\\Icons\\Spell_Nature_Earthquake",
				},
				["conditions"] = {
					["type"] = "player_trackers",
				},
			},
			[2] = {
				["properties"] = {
					["inverted"] = false,
					["alpha"] = 1,
					["width"] = 32.00000224923633,
					["y_offset"] = -160.0000022492363,
					["x_offset"] = 19.00000105432953,
					["height"] = 32.00000224923633,
					["icon"] = "interface\\icons\\Ability_Rogue_Ambush",
				},
				["conditions"] = {
					["threshold"] = 60,
					["type"] = "player_power",
				},
			},
			[3] = {
				["properties"] = {
					["inverted"] = true,
					["alpha"] = 1,
					["width"] = 32.00000224923633,
					["y_offset"] = -160.0000022492363,
					["x_offset"] = -19.00000105432953,
					["height"] = 32.00000224923633,
					["icon"] = "Interface\\Icons\\Ability_Warrior_BattleShout",
				},
				["conditions"] = {
					["type"] = "player_buffs",
				},
			},
		},
	},
}

--]]
----------------------------------------------------------
