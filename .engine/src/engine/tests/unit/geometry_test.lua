--------------------------------------------------------------------
-- tests/unit/geometry_test.lua : tests UNITAIRES — géométrie pure.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")

harness.describe("domain.geometry", function()

  harness.it("checkIntersect détecte une croix", function()
    local g = domain.geometry
    harness.assert_true(g.checkIntersect({x=0,y=0}, {x=10,y=10}, {x=0,y=10}, {x=10,y=0}))
  end)

  harness.it("checkIntersect rejette deux segments parallèles", function()
    local g = domain.geometry
    harness.assert_false(g.checkIntersect({x=0,y=0}, {x=10,y=0}, {x=0,y=5}, {x=10,y=5}))
  end)

  harness.it("checkIntersect rejette des segments disjoints", function()
    local g = domain.geometry
    harness.assert_false(g.checkIntersect({x=0,y=0}, {x=1,y=1}, {x=5,y=0}, {x=6,y=1}))
  end)

  harness.it("findIntersect calcule le point de croisement", function()
    local g = domain.geometry
    local x, y = g.findIntersect(0, 0, 10, 10, 0, 10, 10, 0)
    harness.assert_approx(x, 5)
    harness.assert_approx(y, 5)
  end)

  harness.it("findIntersect signale les parallèles", function()
    local g = domain.geometry
    local ok, msg = g.findIntersect(0, 0, 10, 0, 0, 5, 10, 5)
    harness.assert_false(ok)
    harness.assert_eq(msg, "The lines are parallel.")
  end)

  harness.it("findIntersect en mode segment rejette hors-segment", function()
    local g = domain.geometry
    -- lignes qui se croisent mais au-delà du segment 1
    local ok = g.findIntersect(0, 0, 1, 1, 5, 0, 5, 10, true, false)
    harness.assert_false(ok)
  end)

  harness.it("get_closest_point projette sur la ligne", function()
    local g = domain.geometry.get_closest_point
    local p = g(0, 0, 10, 0, 5, 7) -- ligne horizontale, point au-dessus
    harness.assert_eq(p[1], 5)
    harness.assert_eq(p[2], 0)
  end)

  harness.it("getPointsGlobalCoor : rectangle droit, 4 coins", function()
    local g = domain.geometry
    local pts = g.getPointsGlobalCoor({x = 100, y = 50, w = 10, h = 20})
    harness.assert_eq(#pts, 4)
  end)

  harness.it("getPointsGlobalCoor : coins exacts sans rotation", function()
    local g = domain.geometry
    local pts = g.getPointsGlobalCoor({x = 0, y = 0, w = 2, h = 2})
    -- coins à ±1 en x et y (ordre : (+,+), (+,-), (-,-), (-,+))
    harness.assert_approx(pts[1].x, 1);  harness.assert_approx(pts[1].y, 1)
    harness.assert_approx(pts[3].x, -1); harness.assert_approx(pts[3].y, -1)
  end)

  harness.it("entitiesCollide : deux rectangles qui se chevauchent", function()
    local g = domain.geometry
    local a = {x = 0, y = 0, w = 40, h = 40, collide = function() end}
    local b = {x = 5, y = 5, w = 40, h = 40, collide = function() end}
    harness.assert_true(g.entitiesCollide(a, b))
  end)

  harness.it("entitiesCollide : rectangles éloignés", function()
    local g = domain.geometry
    local a = {x = 0, y = 0, w = 10, h = 10, collide = function() end}
    local b = {x = 500, y = 500, w = 10, h = 10, collide = function() end}
    harness.assert_false(g.entitiesCollide(a, b))
  end)

  harness.it("entitiesCollide : sans champ collide -> faux", function()
    local g = domain.geometry
    harness.assert_false(g.entitiesCollide({x=0,y=0,w=10,h=10}, {x=1,y=1,w=10,h=10}))
  end)

  harness.it("entitiesCollide : entité contenue non détectée (limite connue)", function()
    local g = domain.geometry
    -- petite boîte entièrement dans la grande : segments ne se croisent pas
    local big = {x = 0, y = 0, w = 100, h = 100, collide = function() end}
    local small = {x = 0, y = 0, w = 10, h = 10, collide = function() end}
    harness.assert_false(g.entitiesCollide(big, small))
  end)
end)

return harness
