--------------------------------------------------------------------
-- domain/mathx.lua : extensions mathématiques pures.
-- Aucune dépendance LÖVE ; utilisable avec n'importe quel RNG
-- (rng() est injecté, par défaut math.random de la plateforme).
-- Source historique : https://love2d.org/wiki/General_math
--------------------------------------------------------------------
local mathx = {}

-- RNG injecté : toute fonction aléatoire passe par ici -> testabilité
-- (les tests branchent un RNG déterministe, seedé).
mathx.rng = function(...) return math.random(...) end

-- Averages an arbitrary number of angles (in radians).
function mathx.averageAngles(...)
  local x, y = 0, 0
  for i = 1, select('#', ...) do
    local a = select(i, ...)
    x, y = x + math.cos(a), y + math.sin(a)
  end
  return math.atan2(y, x)
end

-- Distance between two 2D points.
function mathx.dist(x1, y1, x2, y2)
  return ((x2 - x1)^2 + (y2 - y1)^2)^0.5
end

-- Shortest absolute difference between two angles.
function mathx.angleDiff(a1, a2)
  return math.pi - math.abs(math.abs(a1 - a2) - math.pi)
end

-- Angle between two points.
function mathx.angle(x1, y1, x2, y2)
  return math.atan2(y2 - y1, x2 - x1)
end

-- Closest multiple of 'size' (default 10).
function mathx.multiple(n, size)
  size = size or 10
  return mathx.round(n / size) * size
end

-- Clamp a number to within a certain range.
function mathx.clamp(low, n, high)
  return math.min(math.max(low, n), high)
end

-- Linear interpolation between two numbers.
function mathx.lerp(a, b, t) return (1 - t) * a + t * b end
function mathx.lerp2(a, b, t) return a + (b - a) * t end

-- Cosine interpolation between two numbers.
function mathx.cerp(a, b, t)
  local f = (1 - math.cos(t * math.pi)) * .5
  return a * (1 - f) + b * f
end

-- Normalize two numbers. Returns x, y and the initial length.
function mathx.normalize(x, y)
  local l = (x * x + y * y)^.5
  if l == 0 then return 0, 0, 0 end
  return x / l, y / l, l
end

-- 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function mathx.round(n, deci)
  deci = 10^(deci or 0)
  return math.floor(n * deci + .5) / deci
end

-- Randomly returns either -1 or 1 (via le RNG injecté).
function mathx.rsign()
  return mathx.rng(2) == 2 and 1 or -1
end

-- 1 if positive, -1 if negative, 0 if zero.
function mathx.sign(n)
  return n > 0 and 1 or n < 0 and -1 or 0
end

-- Precise random decimal between min and max (via le RNG injecté).
function mathx.prandom(min, max)
  return mathx.rng() * (max - min) + min
end

return mathx
