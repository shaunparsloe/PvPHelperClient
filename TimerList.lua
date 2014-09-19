-- ****************************************************
-- TimerList
-- ****************************************************
TimerList={};
TimerList.__index = TimerList -- failed table lookups on the instances should fallback to the class table, to get methods

local L = PVPHelperLib_LocalizationTable;

-- Intialise the List
function TimerList.new()
	-- the new instance
	local self = setmetatable({}, TimerList)
	self.TimerLookup = {}
	return self;
end

function TimerList:Add(timer)
	table.insert(self, timer)
	self.TimerLookup[tostring(timer.TimerId)] = table.getn(self); 	-- Add to lookup table.
end

function TimerList:Delete(timerId)
	
	local foundId = self.SpellIDLookup[tostring(timerId)];
	--print("FoundID="..tostring(foundId));
	
  	if foundId then
  		
		for i,timer in ipairs(self) do
			--print("BeltAndBraces-SELF-Lookup " ..i.." - " .. cctype.SpellId .. " " .. cctype.CCName);
			if timer.TimerId == timerId then
				--print("Found and removed self at " .. i);
				table.remove(self, i);
			end
		end  
		for i,timer in ipairs(self.TimerLookup) do
			---print("BeltAndBracesSpellIDLookup " ..i.." - " .. cctype.SpellId .. " " .. cctype.CCName);
			if timer.TimerId == timerId then
				--print("Found and removed Lookup" .. i);
				table.remove(self.TimerLookup, i);
			end
		end  
	end
end

function TimerList:LookupTimerId(timerId)
  local foundId = self.TimerLookup[tostring(timerId)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end

function TimerList:DeleteExpiredTimers()
	for i, timer in ipairs(self) do
		if not timer:IsActive() then
			--print("Found and removed expired timer at " .. i);
			table.remove(self, i);
		end
	end	
end

function TimerList:CheckTimers()
	for i, timer in ipairs(self) do
		if timer:IsActive() then
			timer.parent:Tick(timer:TimeRemaining());
		else
			timer.parent:Tick(timer:TimeRemaining());
			--print("Found and removed expired timer at " .. i);
			table.remove(self, i);
		end
	end	
end

