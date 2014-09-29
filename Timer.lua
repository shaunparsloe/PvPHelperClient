-- ****************************************************
-- Class Timer
-- ****************************************************
Timer={};
Timer.__index = Timer -- failed table lookups on the instances should fallback to the class table, to get methods

-- Create this cover function to check mandatory and optional parameters for TimerS
function Timer.new (options)
	-- the new instance
	local self = setmetatable(
	{	
		parent = options.parent,
		TimerId = options.TimerId,
		Duration = options.Duration, 
		StartTime = GetPvPClockTime(),
		ExecuteTime = options.ExecuteTime
	}
	, Timer)
		
	if not self.TimerId then
		print("ERROR SETTING UP TIMER: MISSING TIMERID");
	end
	
	if self.Duration and not self.ExecuteTime then
		self.ExecuteTime = self.StartTime + self.Duration;
	end
	
	if self.ExecuteTime and not self.Duration then
		self.Duration = self.ExecuteTime - self.StartTime;
	end
	
	print("Added Timer: Duration: "..self.Duration..", executes: "..self.ExecuteTime);
	
	-- return the instance
	return self;
end

-- Restart for whatever the duration is.
function Timer:Start()
	self.StartTime = GetPvPClockTime()
	self.ExecuteTime = self.StartTime + self.Duration
	return self
end


function Timer:IsActive()
	local retval = false;
	if (self.ExecuteTime > GetPvPClockTime()) then
		retval = true;
	else
		retval = false;
	end

	return retval;
end

function Timer:TimeRemaining()
	return self.ExecuteTime - GetPvPClockTime();
end


-- ****************************************************
-- Class Timer
-- ****************************************************

