

--local filepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelper\\"
local filepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelper\\"
--local libfilepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelperLibrary\\"
local libfilepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelperLibrary\\"
dofile(filepath.."Utils.lua")
dofile(libfilepath.."Localization.lua")
dofile(libfilepath.."CCType.lua")
dofile(libfilepath.."CCTypeList.lua")
--dofile(libfilepath.."Foe.lua")
--dofile(libfilepath.."FoeList.lua")
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
  objPvPHelper:MessageReceived("PvPHelper", "0999:What spells do you have?") 
  
  --Assert
  --Functionality
  -- Send a message to a client - What spells do you have
  -- SendMessage("WhatSpellsDoYouHave", toFriend1)
  -- Event will fire: Message received:
  -- Format will be <prefix>:<header>:body  
  TESTAssert("0999:What spells do you have?",  objPvPHelper.Message.Text, "objPvPHelper.LastMessage")
  TESTAssert("PvPHelper",  objPvPHelper.Message.Prefix, "objPvPHelper.Prefix")
  TESTAssert("0999",  objPvPHelper.Message.Header, "objPvPHelper.Header")
  TESTAssert("What spells do you have?",  objPvPHelper.Message.Body, "objPvPHelper.Body")
  -- objPvPHelper:MessageReceived("MySpells:100,1234,98765")
  -- client responds with - I have xxx spells.
  
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelper", "0888")   
  --Assert
  TESTAssert("0888",  objPvPHelper.Message.Text, "objPvPHelper.LastMessage")
  TESTAssert("PvPHelper",  objPvPHelper.Message.Prefix, "objPvPHelper.Prefix")
  TESTAssert("0888",  objPvPHelper.Message.Header, "objPvPHelper.Header")
  TESTAssert("",  objPvPHelper.Message.Body, "objPvPHelper.Body")
  
  
    -- Arrange
  objPvPHelper = PvPHelper.new()
--Act
  objPvPHelper.Message.From = "MyFriend001"
  objPvPHelper:SendMessage("MySpells", "100,1234,98765")
  --Assert
  TESTAssert("PvPHelper",  objPvPHelper.Message.Prefix, "SendMessage1 objPvPHelper.Prefix")
  TESTAssert("0020",  objPvPHelper.Message.Header, "SendMessage1 objPvPHelper.Header")
  TESTAssert("0020:100,1234,98765",  objPvPHelper.Message.Body, "SendMessage1 objPvPHelper.Body")
  TESTAssert("MyFriend001",  objPvPHelper.Message.To, "SendMessage1 objPvPHelper.To")

  -- Arrange
  objPvPHelper = PvPHelper.new()
  --Act
  objPvPHelper.Message.From = "JoeBloggs"
  objPvPHelper:SendMessage("MySpells", "100,1234,98765")
  --Assert
  TESTAssert("PvPHelper",  objPvPHelper.Message.Prefix, "SendMessage2 objPvPHelper.Prefix")
  TESTAssert("0020",  objPvPHelper.Message.Header, "SendMessage2 objPvPHelper.Header")
  TESTAssert("0020:100,1234,98765",  objPvPHelper.Message.Body, "SendMessage2 objPvPHelper.Body")
  TESTAssert("JoeBloggs",  objPvPHelper.Message.To, "SendMessage2 objPvPHelper.To")

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
  
  -- Act
  objPvPHelper:MessageReceived("PvPHelper", "0010", "WHISPER", "MrRaidLeader")   -- 0010 = WhatSpellsDoYouHave
  -- Assert that when this message is received, it must automatically reply which spells we have.
  --objPvPHelper:SendMessage("MySpells", "100,1234,98765", "MyFriend001")
  --Assert
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "AutoSendSpells - Prefix")
  TESTAssert("0020", objPvPHelper.Message.Header, "AutoSendSpells - Header")
  TESTAssert("0020:1776,2094", objPvPHelper.Message.Body, "AutoSendSpells - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.To, "AutoSendSpells - To")

end

function TEST_MESSAGE_SETCCTARGET()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelper", "0030:GUIDBADPRIEST1234", "WHISPER", "MrRaidLeader")   -- 0030 = Set CC Target
  --Assert that the CCTarget1 button is set to that GUID
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "SetCCTarget - Prefix")
  TESTAssert("0030", objPvPHelper.Message.Header, "SetCCTarget - Header")
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.Message.Body, "SetCCTarget - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.From, "SetCCTarget - From")
  -- Now there must be the CCTarget set
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.CCTarget, "SetCCTarget - CCTarget")
  TESTAssert("Sahk", objPvPHelper.UI.CCTargetButton.Name.Text, "SetCCTarget - CCTargetButton.Name.Text")
  TESTAssert(255, objPvPHelper.UI.CCTargetButton.colR, "SetCCTarget - CCTargetButton.colR")
  TESTAssert(245, objPvPHelper.UI.CCTargetButton.colG, "SetCCTarget - CCTargetButton.colG")
  TESTAssert(105, objPvPHelper.UI.CCTargetButton.colB, "SetCCTarget - CCTargetButton.colB")

end

function TEST_MESSAGE_SETMAINASSIST()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelper", "0040:BUDDYGUID1234", "RAID")   -- 0030 = Set CC Target
  --Assert that the CCTarget1 button is set to that GUID
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "SetCCTarget - Prefix")
  TESTAssert("0040", objPvPHelper.Message.Header, "SetCCTarget - Header")
  TESTAssert("BUDDYGUID1234", objPvPHelper.Message.Body, "SetCCTarget - Body")
  TESTAssert(nil, objPvPHelper.Message.From, "SetCCTarget - From")
  -- Now there must be the CCTarget set
  TESTAssert("BUDDYGUID1234", objPvPHelper.MainAssist, "SetCCTarget - MainAssit")
  
end

function TEST_MESSAGE_DOACTIONNOW()
  -- Arrange
  objPvPHelper = PvPHelper.new()
  -- Act
  objPvPHelper:MessageReceived("PvPHelper", "0060:1776", "WHISPER", "MrRaidLeader")   -- 0060 = DoActionNow
  --Assert that the correct spell has been passed to the body 
  TESTAssert("1776", objPvPHelper.Message.Body, "SetCCTarget - Body")
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
  objPvPHelper:MessageReceived("PvPHelper", "0050:1776", "WHISPER", "MrRaidLeader")   -- 0050 = GetReadyToAct
  --Assert that the correct spell has been passed to the body 
  TESTAssert("1776", objPvPHelper.Message.Body, "SetCCTarget - Body") -- 1776 = GOUGE
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
  PvPHelper_OnEvent(objPvPHelper.UI.MainFrame, "CHAT_MSG_ADDON", "PvPHelper", "0030:GUIDBADPRIEST1234", "WHISPER", "MrRaidLeader")   -- 0030 = Set CC Target
  --Assert that the CCTarget1 button is set to that GUID
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "SetCCTarget - Prefix")
  TESTAssert("0030", objPvPHelper.Message.Header, "SetCCTarget - Header")
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.Message.Body, "SetCCTarget - Body")
  TESTAssert("MrRaidLeader", objPvPHelper.Message.From, "SetCCTarget - From")
  -- Now there must be the CCTarget set
  TESTAssert("GUIDBADPRIEST1234", objPvPHelper.CCTarget, "SetCCTarget - CCTarget")
  
end


function TEST_MESSAGE_CCSPELLHASBEENUSED()
  -- Arrange - Tell the PVPHelper to DoActionNow
  objPvPHelper = PvPHelper.new()
  objPvPHelper:MessageReceived("PvPHelper", "0060:1776", "WHISPER", "MrRaidLeader")   -- 0060 = DoActionNow

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
  
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "Sent SpellIsOnCooldown - Prefix")
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
  
  TESTAssert("PvPHelper", objPvPHelper.Message.Prefix, "Sent ThisSpellIsOffCooldown - Prefix")
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
TEST_MESSAGES_RECEIVED()
TEST_CCTYPES()
TEST_MESSAGE_WHATSPELLSDOYOUHAVE()
TEST_MESSAGE_SETCCTARGET()
TEST_MESSAGE_SETMAINASSIST()
TEST_MESSAGE_DOACTIONNOW()
TEST_MESSAGE_GETREADYFORACTION()
TEST_EVENT_CHATMESSAGE()
TEST_MESSAGE_CCSPELLHASBEENUSED()
print("\n--END TESTS--")



