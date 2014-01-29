level = {}

function level.load(zone, level)
  local lvl = {}
  local name = string.format("levels/z%02dl%02d.txt", zone, level)
  local it = love.filesystem.lines(name);
  local confLine = it();
  local config = {
    pdir = tonumber(confLine:sub(1, 1)),
    reset = confLine:sub(2, 2) == 'r',
    needdistkey = false,
    hascoins = false,
  }
  local lineNumber = 0
  local lvlline = {}
  local coins = 0
  local coinspos = {}
  for line in it do
    lineNumber = lineNumber + 1
    lvlline = {}
    for i = 1, line:len() do
      c = line:sub(i, i)
      if c == 'p' then
        config.px = i + 0.5
        config.py = lineNumber + 0.5
        c = ' '
      elseif c == 'n' then
        config.nx = i + 0.5
        config.ny = lineNumber + 0.5
      elseif c == 'k' then
        config.kx = i + 0.5
        config.ky = lineNumber + 0.5
      elseif c == '$' then
        coins = coins + 1
        config.hascoins = true
        table.insert(coinspos, { x = i, y = lineNumber })
      elseif c == '2' then
        config.needdistkey = true
      end
      table.insert(lvlline, c)
    end
    table.insert(lvl, lvlline)
  end
  return { config = config, coins = coins, map = lvl, coinspos = coinspos }
end

function level.move(lvl, ox, oy, dx, dy, colls)
  local r = {
    collect = nil,
    npx = dx,
    npy = dy,
  }

  local onpos = level.bl(lvl, ox, oy)
  if string.find(colls, onpos) then
    r.collect = onpos
    level.bl(lvl, ox, oy, ' ')
  end

  local ondt;
  ondt = level.bl(lvl, ox, dy);
  if ondt == 'x' then r.npy = oy end
  ondt = level.bl(lvl, dx, oy);
  if ondt == 'x' then r.npx = ox end

  return r
end

function level.bl(lvl, x, y, replace)
  local line = lvl.map[math.floor(y)]
  if not line then return 'x' end
  local value = line[math.floor(x)]
  if not value then return 'x' end

  if replace then
    line[math.floor(x)] = replace
    return replace
  else
    return value
  end
end

function level.ray(lvl, x, y, dir)
  local max = 8
  for d = 0, max, 0.05 do
    local e = level.bl(lvl, x + math.cos(dir) * d, y + math.sin(dir) * d)
    if e == 'x' then
      return d
    end
  end
  return max
end

function level.rays(lvl, x, y, dir)
  local suma = 0
  local sumd = 0
  for a = -math.pi / 2, math.pi / 2, 0.2 do
    local d = level.ray(lvl, x, y, dir + a)
    suma = suma + a * d
    sumd = sumd + d
  end
  local gooddir = suma / sumd
  return level.ray(lvl, x, y, dir + gooddir), gooddir
end

