--------------------------------------------------------------------
-- tests/unit/mathx_test.lua : tests UNITAIRES — couche domain pure.
-- Aucune dépendance LÖVE, exécutable avec du Lua nu.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")

harness.describe("domain.mathx", function()

  harness.it("clamp borne aux deux extrémités", function()
    local m = domain.mathx
    harness.assert_eq(m.clamp(0, -5, 5), 0)
    harness.assert_eq(m.clamp(-10, -5, 5), -5)
    harness.assert_eq(m.clamp(10, -5, 5), 5)
  end)

  harness.it("dist calcule la distance euclidienne", function()
    local m = domain.mathx
    harness.assert_eq(m.dist(0, 0, 3, 4), 5)
    harness.assert_eq(m.dist(1, 1, 1, 1), 0)
    harness.assert_approx(m.dist(0, 0, 1, 1), math.sqrt(2))
  end)

  harness.it("angle entre deux points", function()
    local m = domain.mathx
    harness.assert_approx(m.angle(0, 0, 1, 0), 0)
    harness.assert_approx(m.angle(0, 0, 0, 1), math.pi / 2)
    harness.assert_approx(m.angle(0, 0, -1, 0), math.pi)
  end)

  harness.it("angleDiff retourne le plus court écart", function()
    local m = domain.mathx
    harness.assert_approx(m.angleDiff(0, math.pi), math.pi)
    harness.assert_approx(m.angleDiff(0, 2 * math.pi), 0)
    -- un tour complet moins un chouïa doit rester petit
    harness.assert_approx(m.angleDiff(0, 2 * math.pi - 0.1), 0.1, 1e-6)
  end)

  harness.it("lerp interpole linéairement", function()
    local m = domain.mathx
    harness.assert_eq(m.lerp(0, 10, 0), 0)
    harness.assert_eq(m.lerp(0, 10, 0.5), 5)
    harness.assert_eq(m.lerp(0, 10, 1), 10)
    harness.assert_eq(m.lerp2(0, 10, 0.25), 2.5)
  end)

  harness.it("cerp vaut a en 0 et b en 1", function()
    local m = domain.mathx
    harness.assert_approx(m.cerp(0, 10, 0), 0)
    harness.assert_approx(m.cerp(0, 10, 1), 10)
  end)

  harness.it("normalize gère vecteur nul et vecteur unitaire", function()
    local m = domain.mathx
    local x, y, l = m.normalize(0, 0)
    harness.assert_eq(x, 0)
    harness.assert_eq(y, 0)
    harness.assert_eq(l, 0)
    local x, y, l = m.normalize(3, 4)
    harness.assert_approx(x, 0.6)
    harness.assert_approx(y, 0.8)
    harness.assert_approx(l, 5)
  end)

  harness.it("round arrondit au deci près", function()
    local m = domain.mathx
    harness.assert_eq(m.round(2.5), 3)
    harness.assert_eq(m.round(2.4), 2)
    harness.assert_eq(m.round(3.14159, 2), 3.14)
  end)

  harness.it("multiple arrondit au multiple de size", function()
    local m = domain.mathx
    harness.assert_eq(m.multiple(12, 10), 10)
    harness.assert_eq(m.multiple(15, 10), 20)
    harness.assert_eq(m.multiple(7), 10)
  end)

  harness.it("sign donne -1/0/1", function()
    local m = domain.mathx
    harness.assert_eq(m.sign(3), 1)
    harness.assert_eq(m.sign(-3), -1)
    harness.assert_eq(m.sign(0), 0)
  end)

  harness.it("prandom via RNG déterministe reste borné", function()
    local mathx = domain.mathx
    local restore = require("engine.tests.lib.deterministic").install(42)
    for i = 1, 50 do
      local v = mathx.prandom(-10, 10)
      harness.assert_true(v >= -10 and v <= 10)
    end
    restore()
  end)

  harness.it("rsign via RNG déterministe donne ±1", function()
    local mathx = domain.mathx
    local restore = require("engine.tests.lib.deterministic").install(7)
    local saw = {}
    for i = 1, 20 do
      local v = mathx.rsign()
      harness.assert_true(v == 1 or v == -1)
      saw[v] = true
    end
    restore()
  end)

  harness.it("averageAngles moyenne des angles", function()
    local m = domain.mathx
    harness.assert_approx(m.averageAngles(0, math.pi), math.pi / 2, 1e-6)
    harness.assert_approx(m.averageAngles(0), 0)
  end)
end)

return harness
