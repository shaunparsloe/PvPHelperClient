-- ****************************************************
-- UTILS
-- ****************************************************
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--local clock = os.clock
function sleep(numSecToSleep)  -- seconds
  local startTime = time()
  local sec1 = startTime + 1;
  while time() - startTime <= numSecToSleep do 
    --if clock() > sec1 then
    --  sec1 = sec1 + 1;
    --  print("Sleep 1sec...");
    --end
  end
end

--- Pads str to length len with char from left
function string.rpad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

-- Extend math function to round to nearest integer
function math.round(x)
  if x%2 ~= 0.5 then
    return math.floor(x+0.5)
  end
  return x-0.5
end


local function ClassHexColor(class)
	local hex
	if classcolors[class] then
		hex = format("%.2x%.2x%.2x", classcolors[class].r*255, classcolors[class].g*255, classcolors[class].b*255)
	end
	return hex or "cccccc"
end


function TESTAssert(expected, actual, description)
  local blnRetval = false
  local join = ": "
  local calledfrom = debug.getinfo(2).name;
  if (actual == expected) then
    blnRetval = true;
  else
    if not description then
      description = ""
      join = ""
    end
      print("[TESTERROR:"..calledfrom.."] "..description..join.."Expected value: ["..tostring(expected).."] Actual value: ["..tostring(actual).."]");
  end
  return blnRetval
end

--Conditional depending on test/live
if (os) then
  function time()
    return os.clock()
  end
else
  function print(message)
    ChatFrame1:AddMessage(message)
  end
end
-- ****************************************************
-- UTILS
-- ****************************************************
