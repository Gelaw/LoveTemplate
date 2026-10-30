--------------------------------------------------------------------
-- tests/state_test.lua : tests UNITAIRES PROJET — état de jeu pur (game/state.lua).
-- Exemple de ce que la séparation domain rend possible : on teste
-- les règles métier (vies, score, gameover) sans moteur du tout.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")

local state = require("state")

harness.describe("game.state (exemple projet)", function()

  harness.it("new : valeurs par défaut", function()
    local s = state.new()
    harness.assert_eq(s.score, 0)
    harness.assert_eq(s.lives, 3)
    harness.assert_false(s.gameover)
  end)

  harness.it("new : params pris en compte", function()
    local s = state.new({score = 100, lives = 1})
    harness.assert_eq(s.score, 100)
    harness.assert_eq(s.lives, 1)
  end)

  harness.it("addScore additionne", function()
    local s = state.new()
    state.addScore(s, 50)
    harness.assert_eq(s.score, 50)
    state.addScore(s, 25)
    harness.assert_eq(s.score, 75)
  end)

  harness.it("addScore ne descend pas sous zéro", function()
    local s = state.new()
    state.addScore(s, -100)
    harness.assert_eq(s.score, 0)
  end)

  harness.it("update avance le temps quand pas gameover", function()
    local s = state.new()
    state.update(s, 0.5)
    state.update(s, 0.5)
    harness.assert_approx(s.time, 1.0)
  end)

  harness.it("update fige le temps après gameover", function()
    local s = state.new({lives = 1})
    state.loseLife(s)
    harness.assert_true(s.gameover)
    local t = s.time
    state.update(s, 1)
    harness.assert_eq(s.time, t)
  end)

  harness.it("loseLife décrémente et déclenche gameover à 0", function()
    local s = state.new({lives = 2})
    harness.assert_false(state.loseLife(s)) -- 1 vie
    harness.assert_false(s.gameover)
    harness.assert_true(state.loseLife(s))  -- 0 vie
    harness.assert_true(s.gameover)
    harness.assert_eq(s.lives, 0)
  end)

  harness.it("reset restaure les défauts", function()
    local s = state.new({score = 999})
    state.reset(s)
    harness.assert_eq(s.score, 0)
    harness.assert_eq(s.lives, 3)
    harness.assert_false(s.gameover)
  end)
end)

return harness
