--------------------------------------------------------------------
-- examples/snake/snake_setup.lua : exemple de setup projet COMPLET.
-- Pour jouer a cet exemple : lancez `love examples/snake` (le dossier
-- contient son propre main.lua minimal) ou copiez le contenu de run()
-- dans votre game/setup.lua.
--
-- Montre les patterns du template en action :
--   - logique pure externalisee (snake.lua, testable sans moteur)
--   - entites + HUD sur calque 9
--   - bindings clavier ZQSD + manette (addPadBind)
--   - letterbox (jamais de HUD coupe)
--   - gameover + restart
--------------------------------------------------------------------
local snake = require("examples.snake.snake")

local snakeSetup = {}

snakeSetup.config = {
  title = "Snake (exemple)",
  width = 960,
  height = 540,
  resizable = true,
  vsync = 1,
}

-- Taille d'une cellule en pixels (le monde virtuel fait cols*cell x rows*cell)
local CELL = 30

function snakeSetup.run()
  local engine = core.engine

  -- Letterbox : le monde 600x450 tient toujours dans la fenetre
  engine.virtualWidth = 20 * CELL
  engine.virtualHeight = 15 * CELL + 40 -- +40 pour la ligne de HUD
  engine.letterbox = true

  -- Bindings clavier + manette (union automatique via isBindDown)
  engine.addBind("escape", "quit")
  engine.addBind("z", "up");    engine.addPadBind("dpup", "up")
  engine.addBind("s", "down");  engine.addPadBind("dpdown", "down")
  engine.addBind("q", "left");  engine.addPadBind("dpleft", "left")
  engine.addBind("d", "right"); engine.addPadBind("dpright", "right")
  engine.addBind("space", "restart")

  local game = snake.new(20, 15, function() return domain.mathx.rng() end)
  snakeSetup.game = game

  -- Le serpent = une entite par segment, dessinee en carre
  local function refreshEntities()
    core.entities.clear()
    for i, seg in ipairs(game.body) do
      core.entities.add({
        x = (seg.x - 0.5) * CELL,
        y = (seg.y - 0.5) * CELL + 20, -- +20 : laisse la ligne de HUD en haut
        w = CELL - 2, h = CELL - 2, shape = "rectangle",
        color = i == 1 and {0.2, 0.9, 0.4} or {0.1, 0.7, 0.3},
      })
    end
    if game.food then
      core.entities.add({
        x = (game.food.x - 0.5) * CELL,
        y = (game.food.y - 0.5) * CELL + 20,
        w = CELL - 8, h = CELL - 8, shape = "circle", radius = (CELL - 8) / 2,
        color = {0.9, 0.2, 0.2},
      })
    end
  end
  refreshEntities()

  -- Boucle de jeu : un "tick" toutes les 0.12s
  local acc = 0
  engine.addUpdateFunction(function(dt)
    if engine.isBindDown("restart") and game.gameover then
      game = snake.new(game.cols, game.rows, function() return domain.mathx.rng() end)
      snakeSetup.game = game
      acc = 0
      refreshEntities()
      return
    end
    if game.gameover then return end
    if engine.isBindDown("up")    then snake.setDir(game, "up") end
    if engine.isBindDown("down")  then snake.setDir(game, "down") end
    if engine.isBindDown("left")  then snake.setDir(game, "left") end
    if engine.isBindDown("right") then snake.setDir(game, "right") end
    acc = acc + dt
    while acc >= 0.12 and not game.gameover do
      acc = acc - 0.12
      snake.step(game)
    end
    refreshEntities()
  end)

  -- HUD (calque 9, coordonnees d'ecran : jamais affecte par la camera)
  engine.addDrawFunction(function()
    local api = core.api()
    api.origin()
    api.setColor(1, 1, 1)
    if game.gameover then
      api.print(("GAME OVER - score %d - ESPACE pour recommencer"):format(game.score), 12, 8)
    else
      api.print(("Snake - score %d - ZQSD ou fleches manette"):format(game.score), 12, 8)
    end
  end, 9)
end

return snakeSetup
