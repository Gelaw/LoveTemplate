--------------------------------------------------------------------
-- tests/unit/binds_test.lua : tests UNITAIRES — bindings en scancodes,
-- suivi événementiel (isBindDown) et reset à l'init.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")

harness.describe("core.engine bindings (scancodes + événements)", function()

  local m = mock.new()
  core.attach(m.backend)
  local engine = core.engine

  harness.it("onBindPressed/Released : suivi événementiel", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("w", "up")
    harness.assert_false(engine.isBindDown("up"))
    engine.onBindPressed("w")
    harness.assert_true(engine.isBindDown("up"))
    engine.onBindReleased("w")
    harness.assert_false(engine.isBindDown("up"))
  end)

  harness.it("action sans binding : faux, pas de crash", function()
    engine.bindings = {}
    engine.bindsDown = {}
    harness.assert_false(engine.isBindDown("actionInconnue"))
  end)

  harness.it("le suivi survit à plusieurs pressions", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("d", "right")
    engine.onBindPressed("d")
    engine.onBindPressed("d") -- double event (key repeat) : reste actif
    harness.assert_true(engine.isBindDown("right"))
    engine.onBindReleased("d")
    harness.assert_false(engine.isBindDown("right"))
  end)

  harness.it("plusieurs binds simultanés", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("w", "up")
    engine.addBind("a", "left")
    engine.onBindPressed("w")
    engine.onBindPressed("a")
    harness.assert_true(engine.isBindDown("up"))
    harness.assert_true(engine.isBindDown("left"))
    engine.onBindReleased("w")
    harness.assert_false(engine.isBindDown("up"))
    harness.assert_true(engine.isBindDown("left"))
  end)

  harness.it("engine.init remet bindsDown à zéro", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("s", "down")
    engine.onBindPressed("s")
    harness.assert_true(engine.isBindDown("down"))
    engine.init(function() end) -- réinit complète
    harness.assert_false(engine.isBindDown("down"))
  end)

  harness.it("3e source : fallback isBindKeyDown (layout local)", function()
    -- Simule le web AZERTY : scancodes dérivés du caractère produit,
    -- donc isScancodeDown("w") est faux, mais la touche localisée
    -- correspondant au bind physique répond (isBindKeyDown).
    local m2 = mock.new()
    m2.backend.isScancodeDown = function(sc) return false end
    m2.backend.isBindKeyDown = function(sc)
      -- mapping scancode physique -> touche AZERTY effective
      local azerty = { w = "z", a = "q", s = "s", d = "d" }
      return azerty[sc] == "z" -- seule la touche gravée Z est tenue
    end
    core.attach(m2.backend)
    local engine = core.engine
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("w", "up")
    engine.addBind("a", "left")
    harness.assert_true(engine.isBindDown("up"))    -- via fallback layout
    harness.assert_false(engine.isBindDown("left")) -- q non tenue
  end)

  harness.it("union : le polling scancode seul suffit aussi", function()
    local m3 = mock.new()
    m3.backend.isScancodeDown = function(sc) return sc == "d" end
    core.attach(m3.backend)
    local engine = core.engine
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("d", "right")
    harness.assert_true(engine.isBindDown("right"))
  end)
end)

return harness
