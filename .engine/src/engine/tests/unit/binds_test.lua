--------------------------------------------------------------------
-- tests/unit/binds_test.lua : tests UNITAIRES — bindings en touches.
-- Le VRAI chemin de lecture du gameplay est :
--   engine.isBindDown(action) -> backend.isKeyDown(key) -> love.keyboard.isDown
-- Cette batterie couvre chaque étape de la chaîne, chaque direction,
-- et les cas limites (release, touches non bindées, re-binds).
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("core.engine bindings (polling isDown pur)", function()

  local m = mock.new()
  core.attach(m.backend)
  local engine = core.engine

  local function freshBindings()
    engine.bindings = {}
    m.held = {}
  end

  -- --- Le chemin complet, direction par direction ---

  local directions = {
    {key = "z", action = "up"},
    {key = "q", action = "left"},
    {key = "s", action = "down"},
    {key = "d", action = "right"},
    {key = "escape", action = "quit"},
  }

  for _, dir in ipairs(directions) do
    harness.it(dir.action .. " : inactif sans touche, actif si '" .. dir.key .. "' tenu, inactif au relâchement", function()
      freshBindings()
      engine.addBind(dir.key, dir.action)
      -- repos : inactif
      harness.assert_false(engine.isBindDown(dir.action))
      -- touche tenue : actif
      m.held[dir.key] = true
      harness.assert_true(engine.isBindDown(dir.action))
      -- relâchement : inactif
      m.held[dir.key] = nil
      harness.assert_false(engine.isBindDown(dir.action))
    end)
  end

  -- --- Cas limites ---

  harness.it("action sans binding : faux, pas de crash", function()
    freshBindings()
    harness.assert_false(engine.isBindDown("actionInconnue"))
  end)

  harness.it("une autre touche tenue n'active pas le bind", function()
    freshBindings()
    engine.addBind("z", "up")
    m.held["a"] = true -- touche non bindée tenue
    harness.assert_false(engine.isBindDown("up"))
  end)

  harness.it("plusieurs binds actifs simultanément", function()
    freshBindings()
    engine.addBind("z", "up")
    engine.addBind("q", "left")
    m.held["z"] = true
    m.held["q"] = true
    harness.assert_true(engine.isBindDown("up"))
    harness.assert_true(engine.isBindDown("left"))
    m.held["z"] = nil
    harness.assert_false(engine.isBindDown("up"))
    harness.assert_true(engine.isBindDown("left"))
  end)

  harness.it("re-bind : la nouvelle touche remplace l'ancienne", function()
    freshBindings()
    engine.addBind("z", "up")
    engine.addBind("w", "up") -- re-bind
    m.held["z"] = true
    harness.assert_false(engine.isBindDown("up")) -- ancienne touche ignorée
    m.held["w"] = true
    harness.assert_true(engine.isBindDown("up"))
  end)

  harness.it("backend sans isKeyDown : faux sans crash", function()
    local bare = mock.new()
    bare.backend.isKeyDown = nil
    core.attach(bare.backend)
    local savedBindings = engine.bindings
    engine.bindings = {up = "z"}
    harness.assert_false(engine.isBindDown("up"))
    engine.bindings = savedBindings
    core.attach(m.backend)
  end)

  -- --- Bindings manette ---

  harness.it("pad : addPadBind/getPadBindOf + isBindDown via isPadDown", function()
    freshBindings()
    engine.padBindings = {}
    engine.addPadBind("dpup", "up")
    harness.assert_eq(engine.getPadBindOf("up"), "dpup")
    harness.assert_false(engine.isBindDown("up"))
    m.padHeld["dpup"] = true
    harness.assert_true(engine.isBindDown("up"))
    m.padHeld["dpup"] = nil
    harness.assert_false(engine.isBindDown("up"))
  end)

  harness.it("pad : union clavier + manette (l'un ou l'autre active l'action)", function()
    freshBindings()
    engine.padBindings = {}
    engine.addBind("z", "up")
    engine.addPadBind("dpup", "up")
    m.held["z"] = true
    harness.assert_true(engine.isBindDown("up")) -- clavier seul
    m.held["z"] = nil
    m.padHeld["dpup"] = true
    harness.assert_true(engine.isBindDown("up")) -- manette seule
    m.padHeld["dpup"] = nil
    harness.assert_false(engine.isBindDown("up"))
  end)

  harness.it("pad : action sans aucun bind -> faux ; backend sans isPadDown -> faux sans crash", function()
    freshBindings()
    engine.padBindings = {}
    harness.assert_false(engine.isBindDown("up"))
    local bare = mock.new()
    bare.backend.isPadDown = nil
    core.attach(bare.backend)
    engine.padBindings = {up = "dpup"}
    harness.assert_false(engine.isBindDown("up"))
    core.attach(m.backend)
  end)

  harness.it("engine.init remet les bindings manette à zéro", function()
    engine.bindings = {}
    engine.padBindings = {up = "dpup"}
    engine.init(function() end)
    harness.assert_nil(engine.getPadBindOf("up"))
  end)

  harness.it("engine.init remet les bindings à zéro", function()
    engine.bindings = {}
    m.held = {}
    engine.addBind("s", "down")
    m.held["s"] = true
    harness.assert_true(engine.isBindDown("down"))
    engine.init(function() end) -- réinit complète
    m.held["s"] = true
    harness.assert_false(engine.isBindDown("down")) -- bind disparu
  end)
end)

return harness
