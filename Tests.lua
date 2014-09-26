

--local filepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelper\\"
local filepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelper\\"
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

dofile(filepath.."PvPHelper.lua")

function TEST_MESSAGES_RECEIVED()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  
  -- Act
  objPvPHelper:MessageReceived("PvPHelperClient", "WhatSpellsDoYouHave") 
  
  --Assert
  --Functionality
  -- Send a message to a client - What spells do you have
  -- SendMessage("WhatSpellsDoYouHave", toFriend1)
  -- Event will fire: Message received:
  -- Format will be <prefix>:<header>:body  
  TESTAssert("WhatSpellsDoYouHave",  objPvPHelper.Message.Text, "objPvPHelper.LastMessage")
  TESTAssert("WhatSpellsDoYouHave",  objPvPHelper.Message.Header, "objPvPHelper.Header")
  -- objPvPHelper:MessageReceived("MySpells:100,1234,98765")
  -- client responds with - I have xxx spells.
 end


function TEST_CCTYPES()
  -- Arrange/Act
  objPvPHelper = PvPHelper.new()
  
  -- Assert
  TESTAssert(1776,  objPvPHelper.CCTypes[1].SpellId, "objPvPHelper.CCTypes[1].SpellId")
  TESTAssert(2094,  objPvPHelper.CCTypes[2].SpellId, "objPvPHelper.CCTypes[2].SpellId")
 
end

function TEST_MESSAGE_WHATSPELLSDOYOUHAVE()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  
  -- Set flags to log messages
  DEBUG.LogMessages = true;
  GVAR.MessageLog = {};

  -- Act
  objPvPHelper:MessageReceived("PvPHelperClient", "WhatSpellsDoYouHave", "WHISPER", "MrRaidLeader")   -- WhatSpellsDoYouHave = WhatSpellsDoYouHave
  -- Assert that when this message is received, it must automatically reply which spells we have.
  --objPvPHelper:SendMessage("MySpells", "100,1234,98765", "MyFriend001")
  --Assert
  TESTAssert("MySpells", GVAR.MessageLog[1].Header, "AutoSendSpells - Header")
  TESTAssert("1776,2094", GVAR.MessageLog[1].Payload2, "AutoSendSpells - Body")
  TESTAssert("MrRaidLeader", GVAR.MessageLog[1].To, "AutoSendSpells - To")

  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send reply to server only");

end

function TEST_MESSAGE_DOACTIONNOW()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelperClient", "ActNow.1776", "WHISPER", "MrRaidLeader")   -- ActNow = DoActionNow
  --Assert that the correct spell has been passed to the body 
  TESTAssert("1776", objPvPHelper.Message.Payload2, "SetCCTarget - Body")
  -- Tell the UI to do the action now
  -- The UI must show a message
  -- the UI should display a CCaction button
  
  -- It should have cleared the Spell Notification object
  -- Should have a spell id set that this is the current spell that we are requested to do.
  TESTAssert(1776, objPvPHelper.CCSpellId, "objPvPHelper.CCSpellId")
  TESTAssert(false, objPvPHelper.CCSpellNotified, "objPvPHelper.CCSpellNotified")

end

function TEST_MESSAGE_GETREADYFORACTION()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelperClient", "PrepareToAct:1776", "WHISPER", "MrRaidLeader")   -- PrepareToAct = GetReadyToAct
  --Assert that the correct spell has been passed to the body 
  TESTAssert("1776", objPvPHelper.Message.Payload2, "SetCCTarget - Body") -- 1776 = GOUGE
  -- Tell the UI to do the action now
  -- The UI must show a message
  -- the UI should display a CCaction button
  
  -- It should have cleared the Spell Notification object
  -- Should have a spell id set that this is the current spell that we are requested to do.
  TESTAssert(1776, objPvPHelper.NextCCSpellId, "objPvPHelper.NextCCSpellId")
  TESTAssert(false, objPvPHelper.NextCCSpellNotified, "objPvPHelper.NextCCSpellNotified")

end


function TEST_EVENT_CHATMESSAGE()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  PvPHelper_OnEvent(objPvPHelper.UI.MainFrame, "CHAT_MSG_ADDON", "PvPHelperClient", "0030:GUIDBADPRIEST1234", "WHISPER", "MrRaidLeader")   -- 0030 = Set CC Target
  --Assert that the CCTarget1 button is set to that GUID
  TESTAssert("PvPHelperClient", objPvPHelper.Message.Prefix, "SetCCTarget - Prefix")
  TESTAssert("0030", objPvPHelper.Message.Header, "SetCCTarget - Header")
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.Message.Payload2, "SetCCTarget - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.From, "SetCCTarget - From")
  -- Now there must be the CCTarget set
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.CCTarget, "SetCCTarget - CCTarget")
  
end


function TEST_MESSAGE_CCSPELLHASBEENUSED()
  -- Arrange - Tell the PVPHelper to DoActionNow
  objPvPHelper = PvPHelper.new()
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
  TESTAssert("0080:1776", objPvPHelper.Message.Payload2, "Sent SpellIsOnCooldown - Body")
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
  TESTAssert("0090:1776", objPvPHelper.Message.Payload2, "Sent ThisSpellIsOffCooldown - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.To, "Sent ThisSpellIsOffCooldown - To")
  
  TESTAssert("nil", tostring(objPvPHelper.SpellsOnCooldown[1776]), "ThisSpellIsOffCooldown CCSpellId")


end

-- When we cast a spell, it will show up in the Combat_log_events
--function TEST_EVENT_HAVEJUSTCASTSPELL()
--end




-- TESTS TO PERFORM
print("--START TESTS--\n")
TEST_MESSAGES_RECEIVED()
TEST_CCTYPES()
TEST_MESSAGE_WHATSPELLSDOYOUHAVE()
TEST_MESSAGE_DOACTIONNOW()
TEST_MESSAGE_GETREADYFORACTION()
TEST_EVENT_CHATMESSAGE()
TEST_MESSAGE_CCSPELLHASBEENUSED()
print("\n--END TESTS--")



