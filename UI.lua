PvPHelper_UI = {}
PvPHelper_UI.__index = PvPHelper_UI; -- failed table lookups on the instances should fallback to the class table, to get methods

function PvPHelper_UI.new (parentObject)
  local self = setmetatable({}, PvPHelper_UI)
  
  self:CreateMainFrame();
  
  self.CCActionButtons = {};
  
  self.parent = parentObject;
  self.MainFrame.parent = parentObject; -- Cyclical call back to self.  This is used so the eventhandler can pick up the object
 
  return self;
  
end


function PvPHelper_UI:CreateMainFrame()
  local frame = CreateFrame("Frame", "PVPHelperClient_MainFrame", UIParent);
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

  frame:SetUserPlaced(true);

-- TODO: Run this and see where it appears!
  local fontstring = frame:CreateFontString("PVPHelperText", "ARTWORK","GameFontNormal")
  fontstring:SetPoint("TOPLEFT", -5, -15);
  fontstring:SetSize(350, 12);
  fontstring:SetText("fontstring set in UI.lua");
    
  frame.StatusText = fontstring;

  local fontstring2 = frame:CreateFontString("PVPHelperText", "ARTWORK","GameFontNormal")
  fontstring2:SetPoint("TOPLEFT", -5, -15);
  fontstring2:SetSize(350, 52);
  fontstring2:SetText("0");
    
  frame.TimerText = fontstring2;
  
  
  frame.MessageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.MessageText:SetPoint("TOPLEFT",0,"TOPLEFT",0,-50)
  frame.MessageText:SetShadowOffset(0, 0)
  frame.MessageText:SetShadowColor(0, 0, 0, 0)
  frame.MessageText:SetTextColor(1, 1, 1, 1)
  frame.MessageText:SetWidth(300)
  frame.MessageText:SetText("MESSAGETEXT");

  self.MainFrame = frame;
  
  frame:Hide();
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
    self.MainFrame.StatusText:SetText("Prepare to "..objSpell.CCName.." in "..secondsTime.." seconds");
  else
    print("PvPHelper_UI:PrepareToAct: CANNOT FIND SPELL:"..spellId);
    
  end
end

function PvPHelper_UI:DoCCActionNow(spellId)
 -- Must display the text.
    local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
  if objSpell then
    self.MainFrame.StatusText:SetText("Do "..objSpell.CCName.." NOW!");
  else
    print("PvPHelper_UI:DoCCActionNow: CANNOT FIND SPELL:"..spellId);
  end

end

function PvPHelper_UI:DoLateCCAction(spellId)
 -- Must display the text.
    local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
  if objSpell then
    self.MainFrame.StatusText:SetText("LATE! Do "..objSpell.CCName.." NOW!");
  else
    print("PvPHelper_UI:DoLateCCActionNow: CANNOT FIND SPELL:"..spellId);
  end

end

function PvPHelper_UI:DoVeryLateCCAction(spellId)
 -- Must display the text.
    local objSpell = self.parent.AllCCTypes:LookupSpellId(spellId)
  if objSpell then
    self.MainFrame.StatusText:SetText("VERY LATE! Do "..objSpell.CCName.." NOW!");
  else
    print("PvPHelper_UI:DoVeryLateCCActionNow: CANNOT FIND SPELL:"..spellId);
  end

end

function PvPHelper_UI:SetTimerText(param)
  --print("Tick:"..tostring(param));
  self.MainFrame.TimerText:SetText(param);
end
