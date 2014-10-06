PvPHelperClient = {}
PvPHelperClient.__index = PvPHelperClient; -- failed table lookups on the instances should fallback to the class table, to get methods
PvPHelperClient_MainFrame = {}
  
GVAR = {};


function PvPHelperClient.new (options)
  local self = setmetatable({}, PvPHelperClient)
  self.AllCCTypes = CCTypeList:LoadAllCCTypes();
  self.Message = deepcopy(Message.new());
  self.Message.ReceivePrefix = "PvPHelperClient";
  self.Flags = {};
  
  self.CCTypes = self:MyCCTypes();
  self.SpellsOnCooldown = CCTypeList.new();
  self.MainAssit = nil;
  self.CCTarget = nil;
  self.InCombat = false;
  self.MyName = UnitName("player").."-"..GetRealmName();
  self.UI = PvPHelper_UI.new(self);
  self.Timer = Timer.new();
  
  PvPHelperClient_MainFrame = self.MainFrame;
    
  --print("DEBUG: PVPHELPER: Setting MainFrame.PvPHelperClient to self");
  return self;
end

function PvPHelperClient:MyCCTypes()
  local myCCTypes = CCTypeList.new();
  
  local localizedClass, myClass = UnitClass("player");
  --print("DEBUG:PvPHelperClient:MyCCTypes(): My Class is "..myClass);
  local i, cctype
  for i,cctype in ipairs(self.AllCCTypes) do
    if myClass == cctype.Class then
      --print("DEBUG:PvPHelperClient:MyCCTypes(): Checking spell "..cctype.CCName);
      if DoesPlayerHaveSpell(cctype.SpellId) then
        myCCTypes:Add(cctype)
        --print("DEBUG: PvPHelperClient:MyCCTypes(): My CC Spell is ("..cctype.SpellId..") "..cctype.CCName);
      else
        --print("DEBUG: PvPHelperClient:MyCCTypes(): NOT MY CC. Spell is ("..cctype.SpellId..") "..cctype.CCName);
      end
    else
      --print("DEBUG:PvPHelperClient:MyCCTypes():Ignore ("..cctype.SpellId..") "..cctype.CCName.." as it is for "..cctype.Class.." and I am a "..myClass);
    end
  end
  return myCCTypes
end


function PvPHelperClient:MessageReceived(strPrefix, strMessage, strType, strSender)
 --print("DEBUG:PvPHelperClient:MessageReceived "..strMessage)
  self.Message:Format(strPrefix, strMessage, strType, strSender)
  --print(tostring(self.Message.Header));
  if (self.Message.Header)=="WhatSpellsDoYouHave" then -- 0010 = What spells do you have
   --print("DEBUG:PvPHelper: Been asked which spells I have, reply with a list of my spells:"..self.CCTypes:ListSpellIds());
    self.UI.MainFrame:Show();
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
    --print("DEBUG:PvPHelperClient:MessageReceived: Unknown message header: "..tostring(self.Message.Header));
  end
end

function PvPHelperClient:SendMessage(strMessage, strTarget)
  --print("DEBUG: Sending message to server("..self.Message.From..") "..strMessage.." - "..strTarget);
  if (self.Message.From) then -- can only reply to server messages
    --self.Message.Prefix = "NEWPvPHelper";
    self.Message:SendMessagePrefixed("PvPHelperServer", strMessage, strTarget, self.Message.From);
  end
end


function PvPHelperClient:PrepareToAct(strMessage)
 --print("DEBUG:PVPHELPER: Asked to Prepare to act. Message "..strMessage);

  local messageSplit = string_split(strMessage, ",");

    local spellId = messageSplit[1]; -- Will Be "PrepareToAct"
    local secondsTime = messageSplit[2];
  
 --print("DEBUG:PvPHelperClient:PrepareToAct:Adding timer with duration = "..secondsTime);
  local timer = Timer.new({TimerId=spellId, Duration = secondsTime, parent=self})
  self.Timer = timer;
  
  self.UI:PrepareToAct(spellId, secondsTime)
  self:PlaySound(spellId.."_Prepare.mp3")
end


function PvPHelperClient:Tick(seconds)
  --print("PVPHELPER: Tick("..seconds..")");
  if seconds == 5 then
    if self.Flags.Do5SecondsSound then
      self.Flags.Do5SecondsSound = true;
      self:PlaySound(spellId.."_Prepare.mp3");
    end
  else
    self.Flags.Do5SecondsSound = nil;
  end
  if seconds == 3 then
    --print("Ticking 3");
    if not self.Flags.Do3SecondsSound then
      --print("Playing 3");
      self.Flags.Do3SecondsSound = true;
      self:PlaySound("Countdown_3.mp3")
    end
  else
    --print("Clearing 3 flag");
    self.Flags.Do3SecondsSound = nil;
  end
  if seconds == 2 then
    if not self.Flags.Do2SecondsSound then
      self.Flags.Do2SecondsSound = true;
      self:PlaySound("Countdown_2.mp3")
    end
  else
    self.Flags.Do2SecondsSound = nil;
  end
  if seconds == 1 then
    if not self.Flags.Do1SecondsSound then
      self.Flags.Do1SecondsSound = true;
      self:PlaySound("Countdown_1.mp3")
    end
  else
    self.Flags.Do1SecondsSound = nil;
  end
  self.UI:SetTimerText(seconds)
end

function PvPHelperClient:PlaySound(soundFileName)
  if (soundFileName) then
    --print("DEBUG: PvPHelperClient:PlaySound(Interface\\AddOns\\PvPHelperClient\\Sounds\\"..soundFileName..")");

    PlaySoundFile("Interface\\AddOns\\PvPHelperClient\\Sounds\\"..soundFileName)

    if DEBUG and DEBUG.LogSound then
      GVAR.PlaySound = soundFileName;
    end
  else
    print("No soundfile passed");
  end 
end

function PvPHelperClient:DoCCActionNow(spellId)
  --print("DEBUG: PVPHELPER: ACT NOW on spellid"..spellId);
  
  -- Reset the timer if it is running
  self.UI:SetTimerText("")
  self.Timer = Timer.new();

  self.UI:DoCCActionNow(spellId)
  self:PlaySound(spellId.."_ActNow.mp3")
  
end

function PvPHelperClient:DoLateCCAction(spellId)
--print("PVPHELPER: ACT NOW on spellid"..spellId);
  self.UI:DoLateCCAction(spellId)
  self:PlaySound(spellId.."_LateActNow.mp3")
end

function PvPHelperClient:DoVeryLateCCAction(spellId)
--print("PVPHELPER: ACT NOW on spellid"..spellId);
  self.UI:DoVeryLateCCAction(spellId)
  self:PlaySound(spellId.."_VeryLateActNow.mp3")
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

  --print ("DEBUG:PvPHelperClient:RegisterMainFrameEvents(frame) - setting script");
  frame:SetScript("OnEvent", PvPHelper_OnEvent)

end

function PvPHelper_OnEvent(frame, event, ...)
    local timestamp, Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, param15,
    param16, param17, param18, param19, param20, param21, param22, param23=...
--print("Event: "..tostring(event)..":"..tostring(Event))

  local pvpHelper = frame.parent;
  
  if event == "PLAYER_REGEN_DISABLED" then
    pvpHelper.InCombat = true;
  elseif event == "PLAYER_REGEN_ENABLED" then
    pvpHelper.InCombat = false;
  elseif event == "PLAYER_ENTERING_WORLD" then
    print("PVPHELPER IS IN THE HOUSE!!!")
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then

--print("UNIT_SPELLCAST_SUCCEEDED!")
--print("ts:"..tostring(timestamp)
--  .."|Ev:"..tostring(Event)
--  .."|HC".. tostring(hideCaster)
--  .."|SG".. tostring(sourceGUID)
--  .."|SN".. tostring(sourceName)
--  .."|SF".. tostring(sourceFlags))
  local ccType = frame.parent.CCTypes:LookupSpellId(sourceName);
  if ccType then
    --print("DEBUG:This is one of my CC Spells");
    -- TODO: Remove this comment
    -- Need to comment this out to try to debug why the system keeps crashing when 2x
    -- ccTypes are run together
    pvpHelper.SpellsOnCooldown:Add(ccType);
    
    pvpHelper:SendMessage("SpellCoolDown", tostring(ccType.SpellId))
--    pvpHelper:SendMessage23456("ThisSpellIsOnCooldown123456", tostring(ccType.SpellId))
--    self:SendMessage("MySpells", self.CCTypes:ListSpellIds())

  else
    --print("DEBUG:Not one of my CC Spells - spell ID="..sourceName);
  end
--  pvpHelper:SendMessage("ThisSpellIsOnCooldown", tostring(pvpHelper.CCSpellId))
  
  elseif event == "CHAT_MSG_ADDON" then
--print("DEBUG:PvPHelperClient-MESSAGE RECEIVED with stamp "..timestamp.." - "..tostring(Event))
  
    if (timestamp == "PvPHelperClient") then
      pvpHelper:MessageReceived(tostring(timestamp), tostring(Event), tostring(hideCaster), tostring(sourceGUID))
--  else
    --print("DEBUG:PvpHelperClient ERROR Message Received with stamp "..timestamp)
    end

    
  end
end

function PVPHelper_OnUpdate(frame, elapsed)

  local pvpHelper = frame.parent;

  -- Countdown timer tick
  frame.TimerTick = frame.TimerTick + elapsed;   
  if (frame.TimerTick > 0.1) then

    if pvpHelper.Timer:IsActive() then
      pvpHelper:Tick(pvpHelper.Timer:TimeRemaining());
    end
    
    frame.TimerTick = 0;
  end
  

  -- Check for spell updates
  frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed;   

  if (frame.TimeSinceLastUpdate > 0.5) then
    
    -- If we have notified the server that it's on cooldown, but now it's available, tell the server.
    

    local i, spell
    for i, spell in ipairs( pvpHelper.SpellsOnCooldown) do
      --print("Spell on cooldown:"..spell.CCName);
      
      
      local start, duration, enabled = GetSpellCooldown(spell.SpellId);
      --print("Checking if ".. spell.SpellId.. " is useable");
      
      if enabled == 0 then
        --print("DEBUG:Spell is currently active, use it and wait " .. duration .. " seconds for the next one.");
      elseif ( start > 0 and duration > 0) then
        --print("DEBUG:Spell is cooling down, wait " .. (start + duration - GetPvPClockTime()) .. " seconds for the next one.");
      else
        --print("DEBUG:Spell is ready.");
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

SLASH_PVPHCLIENT1 = '/PvPHClient';
local function handler(msg, editbox)
 if msg == 'show' then
  pvpHelper.UI.MainFrame:Show();
 elseif msg == 'hide' then
  pvpHelper.UI.MainFrame:Hide();
 end
end
SlashCmdList["PVPHCLIENT"] = handler; -- Also a valid assignment strategy