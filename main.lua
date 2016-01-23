require("mobdebug").start()

--require('debug')
local Peon = require('Peon')
local HC = require('HC')

function math.round(x)
  if x - math.floor(x) < math.ceil(x) - x then
    return math.floor(x)
  else
    return math.ceil(x)
  end
end

world = {
  collider = HC.new(200),
  creatures = {},
  structs = {}
}

function love.load(arg)
  circle = HC.circle(400,300,20)
  
  table = { circle = 123 }
  
  Terrain = love.graphics.newImage('SevenKingdoms_graphics/terrain/I_tpict1.res.png')
  
  grassQ = love.graphics.newQuad(380, 0, 60, 60, Terrain:getWidth(), Terrain:getHeight())
  
  Trees = love.graphics.newImage('SevenKingdoms_graphics/terrain/Plant-sprites-badlands-terrain.png')
  
  treeQ = love.graphics.newQuad(400, 40, 30, 50, Trees:getWidth(), Trees:getHeight())
  
  Buildings = love.graphics.newImage('SevenKingdoms_graphics/buildings/Village-sprites.png')
  
  hutQ = love.graphics.newQuad(70, 0, 30, 32, Buildings:getWidth(), Buildings:getHeight())
  
  playerImg = love.graphics.newImage('SevenKingdoms_graphics/sprites/hobglob/0000.png')
  
  tree = { t = Trees, g = treeQ, x = 200, y = 150, w = 30, h = 50, r = 20, shape = world.collider:circle(300, 150, 50) }
  hut = { t = Buildings, g = hutQ, x = 400, y = 350, w = 32, h = 30, r = 20 }
  
  for i = 1, 5 do
    peon = Peon:new({ x = math.random(0, love.graphics.getWidth()), y = math.random(0, love.graphics.getHeight()), world = world })
    --peon = Peon:new({ x = 300, y = 300, world = world })
  
    world.creatures[peon.shape] = peon
  end
  
  world.structs[tree.shape] = tree
end

wood = 0

t = 0.0
function love.update(dt)
  t = t + dt
  
  for shape, creature in pairs(world.creatures) do
    creature:update({ tree }, dt)
  end
end

function love.draw(dt)
  -- Draw the grass background
  for i = 0, love.graphics.getWidth(), 60 do
    for j = 0, love.graphics.getHeight(), 60 do
      love.graphics.draw(Terrain, grassQ, i, j)
    end
  end
  
  -- Draw a tree
  love.graphics.draw(tree.t, tree.g, tree.x - tree.w / 2, tree.y - tree.h / 2)
  love.graphics.draw(hut.t, hut.g, hut.x - hut.w / 2, hut.y - hut.h / 2)
  
  love.graphics.print(string.format("Wood: %d", wood), 20, 20)
  
  for shape, creature in pairs(world.creatures) do
    creature:draw(dt)
  end
end