--------------------------------------------------------------------
-- tests/state_test.lua : tests UNITAIRES PROJET — état de jeu pur (game/state.lua).
-- Exemple de ce que la séparation domain rend possible : on teste
-- les règles métier (vies, score, gameover) sans moteur du tout.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

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

harness.describe("game.state persistance (save/load via backend)", function()

  local m = mock.new()
  core.attach(m.backend)

  harness.it("serialize produit un texte deterministe", function()
    local s = state.new({score = 10, lives = 2})
    harness.assert_eq(state.serialize(s),
      '{"events"={},"gameover"=false,"level"=1,"lives"=2,"score"=10,"time"=0}')
  end)

  harness.it("save puis load restaure l'état (round-trip fichier)", function()
    local s = state.new({score = 250, lives = 1})
    state.update(s, 3.5)
    local ok = state.save(s, "savegame.txt")
    harness.assert_true(ok)
    local s2 = state.new()
    local loaded = state.load(s2, "savegame.txt")
    harness.assert_true(loaded == s2)
    harness.assert_eq(s2.score, 250)
    harness.assert_eq(s2.lives, 1)
    harness.assert_approx(s2.time, 3.5)
  end)

  harness.it("load sur fichier absent : nil + message, pas de crash", function()
    local s = state.new()
    local res, err = state.load(s, "inexistant.txt")
    harness.assert_true(res == nil)
    harness.assert_true(type(err) == "string")
  end)

  harness.it("load sur fichier corrompu : nil + message, pas de crash", function()
    m.files = {bad = "{pas du tout valide = ???}"}
    local s = state.new()
    local res = state.load(s, "bad")
    harness.assert_true(res == nil)
  end)
end)

return harness
