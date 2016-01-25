local stats = require('stats')

local Noise2d = {}

function Noise2d.generate(height, width, layers, frequency, persistency)
  local data = {}
  
  for i = 1, height * width do
    data[i] = 0
  end
  
  for l = 1, layers do
    local f = frequency * l
    local a = math.pow(persistency, l - 1)
    
    for i = 1, height do
      for j = 1, width do
        data[i + (j - 1) * height] = data[i + (j - 1) * height] + a * love.math.noise(i * f / height, j * f / width)
      end
    end
  end
  
  local x = 0.0
  local x2 = 0.0
  
  for i = 1, height * width do
    x = x + data[i]
    x2 = x2 + data[i] * data[i]
  end
  
  x = x / (height * width)
  x2 = x2 / (height * width)
  
  local std = math.sqrt(x2 - x * x)
  
  for i = 1, height * width do
    data[i] = (data[i] - x) / std
  end
  
  return data
end

return Noise2d