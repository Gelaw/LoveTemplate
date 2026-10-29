--------------------------------------------------------------------
-- tests/unit/binds_test.lua : tests UNITAIRES — bindings en touches
-- (lettres produites) : suivi événementiel (isBindDown) et reset.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")

harness.describe("core.engine bindings (touches + événements)", function()

  local m = mock.new()
  core.attach(m.backend)
  local engine = core.engine

  harness.it("onBindPressed/Released : suivi événementiel", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("z", "up")
    harness.assert_false(engine.isBindDown("up"))
    engine.onBindPressed("z")
    harness.assert_true(engine.isBindDown("up"))
    engine.onBindReleased("z")
    harness.assert_false(engine.isBindDown("up"))
  end)

  harness.it("action sans binding : faux, pas de crash", function()
    engine.bindings = {}
    engine.bindsDown = {}
    harness.assert_false(engine.isBindDown("actionInconnue"))
  end)

  harness.it("double pression (key repeat) : reste actif", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("d", "right")
    engine.onBindPressed("d")
    engine.onBindPressed("d")
    harness.assert_true(engine.isBindDown("right"))
    engine.onBindReleased("d")
    harness.assert_false(engine.isBindDown("right"))
  end)

  harness.it("plusieurs binds simultanés", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("z", "up")
    engine.addBind("q", "left")
    engine.onBindPressed("z")
    engine.onBindPressed("q")
    harness.assert_true(engine.isBindDown("up"))
    harness.assert_true(engine.isBindDown("left"))
    engine.onBindReleased("z")
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

  harness.it("union : le polling isDown seul suffit aussi", function()
    local m2 = mock.new()
    m2.backend.isKeyDown = function(key) return key == "d" end
    core.attach(m2.backend)
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("d", "right")
    harness.assert_true(engine.isBindDown("right"))
  end)

  harness.it("quit : keypressed sur la touche bindée", function()
    engine.bindings = {}
    engine.bindsDown = {}
    engine.addBind("escape", "quit")
    -- (le quit réel passe par l'adapter ; ici on teste le suivi)
    engine.onBindPressed("escape")
    harness.assert_true(engine.isBindDown("quit"))
  end)
end)

return harness
