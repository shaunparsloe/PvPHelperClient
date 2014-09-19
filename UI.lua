PvPHelper_UI = {}
PvPHelper_UI.__index = PvPHelper_UI; -- failed table lookups on the instances should fallback to the class table, to get methods

function PvPHelper_UI.new (parentObject)
  local self = setmetatable({}, PvPHelper_UI)
  
  self:CreateMainFrame();
  
  self.CCActionButtons = {};
  
  self.parent = parentObject;
  self.MainFrame.parent = parentObject; -- Cyclical call back to self.  This is used so the eventhandler can pick up the object

  -- Create Assist Button
  local button = self:CreateStandardButton(self.MainFrame, 210, -100, "ASSIST")
	button 	:SetScript("OnClick", function(self, button, down)
		print("PvPHelper: Been asked which spells I have, reply with a list of my spells");
--		PVPHelper_MainFrame.parent:SendMessage("MySpells", PVPHelper_MainFrame.parent.CCTypes:ListSpellIds())
--		PVPHelper_MainFrame.parent:SendMessage("SpellCoolDown", "8122")	 - this works
--		PVPHelper_MainFrame.parent:SendMessage("SpellCoolDown", "15487")  - this crashes the system
--		PVPHelper_MainFrame.parent:SendMessage("SpellCoolDown", "SPELL-15487")

		
		--		pvpHelper:SendMessage23456("ThisSpellIsOnCooldown123456", tostring(ccType.SpellId))

	  		--self:SendMessage("DummyTestMessage", nil, k.Name)

	end)
  self.AssistButton = button;
  --Disable AssistButton
--  self:DisableButton(self.AssistButton);
--  
--  -- CC Target Button
--  button = nil;
--  button = self:CreatePlayerButton(self.MainFrame, "CCTARGET", 110, -10)
--  button:SetAttribute("type1", "macro") -- left click causes macro
--  button:SetAttribute("macrotext1", "/say Bye!"); -- text for macro on left click
--  self.CCTargetButton = button;
--  -- Disable
--  self:DisableButton(self.CCTargetButton);
  
--  
--  for i, cctype in ipairs(parentObject.CCTypes) do
--    --if i==1 then
--    local button = self:CreateStandardButton(self.MainFrame, 220, (60*-i)+60, "CC NOW "..cctype.CCName)
--    
--    button:SetAttribute("unit", "target");
--    button:SetAttribute("type", "spell");
--    button:SetAttribute("spell", cctype.SpellId);
--    button.SpellId = cctype.SpellId;
--    button.SpellName = cctype.SpellName;
--    table.insert(self.CCActionButtons, button)
--    -- Disable
--    self:DisableButton(button);
--    --end
--  end
  return self;
  
end


function PvPHelper_UI:CreateMainFrame()
	local frame = CreateFrame("Frame", "PVPHelper_MainFrame", UIParent);
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetResizable(true)
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)

	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	frame:SetBackdrop( { 
	  bgFile = "Interface/DialogFrame/UI-DialogBox-Background"
	  , edgeFile = "Interface/DialogFrame/UI-DialogBox-Border"
	  , tile = true
	  , tileSize = 32
	  , edgeSize = 16, 
	  insets = { left = 5, right = 5, top = 5, bottom = 5 }
	});

	frame:SetPoint("CENTER",100,100); 
	frame:SetWidth(300); 
	frame:SetHeight(100);

	fontstring = frame:CreateFontString("PVPHelperText", "ARTWORK","GameFontNormal")
	fontstring:SetPoint("TOPLEFT", -5, -15);
	fontstring:SetSize(350, 12);
  frame:SetUserPlaced(true);

-- TODO: Run this and see where it appears!
  fontstring:SetText("fontstring set in UI.lua");
  
  frame.StatusText = fontstring;
  
  frame.MessageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.MessageText:SetPoint("TOPLEFT",0,"TOPLEFT",0,-50)
  frame.MessageText:SetShadowOffset(0, 0)
  frame.MessageText:SetShadowColor(0, 0, 0, 0)
  frame.MessageText:SetTextColor(1, 1, 1, 1)
  frame.MessageText:SetWidth(300)
  frame.MessageText:SetText("MESSAGETEXT");

	self.MainFrame = frame;
end

function PvPHelper_UI:DisableButton(button)  
  if (button) then
    --button:Disable();
    button:SetAlpha(0.3);
    --button:Hide();
  end
end

function PvPHelper_UI:EnableButton(button)  
  if (button) then
    --button:Enable();
    button:SetAlpha(1.0);
    --button:Show();
  end
end

function PvPHelper_UI:CreateStandardButton(frame, ofsx, ofsy, buttonText, buttonWidth, buttonHeight)

  local button = CreateFrame("Button", "AssistButton", frame, "SecureActionButtonTemplate")
  
  button:SetPoint("TOPLEFT", ofsx or 0, ofsy or 0)
  button:SetWidth(buttonWidth or 100)
  button:SetHeight(buttonHeight or 60)
  
   -- Button Text
	if (buttonText) then
    button:SetText(buttonText)
  end
  
  -- NORMAL BUTTON
  button:SetNormalFontObject("GameFontNormal")
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
--button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
	button:SetNormalTexture(ntex)
	
  --HIGHLIGHT BUTTON
  button:SetHighlightFontObject("GameFontHighlight")
  local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
--button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	button:SetHighlightTexture(htex)
	
  --PUSHED BUTTON
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
--button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	button:SetPushedTexture(ptex)
  
  return button;
end

function PvPHelper_UI:CreatePlayerButton(frame, strButtonName, ofsx, ofsy, buttonWidth, buttonHeight)
    
    buttonWidth = buttonWidth or 100
    buttonHeight = buttonHeight or 60
    
		local button = CreateFrame("Button", strButtonName, frame, "SecureActionButtonTemplate")
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("TOPLEFT", ofsx or 0, ofsy or 0)
    button:SetWidth(buttonWidth)
    button:SetHeight(buttonHeight)
     	
		button.Name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.Name:SetPoint("TOPLEFT", button)
		button.Name:SetShadowOffset(0, 0)
		button.Name:SetShadowColor(0, 0, 0, 0)
		button.Name:SetTextColor(1, 1, 1, 1)

    button.ClassColorBackground = button:CreateTexture(nil, "BORDER")
    button.ClassColorBackground:SetTexture(.5, .5, .5, .5)
    button.ClassColorBackground:SetWidth(buttonWidth)
    button.ClassColorBackground:SetHeight(buttonHeight)
    button.ClassColorBackground:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button.HealthBar = button:CreateTexture(nil, "ARTWORK")
    button.HealthBar:SetTexture(.6, .6, .6, .5)
    button.HealthBar:SetWidth(buttonWidth)
    button.HealthBar:SetHeight(buttonHeight/2)
		button.HealthBar:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -buttonHeight/2)
    
    button.HealthText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.HealthText:SetPoint("TOPLEFT",button,"TOPLEFT",0,-buttonHeight/2)
		button.HealthText:SetShadowOffset(0, 0)
		button.HealthText:SetShadowColor(0, 0, 0, 0)
		button.HealthText:SetTextColor(1, 1, 1, 1)
    button.HealthText:SetWidth(buttonWidth)

		return button;
end


function PvPHelper_UI:PrepareToAct(spellId, secondsTime)
  -- Must display the text.
  	local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
	if objSpell then
--   		print("TODO: Analysis on how to best display the PvPHelper:UI:PrepareToAct action") 
		--print("SHOUT: GET READY TO "..spellId)
		self.MainFrame.StatusText:SetText("Prepare to "..objSpell.CCName.." in "..secondsTime.." seconds");
	else
		print("PvPHelper_UI:PrepareToAct: CANNOT FIND SPELL:"..spellId);
		
	end
end

function PvPHelper_UI:DoCCActionNow(spellId)
 -- Must display the text.
  	local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
	if objSpell then
--   		print("TODO: Analysis on how to best display the PvPHelper:UI:PrepareToAct action") 
		--print("SHOUT: GET READY TO "..spellId)
		self.MainFrame.StatusText:SetText("Do "..objSpell.CCName.." NOW!");
	else
		print("PvPHelper_UI:DoCCActionNow: CANNOT FIND SPELL:"..spellId);
	end

end

function PvPHelper_UI:DoLateCCAction(spellId)
 -- Must display the text.
  	local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
	if objSpell then
--   		print("TODO: Analysis on how to best display the PvPHelper:UI:PrepareToAct action") 
		--print("SHOUT: GET READY TO "..spellId)
		self.MainFrame.StatusText:SetText("LATE! Do "..objSpell.CCName.." NOW!");
	else
		print("PvPHelper_UI:DoCCActionNow: CANNOT FIND SPELL:"..spellId);
	end

end

function PvPHelper_UI:DoVeryLateCCAction(spellId)
 -- Must display the text.
  	local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
	if objSpell then
--   		print("TODO: Analysis on how to best display the PvPHelper:UI:PrepareToAct action") 
		--print("SHOUT: GET READY TO "..spellId)
		self.MainFrame.StatusText:SetText("VERY LATE! Do "..objSpell.CCName.." NOW!");
	else
		print("PvPHelper_UI:DoCCActionNow: CANNOT FIND SPELL:"..spellId);
	end

end

function PvPHelper_UI:SetCCButton(guid)
  --print("Setting CC Target Button")
  if (self.CCTargetButton) then
    button = self.CCTargetButton;
    
    -- Calculate name, guid and class information
    local class, classFileName, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
    --print("SETCCBUTTON START")
    --print("GUID = "..tostring(guid));
    --print("class = "..tostring(class))
    --print("classFileName = "..tostring(classFileName))
    --print("race = "..tostring(race))
    --print("raceFilename = "..tostring(raceFilename))
    --print("sex = "..tostring(sex))
    --print("name = "..tostring(name))
    --print("realm = "..tostring(realm))
    --print("SETCCBUTTON END")
    
    
    button.Name:SetText(name)

    --local fullname = UnitName(playername); 
    --print("Fullname = "..tostring(fullname))
    --local guid = UnitGUID(playername); 
    --print("GUID = "..tostring(guid))
    --local qclass, classFileName = UnitClass("target")
    --print("Class = "..tostring(class))
    --print("ClassFileName = "..tostring(classFileName))
    
    --  TODO: REmove once testing is over
    -- this is only for testing 
    if not class then
      print("Unable to determine class - is this a player target?")
      --class = "Warrior"
      --classFileName = "WARRIOR"
      name = UnitName("target")
      class, classFileName = UnitClass("target")
    end

    -- Set up colours and bars
    local qcolor = RAID_CLASS_COLORS[classFileName]
    button.colR  = qcolor.r
    button.colG  = qcolor.g
    button.colB  = qcolor.b
    button.ClassColorBackground:SetTexture(button.colR*.5, button.colG*.5, button.colB*.5, 1)
    button.HealthBar:SetTexture(button.colR, button.colG, button.colB, 1)
    
    -- Health bar
    local maxHealth = UnitHealthMax("target")
    if maxHealth then
      local health = UnitHealth("target")
      SetButtonHealth(button, maxHealth, health);
    end
    
    -- Set the macro so that on button click, it targets the player
    if not inCombat or not InCombatLockdown() then
      button:SetAttribute("macrotext1", "/target "..tostring(name))
      --print("PVPHELPER: Set the CC Button Macro to /target "..name)
    end


   -- for i, CCActionButton in ipairs(self.CCActionButtons) do
   --   print ("SEtting target to "..name)
   --   CCActionButton:SetAttribute("unit", name);
   -- end
    
    
    -- Enable button
    PvPHelper_UI:EnableButton(button);
    
    
    
  end
end

function PvPHelper_UI:SetMainAssist(guid)
  local calledfrom = debug.getinfo(1).name;
  print(tostring(calledfrom).." NOT IMPLEMENTED")
end

function PvPHelper_UI_SetupCCButtonWithClass(setbutton)
  button = setbutton.SetButton;
  local name = UnitName("target"); 
  local guid = UnitGUID("target"); 
  --print(name.." has the GUID: "..guid);
  local targetID = UnitGUID("target"); 
  local qname       = UnitName("target")
  --print("Unitname = "..tostring(qname))
  local qclass, qclassFileName = UnitClass("target")
  --print("qclass = "..tostring(qclass)..", qclassFileName= "..tostring(qclassFileName))
  local qcolor = RAID_CLASS_COLORS[qclassFileName]

  local foe = Foe.new ({GUID=guid, Name=name, Class=strupper(qclass)})
  button.Foe = foe;
  local foundfoe = GVAR.PvPServer.FoeList:LookupGUID(guid)

  if not foundfoe then
    --print("ADDED FOE "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") TO FOE LIST")
    GVAR.PvPServer.FoeList:Add(deepcopy(foe));
  else
    --print("FOUND FOE "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") IN FOE LIST")
  end

  print(qclass, qcolor.r, qcolor.g, qcolor.b)
  

  local qSpec = GetSpecialization("target")
  print("qSpec = "..tostring(qSpec))

  local qSpecName = qSpec and select(2, GetSpecializationInfo(qSpec)) or "None"
  print("qSpecName = "..tostring(qSpecName))
  local qInspectSpec =  GetInspectSpecialization("target") 
  print("qInspectSpec = "..tostring(qInspectSpec))

  local colR = qcolor.r
  local colG = qcolor.g
  local colB = qcolor.b
  button.colR  = colR
  button.colG  = colG
  button.colB  = colB
  button.colR5 = colR*0.5
  button.colG5 = colG*0.5
  button.colB5 = colB*0.5
  button.ClassColorBackground:SetTexture(button.colR5, button.colG5, button.colB5, 1)
  button.HealthBar:SetTexture(colR, colG, colB, 1)

  --print("healthbar texture set")

  button.Name:SetText(qname)
  
  if not inCombat or not InCombatLockdown() then
    button:SetAttribute("macrotext1", "/target "..qname)
    --print("Set the Macro to /target "..qname)
  end

  local maxHealth = UnitHealthMax("target")
  if maxHealth then
    local health = UnitHealth("target")
    SetButtonHealth(button, maxHealth, health);
  end

  setbutton:Hide();
  PvPHelper_UI:EnableButton(button);
  return button;
end


function SetButtonHealth(button, maxHealth, health)
  if maxHealth then
    local healthBarWidth = button.ClassColorBackground:GetWidth();
    if health then
      local width = 0.01
      local percent = 0
      if maxHealth > 0 and health > 0 then
        local hvalue = maxHealth / health
        width = healthBarWidth / hvalue
        width = math.max(0.01, width)
        width = math.min(healthBarWidth, width)
        percent = math.floor( (100/hvalue) + 0.5 )
        percent = math.max(0, percent)
        percent = math.min(100, percent)
      end
      --ENEMY_Name2Percent[targetName] = percent
--      print("health percent = ".. percent .."%")
      button.HealthBar:SetWidth(width)
      button.HealthText:SetText(percent)
    end
  end
  return button;
end

