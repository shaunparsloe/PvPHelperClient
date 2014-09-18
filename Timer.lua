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
		CallbackFunction_TimerEnds = options.TimerEndsFunction,
		Duration = options.Duration, 
		StartTime = time(),
		ExecuteTime = options.ExecuteTime
	}
	, Timer)
	
	if not (self.CallbackFunction_TimerEnds) then
		print("ERROR SETTING UP TIMER. Missing callback function");
	end
	
	if self.Duration and not self.ExecuteTime then
		self.ExecuteTime = self.StartTime + self.Duration;
	end
	
	if self.ExecuteTime and not self.Duration then
		self.Duration = self.ExecuteTime - self.StartTime;
	end
	
	-- return the instance
	return self;
end

-- Restart for whatever the duration is.
function Timer:Start()
	self.StartTime = time()
	self.ExecuteTime = self.StartTime + self.Duration
	return self
end


function Timer:IsActive()
	local retval = false;
	if (self.ExecuteTime > time()) then
		retval = true;
	else
		retval = false;
	end

	return retval;
end


-- ****************************************************
-- Class Timer
-- ****************************************************

