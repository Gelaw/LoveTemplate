--------------------------------------------------------------------
-- tests/unit/state_test.lua : tests UNITAIRES — état de jeu pur.
-- Exemple de ce que la séparation domain rend possible : on teste
-- les règles métier (vies, score, gameover) sans moteur du tout.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")

harness.describe("domain.state", function()

  harness.it("new : valeurs par défaut", function()
    local s = domain.state.new()
    harness.assert_eq(s.score, 0)
    harness.assert_eq(s.lives, 3)
    harness.assert_false(s.gameover)
  end)

  harness.it("new : params pris en compte", function()
    local s = domain.state.new({score = 100, lives = 1})
    harness.assert_eq(s.score, 100)
    harness.assert_eq(s.lives, 1)
  end)

  harness.it("addScore additionne", function()
    local s = domain.state.new()
    domain.state.addScore(s, 50)
    harness.assert_eq(s.score, 50)
    domain.state.addScore(s, 25)
    harness.assert_eq(s.score, 75)
  end)

  harness.it("addScore ne descend pas sous zéro", function()
    local s = domain.state.new()
    domain.state.addScore(s, -100)
    harness.assert_eq(s.score, 0)
  end)

  harness.it("update avance le temps quand pas gameover", function()
    local s = domain.state.new()
    domain.state.update(s, 0.5)
    domain.state.update(s, 0.5)
    harness.assert_approx(s.time, 1.0)
  end)

  harness.it("update fige le temps après gameover", function()
    local s = domain.state.new({lives = 1})
    domain.state.loseLife(s)
    harness.assert_true(s.gameover)
    local t = s.time
    domain.state.update(s, 1)
    harness.assert_eq(s.time, t)
  end)

  harness.it("loseLife décrémente et déclenche gameover à 0", function()
    local s = domain.state.new({lives = 2})
    harness.assert_false(domain.state.loseLife(s)) -- 1 vie
    harness.assert_false(s.gameover)
    harness.assert_true(domain.state.loseLife(s))  -- 0 vie
    harness.assert_true(s.gameover)
    harness.assert_eq(s.lives, 0)
  end)

  harness.it("reset restaure les défauts", function()
    local s = domain.state.new({score = 999})
    domain.state.reset(s)
    harness.assert_eq(s.score, 0)
    harness.assert_eq(s.lives, 3)
    harness.assert_false(s.gameover)
  end)
end)

return harness
