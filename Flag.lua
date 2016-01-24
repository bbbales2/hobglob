local Flag = {
  x = 0,
  y = 0,
  type = 'worker',
  t = 0,
  shape = nil,
  world = nil,
  r = 100,
  selected = false,
  __type = 'Flag'
}

local w = 32
local h = 32

local HC = require('HC')

local workerQuad = love.graphics.newQuad(96, 64 + 882, w, h, texture:getWidth(), texture:getHeight())
local armyQuad = love.graphics.newQuad(64, 64 + 882, w, h, texture:getWidth(), texture:getHeight())
  
function Flag:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  o.shape = o.world.collider:circle(o.x, o.y, o.r)
  
  return o
end

function Flag:update(world, dt)
  self.t = self.t + dt
end

function Flag:draw(sb, dt)
  if self.type == 'worker' then
    sb:add(workerQuad, self.x - w / 2, self.y - w / 2)
  else
    sb:add(armyQuad, self.x - w / 2, self.y - w / 2)
  end
  
  --if self.selected then
  --  love.graphics.setColor(255, 0, 0)
  --else
  --  love.graphics.setColor(0, 0, 255)
  --end
  --love.graphics.circle("line", self.x, self.y, self.r, 20)
  --love.graphics.setColor(255, 255, 255)
end

return Flag