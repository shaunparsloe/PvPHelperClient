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
  objPvPHelper = PvPHelperClient.new()
  
  -- Act
  objPvPHelper:MessageReceived("PvPHelperClient", "WhatSpellsDoYouHave", "WHISPER", "MrRaidLeader") 
  
  -- Server sends to client, "What spells do you have", 
  -- Client responds with, "I have xxx spells"
   TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages to server");

  TESTAssert("MrRaidLeader", GVAR.MessageLog[1].To, "Send to MrRaidLeader");
  TESTAssert("MySpells", GVAR.MessageLog[1].Header, "Send my spells");
  TESTAssert("1776,2094", GVAR.MessageLog[1].Body, "List of my spells");

 end

function TEST_MESSAGE_PREPARETOACT()
  
  -- Arrange
  objPvPHelper = PvPHelperClient.new()
  
  -- Act
  -- Get a note to prepare to act in 25 sec.
  objPvPHelper:MessageReceived("PvPHelperClient", "PrepareToAct.1776,25", "WHISPER", "MrRaidLeader") 
  
  -- Rubbish.  TODO: Fix this bit:
   TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages to server");


end

function TEST_MESSAGE_ACTNOW()
  -- Arrange - Tell the PVPHelper to DoActionNow
  objPvPHelper = PvPHelperClient.new()
  objPvPHelper:MessageReceived("PvPHelperClient", "ActNow.1776", "WHISPER", "MrRaidLeader")   -- ActNow = DoActionNow

  -- This should have set up the CCSpellID to 1776 and the CCSpellNotified status to false.
  TESTAssert(1776, objPvPHelper.CCSpellId, "SET objPvPHelper.CCSpellId")
  TESTAssert(false, objPvPHelper.CCSpellNotified, "SET objPvPHelper.CCSpellNotified")
  
  -- Set up the spells that can be cast.  
  DEBUG.spells = {}
  DEBUG.spells[1776] = {}
  DEBUG.spells[1776].retval = false -- Cant cast this
  DEBUG.spells[1776].nomana = false  -- Because no mana
 
  -- Act
  local elapsed = 10;
  PVPHelper_OnUpdate(objPvPHelper.UI.MainFrame, elapsed)
  
  -- Assert
  -- So what should happen here is that we should see that this spell is now on cooldown and a message must
  -- be sent to the Server to say that this spell is now on Cooldown.
  
  TESTAssert("PvPHelperClient", objPvPHelper.Message.Prefix, "Sent SpellIsOnCooldown - Prefix")
  TESTAssert("0080", objPvPHelper.Message.Header, "Sent SpellIsOnCooldown - Header")
  TESTAssert("0080:1776", objPvPHelper.Message.Body, "Sent SpellIsOnCooldown - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.To, "Sent SpellIsOnCooldown - To")
  
  TESTAssert("OnCooldown", objPvPHelper.SpellsOnCooldown[1776], "pvpHelper.SpellsOnCooldown[CCSpellId]")

  
  -- Now set it up so that the spell is available again
  -- Set up the spells that can be cast.  
  DEBUG.spells[1776].retval = true -- Can cast it again
  DEBUG.spells[1776].nomana = nil  -- n/a
 
  -- Act
  PVPHelper_OnUpdate(objPvPHelper.UI.MainFrame, elapsed)
  
  -- Assert
  -- So what should happen here is that we should see that this spell is now on cooldown and a message must
  -- be sent to the Server to say that this spell is now on Cooldown.
  
  TESTAssert("PvPHelperClient", objPvPHelper.Message.Prefix, "Sent ThisSpellIsOffCooldown - Prefix")
  TESTAssert("0090", objPvPHelper.Message.Header, "Sent ThisSpellIsOffCooldown - Header")
  TESTAssert("0090:1776", objPvPHelper.Message.Body, "Sent ThisSpellIsOffCooldown - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.To, "Sent ThisSpellIsOffCooldown - To")
  
  TESTAssert("nil", tostring(objPvPHelper.SpellsOnCooldown[1776]), "ThisSpellIsOffCooldown CCSpellId")


end

-- When we cast a spell, it will show up in the Combat_log_events
--function TEST_EVENT_HAVEJUSTCASTSPELL()
--end




-- TESTS TO PERFORM
print("--START TESTS--\n")

TEST_MESSAGE_WHATSPELLSDOYOUHAVE()

TEST_MESSAGE_PREPARETOACT()
--TEST_MESSAGE_ACTNOW()
print("\n--END TESTS--")



