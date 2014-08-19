simulation = {
  update_rate = 7,
  tick = 0, 
  running = false
}

function simulation:update(dt)
  self.tick = self.tick + dt
  if self.tick > (1 / self.update_rate) then
    if self.running then
      self:step()
    end
    self.tick = 0
  end  
end

function simulation:step()
  for y=0, (world.height-1) do
    for x=0,(world.width-1) do
      local cell = world.world[y][x]
      local check = {
        {x = x + 1, y = y},
        {x = x - 1, y = y},
        {x = x, y = y + 1},
        {x = x, y = y - 1},
        {x = x - 1, y = y + 1},
        {x = x + 1, y = y - 1},
        {x = x + 1, y = y + 1},
        {x = x -1, y = y - 1}
      }
    local n = 0
    for i,v in ipairs(check) do
      if in_range(v.x, 0, world.width-1) and in_range(v.y, 0, world.height-1) then
        if world.world[v.y][v.x].status then
          n = n + 1
        end
      end
    end
    local status = false
    if cell.status then
      if n == 2 or n == 3 then 
        status = true
      else
        status = false
      end
    else
      if n == 3 then 
        status = true
      else
        status = false
      end
    end
    cell.next_status = status
    end  
  end
  self:update_world()
end

function simulation:update_world()
  for y=0, (world.height - 1) do
    for x=0, (world.width - 1) do
      world.world[y][x].status = world.world[y][x].next_status
    end
  end
end

function simulation:toggle()
  self.running = not self.running
end  