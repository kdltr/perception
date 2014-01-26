
gdebug = {
  angle = 0
}

function gdebug.draw()
  for y = 1, #lvl.map do
    for x = 1, #(lvl.map[y]) do
      if lvl.map[y][x] ~= ' ' then
        if lvl.map[y][x] == 'x' then
          love.graphics.setColor(128, 128, 128, 128)
        else
          love.graphics.setColor(128, 0, 0, 128)
        end
        love.graphics.rectangle('fill', x*15, y*15, 15, 15);
      end
      love.graphics.setColor(0, 0, 0, 128)
      love.graphics.print(lvl.map[y][x], x * 15 + 2, y * 15 + 2);
    end
  end

  love.graphics.setLineWidth(1)
  love.graphics.setColor(64, 255, 64, 128)
  love.graphics.circle('fill', 15*p.x, 15*p.y, 3)
  love.graphics.line(15*p.x, 15*p.y, 15*p.x+math.cos(p.dir)*8, 15*p.y+math.sin(p.dir)*8)
  love.graphics.setColor(255, 64, 64, 128)
  love.graphics.line(15*p.x, 15*p.y, 15*p.x+math.cos(p.dir+gdebug.angle)*18, 15*p.y+math.sin(p.dir+gdebug.angle)*18)
end
