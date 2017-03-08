require('gdebug')
require('utils')
require('level')
require('sound')
require('game')
require('graph')

p = {}
p.x = 0
p.y = 0
p.dir = 0
p.hasKey = false

v = {}
v.x = 0
v.y = 0

playing = false
finished = false
levelnum = 1

winTimer = 0
finishTimer = 0

collectables = 'a';
lvl = nil

debugmode = false

function love.load()
  graph.init()
  loadLevel(1, levelnum)
  playing = true
end

function loadLevel(z, l)
  lvl = level.load(1, l)
  if lvl.config.reset then
    game.init()
    sound.stop()
    sound.clean()
    sound.add(0)
  end
  p.x = lvl.config.px
  p.y = lvl.config.py
  p.dir = lvl.config.pdir * math.pi / 2
  p.hasKey = false
  sound.start()
end

function love.gamepadpressed(j, b)
  if b == 'dpup' then
    v.y = -1
  elseif game.cap.turn and b == 'dpleft' then
    v.x = -1
  elseif game.cap.turn and b == 'dpright' then
    v.x = 1
  elseif b == 'a' then
    --TODO sound.playOnceNow('bwap')
  end
end

function love.gamepadreleased(j, b)
  if (b == 'dpup' or b == 'dpdown') then
    v.y = 0
  elseif b == 'dpleft' or b == 'dpright' then
    v.x = 0
  end
end

function love.keypressed(key)
  if key == 'd' then debugmode = not debugmode end
  if key == 'q' then love.event.quit() end
  if key == 'f' then love.window.setFullscreen(not love.window.getFullscreen) end
  if key == 'up' then
    v.y = -1
  elseif game.cap.turn and key == 'left' then
    v.x = -1
  elseif game.cap.turn and key == 'right' then
    v.x = 1
  end
end

function love.keyreleased(key)
  if (key == 'up' or key == 'down') then
    v.y = 0
  elseif key == 'left' or key == 'right' then
    v.x = 0
  end
end

function love.update(dt)
  if playing then
    game.update(dt)
  elseif finished then
    if finishTimer == 0 then
      sound.playOnceNow('win')
      sound.clean()
      sound.add(5)
      sound.breakk(5)
    end
    if finishTimer > 4 + 13 + 1  then
      love.event.quit()
    end
    finishTimer = finishTimer + dt
  else
    if winTimer == 0 then
      sound.stop()
      sound.remove(3)
      sound.playOnceNow('win')
      winTimer = winTimer + dt
    elseif winTimer > 3 then
      levelnum = levelnum + 1
      loadLevel(1, levelnum)
      playing = true
      winTimer = 0
    else
      winTimer = winTimer + dt
    end
  end
  sound.update(dt)
end

function love.draw()
  graph.draw()

  if finishTimer > 12 then
    love.graphics.setColor(0, 0, 0, 255 * math.max((finishTimer - 12) / 6, 0))
    love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
  end

  if debugmode then gdebug.draw() end
end

