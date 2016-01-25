--require("mobdebug").start()

local table = require('table')

texture = love.graphics.newImage('processed_graphics/texture.png')

--require('debug')
local Peon = require('Peon')
local Flag = require('Flag')
local Tree = require('Tree')
local Map = require('Map')

local HC = require('HC')
local Camera = require "hump.camera"

local oldType = type 
function type(x)
  local mt = getmetatable(x)
  
  if mt and mt.__type then
    return mt.__type
  else
    return oldType(x)
  end
end

function math.round(x)
  if x - math.floor(x) < math.ceil(x) - x then
    return math.floor(x)
  else
    return math.ceil(x)
  end
end

world = {
  map = nil,
  collider = HC.new(100),
  creatures = {},
  structs = {},
  wood = 0,
  width = 1024,
  height = 768,
  player = {
    x = 500,
    y = 200,
    z = 1.0,
    camera = Camera.new(0, 0)
  }
}

local mouse = world.collider:point(0, 0)
local selected = nil
local flags = 2

sb = love.graphics.newSpriteBatch(texture, 2000)

function love.load(arg)
  world.map = Map:new({ width = world.width, height = world.height, world = world })
  --Buildings = love.graphics.newImage('SevenKingdoms_graphics/buildings/Village-sprites.png')
  
  --hutQ = love.graphics.newQuad(70, 0, 30, 32, Buildings:getWidth(), Buildings:getHeight())
  hutQ = love.graphics.newQuad(320, 1081, 60, 60, texture:getWidth(), texture:getHeight())
  
  hut = { t = Buildings, g = hutQ, x = 400, y = 350, w = 32, h = 30, r = 20 }
  
  for i = 1, 300 do
    tree = Tree:new({ x = math.random(0, world.width), y = math.random(0, world.height), world = world })
    --peon = Peon:new({ x = 300, y = 300, world = world })
  
    world.structs[tree.shape] = tree
  end

  tree = Tree:new({ x = 700, y = 300, world = world, selected = true })
  
  world.structs[tree.shape] = tree
  
  for i = 1, 10 do
    peon = Peon:new({
      x = math.random(0, love.graphics.getWidth()),
      y = math.random(0, love.graphics.getHeight()),
      world = world,
      state = 'walking'
    })
  
    --peon = Peon:new({ x = 300, y = 300, world = world })
  
    world.creatures[peon.shape] = peon
  end
end

function love.keyreleased(key, scancode)
  if scancode == 'escape' then
    selected.selected = false
    
    selected = nil
  end
end

function love.mousereleased(x, y, button, istouch)
  x = x + math.floor(world.player.x) - love.graphics.getWidth() / 2
  y = y + math.floor(world.player.y) - love.graphics.getHeight() / 2
  
  print(x, y, world.player.x, world.player.y)
  
  if button == 1 then -- select
    if selected then
      selected.selected = false
    end
    
    distances = {}
    
    mouse:moveTo(x, y)
    
    for shape, delta in pairs(world.collider:collisions(mouse)) do
      other = world.structs[shape] or world.creatures[shape]
      
      table.insert(distances, { object = other, distance = math.sqrt(math.pow(other.x - x, 2), math.pow(other.y - y, 2)) })
    end
    
    table.sort(distances, function(a, b) return a.distance < b.distance end)
    
    if #distances > 0 then
      distances[1].object.selected = true
      
      selected = distances[1].object
    end
  elseif button == 2 then
    flag = Flag:new({ x = x, y = y, world = world })
  
    world.structs[flag.shape] = flag
  end
end
t = 0.0
function love.update(dt)
  t = t + dt
  
  for shape, creature in pairs(world.creatures) do
    creature:update({ tree }, dt)
  end
  
  if love.keyboard.isDown("up") then
    world.player.y = world.player.y - 200 * dt
  end
  
  if love.keyboard.isDown("down") then
    world.player.y = world.player.y + 200 * dt
  end
  
  if love.keyboard.isDown("left") then
    world.player.x = world.player.x - 200 * dt
  end
  
  if love.keyboard.isDown("right") then
    world.player.x = world.player.x + 200 * dt
  end
  
  if love.keyboard.isDown("a") then
    world.player.z = world.player.z + dt
  end
  
  if love.keyboard.isDown("s") then
    world.player.z = world.player.z - dt
  end
  
  world.player.camera:lookAt(math.floor(world.player.x), math.floor(world.player.y))
  world.player.camera:zoomTo(world.player.z)
end

function love.draw(dt)
  world.player.camera:attach()
  
  sb:clear()
 
  world.map:draw(sb, dt)
  
  toDraw = {}
  
  -- Draw a tree
  for shape, struct in pairs(world.structs) do
    table.insert(toDraw, { y = struct.y, object = struct })
  end
  
  for shape, creature in pairs(world.creatures) do
    table.insert(toDraw, { y = creature.y, object = creature })
  end
  
  table.sort(toDraw, function(a, b) return a.y < b.y end)
  
  --batch = love.graphics.newSpriteBatch(Peon.texture, N)
  
  --struct:draw(dt)
  for i, obj in ipairs(toDraw) do
    obj.object:draw(sb, dt)
  end
  
  love.graphics.draw(sb, 0, 0)
  
  world.player.camera:detach()
  
  --love.graphics.draw(texture, hut.g, hut.x - hut.w / 2, hut.y - hut.h / 2)
  
  love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 20, 60)
  love.graphics.print(string.format("Wood: %d", world.wood), 20, 20)
  love.graphics.print(string.format("Flags: %d", flags), 20, 40)
end