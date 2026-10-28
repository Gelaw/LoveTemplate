--------------------------------------------------------------------
-- domain/geometry.lua : géométrie pure — hitbox, intersections.
-- Zéro dépendance LÖVE. Utilisé par core/entities pour les collisions.
--------------------------------------------------------------------
local geometry = {}

-- Points (coins) de la hitbox d'une entité en coordonnées globales.
-- L'entité doit fournir x, y et w/width + h/height ; angle optionnel.
function geometry.getPointsGlobalCoor(entity)
  local cos, sin = math.cos, math.sin
  local x, y, a = entity.x, entity.y, -(entity.angle or 0)
  local w, h = (entity.w or entity.width), (entity.h or entity.height)
  local points = {}
  if w and h then
    local corners = {{.5, .5}, {.5, -.5}, {-.5, -.5}, {-.5, .5}}
    for i = 1, 4 do
      local c = corners[i]
      table.insert(points, {
        x = x + c[1] * w * cos(a) + c[2] * h * sin(a),
        y = y - c[1] * w * sin(a) + c[2] * h * cos(a)
      })
    end
  end
  return points
end

-- Deux segments (donnés en points {x,y}) s'intersectent-ils ?
function geometry.checkIntersect(l1p1, l1p2, l2p1, l2p2)
  local function checkDir(pt1, pt2, pt3)
    return geometry.sign(((pt2.x - pt1.x) * (pt3.y - pt1.y))
      - ((pt3.x - pt1.x) * (pt2.y - pt1.y)))
  end
  return (checkDir(l1p1, l1p2, l2p1) ~= checkDir(l1p1, l1p2, l2p2))
    and (checkDir(l2p1, l2p2, l1p1) ~= checkDir(l2p1, l2p2, l1p2))
end

-- Intersection de deux lignes (ou segments si seg1/seg2) données en
-- coordonnées numériques. Retourne x, y ou false, message.
function geometry.findIntersect(l1p1x, l1p1y, l1p2x, l1p2y, l2p1x, l2p1y, l2p2x, l2p2y, seg1, seg2)
  local a1, b1 = l1p2y - l1p1y, l1p1x - l1p2x
  local a2, b2 = l2p2y - l2p1y, l2p1x - l2p2x
  local c1, c2 = a1 * l1p1x + b1 * l1p1y, a2 * l2p1x + b2 * l2p1y
  local det = a1 * b2 - a2 * b1
  if det == 0 then return false, "The lines are parallel." end
  local x = (b2 * c1 - b1 * c2) / det
  local y = (a1 * c2 - a2 * c1) / det
  if seg1 or seg2 then
    local min, max = math.min, math.max
    if seg1 and not (min(l1p1x, l1p2x) <= x and x <= max(l1p1x, l1p2x)
      and min(l1p1y, l1p2y) <= y and y <= max(l1p1y, l1p2y)) or
      seg2 and not (min(l2p1x, l2p2x) <= x and x <= max(l2p1x, l2p2x)
      and min(l2p1y, l2p2y) <= y and y <= max(l2p1y, l2p2y)) then
      return false, "The lines don't intersect."
    end
  end
  return x, y
end

-- Point le plus proche de (a,b) sur la ligne (x1,y1)-(x2,y2).
function geometry.get_closest_point(x1, y1, x2, y2, a, b)
  if x1 == x2 then return {x1, b} end
  if y1 == y2 then return {a, y1} end
  local m1 = (y2 - y1) / (x2 - x1)
  local m2 = -1 / m1
  local x = (m1 * x1 - m2 * a + b - y1) / (m1 - m2)
  local y = m2 * (x - a) + b
  return {x, y}
end

-- Alias internes utilisés par les fonctions du module.
geometry.sign = function(n) return n > 0 and 1 or n < 0 and -1 or 0 end

-- Détermine si deux entités (hitbox rectangulaires, angle quelconque)
-- entrent en collision : les segments de leurs hitbox s'intersectent-ils ?
-- Limitation connue : pas de détection quand une entité est entièrement
-- contenue dans une autre.
function geometry.entitiesCollide(entity1, entity2)
  if not (entity1.collide and entity2.collide) then return false end
  local points1 = geometry.getPointsGlobalCoor(entity1)
  local points2 = geometry.getPointsGlobalCoor(entity2)
  if #points1 == 0 or #points2 == 0 then return false end
  for p1 = 1, #points1 do
    for p2 = 1, #points2 do
      if geometry.checkIntersect(
        points1[p1], points1[p1 % #points1 + 1],
        points2[p2], points2[p2 % #points2 + 1]) then
        return true
      end
    end
  end
  return false
end

return geometry
