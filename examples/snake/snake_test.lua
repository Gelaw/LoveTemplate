--------------------------------------------------------------------
-- examples/snake/snake_test.lua : tests UNITAIRES de la logique pure
-- du snake (examples/snake/snake.lua). Aucune dependance moteur :
-- on injecte un RNG seed pour la nourriture -> deterministe.
-- Declare dans tests/suite.lua comme "examples/snake/snake_test".
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")

local snake = require("examples.snake.snake")

-- RNG deterministe simple (LCG), pour que placeFood soit reproductible.
local function seededRng(seed)
  local state = seed
  return function()
    state = (1103515245 * state + 12345) % 2147483648
    return state / 2147483648
  end
end

harness.describe("examples/snake (logique pure)", function()

  harness.it("new : serpent au centre, direction droite, nourriture placee", function()
    local s = snake.new(20, 15, seededRng(1))
    harness.assert_eq(s.body[1].x, 10)
    harness.assert_eq(s.body[1].y, 7)
    harness.assert_eq(s.dir, snake.DIRS.right)
    harness.assert_true(s.food ~= nil)
    harness.assert_false(s.gameover)
  end)

  harness.it("step : avance la tete d'une case dans la direction courante", function()
    local s = snake.new(20, 15, seededRng(1))
    local hx, hy = s.body[1].x, s.body[1].y
    snake.step(s)
    harness.assert_eq(s.body[1].x, hx + 1)
    harness.assert_eq(s.body[1].y, hy)
    harness.assert_eq(#s.body, 1) -- pas de croissance sans nourriture
  end)

  harness.it("setDir : changement de direction applique au prochain step", function()
    local s = snake.new(20, 15, seededRng(1))
    snake.setDir(s, "up")
    snake.step(s)
    harness.assert_eq(s.body[1].y, 6) -- montait de 7 a 6
  end)

  harness.it("setDir : demi-tour interdit (ignore)", function()
    local s = snake.new(20, 15, seededRng(1)) -- direction = right
    snake.setDir(s, "left") -- oppose a right -> ignore
    snake.step(s)
    harness.assert_eq(s.body[1].x, 11) -- est bien alle a droite
  end)

  harness.it("manger : score +10, evenement 'eat', nouvelle nourriture", function()
    local s = snake.new(20, 15, seededRng(1))
    -- place la nourriture juste devant la tete
    s.food = {x = s.body[1].x + 1, y = s.body[1].y}
    local events = snake.step(s)
    local ate = false
    for _, e in ipairs(events) do if e == "eat" then ate = true end end
    harness.assert_true(ate)
    harness.assert_eq(s.score, 10)
    harness.assert_eq(#s.body, 2) -- a grandi
  end)

  harness.it("mur : gameover + evenement 'gameover'", function()
    local s = snake.new(5, 5, seededRng(1))
    s.body = {{x = 5, y = 3}} -- tete contre le mur droit, direction right
    local events = snake.step(s)
    harness.assert_true(s.gameover)
    local over = false
    for _, e in ipairs(events) do if e == "gameover" then over = true end end
    harness.assert_true(over)
  end)

  harness.it("morsure : se mordre la queue -> gameover", function()
    local s = snake.new(10, 10, seededRng(1))
    -- serpent en carre : tete (5,5), va a droite puis tourne pour se mordre
    s.body = {{x = 5, y = 5}, {x = 5, y = 6}, {x = 6, y = 6}, {x = 6, y = 5}}
    -- direction up amene la tete sur (5,4)... on force une morsure directe :
    s.body = {{x = 5, y = 5}, {x = 4, y = 5}, {x = 4, y = 4}, {x = 5, y = 4}}
    snake.setDir(s, "up") -- tete va en (5,4) = sa propre queue (qui ne bouge pas si on mange)
    s.food = {x = 5, y = 4} -- nourriture sur la queue -> la queue ne part pas -> morsure
    snake.step(s)
    harness.assert_true(s.gameover)
  end)

  harness.it("step apres gameover : ne change plus rien", function()
    local s = snake.new(5, 5, seededRng(1))
    s.body = {{x = 5, y = 3}}
    snake.step(s) -- mort au mur
    harness.assert_true(s.gameover)
    local tick = s.tick
    snake.step(s)
    harness.assert_eq(s.tick, tick)
  end)
end)

return harness
