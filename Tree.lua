local Tree = {
  x = 0,
  y = 0,
  t = 0,
  shape = nil,
  world = nil,
  r = 10,
  selected = false,
  leaves = 10,
  __type = 'Tree'
}

local w = 28
local h = 50

local HC = require('HC')

  
local quads = {
  {
    love.graphics.newQuad(344, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(372, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight())
  },
  {
    love.graphics.newQuad(402, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(430, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight())
  },
  {
    love.graphics.newQuad(32, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(254, 40 + 978, 28, 50, texture:getWidth(), texture:getHeight())
  }
  --,
  --love.graphics.newQuad(400, 40, 32, 50, Trees:getWidth(), Trees:getHeight())
}

function Tree:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  o.shape = o.world.collider:circle(o.x, o.y, o.r)
  
  o.quadChoices = {
    math.random(1, 1),
    math.random(1, 1),
    math.random(1, 1)
  }
  
  o.leaves = math.random(1, 10)
  
  return o
end

function Tree:update(world, dt)
  self.t = self.t + dt
end

function Tree:draw(sb, dt)
  local dx = 14
  local dy = 45
  
  if self.leaves >= 10 then
    sb:add(quads[1][self.quadChoices[1]], self.x - dx, self.y - dy)
  elseif self.leaves >= 6 then
    sb:add(quads[2][self.quadChoices[2]], self.x - dx, self.y - dy)
  else
    sb:add(quads[3][self.quadChoices[3]], self.x - dx, self.y - dy)
  end
  
  --if self.selected then
  --  love.graphics.setColor(255, 0, 0)
  --  love.graphics.circle("line", self.x, self.y, self.r, 20)
  --  love.graphics.setColor(255, 255, 255)
  --end
end

return Tree