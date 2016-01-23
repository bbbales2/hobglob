local Peon = { x = 0, y = 0, angle = 1.5 * math.pi, state = 'walking', frame = 0, t = 0 }

local w = 85
local h = 98
local r = 20

local anim8 = require('anim8')

local texture = love.graphics.newImage('processed_graphics/hobglob.png')
local hanim = anim8.newGrid(w, h, texture:getWidth(), texture:getHeight(), 0, 0)
  
walking = { 
  hanim('1-8', 3),
  hanim('1-8', 2),
  hanim('1-8', 1),
  hanim('8-1', 7),
  hanim('8-1', 8),
  hanim('8-1', 9),
  hanim('1-8', 4),
  hanim('1-8', 5)
}

chopping = {
  hanim('1-4', 6)
}
  
function Peon:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Peon:update(world, dt)
  if self.state == 'walking' then
    if self.target == nill then
      self.target = world[1]
    end
    
    dx = self.target.x - self.x
    dy = self.target.y - self.y
      
    distance = math.sqrt(dx * dx + dy * dy)
      
    self.angle = math.atan2(dy, dx)
      
    self.speed = 1 / (1 + math.exp((self.target.r + r) - distance))
      
    self.x = self.x + self.speed * dx / distance
    self.y = self.y + self.speed * dy / distance
      
    self.anim = walking[1 + (math.round(8 * ((self.angle %  (2 * math.pi)) / (2 * math.pi))) % 8)]
      
    if (self.target.r + r) > distance and self.target == tree then
      self.state = 'chopping'
      self.chop_time = t + 1.0
    end
    
    if (self.target.r + r) > distance and self.target == hut then
      self.state = 'walking'
      self.target = tree
      
      wood = wood + 4
    end
  end
  
  if self.state == 'chopping' then
    self.anim = chopping[1]
    
    if t > self.chop_time then
      self.state = 'walking'
      
      self.target = hut
    end
  end
   
  self.frame = math.floor((t * 20.0) % #self.anim) + 1
  
  self.t = self.t + dt
end

function Peon:draw(dt)
    love.graphics.draw(texture, self.anim[self.frame], self.x - w / 2, self.y - h / 2.0)
end

return Peon