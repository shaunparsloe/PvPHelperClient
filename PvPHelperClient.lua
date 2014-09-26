PvPHelperClient = {}
PvPHelperClient.__index = PvPHelperClient; -- failed table lookups on the instances should fallback to the class table, to get methods

GVAR = {};


function PvPHelperClient.new (options)
	local self = setmetatable({}, PvPHelperClient)
	self.AllCCTypes = CCTypeList:LoadAllCCTypes();
	self.Message = deepcopy(Message.new());
	self.Message.ReceivePrefix = "PvPHelperClient";

	self.CCTypes = self:MyCCTypes();
	self.SpellsOnCooldown = CCTypeList.new();
	self.MainAssit = nil;
	self.CCTarget = nil;
	self.InCombat = false;
	self.MyName = UnitName("player").."-"..GetRealmName();
	self.UI = PvPHelper_UI.new(self);
	self.Timers = TimerList.new();
	print("DEBUG: PVPHELPER: Setting MainFrame.PvPHelperClient to self");
	return self;
end

function PvPHelperClient:MyCCTypes()
	local myCCTypes = CCTypeList.new();
	
	for i,cctype in ipairs(self.AllCCTypes) do
		if IsPlayerSpell(cctype.SpellId) then
			myCCTypes:Add(cctype)
			print("DEBUG: PVPHELPER: My CCType "..cctype.CCName);
		end
	end
	return myCCTypes
end

function PvPHelperClient:MessageReceived(strPrefix, strMessage, strType, strSender)
	print("DEBUG:PvPHelperClient:MessageReceived "..strMessage)
	self.Message:Format(strPrefix, strMessage, strType, strSender)
	print(tostring(self.Message.Header));
	if (self.Message.Header)=="WhatSpellsDoYouHave" then -- 0010 = What spells do you have
		-- print("DEBUGPvPHelper: Been asked which spells I have, reply with a list of my spells");
		self:SendMessage("MySpells", self.CCTypes:ListSpellIds())
	elseif (self.Message.Header)=="SetCCTarget" then -- 0030 = Set CCTarget
		self:SetCCTarget(self.Message.Body)
	elseif (self.Message.Header)=="SetMainAssist" then -- 0040 = Set Main Assist
		self:SetMainAssist(self.Message.Body)
	elseif (self.Message.Header)=="PrepareToAct" then -- 0050 = PrepareToAct
		self:PrepareToAct(self.Message.Body);
	elseif (self.Message.Header)=="ActNow" then -- 0060 = DoActionNow
		self:DoCCActionNow(self.Message.Body);
	elseif (self.Message.Header)=="LateActNow" then -- 0060 = DoActionNow
		self:DoLateCCAction(self.Message.Body);
	elseif (self.Message.Header)=="VeryLateActNow" then -- 0060 = DoActionNow
		self:DoVeryLateCCAction(self.Message.Body);
	else
		print("PvPHelperClient:MessageReceived: Unknown message header: "..tostring(self.Message.Header));
	end
end

function PvPHelperClient:SendMessage(strMessage, strTarget)
	-- print("DEBUG: Sending message to server("..self.Message.From..") "..strMessage.." - "..strTarget);
	if (self.Message.From) then -- can only reply to server messages
		--self.Message.Prefix = "NEWPvPHelper";
		self.Message:SendMessagePrefixed("PvPHelperServer", strMessage, strTarget, self.Message.From);
	end
end




--Conditional depending on test/live
--
--function PvPHelperClient:SetCCTarget(guid)
--	self.CCTarget = guid
--	self.UI:SetCCButton(self.CCTarget)
--end
--
--function PvPHelperClient:SetMainAssist(guid)
--	self.MainAssist = guid
--	UI_SetMainAssist(self.MainAssist)
--end

function PvPHelperClient:PrepareToAct(strMessage)
	print("PVPHELPER: Asked to Prepare to act. Message "..strMessage);

	local messageSplit = string_split(strMessage, ",");

    local spellId = messageSplit[1]; -- Will Be "PrepareToAct"
    local secondsTime = messageSplit[2];
	
	print("Adding timer with duration = "..secondsTime);
	local timer = Timer.new({TimerId=spellId, Duration = secondsTime, parent=self})
	self.Timers:Add(timer);
	
	self.UI:PrepareToAct(spellId, secondsTime)
end


function PvPHelperClient:Tick(seconds)
--	print("PVPHELPER: ACT NOW on spellid"..spellId);
	self.UI:Tick(seconds)
end

function PvPHelperClient:DoCCActionNow(spellId)
--	print("PVPHELPER: ACT NOW on spellid"..spellId);
	self.UI:DoCCActionNow(spellId)
end

function PvPHelperClient:DoLateCCAction(spellId)
--	print("PVPHELPER: ACT NOW on spellid"..spellId);
	self.UI:DoLateCCAction(spellId)
end

function PvPHelperClient:DoVeryLateCCAction(spellId)
--	print("PVPHELPER: ACT NOW on spellid"..spellId);
	self.UI:DoVeryLateCCAction(spellId)
end

function PvPHelperClient:RegisterMainFrameEvents(frame)
	frame.TimeSinceLastUpdate = 0;
	frame.TimerTick = 0;
	frame:SetScript("OnUpdate", PVPHelper_OnUpdate)

	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("CHAT_MSG_ADDON")
	frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		frame:RegisterEvent("PLAYER_REGEN_DISABLED");
			frame:RegisterEvent("PLAYER_REGEN_ENABLED");

	print ("PVPHELPER - setting script");
	frame:SetScript("OnEvent", PvPHelper_OnEvent)

end

function PvPHelper_OnEvent(frame, event, ...)
		local timestamp, Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, param15,
		param16, param17, param18, param19, param20, param21, param22, param23=...
--	print("Event: "..tostring(event)..":"..tostring(Event))

	local pvpHelper = frame.parent;
	
	if event == "PLAYER_REGEN_DISABLED" then
		pvpHelper.InCombat = true;
	elseif event == "PLAYER_REGEN_ENABLED" then
		pvpHelper.InCombat = false;
	elseif event == "PLAYER_ENTERING_WORLD" then
		print("PVPHELPER IS IN THE HOUSE!!!")
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then

--	print("UNIT_SPELLCAST_SUCCEEDED!")
--	print("ts:"..tostring(timestamp)
--	.."|Ev:"..tostring(Event)
--	.."|HC".. tostring(hideCaster)
--	.."|SG".. tostring(sourceGUID)
--	.."|SN".. tostring(sourceName)
--	.."|SF".. tostring(sourceFlags))
	local ccType = frame.parent.CCTypes:LookupSpellId(sourceName);
	if ccType then
		print("This is one of my CC Spells");
		-- TODO: Remove this comment
		-- Need to comment this out to try to debug why the system keeps crashing when 2x
		-- ccTypes are run together
		pvpHelper.SpellsOnCooldown:Add(ccType);
		
		pvpHelper:SendMessage("SpellCoolDown", "SPELL-"..tostring(ccType.SpellId))
--		pvpHelper:SendMessage23456("ThisSpellIsOnCooldown123456", tostring(ccType.SpellId))
--		self:SendMessage("MySpells", self.CCTypes:ListSpellIds())

	else
		print("Not one of my CC Spells");
	end
--	pvpHelper:SendMessage("ThisSpellIsOnCooldown", tostring(pvpHelper.CCSpellId))
	
	elseif event == "CHAT_MSG_ADDON" then
--	print("PvPHelperClient-MESSAGE RECEIVED with stamp "..timestamp.." - "..tostring(Event))
	
		if (timestamp == "PvPHelperClient") then
			pvpHelper:MessageReceived(tostring(timestamp), tostring(Event), tostring(hideCaster), tostring(sourceGUID))
--	else
--		print("PvpHelperClient ERROR Message Received with stamp "..timestamp)
		end

		
	end
end

function PVPHelper_OnUpdate(frame, elapsed)

	-- Countdown timer tick
	frame.TimerTick = frame.TimerTick + elapsed; 	
	if (frame.TimerTick > 0.1) then
		local pvpHelper = frame.parent;

		pvpHelper.Timers:CheckTimers();

		frame.TimerTick = 0;
	end
	

	-- Check for spell updates
	frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed; 	

	if (frame.TimeSinceLastUpdate > 0.5) then
		
		-- If we have notified the server that it's on cooldown, but now it's available, tell the server.
		
		local pvpHelper = frame.parent;

		
		for i, spell in ipairs( pvpHelper.SpellsOnCooldown) do
			--print("Spell on cooldown:"..spell.CCName);
			
			
			local start, duration, enabled = GetSpellCooldown(spell.SpellId);
			--print("Checking if ".. spell.SpellId.. " is useable");
			
			if enabled == 0 then
--				DEFAULT_CHAT_FRAME:AddMessage("Spell is currently active, use it and wait " .. duration .. " seconds for the next one.");
			elseif ( start > 0 and duration > 0) then
--				DEFAULT_CHAT_FRAME:AddMessage("Spell is cooling down, wait " .. (start + duration - GetTime()) .. " seconds for the next one.");
			else
--				DEFAULT_CHAT_FRAME:AddMessage("Spell is ready.");
				pvpHelper.SpellsOnCooldown:Delete(spell);
			 	pvpHelper:SendMessage("ThisSpellIsOffCooldown", tostring(spell.SpellId))
			end
			
		end
	
		frame.TimeSinceLastUpdate = 0;
	end
end



print("LOADING PVPHELPER")
local pvpHelper = PvPHelperClient.new();

pvpHelper:RegisterMainFrameEvents(pvpHelper.UI.MainFrame)

RegisterAddonMessagePrefix("PvPHelperClient");
--RegisterAddonMessagePrefix("PvPHelperServer");

