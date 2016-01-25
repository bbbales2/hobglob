local Noise2d = require 'Noise2d'
local JumperGrid = require('jumper.grid')
local JumperPathfinder = require('jumper.pathfinder')

local Map = {
  width = 100,
  height = 100,
  grid = {},
  world = nil,
  jgrid = {},
  router = nil,
  __type = 'Map'
}

w = 50
h = 50
local quads = {
    love.graphics.newQuad(380, 1081, w, h, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(450, 1081, w, h, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(320, 1081, w, h, texture:getWidth(), texture:getHeight()),
    love.graphics.newQuad(510, 1081, w, h, texture:getWidth(), texture:getHeight())
}
  
local cost = {
  1,
  1,
  2,
  4
}

function Map:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Convert width and height to internal format
  o.width = math.floor((o.width + w - 1) / w)
  o.height = math.floor((o.height + h - 1) / h)
  
  local noise = Noise2d.generate(o.width, o.height, 16, 1, 0.8)
  
  for i = 1, o.height do
    o.grid[i] = {}
    for j = 1, o.width do
      local val = noise[i + (j - 1) * o.height]
      
      o.grid[i][j] = 1
      
      if val > 1.0 then
        o.grid[i][j] = 4
      elseif val > 0.5 then
        o.grid[i][j] = 3
      elseif val > 0.0 then
        o.grid[i][j] = 2
      end
    end
  end
  
  o.jgrid = JumperGrid(o.grid)
    
  o.pathFinder = JumperPathfinder(o.jgrid, 'ASTAR', function(x) return x < 4 end)--
  
  return o
end

function Map:update(world, dt)
  self.t = self.t + dt
end

function Map:pixelToTileCoords(x, y)
  local lx = math.floor((x + w - 1) / w)
  local ly = math.floor((y + h - 1) / h)
  
  return lx, ly
end

function Map:getPath(x1, y1, x2, y2)
  local lx1, ly1 = self:pixelToTileCoords(x1, y1)
  local lx2, ly2 = self:pixelToTileCoords(x2, y2)
  
  local path = self.pathFinder:getPath(lx1, ly1, lx2, ly2)
  
  if path then
    local list = { { x = x1, y = y1 } }
    local i = 1
    
    for node, count in path:nodes() do
      if i > 1 then
        list[i] = { x = (node:getX() - 1) * w + w / 2, y = (node:getY() - 1) * w + w / 2 }
      end
      i = i + 1
    end
    
    list[#list] = { x = x2, y = y2 }
    
    return list
  end
end

function Map:draw(sb, dt)
  for i = 1, self.height do
    for j = 1, self.width do
      sb:add(quads[self.grid[i][j]], (j - 1) * w, (i - 1) * h)
    end
  end
end

return Map