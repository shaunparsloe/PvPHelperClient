--local filepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelper\\"
local filepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelperClient\\"
--local libfilepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelperLibrary\\"
local libfilepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelperLibrary\\"
dofile(libfilepath.."Utils.lua")
dofile(libfilepath.."Localization.lua")
dofile(libfilepath.."CCType.lua")
dofile(libfilepath.."CCTypeList.lua")
dofile(filepath.."Timer.lua")
dofile(filepath.."TimerList.lua")
--dofile(libfilepath.."FoeDR.lua")
--dofile(libfilepath.."FoeDRList.lua")
dofile(libfilepath.."Message.lua")
dofile(filepath.."UI.lua")
dofile(libfilepath.."Test_MockWoWFunctions.lua")

dofile(filepath.."PvPHelperClient.lua")



DEBUG.SetClockSeconds = 1000;

-- Use these flags to log messages for debugging
DEBUG.LogMessages = true;
GVAR.MessageLog = {};


function TEST_MESSAGE_WHATSPELLSDOYOUHAVE()

  -- Arrange
  objPvPHelperClient = PvPHelperClient.new()
  
  -- Act
  objPvPHelperClient:MessageReceived("PvPHelperClient", "WhatSpellsDoYouHave", "WHISPER", "MrRaidLeader") 
  
  -- Server sends to client, "What spells do you have", 
  -- Client responds with, "I have xxx spells"
   TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages to server");

  TESTAssert("MrRaidLeader", GVAR.MessageLog[1].To, "Send to MrRaidLeader");
  TESTAssert("MySpells", GVAR.MessageLog[1].Header, "Send my spells");
  TESTAssert("1776,2094", GVAR.MessageLog[1].Body, "List of my spells");

 end
function TEST_MESSAGE_ACTNOW()
  -- Arrange - Tell the PVPHelper to DoActionNow
  objPvPHelperClient = PvPHelperClient.new()
  objPvPHelperClient:MessageReceived("PvPHelperClient", "ActNow.1776", "WHISPER", "MrRaidLeader")   -- ActNow = DoActionNow

  -- This should have set up the CCSpellID to 1776 and the CCSpellNotified status to false.
  TESTAssert(1776, objPvPHelperClient.CCSpellId, "SET objPvPHelperClient.CCSpellId")
  TESTAssert(false, objPvPHelperClient.CCSpellNotified, "SET objPvPHelperClient.CCSpellNotified")
  
  -- Set up the spells that can be cast.  
  DEBUG.spells = {}
  DEBUG.spells[1776] = {}
  DEBUG.spells[1776].retval = false -- Cant cast this
  DEBUG.spells[1776].nomana = false  -- Because no mana
 
  -- Act
  local elapsed = 10;
  PVPHelper_OnUpdate(objPvPHelperClient.UI.MainFrame, elapsed)
  
  -- Assert
  -- So what should happen here is that we should see that this spell is now on cooldown and a message must
  -- be sent to the Server to say that this spell is now on Cooldown.
  
  TESTAssert("PvPHelperClient", objPvPHelperClient.Message.Prefix, "Sent SpellIsOnCooldown - Prefix")
  TESTAssert("0080", objPvPHelperClient.Message.Header, "Sent SpellIsOnCooldown - Header")
  TESTAssert("0080:1776", objPvPHelperClient.Message.Body, "Sent SpellIsOnCooldown - Body")
  TESTAssert("MrRaidLeader", objPvPHelperClient.Message.To, "Sent SpellIsOnCooldown - To")
  
  TESTAssert("OnCooldown", objPvPHelperClient.SpellsOnCooldown[1776], "pvpHelper.SpellsOnCooldown[CCSpellId]")

  
  -- Now set it up so that the spell is available again
  -- Set up the spells that can be cast.  
  DEBUG.spells[1776].retval = true -- Can cast it again
  DEBUG.spells[1776].nomana = nil  -- n/a
 
  -- Act
  PVPHelper_OnUpdate(objPvPHelperClient.UI.MainFrame, elapsed)
  
  -- Assert
  -- So what should happen here is that we should see that this spell is now on cooldown and a message must
  -- be sent to the Server to say that this spell is now on Cooldown.
  
  TESTAssert("PvPHelperClient", objPvPHelperClient.Message.Prefix, "Sent ThisSpellIsOffCooldown - Prefix")
  TESTAssert("0090", objPvPHelperClient.Message.Header, "Sent ThisSpellIsOffCooldown - Header")
  TESTAssert("0090:1776", objPvPHelperClient.Message.Body, "Sent ThisSpellIsOffCooldown - Body")
  TESTAssert("MrRaidLeader", objPvPHelperClient.Message.To, "Sent ThisSpellIsOffCooldown - To")
  
  TESTAssert("nil", tostring(objPvPHelperClient.SpellsOnCooldown[1776]), "ThisSpellIsOffCooldown CCSpellId")


end

-- When we cast a spell, it will show up in the Combat_log_events
--function TEST_EVENT_HAVEJUSTCASTSPELL()
--end


function TEST_MESSAGE_PREPARETOACT()
  GVAR.MessageLog = {};
  DEBUG.SetClockSeconds = 100;

  -- Arrange
  objPvPHelperClient = PvPHelperClient.new()
  objPvPHelperClient:RegisterMainFrameEvents(objPvPHelperClient.UI.MainFrame)

  -- Act
  -- Get a note to prepare to act in 25 sec.
  objPvPHelperClient:MessageReceived("PvPHelperClient", "PrepareToAct.1776,10", "WHISPER", "MrRaidLeader") 
  elapsed = 1;
  PVPHelper_OnUpdate(objPvPHelperClient.UI.MainFrame, elapsed) 
  
  
  -- Rubbish.  TODO: Fix this bit:
   TESTAssert(0, table.getn(GVAR.MessageLog), "Should send new messages to server");
  TESTAssert(true, objPvPHelperClient.Timer:IsActive(),"Should have an Active timer")
  
  TESTAssert(10, objPvPHelperClient.Timer:TimeRemaining(),"With 10 second duration")

  DEBUG.SetClockSeconds = 105;
  TESTAssert(5, objPvPHelperClient.Timer:TimeRemaining(),"With 5 sec remaining")

  elapsed = 1;
  PVPHelper_OnUpdate(objPvPHelperClient.UI.MainFrame, elapsed) 

   TESTAssert(0, table.getn(GVAR.MessageLog), "Should send new messages to server");
  TESTAssert(5, objPvPHelperClient.Timer:TimeRemaining(),"With 5 sec remaining")

end




-- TESTS TO PERFORM
print("--START TESTS--\n")

TEST_MESSAGE_WHATSPELLSDOYOUHAVE()

TEST_MESSAGE_PREPARETOACT()
--TEST_MESSAGE_ACTNOW()
print("\n--END TESTS--")



