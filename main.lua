screen = {
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight()
}

require 'world'
require 'shader'
require 'simulation'

local bloom_alpha = 180
local desaturate_factor = 0
local desaturate_fadeSpeed = 5

local canvas = {
  love.graphics.newCanvas(screen.width / 2, screen.height /2),
  love.graphics.newCanvas(screen.width / 2, screen.height /2),
  love.graphics.newCanvas(screen.width / 2, screen.height /2),
  love.graphics.newCanvas(screen.width, screen.height)
}

function love.load()
	world:init()
  shader.blur:setRenderTargetSize(screen.width / 2, screen.height / 2)
  shader.blur:setIntensity(1)
end

function love.update(dt)
	local gx, gy = world:getGridPosition(love.mouse.getX(),love.mouse.getY())
  if love.mouse.isDown('l') then
    world:setCell(gx, gy, true)
  elseif love.mouse.isDown('r') then
    world:setCell(gx, gy, false)
  end
  
  if simulation.running then
    desaturate_factor = desaturate_factor - desaturate_fadeSpeed * dt
    if desaturate_factor < 0 then desaturate_factor = 0 end
  else
    desaturate_factor = desaturate_factor + desaturate_fadeSpeed * dt
    if desaturate_factor > 0.5 then desaturate_factor = 0.5 end
  end
  
  shader.desaturate:setFactor(desaturate_factor)
  
  simulation:update(dt)
  world:update(dt)
end

function love.draw()
	canvas[1]:clear()
  canvas[2]:clear()
  canvas[3]:clear()
  canvas[4]:clear()
  
  love.graphics.setBlendMode('alpha')
  love.graphics.setCanvas(canvas[1])
  world:draw(0.5)
  love.graphics.setCanvas(canvas[2])
  shader.blur.setVertical()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(canvas[1])
  love.graphics.setCanvas(canvas[3])
  shader.blur.setHorizontal()
  love.graphics.draw(canvas[2])
  love.graphics.setShader()
  
  love.graphics.setCanvas(canvas[4])
  love.graphics.setColor(255, 255, 255, 255)
  world:draw(1)
  love.graphics.setColor(255, 255, 255, bloom_alpha)
  love.graphics.setBlendMode('additive')
  love.graphics.draw(canvas[3], 0, 0, 0, 2, 2)
  love.graphics.setCanvas()
  
  love.graphics.setBlendMode('alpha')
  love.graphics.setColor(255,100,255,255)
  
  shader.desaturate.set()
  love.graphics.draw(canvas[4])
  
  local gx, gy = world:getGridPosition(love.mouse.getX(), love.mouse.getY())
  love.graphics.setColor(world.color.live_cell)
end

function love.keypressed(key)
  if key == 'escape' then love.event.push('quit')end
  if key == ' ' then simulation:toggle() end
  if key == 's' then simulation:step()end
  if key == 'c' then world:clear() end
end  

function love.mousepressed(x, y, key)
  if key == 'l' then
    local gx, gy = world:getGridPosition(x,y)
    world:setCell(gx, gy, true)
  end
end  

function in_range(number, low, high)
  if number >= low and number <= high then
    return true
  else return false end
end  

function random_bool()
  local i = math.random()
  if i >= 0.5 then return true else return false end
end  