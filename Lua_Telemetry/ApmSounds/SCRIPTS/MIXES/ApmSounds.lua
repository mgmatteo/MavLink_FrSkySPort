local soundfile_base = "/SOUNDS/en/fm_"
-- local soundfile_base = "/SOUNDS/en/ALFM"

--Inputs di prova
local inputs = {{"Repeat", VALUE, 0, 1, 1} }

-- Internal
local last_FM = 0
local last_FM_play = 0
local received_telemetry = false
local first_telemetry = -1

local function nextRepeatFlightmode(FM)
  if last_FM_play < 1 then
	return 0
  end
  -- Auto or guided (every 15 sec)
  if FM == 3 or FM == 4  then
	return last_FM_play + 15*100
  -- Return to launch or land (every 5 sec)
  elseif FM == 6 or FM == 9 then
    return last_FM_play + 5*100
  end
  -- All others (every hour)
   return last_FM_play + 3600*100
end

local function playFlightmode()
  if received_telemetry == false 
  then
    local rssi = getValue("rssi")
    if rssi < 1 
	then
	  return
	end
	if first_telemetry < 0 
	then
		first_telemetry = getTime()
	end
	if (first_telemetry + 150) > getTime()
	then
		return
	end
	received_telemetry = true
  end
  local FM = getValue("fuel")
  if (FM ~= last_FM) or (nextRepeatFlightmode(FM) < getTime())
  then
	last_FM_play = getTime()
	playFile(soundfile_base  .. FM .. ".wav")	
	-- playFile(soundfile_base  .. FM .. "E.wav")
	last_FM = FM
  end
end

local function run_func(repeat_flightMode)
 local repeat_FM = repeat_flightMode
 playFlightmode()
end  

-- Return statement
return { run=run_func, init=init, input=inputs}