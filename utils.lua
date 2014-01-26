
utils = {}

function utils.dist(x1, y1, x2, y2)
  local d1 = x1 - x2
  local d2 = y1 - y2
  return math.sqrt(d1*d1 + d2*d2)
end

function utils.range(a, b, c)
  return a * (1 - c) + b * c
end

function utils.hsv(h, s, v)
    if s <= 0 then return v,v,v end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end



