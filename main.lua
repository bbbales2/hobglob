require("mobdebug").start()

--require('debug')

local anim8 = require('anim8')

function math.round(x)
  if x - math.floor(x) < math.ceil(x) - x then
    return math.floor(x)
  else
    return math.ceil(x)
  end
end

function love.load(arg)
  Terrain = love.graphics.newImage('SevenKingdoms_graphics/terrain/I_tpict1.res.png')
  
  grassQ = love.graphics.newQuad(380, 0, 60, 60, Terrain:getWidth(), Terrain:getHeight())
  
  Trees = love.graphics.newImage('SevenKingdoms_graphics/terrain/Plant-sprites-badlands-terrain.png')
  
  treeQ = love.graphics.newQuad(400, 40, 30, 50, Trees:getWidth(), Trees:getHeight())
  
  Buildings = love.graphics.newImage('SevenKingdoms_graphics/buildings/Village-sprites.png')
  
  hutQ = love.graphics.newQuad(70, 0, 30, 32, Buildings:getWidth(), Buildings:getHeight())
  
  playerImg = love.graphics.newImage('SevenKingdoms_graphics/sprites/hobglob/0000.png')
  
  tree = { t = Trees, g = treeQ, x = 300, y = 150, w = 30, h = 50, r = 20 }
  hut = { t = Buildings, g = hutQ, x = 400, y = 300, w = 32, h = 30, r = 20 }
  
  kw = 85
  kh = 98
  Hobglob = love.graphics.newImage('processed_graphics/hobglob.png')
  hanim = anim8.newGrid(kw, kh, Hobglob:getWidth(), Hobglob:getHeight(), 0, 0)
  
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
  
  hgob = {
    t = Hobglob,
    target = tree,
    state = 'walking',
    frame = 0,
    angle = 1.5 * math.pi,
    x = 200,
    y = 200,
    r = 20,
    w = 85,
    h = 98
  }
  
  creatures = { hgob }
end

wood = 0

t = 0.0
function love.update(dt)
  t = t + dt
  
  for k, creature in pairs(creatures) do
    if creature.state == 'walking' then
      dx = creature.target.x - creature.x
      dy = creature.target.y - creature.y
      
      distance = math.sqrt(dx * dx + dy * dy)
      
      creature.angle = math.atan2(dy, dx)
      
      creature.speed = 1 / (1 + math.exp((creature.target.r + creature.r) - distance))--
      
      creature.x = creature.x + creature.speed * dx / distance
      creature.y = creature.y + creature.speed * dy / distance
      
      creature.anim = walking[1 + math.round(8 * ((creature.angle %  (2 * math.pi)) / (2 * math.pi)))]
      
      if (creature.target.r + creature.r) > distance and creature.target == tree then
        creature.state = 'chopping'
        creature.chop_time = t + 1.0
      end
      
      if (creature.target.r + creature.r) > distance and creature.target == hut then
        creature.state = 'walking'
        creature.target = tree
        
        wood = wood + 4
      end
    end
    
    if creature.state == 'chopping' then
      creature.anim = chopping[1]
      
      if t > creature.chop_time then
          creature.state = 'walking'
          
          creature.target = hut
        end
    end
        
    creature.frame = math.floor((t * 20.0) % #creature.anim) + 1
  end
  
  
end

function love.draw(dt)
  -- Draw the grass background
  print(love.graphics.getWidth())
  for i = 0, love.graphics.getWidth(), 60 do
    for j = 0, love.graphics.getHeight(), 60 do
      love.graphics.draw(Terrain, grassQ, i, j)
    end
  end
  
  -- Draw a tree
  love.graphics.draw(tree.t, tree.g, tree.x - tree.w / 2, tree.y - tree.h / 2)
  love.graphics.draw(hut.t, hut.g, hut.x - hut.w / 2, hut.y - hut.h / 2)
  
  love.graphics.print(string.format("Wood: %d", wood), 20, 20)
  
  for k, creature in pairs(creatures) do
    love.graphics.draw(Hobglob, creature.anim[creature.frame], creature.x - creature.w / 2, creature.y - creature.h / 2.0)
  end
end