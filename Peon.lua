local Peon = {
  x = 0,
  y = 0,
  angle = 1.5 * math.pi,
  state = 'standing',
  frame = 0,
  t = 0,
  shape = nil,
  world = nil,
  r = 10,
  selected = false,
  __type = 'Peon'
}


local w = 85
local h = 98

local anim8 = require('anim8')
local HC = require('HC')

local hanim = anim8.newGrid(w, h, texture:getWidth(), texture:getHeight(), 0, 0)
  
walking = { 
  hanim('1-8', 3),
  hanim('1-8', 2),
  hanim('1-8', 1),
  hanim('8-1', 7),
  hanim('8-1', 8),
  hanim('8-1', 9),
  hanim('1-8', 5),
  hanim('1-8', 4)
}

chopping = {
  hanim('1-4', 6)
}

function Peon:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  o.shape = o.world.collider:circle(o.x, o.y, o.r)
  
  return o
end

function Peon:update(world, dt)
  if self.state == 'walking' then
    if self.target == nill then
      self.target = world[1]
    end
    
    -- Walk towards target
    dx = self.target.x - self.x
    dy = self.target.y - self.y
    
    tdistance = math.sqrt(dx * dx + dy * dy)
    
    dx = dx / tdistance
    dy = dy / tdistance
    
    
    --Avoid other creatures
    for shape, delta in pairs(self.world.collider:collisions(self.shape)) do
      other = self.world.creatures[shape] or self.world.structs[shape]
      if type(other) == 'Peon' or type(other) == 'Tree' then -- If we've collided with a creature
        --print(delta.x, delta.y)
        local ddx = (other.x - self.x)
        local ddy = (other.y - self.y)
        local dd = math.sqrt(ddx * ddx + ddy * ddy)
        
        local f = 1 / (1 + math.exp(-(other.r + self.r - dd - 10) / 2.0))
        
        dx = dx - f * ddx / dd
        dy = dy - f * ddy / dd
      end
    end
    
    distance = math.sqrt(dx * dx + dy * dy)
    
    dx = dx / distance
    dy = dy / distance
    self.angle = math.atan2(dy, dx)
    
    self.speed = 50.0-- / (1 + math.exp((self.target.r + r) - distance))
    
    self.x = self.x + dt * self.speed * dx
    self.y = self.y + dt * self.speed * dy
    
    self.anim = walking[1 + (math.round(8 * ((self.angle %  (2 * math.pi)) / (2 * math.pi))) % 8)]
    
    self.shape:moveTo(self.x, self.y)
    
    if (self.target.r + self.r) > tdistance and self.target == tree then
      self.state = 'chopping'
      self.chop_time = t + 1.0
    end
    
    if (self.target.r + self.r) > tdistance and self.target == hut then
      self.state = 'walking'
      self.target = tree
      
      self.world.wood = self.world.wood + 4
    end
  
    self.frame = math.floor((t * 20.0) % #self.anim) + 1
  elseif self.state == 'chopping' then
    self.anim = chopping[1]
    
    if t > self.chop_time then
      self.state = 'walking'
      
      self.target = hut
    end
  
    self.frame = math.floor((t * 20.0) % #self.anim) + 1
  elseif self.state == 'standing' then
    self.anim = chopping[1]
    self.frame = 1
  end
   
  self.t = self.t + dt
end

function Peon:draw(sb, dt)
  local dx = w / 2.0
  local dy = 60
  
  sb:add(self.anim[self.frame], self.x - dx, self.y - dy)
  --if self.selected then
  --  love.graphics.setColor(255, 0, 0)
  --  love.graphics.circle("fill", self.x, self.y, self.r, 20)
  --  love.graphics.setColor(255, 255, 255)
  --end
  
  --love.graphics.setColor(255, 0, 0)
  --love.graphics.circle("line", self.x, self.y, 10.0, 20)
  --love.graphics.setColor(255, 255, 255)
end

return Peon