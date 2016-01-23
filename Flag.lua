local Flag = {
  x = 0,
  y = 0,
  type = 'worker',
  t = 0,
  shape = nil,
  world = nil,
  r = 200
}

local w = 32
local h = 32

local HC = require('HC')

local texture = love.graphics.newImage('SevenKingdoms_graphics/gui/cursors.png')
local workerQuad = love.graphics.newQuad(96, 64, w, h, texture:getWidth(), texture:getHeight())
local armyQuad = love.graphics.newQuad(64, 64, w, h, texture:getWidth(), texture:getHeight())
  
function Flag:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  o.shape = o.world.collider:point(o.x, o.y)
  
  return o
end

function Flag:update(world, dt)
  self.t = self.t + dt
end

function Flag:draw(dt)
  if self.type == '' do
    love.graphics.draw(texture, self.anim[self.frame], self.x - w / 2, self.y - h / 2.0)
  end
  
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("line", self.x, self.y, self.r, 20)
  love.graphics.setColor(255, 255, 255)
end

return Flag