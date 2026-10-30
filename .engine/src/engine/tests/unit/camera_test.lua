--------------------------------------------------------------------
-- tests/unit/camera_test.lua : tests UNITAIRES — caméra (core)
-- avec backend mock. La logique follow/moveTo/shake est pure,
-- seul apply() touche le backend (enregistré dans le mock).
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("core.camera", function()

  local m = mock.new()
  core.attach(m.backend)

  harness.it("follow : la caméra suit l'entité", function()
    local cam = core.camera
    cam.x, cam.y = 0, 0
    cam.mode = {"follow", {x = 100, y = 200}}
    cam:update(0.016)
    harness.assert_eq(cam.x, 100)
    harness.assert_eq(cam.y, 200)
  end)

  harness.it("moveTo : s'arrête une fois arrivée", function()
    local cam = core.camera
    cam.mode = {"moveTo", {x = 50, y = 60}}
    cam:update(0.016)
    harness.assert_eq(cam.x, 50)
    harness.assert_eq(cam.y, 60)
    harness.assert_nil(cam.mode)
  end)

  harness.it("mode nil : update sans erreur", function()
    local cam = core.camera
    cam.mode = nil
    cam:update(0.016) -- ne doit pas planter
    harness.assert_nil(cam.mode)
  end)

  harness.it("shake : remplit les steps puis s'éteint", function()
    local cam = core.camera
    local restore = require("engine.tests.lib.deterministic").install(3)
    cam.shake(10, 0.3)
    restore()
    harness.assert_eq(#cam.shaker.steps, 10)
    -- après 0.3s d'update, le shaker est vidé
    for i = 1, 20 do cam:update(0.016) end
    harness.assert_eq(#cam.shaker.steps, 0)
    harness.assert_eq(cam.shaker.n, 1)
  end)

  harness.it("apply : passe par le backend (translate/scale/rotate)", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    local cam = core.camera
    cam.x, cam.y, cam.scale, cam.angle = 10, 20, 2, 0
    m2.reset()
    cam:apply()
    harness.assert_true(m2.count("rotate") >= 1)
    harness.assert_true(m2.count("scale") >= 1)
    harness.assert_true(m2.count("translate") >= 1)
  end)
end)

return harness
