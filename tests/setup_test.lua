--------------------------------------------------------------------
-- tests/setup_test.lua : test d'INTÉGRATION PROJET.
-- Dépend du VRAI game/setup.lua (contrairement aux tests du moteur,
-- dans .engine/, qui utilisent leurs propres scénarios).
--
-- Si vous remplacez la démo par votre jeu, adaptez ce test à votre
-- setup : c'est lui qui garantit que l'initialisation de VOTRE projet
-- ne casse pas le moteur.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("projet : game/setup.lua (intégration)", function()

  local m = mock.new()
  core.attach(m.backend)

  local ok, setup = pcall(require, "setup")
  harness.it("setup.lua se charge et expose config/run", function()
    harness.assert_true(ok)
    harness.assert_true(type(setup) == "table")
    harness.assert_true(type(setup.config) == "table")
    harness.assert_true(type(setup.run) == "function")
  end)

  harness.it("config : champs fenêtre présents", function()
    harness.assert_true(type(setup.config.title) == "string")
    harness.assert_true(type(setup.config.width) == "number")
    harness.assert_true(type(setup.config.height) == "number")
  end)

  harness.it("setup.run() initialise le moteur sans erreur", function()
    core.engine.init(setup.run)
    harness.assert_true(#core.engine.draws[5] >= 1) -- calque entités
    harness.assert_true(#core.engine.draws[6] >= 1) -- calque particules
    harness.assert_true(#core.engine.draws[9] >= 1) -- calque UI/HUD
    harness.assert_true(core.entities.count() >= 1)
  end)

  harness.it("les bindings du projet sont enregistrés", function()
    harness.assert_eq(core.engine.getBindOf("quit"), "escape")
    harness.assert_eq(core.engine.getBindOf("up"), "z")
    harness.assert_eq(core.engine.getBindOf("left"), "q")
    harness.assert_eq(core.engine.getBindOf("down"), "s")
    harness.assert_eq(core.engine.getBindOf("right"), "d")
  end)

  harness.it("60 frames de boucle complètes sans crash", function()
    local engine = core.engine
    engine.init(setup.run)
    m.reset()
    for i = 1, 60 do
      engine.update(1 / 60)
      m.advance(1 / 60)
      engine.draw()
    end
    harness.assert_true(#m.log > 0)
    harness.assert_true(m.count("rectangle") > 0)
  end)

  harness.it("gameplay : une touche tenue déplace des entités", function()
    local engine = core.engine
    m.held = {}
    engine.init(setup.run)
    local player = core.entities.list[1]
    local y0 = player.y
    m.held["z"] = true -- up, via polling (le vrai chemin de prod)
    for i = 1, 30 do engine.update(1 / 60) end
    harness.assert_true(player.y < y0)
    m.held["z"] = nil
    local y1 = player.y
    for i = 1, 10 do engine.update(1 / 60) end
    harness.assert_approx(player.y, y1, 1e-9)
  end)
end)

return harness
