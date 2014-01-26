
sound = {
  measureLength = 1.92,
  numberOfMeasuresPerSample = 2,
  started = false,
  measureTime = 0,
  measure = nil,
  dobreakk = nil,
  loops = {},
}

function sound.start()
  love.audio.setDistanceModel('linear')
  sound.started = true
end

function sound.stop()
  for _, l in pairs(sound.loops) do
    l.loop:stop()
    l.breakk:stop()
  end
  sound.started = false
  sound.dobreakk = nil
  sound.measure = nil
  sound.measureTime = 0
end

function sound.clean()
  sound.loops = {}
  graph.clean()
end

function sound.update(dt)
  if not sound.started then return end

  local mchanges;
  newMeasureTime = (sound.measureTime + dt) % sound.measureLength
  if not sound.measure or newMeasureTime < sound.measureTime then
    mchanges = true
    if not sound.measure then
      sound.measure = 0
    else
      sound.measure = sound.measure + 1
    end
    replay = sound.measure % sound.numberOfMeasuresPerSample
    if sound.dobreakk then
      mchanges = false
      sound.measure = sound.numberOfMeasuresPerSample * math.floor(sound.measure / sound.numberOfMeasuresPerSample) - 1
      local brk, brki = nil, nil
      for i, loop in pairs(sound.loops) do
        loop.loop:stop()
        if i == sound.dobreakk then
          brk = loop
          brki = i
        end
      end
      if brk then
        brk.breakk:play()
        graph.breakk(brki)
      end
      sound.dobreakk = false
    elseif replay == 0 then
      for _, loop in pairs(sound.loops) do
        loop.loop:rewind()
        loop.loop:play()
      end
    end
  end
  sound.measureTime = newMeasureTime

  graph.update(sound.measure + sound.measureTime / sound.measureLength, mchanges)
end

function sound.add(number)
  s = {
    loop = love.audio.newSource('sounds/loop' .. number .. '.ogg'),
    breakk = love.audio.newSource('sounds/break' .. number .. '.ogg'),
    dist = 0,
    angle = 0,
  }
  s.breakk:setVolume(0.5)
  s.loop:setAttenuationDistances(0, 2)
  sound.loops[number] = s

  graph.add(number)
end

function sound.voldec(number, value)
  local l = sound.loops[number]
  if l then
    l.dist = l.dist - value
    sound.updateSound(l)
  end
end

function sound.vol(number, volume)
  local l = sound.loops[number]
  if l then
    l.dist = volume
    sound.updateSound(l)
  end
  graph.vol(number, volume)
end

function sound.angle(number, angle)
  local l = sound.loops[number]
  if l then
    l.angle = angle
    sound.updateSound(l)
  end
  graph.angle(number, angle)
end

function sound.updateSound(l)
  local d = 2 - l.dist;
  l.loop:setPosition(d * math.sin(l.angle), 0, d * math.cos(l.angle));
end

function sound.breakk(number)
  sound.dobreakk = number
end

function sound.remove(number)
  graph.remove(number)
  local l = sound.loops[number]
  if not l then return end
  l.loop:stop()
  l.breakk:stop()
  sound.loops[number] = nil
end

function sound.playOnceNow(name) -- joue tout de suite
  local s = love.audio.newSource('sounds/' .. name .. '.ogg', 'static')
  s:setVolume(0.4)
  s:play()
end

