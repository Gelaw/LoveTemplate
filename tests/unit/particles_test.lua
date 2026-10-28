--------------------------------------------------------------------
-- tests/unit/particles_test.lua : tests UNITAIRES — particules.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")

harness.describe("core.particles", function()

  local m = mock.new()
  core.attach(m.backend)

  harness.it("add/count", function()
    core.particles.clear()
    harness.assert_eq(core.particles.count(), 0)
    core.particles.add({x = 0, y = 0, nudge = 10, size = 4, timeLeft = 1, color = {1, 0, 0}})
    harness.assert_eq(core.particles.count(), 1)
  end)

  harness.it("update décrémente timeLeft", function()
    core.particles.clear()
    core.particles.add({x = 0, y = 0, nudge = 10, size = 4, timeLeft = 1, color = {1, 0, 0}})
    core.particles.update(0.4)
    harness.assert_approx(core.particles.list[1].timeLeft, 0.6)
  end)

  harness.it("timeLeft épuisé : particule retirée + onTermination", function()
    core.particles.clear()
    local terminated = false
    core.particles.add({
      x = 0, y = 0, nudge = 10, size = 4, timeLeft = 0.5, color = {1, 0, 0},
      onTermination = function(self) terminated = true end,
    })
    core.particles.update(0.6)
    harness.assert_true(terminated)
    harness.assert_eq(core.particles.count(), 0)
  end)

  harness.it("draw par défaut via backend", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.particles.clear()
    core.particles.add({x = 0, y = 0, nudge = 10, size = 4, timeLeft = 1, color = {1, 0, 0}})
    m2.reset()
    core.particles.draw(960, 540, {x = 0, y = 0, scale = 1})
    -- 8 branches -> au moins 8 polygones
    harness.assert_true(m2.count("polygon") >= 8)
  end)
end)

return harness
