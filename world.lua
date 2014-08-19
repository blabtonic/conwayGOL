world = {
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  cell_size = 0, 
  world = {},
  fade_speed = 8,
  outline_width = 1,
  color = {
    background = {0, 32, 100, 255},
    outline = {0, 0, 0, 255},
    dead_cell = {0, 0, 0, 0},
    live_cell = {0, 255, 25, 255}
  }
}

function world:init()
  local cell_size = 16
  local width = math.floor(screen.width / cell_size)
  local height = math.floor(screen.height / cell_size)
  love.graphics.setBackgroundColor(self.color.outline)
  self:generate(width, height, cell_size)
end

function world:generate(width, height, cell_size)
  self.cell_size = cell_size
  self.width = width
  self.height = height
  for y=0, (height - 1) do
    self.world[y] = {}
    for x=0, (width - 1) do
      self.world[y][x] = {
        status = false,
        next_status = false,
        neighbours = 0,
        color = 0
      }
    end  
  end
end  

function world:update(dt)
  for y=0, (self.height - 1) do
    for x=0, (self.width - 1) do
      local cell = self.world[y][x]
      if cell.status then
        cell.color = cell.color + self.fade_speed * dt
        if cell.color > 1 then cell.color = 1 end
      else
        cell.color = cell.color - self.fade_speed * dt
        if cell.color < 0 then cell.color = 0 end
      end
      self.world[y][x] = cell
    end
  end
end

function world:draw(scale)
  love.graphics.setColor(self.color.outline)
  love.graphics.rectangle('fill', self.x, self.y, (screen.width - self.x)* scale, (screen.height - self.y)*scale)
  for y=0, (self.height - 1) do
		for x=0, (self.width - 1) do
			local cell = self.world[y][x]

			love.graphics.setColor(self.color.background)
			if scale == 1 then
				love.graphics.rectangle("fill", (self.x + (x * self.cell_size)) * scale, (self.y + (y * self.cell_size)) * scale, (self.cell_size - self.outline_width) * scale, (self.cell_size - self.outline_width) * scale)
			end

			local r = self.color.dead_cell[1] + (self.color.live_cell[1] - self.color.dead_cell[1]) * cell.color
			local g = self.color.dead_cell[2] + (self.color.live_cell[2] - self.color.dead_cell[2]) * cell.color
			local b = self.color.dead_cell[3] + (self.color.live_cell[3] - self.color.dead_cell[3]) * cell.color
			local a = self.color.dead_cell[4] + (self.color.live_cell[4] - self.color.dead_cell[4]) * cell.color
			local size = (self.cell_size - self.outline_width) * cell.color
			love.graphics.setColor(r, g, b, a)

			love.graphics.rectangle("fill", (self.x + (x * self.cell_size) + ((self.cell_size - size) / 2)) * scale , (self.y + (y * self.cell_size) + ((self.cell_size - size) / 2)) * scale, size * scale, size * scale)

		end
	end
end

function world:setCell(x, y, status)
  if in_range(x,0,self.width - 1) and in_range(y,0, self.height - 1) then
    self.world[y][x].status = status
  end  
end  

function world:getGridPosition(x,y)
  local gx = math.floor(x / self.cell_size)
  local gy = math.floor(y / self.cell_size)
  return gx, gy
end  

function world:clear()
  for y=0, (self.height - 1) do
    for x=0, (self.width - 1) do
      self.world[y][x].status = false
    end
  end  
end  