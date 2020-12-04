 -- use pin as the input pulse width counter
local pin, pulse1, i, trig = 4, 0, 0, gpio.trig
gpio.mode(pin,gpio.INT)

local p = {}
for j=0,15 do p[j]={}; p[j]["ON"], p[j]["OFF"] = 0, 0; end

local function showBuffer()
  twoByte = 0
  for j=0,15 do 
    val = p[j]["ON"] > p[j]["OFF"] and 1 or 0
    twoByte = bit.bor(twoByte, bit.lshift(val, j))
  end

  print(string.format("result 0x%X", twoByte))
end

local function pin1cb(level, when)
  -- change the trigger to the other edge
  trig(pin, level == 1  and "down" or "up")
  -- calculate the pulse width
  width = when - pulse1
  -- reset the clock for the next pulse
  pulse1 = when

  -- timeout after 30ms 
  if(width > 30000) then i=0; return; end

  -- check if we got 16 bit
  if(i > 15) then
    showBuffer()
    return
  end

  if(level == 1)then
    p[i]["OFF"]=width
  else
    p[i]["ON"]=width
    i = i +1
  end
end

trig(pin, "down", pin1cb)
