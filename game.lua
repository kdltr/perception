
game = {
  cap = nil,
  sense = nil,
}

function game.init()
  game.cap = {
    turn = false,
  }
  game.sense = {
    dirbeat = false,
    distkey = false,
    distcoin = false,
  }
end

function game.colls(lvl, p)
  local r = 'abc12345'
  if game.sense.distcoin then r = r .. '$' end
  if lvl.coins == 0 and (game.sense.distkey or not lvl.config.needdistkey) then r = r .. 'k' end
  if p.hasKey then r = r .. 'n' end
  return r
end

function game.update(dt)
  p.dir = p.dir + v.x * dt * math.pi / 2;
  local npx = p.x - v.y * math.cos(p.dir) * dt * 4;
  local npy = p.y - v.y * math.sin(p.dir) * dt * 4;

  local r = level.move(lvl, p.x, p.y, npx, npy, game.colls(lvl, p))

  if (r.collect == 'a') then
    game.cap.turn = true
    sound.breakk(0)
  elseif r.collect == '1' then
    game.sense.dirbeat = true
    sound.add(1)
    sound.breakk(1)
  elseif r.collect == '2' then
    game.sense.distkey = true
    sound.add(2)
    sound.breakk(2)
  elseif r.collect == '3' then
    game.sense.distcoin = true
    sound.add(4)
    sound.breakk(4)
  elseif r.collect == 'k' then
    p.hasKey = true
    sound.add(3);
    sound.breakk(3);
  elseif r.collect == '$' then
    sound.playOnceNow('coin')
    lvl.coins = lvl.coins - 1
    if lvl.coins == 0 then
      sound.remove(4)
      game.sense.distcoin = false
    end
    local removable = nil
    for i, e in ipairs(lvl.coinspos) do
      if e.x == math.floor(p.x) and e.y == math.floor(p.y) then
        removable = i
      end
    end
    if removable then
      table.remove(lvl.coinspos, removable)
    end
  elseif r.collect == 'n' then
    playing = false
    if levelnum == 3 then finished = true end
  end

  p.x = r.npx;
  p.y = r.npy;

  local angle = 0
  local dwall = level.ray(lvl, p.x, p.y, p.dir)
  if game.sense.dirbeat and dwall < 2 then
    dwall, angle = level.rays(lvl, p.x, p.y, p.dir)
  end

  sound.angle(0, angle)
  sound.angle(1, angle)
  sound.vol(0, (1 + math.min(dwall, 5)) / 6)
  sound.vol(1, (1 + math.min(dwall, 5)) / 6)
  gdebug.angle = angle

  if p.hasKey then
    sound.vol(3, 1 / (1 + utils.dist(p.x, p.y, lvl.config.nx, lvl.config.ny)))
  end

  if game.sense.distkey and not p.hasKey then
    sound.vol(2, 1 / (1 + utils.dist(p.x, p.y, lvl.config.kx, lvl.config.ky)))
  end

  if game.sense.distcoin then
    local dmin = 1000;
    for _, e in ipairs(lvl.coinspos) do
      local d = utils.dist(p.x, p.y, e.x, e.y)
      if d < dmin then dmin = d end
    end
    sound.vol(4, 1 / (1 + dmin));
  end

end

