PvPHelper = {}
PvPHelper.__index = PvPHelper; -- failed table lookups on the instances should fallback to the class table, to get methods

GVAR = {};
GVAR.UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)


function PvPHelper.new (options)
  local self = setmetatable({}, PvPHelper)
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
  print("DEBUG: PVPHELPER: Setting MainFrame.PvPHelper to self");
  return self;
end

function PvPHelper:MyCCTypes()
  local myCCTypes = CCTypeList.new();
  
  for i,cctype in ipairs(self.AllCCTypes) do
    if IsPlayerSpell(cctype.SpellId) then
      myCCTypes:Add(cctype)
      print("DEBUG: PVPHELPER: My CCType "..cctype.CCName);
    end
  end
  return myCCTypes
end

function PvPHelper:MessageReceived(strPrefix, strMessage, strType, strSender)
	print("PvPHelper:MessageReceived "..strMessage)
  self.Message:Format(strPrefix, strMessage, strType, strSender)
  print(self.Message.Header);
  if (self.Message.Header)=="WhatSpellsDoYouHave" then -- 0010 = What spells do you have
    print("PvPHelper: Been asked which spells I have, reply with a list of my spells");
    self:SendMessage("MySpells", self.CCTypes:ListSpellIds())
  elseif (self.Message.Header)=="SetCCTarget" then -- 0030 = Set CCTarget
    self:SetCCTarget(self.Message.Body)
  elseif (self.Message.Header)=="SetMainAssist" then -- 0040 = Set Main Assist
    self:SetMainAssist(self.Message.Body)
  elseif (self.Message.Header)=="PrepareToAct" then -- 0050 = PrepareToAct
    self:PrepareToAct(self.Message.Body);
  elseif (self.Message.Header)=="DoActionNow" then -- 0060 = DoActionNow
    self:DoCCActionNow(self.Message.Body);
  end
end

function PvPHelper:SendMessage(strMessage, strTarget)
	print("Sending message to server("..self.Message.From..") "..strMessage.." - "..strTarget);
  if (self.Message.From) then -- can only reply to server messages
  	--self.Message.Prefix = "NEWPvPHelper";
    self.Message:SendMessagePrefixed("PvPHelperServer", strMessage, strTarget, self.Message.From);
  end
end




--Conditional depending on test/live
--
--function PvPHelper:SetCCTarget(guid)
--  self.CCTarget = guid
--  self.UI:SetCCButton(self.CCTarget)
--end
--
--function PvPHelper:SetMainAssist(guid)
--  self.MainAssist = guid
--  UI_SetMainAssist(self.MainAssist)
--end
--
--function PvPHelper:PrepareToAct(spellId)
--  spellId = tonumber(spellId);
--  self.NextCCSpellId = spellId
--  self.NextCCSpellNotified = false;
--  self.UI:PrepareToAct(spellId)
--end
--
--function PvPHelper:DoCCActionNow(spellId)
--  spellId = tonumber(spellId);
--  self.CCSpellId = spellId
--  self.CCSpellNotified = false;
--  self.UI:DoCCActionNow(spellId)
--end
--


function PvPHelper:RegisterMainFrameEvents(frame)
	frame.TimeSinceLastUpdate = 0;
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
--  print("Event: "..tostring(event)..":"..tostring(Event))

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
--    self:SendMessage("MySpells", self.CCTypes:ListSpellIds())

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

  
  frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed; 	

  if (frame.TimeSinceLastUpdate > GVAR.UpdateInterval) then
    
    -- If we have notified the server that it's on cooldown, but now it's available, tell the server.
    
    local pvpHelper = frame.parent;

		
		for i, spell in ipairs( pvpHelper.SpellsOnCooldown) do
			--print("Spell on cooldown:"..spell.CCName);
			
			
			local start, duration, enabled = GetSpellCooldown(spell.SpellId);
			--print("Checking if ".. spell.SpellId.. " is useable");
			
			if enabled == 0 then
--			 DEFAULT_CHAT_FRAME:AddMessage("Spell is currently active, use it and wait " .. duration .. " seconds for the next one.");
			elseif ( start > 0 and duration > 0) then
--			 DEFAULT_CHAT_FRAME:AddMessage("Spell is cooling down, wait " .. (start + duration - GetTime()) .. " seconds for the next one.");
			else
--			 DEFAULT_CHAT_FRAME:AddMessage("Spell is ready.");
			 pvpHelper.SpellsOnCooldown:Delete(spell);
			 --pvpHelper:SendMessage("ThisSpellIsOffCooldown", tostring(spell.SpellId))
			end
			
--			if (enabled == 0) then
--				print("This spell is useable again");
--				--pvpHelper:SendMessage("ThisSpellIsOffCooldown", tostring(spell.SpellId))
--				pvpHelper.SpellsOnCooldown:Delete(spell);
--			end
			
			
		end
--    -- Do we have a spell that we're told to cast?
--    if pvpHelper.CCSpellId then
--      usable, nomana = IsUsableSpell(pvpHelper.CCSpellId);
--      if (not usable) then
--      -- Can we not cast that spell?
--        if (not nomana) then
--          --print("The spell cannot be cast");
--          -- Have we notified the server that it cant be cast
--          if not pvpHelper.SpellsOnCooldown[pvpHelper.CCSpellId] then
--            pvpHelper:SendMessage("ThisSpellIsOnCooldown", tostring(pvpHelper.CCSpellId))
--            -- After notifying server, add it to the lists of spells on cooldown.
--            pvpHelper.SpellsOnCooldown[pvpHelper.CCSpellId] = "OnCooldown";
--          end  
--        else
--          --print("You do not have enough mana to cast the spell");
--        end
--      else
--        --print("The spell may be cast");
--        -- Have we notified the server that it cant be cast
--        if pvpHelper.SpellsOnCooldown[pvpHelper.CCSpellId] then
--          pvpHelper:SendMessage("ThisSpellIsOffCooldown", tostring(pvpHelper.CCSpellId))
--          -- After notifying server, clear it from the lists of spells on cooldown.
--          pvpHelper.SpellsOnCooldown[pvpHelper.CCSpellId] = nil;
--        end  
--      end
--    end
  
	  frame.TimeSinceLastUpdate = 0;
  end
end



print("LOADING PVPHELPER")
local pvpHelper = PvPHelper.new();

pvpHelper:RegisterMainFrameEvents(pvpHelper.UI.MainFrame)

RegisterAddonMessagePrefix("PvPHelperClient");
--RegisterAddonMessagePrefix("PvPHelperServer");

