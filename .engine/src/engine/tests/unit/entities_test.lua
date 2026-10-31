--------------------------------------------------------------------
-- tests/unit/entities_test.lua : tests UNITAIRES — registre d'entités
-- (update, suppression terminated, culling via mock).
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("core.entities", function()

  local m = mock.new()
  core.attach(m.backend)

  local cam = {x = 0, y = 0, scale = 1}

  harness.it("add/count/clear", function()
    core.entities.clear()
    harness.assert_eq(core.entities.count(), 0)
    core.entities.add({x = 0, y = 0, w = 10, h = 10})
    core.entities.add({x = 5, y = 5, w = 10, h = 10})
    harness.assert_eq(core.entities.count(), 2)
    core.entities.clear()
    harness.assert_eq(core.entities.count(), 0)
  end)

  harness.it("update appelle entity:update(dt)", function()
    core.entities.clear()
    local dt = 0
    core.entities.add({x = 0, y = 0, w = 1, h = 1, update = function(self, d) dt = d end})
    core.entities.update(0.016)
    harness.assert_eq(dt, 0.016)
  end)

  harness.it("terminated : entité retirée après update", function()
    core.entities.clear()
    local e = core.entities.add({x = 0, y = 0, w = 1, h = 1})
    e.terminated = true
    core.entities.update(0.016)
    harness.assert_eq(core.entities.count(), 0)
  end)

  harness.it("collide : les deux callbacks appelés au contact", function()
    core.entities.clear()
    local hit1, hit2 = false, false
    core.entities.add({
      x = 0, y = 0, w = 40, h = 40,
      collide = function(self, other) hit1 = true end,
    })
    core.entities.add({
      x = 5, y = 5, w = 40, h = 40,
      collide = function(self, other) hit2 = true end,
    })
    core.entities.update(0.016)
    harness.assert_true(hit1)
    harness.assert_true(hit2)
  end)

  harness.it("collide : pas d'appel sans contact", function()
    core.entities.clear()
    local hit = false
    core.entities.add({
      x = 0, y = 0, w = 10, h = 10,
      collide = function(self, other) hit = true end,
    })
    core.entities.add({
      x = 500, y = 500, w = 10, h = 10,
      collide = function(self, other) hit = true end,
    })
    core.entities.update(0.016)
    harness.assert_false(hit)
  end)

  harness.it("collision : entité peut se terminer pendant collide", function()
    core.entities.clear()
    local e1 = core.entities.add({
      x = 0, y = 0, w = 40, h = 40,
      collide = function(self, other) self.terminated = true end,
    })
    core.entities.add({
      x = 5, y = 5, w = 40, h = 40,
      collide = function(self, other) end,
    })
    core.entities.update(0.016)
    harness.assert_eq(core.entities.count(), 1) -- e1 retirée
  end)

  harness.it("draw avec culling : entité visible dans le cadre", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.entities.clear()
    core.entities.add({x = 0, y = 0, w = 10, h = 10, shape = "rectangle"})
    m2.reset()
    core.entities.draw(960, 540, cam)
    harness.assert_true(m2.count("rectangle") >= 1)
    -- hors champ : rien dessiné
    core.entities.clear()
    core.entities.add({x = 100000, y = 100000, w = 10, h = 10, shape = "rectangle"})
    m2.reset()
    core.entities.draw(960, 540, cam)
    harness.assert_eq(m2.count("rectangle"), 0)
  end)

  harness.it("draw image : entity.image rendu via api.draw (taille w/h)", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.entities.clear()
    local img = m2.backend.newImage("src/mon.png")
    core.entities.add({x = 0, y = 0, w = 64, h = 64, image = img})
    m2.reset()
    core.entities.draw(960, 540, cam)
    harness.assert_eq(m2.count("draw"), 1)
    harness.assert_eq(m2.count("rectangle"), 0)
  end)

  harness.it("draw image sans w/h : taille native centree, pas de rectangle", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.entities.clear()
    local img = m2.backend.newImage("src/mon.png")
    core.entities.add({x = 0, y = 0, image = img})
    m2.reset()
    core.entities.draw(960, 540, cam)
    harness.assert_eq(m2.count("draw"), 1)
    harness.assert_eq(m2.count("rectangle"), 0)
  end)
end)

return harness
