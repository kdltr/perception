
graph = {
  effects = {},
  breaking = nil,
  m = 0
}
local ww, wh;


function graph.init()
  ww, wh = love.graphics.getDimensions()
end

function graph.update(m, mchanges)
  graph.m = m
  if mchanges then 
    if graph.breaking ~= 5 then graph.breaking = nil end
    for i, v in pairs(graph.effects) do
      if v.enabled then v.confirmed = true end
    end
  end
end

function graph.draw()
  local list = {}
  for i, v in pairs(graph.effects) do
    if v.enabled and (v.confirmed or graph.breaking) then
      table.insert(list, v)
    end
  end
  table.sort(list, function (a, b)
    return a.order < b.order
  end)
  for _, v in ipairs(list) do
    v.draw(graph.m) 
  end
end

function graph.add(number)
  local e = graph.effects[number]
  if not e then return end
  e.enabled = true
end

function graph.remove(number)
  local e = graph.effects[number]
  if not e then return end
  e.enabled = false
  e.confirmed = false
end

function graph.breakk(i)
  if i == 5 then
    for _, v in pairs(graph.effects) do
      v.enabled = true
    end
  end
  graph.breaking = i
end

function graph.clean()
  for i, v in pairs(graph.effects) do
    v.enabled = false
    v.confirmed = false
  end
end

function graph.vol(number, volume)
  local e = graph.effects[number]
  if not e then return end
  e.volume = volume
end

function graph.angle(number, angle)
  local e = graph.effects[number]
  if not e then return end
  e.angle = angle
end

local e1

local e0
e0 = {
  order = -50,
  enabled = false,
  confirmed = false,
  volume = 1,
  angle = 0,
  draw = function (m)
    local d = e0.volume * wh / 4
    love.graphics.setColor(255, 255, 0)
    love.graphics.setLineWidth(3)
    local cx = ww / 2 + e1.dec * 0.2
    for t = m, m + math.pi * 2, math.pi / 8 do
      local tp = t + math.pi / 32
      if (graph.breaking) then
        love.graphics.circle(
          'line',
          cx + d * math.cos(t),
          wh / 2 + d * math.sin(t),
          math.sin(math.pi * 2 * (m % 1)) * ww / 8
        )
      else
        love.graphics.line(
          cx + d * math.cos(t),
          wh / 2 + d * math.sin(t),
          cx + d * math.cos(tp),
          wh / 2 + d * math.sin(tp)
        )
      end
    end
  end
}
graph.effects[0] = e0

e1 = {
  order = 100,
  enabled = false,
  confirmed = false,
  volume = 1,
  angle = 0,
  r = 0,
  dec = 0,
  draw = function (m)
    e1.r = 20 + e1.volume * wh * 0.2 * 4 * (0.25 - graph.m % 0.25)
    if (graph.breaking ~= 5) then
      e1.dec = math.sqrt(math.abs(e1.angle) / math.pi * 10000) * 2
    else
      e1.dec = 0
    end
    if e1.angle < 0 then e1.dec = -e1.dec end
    for i = 0, 7 do
      local k = i / 7
      if (graph.breaking == 1) then
        love.graphics.setColor(255 * (1 - k), 255 * (1 - k), 255 * k, 255 * (m % 1))
        local a = math.pi * 2 * i / 8
        local dx = math.cos(a) * ww * (1 - (m % 1))
        local dy = math.sin(a) * ww * (1 - (m % 1))
        love.graphics.circle('fill', ww / 2 + e1.dec + dx, wh / 2 + dy, e1.r * (1 - k))
      elseif (graph.breaking == 5) then
        love.graphics.setColor(255 * (1 - k), 255 * (1 - k), 255 * k)
        local a = math.pi * 2 * i / 8
        local dx = math.cos(a) * ww * (math.sin((m % 1) * 2 * math.pi)) / 4
        local dy = math.sin(a) * ww * (math.sin((m % 1) * 2 * math.pi)) / 4
        love.graphics.circle('fill', ww / 2 + dx, wh / 2 + dy, (wh / 8) * (1 - k))
      elseif (graph.breaking) then
        local t = (m % 1) * math.pi
        love.graphics.setColor(
          255 * math.max(t, 1 - k),
          255 * (1 - k),
          255 * math.max(t, k))
        love.graphics.circle('fill', ww / 2 + e1.dec, wh / 2, e1.r * (1 - k))
      else
        love.graphics.setColor(255 * (1 - k), 255 * (1 - k), 255 * k)
        love.graphics.circle('fill', ww / 2 + e1.dec, wh / 2, e1.r * (1 - k))
      end
    end
  end
}
graph.effects[1] = e1

local e2
e2 = {
  order = -100,
  enabled = false,
  confirmed = false,
  volume = 0,
  angle = 0,
  draw = function (m)
    local sqw = ww / 16
    local sqh = wh / 12
    local bw, bh
    local defil = 128
    if graph.breaking == 2 then
      bw = utils.range(sqw / 2, 5, m % 1)
      bh = utils.range(sqh / 2, 5, m % 1)
    elseif graph.breaking then
      defil = -512
      bw = 5
      bh = bw
    else
      bw = 5
      bh = bw
    end
    local beat = math.min((m * 8) % 1, 0.3) * 10
    bw = bw + beat
    bh = bh + beat
    local grey = { 32, 32, 32 }
    local distmax = utils.dist(0, 0, 15, 11)
    for x = 0, 15 do
      for y = 0, 11 do
        love.graphics.setColor(
          utils.hsv(
            (m * defil + 256 * utils.dist(0, 0, x, y) / distmax) % 256,
            255 * e2.volume,
            32 + 223 * e2.volume
          )
        )
        love.graphics.rectangle(
          'fill',
          x * sqw + bw,
          y * sqh + bh,
          sqw - bw * 2,
          sqh - bh * 2
        )
      end
    end
  end
}
graph.effects[2] = e2

local e3
e3 = {
  order = 0,
  enabled = false,
  confirmed = false,
  volume = 1,
  angle = 0,
  oldm = 0,
  parts = {},
  draw = function (m)
    if graph.breaking or math.abs(e3.oldm - m) > (0.6 - e3.volume) / 10 then
      table.insert(e3.parts, {
        angle = math.pi * 2 * math.random(),
        color = { math.random() * 255, math.random() * 255, math.random() * 255, 255 },
        l = 80 + math.random() * (wh / 2 - 80),
        x = ww / 2 + e1.dec
      })
      e3.oldm = m
    end
    love.graphics.setLineWidth(30)
    for i, v in pairs(e3.parts) do
      local btvx, btvy = 0, 0
      if graph.breaking == 5 then
        btvx = wh * math.cos(v.angle) * (1 + math.sin(m * 1.2)) / 5
        btvy = wh * math.sin(v.angle) * (1 + math.sin(m * 1.2)) / 5
        v.x = ww / 2
      elseif graph.breaking then
        btvx = wh * math.cos(v.angle) * (1 - (m % 1))
        btvy = wh * math.sin(v.angle) * (1 - (m % 1))
      end
      love.graphics.setColor(unpack(v.color))
      love.graphics.line(
        btvx + v.x + e1.r * math.cos(v.angle),
        btvy + wh / 2 + e1.r * math.sin(v.angle),
        btvx + v.x + v.l * math.cos(v.angle),
        btvy + wh / 2 + v.l * math.sin(v.angle)
      )
      v.color[4] = v.color[4] / 1.05
      v.angle = v.angle - 0.005
      if v.color[4] < 10 then
        table.remove(e3.parts, i)
      end
    end
  end
}
graph.effects[3] = e3

local e4
e4 = {
  order = 0,
  enabled = false,
  confirmed = false,
  volume = 1,
  angle = 0,
  draw = function (m)
    love.graphics.setColor(0, 0, 255, 192)
    local cx = ww / 2 + e1.dec * 0.1
    local d = e0.volume * wh / 4 + e0.volume * 10
    local dp = 1.25
    local speed = 1 + e4.volume * 4
    if graph.breaking == 4 then
      dp = utils.range(1, dp, m % 1)
    elseif graph.breaking == 5 then
      d = wh / 2 - 40
      speed = math.sin(m) * 4
    end
    for tt = 0, math.pi * 2, math.pi / 8 do
      local t = tt - (m % 1) * math.pi * speed
      local tp = t + math.pi / 16
      local tc = t + math.pi / 32

      love.graphics.polygon(
        'fill',
        cx + d * math.cos(t),
        wh / 2 + d * math.sin(t),
        cx + d * math.cos(tp),
        wh / 2 + d * math.sin(tp),
        cx + d * dp * math.cos(tc),
        wh / 2 + d * dp * math.sin(tc)
      )
    end
  end
}
graph.effects[4] = e4


