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
	return self;
end

function TimerList:Add(timer)
	table.insert(self, timer)
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
		if not timer:IsActive() then
			timer.CallbackFunction_TimerEnds();
			--print("Found and removed expired timer at " .. i);
			table.remove(self, i);
		end
	end	
end

