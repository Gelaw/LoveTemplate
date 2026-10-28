--------------------------------------------------------------------
-- tests/integration/boot_test.lua : tests d'INTÉGRATION.
-- On boote le vrai engine (le même que la prod) mais avec un backend
-- mock : on vérifie l'assemblage complet (init -> setup -> boucle ->
-- draw), la cohérence caméra/entités/particules, et les interactions
-- croisées entre sous-systèmes.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")
local deterministic = require("tests.lib.deterministic")

harness.describe("intégration : boot complet + boucle", function()

  local m = mock.new({width = 800, height = 600})
  core.attach(m.backend)
  local engine = core.engine
  local restoreRng = deterministic.install(42)

  local booted = false
  engine.init(function()
    booted = true
    engine.addBind("w", "up")
    core.entities.add({x = 0, y = 0, w = 20, h = 20, shape = "rectangle"})
    core.entities.add({x = 10, y = 10, w = 20, h = 20, shape = "rectangle",
      collide = function() end})
    core.ui.add({
      x = 10, y = 10, w = 100, h = 30,
      draw = function(self) end,
      onClick = function(self) end,
    })
  end)

  harness.it("init : projectSetup appelé, canvas dimensionné", function()
    harness.assert_true(booted)
    harness.assert_eq(engine.width, 800)
    harness.assert_eq(engine.height, 600)
  end)

  harness.it("init : calques entités/particules/UI enregistrés", function()
    harness.assert_true(#engine.draws[5] >= 1) -- entités
    harness.assert_true(#engine.draws[6] >= 1) -- particules
    harness.assert_true(#engine.draws[9] >= 1) -- UI
  end)

  harness.it("60 frames : pas de crash, opérations graphiques émises", function()
    m.reset()
    for i = 1, 60 do
      engine.update(1 / 60)
      m.advance(1 / 60)
      engine.draw()
    end
    harness.assert_true(#m.log > 0)
    harness.assert_true(m.count("push") > 0)
    harness.assert_true(m.count("rectangle") > 0)
  end)

  harness.it("intégration collisions : callbacks déclenchés dans la boucle", function()
    local hit = false
    core.entities.clear()
    core.entities.add({x = 0, y = 0, w = 30, h = 30,
      collide = function(self, o) hit = true end})
    core.entities.add({x = 5, y = 5, w = 30, h = 30,
      collide = function(self, o) hit = true end})
    engine.update(1 / 60)
    harness.assert_true(hit)
  end)

  harness.it("intégration particules + update : naissance et mort", function()
    core.particles.clear()
    core.particles.add({x = 0, y = 0, nudge = 5, size = 2, timeLeft = 0.1,
      color = {1, 1, 1}})
    harness.assert_eq(core.particles.count(), 1)
    engine.update(0.05)
    harness.assert_eq(core.particles.count(), 1)
    engine.update(0.1)
    harness.assert_eq(core.particles.count(), 0)
  end)

  harness.it("intégration UI : clic consommé dans la boucle", function()
    local clicked = false
    core.ui.clear()
    core.ui.add({
      x = 0, y = 0, w = 50, h = 50,
      draw = function(self) end,
      onClick = function(self) clicked = true end,
    })
    core.ui.mousePress(10, 10, 1)
    core.ui.mouseRelease(10, 10, 1)
    harness.assert_true(clicked)
  end)

  harness.it("intégration caméra : follow après update d'entité", function()
    local player = core.entities.add({x = 0, y = 0, w = 10, h = 10,
      update = function(self, dt)
        self.x = self.x + 100 * dt
        core.camera.mode = {"follow", self}
      end})
    engine.update(0.5)
    harness.assert_approx(core.camera.x, 50)
    harness.assert_approx(player.x, 50)
  end)

  restoreRng()
end)

return harness
