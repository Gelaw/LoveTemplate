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
end)

return harness
