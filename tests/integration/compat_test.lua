--------------------------------------------------------------------
-- tests/integration/compat_test.lua : test d'intégration de la façade
-- de compatibilité base.lua — vérifie que l'API historique expose
-- bien les nouveaux modules (les anciens modules du jeu marchent).
-- Ce test NE DOIT PAS être exécuté sous LÖVE : il simule love.* via
-- un stub minimal puis charge base.lua comme un module ordinaire.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")

harness.describe("intégration : façade base.lua (API historique)", function()

  -- base.lua fait require("domain")/require("core") : déjà chargés par
  -- le runner. On attache d'abord le backend mock (base ne l'exige pas,
  -- mais les fonctions historiques oui).
  local m = mock.new()
  core.attach(m.backend)

  -- Charge la façade dans l'environnement global (comme LÖVE le ferait)
  local chunk = loadfile("src/base.lua")
  if not chunk then
    error("base.lua introuvable — lancez depuis la racine du projet")
  end
  chunk()

  harness.it("les globals historiques existent", function()
    harness.assert_true(type(addDrawFunction) == "function")
    harness.assert_true(type(addUpdateFunction) == "function")
    harness.assert_true(type(addBind) == "function")
    harness.assert_true(type(getBindOf) == "function")
    harness.assert_true(type(cameraShake) == "function")
    harness.assert_true(type(UIMousePress) == "function")
    harness.assert_true(type(UIMouseRelease) == "function")
    harness.assert_true(type(UIMouseMoved) == "function")
    harness.assert_true(type(applyParams) == "function")
    harness.assert_true(type(safeLoadAndRun) == "function")
    harness.assert_true(type(getPointsGlobalCoor) == "function")
    harness.assert_true(type(checkIntersect) == "function")
  end)

  harness.it("camera historique == core.camera", function()
    harness.assert_eq(camera, core.camera)
  end)

  harness.it("entities/particuleEffects historiques == listes core", function()
    harness.assert_eq(entities, core.entities.list)
    harness.assert_eq(particuleEffects, core.particles.list)
  end)

  harness.it("audioManager historique == core.audio", function()
    harness.assert_eq(audioManager, core.audio)
  end)

  harness.it("applyParams copie les champs", function()
    local t = applyParams({a = 1}, {b = 2})
    harness.assert_eq(t.a, 1)
    harness.assert_eq(t.b, 2)
  end)

  harness.it("addBind/getBindOf historiques branchés sur engine", function()
    addBind("k", "actionK")
    harness.assert_eq(getBindOf("actionK"), "k")
    harness.assert_eq(core.engine.getBindOf("actionK"), "k")
  end)

  harness.it("cameraShake historique branché sur core.camera", function()
    local restore = require("tests.lib.deterministic").install(1)
    cameraShake(8, 0.2)
    restore()
    harness.assert_eq(#core.camera.shaker.steps, 10)
  end)

  harness.it("math.* historique : dist/angle/clamp via domain", function()
    harness.assert_eq(math.dist(0, 0, 3, 4), 5)
    harness.assert_eq(math.clamp(-10, 0, 5), 0)
    harness.assert_approx(math.angle(0, 0, 1, 1), math.pi / 4)
  end)
end)

return harness
