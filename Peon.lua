local w = 85
local h = 98

local anim8 = require('anim8')
local HC = require('HC')

local hanim = anim8.newGrid(w, h, texture:getWidth(), texture:getHeight(), 0, 0)

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
    -- If we have no target randomly select one
    while self.target == nil do
      local map = self.world.map
      
      local target = {
        x = math.random(1, self.world.width),
        y = math.random(1, self.world.height)
      }
      
      local path = map:getPath(self.x, self.y, target.x, target.y)
      
      if path then
        self.target = target
        self.path = path
      end
    end
    
    local target, dx, dy, tdistance = 0.0
    
    repeat
      if #self.path == 0 then
        target = nil
        break
      end
      
      target = self.path[1]
    
    -- Walk towards target
      dx = target.x - self.x
      dy = target.y - self.y
    
      tdistance = math.sqrt(dx * dx + dy * dy)
      
      if tdistance < self.r then
        table.remove(self.path, 1)
      end
    until self.r < tdistance
    
    if target then
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
    else
      self.anim = chopping[1]
      self.target = nil
    end
      
    --if self.r > tdistance then
    --  self.target = nil
    --end
  
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
  
  love.graphics.draw(sb, 0, 0)
  sb:clear()
  
  if self.selected then
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", self.x, self.y, self.r, 20)
    love.graphics.setColor(255, 255, 255)
  end
  
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("line", self.x, self.y, 10.0, 20)
  love.graphics.setColor(255, 255, 255)
  
  if #self.path > 0 then
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("line", self.path[1].x, self.path[1].y, 10.0, 20)
    love.graphics.setColor(255, 255, 255)
  
    love.graphics.setColor(0, 255, 255)
    love.graphics.circle("line", self.path[#self.path].x, self.path[#self.path].y, 10.0, 20)
    love.graphics.setColor(255, 255, 255)
  end
  
end

return Peon