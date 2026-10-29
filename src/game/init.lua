--------------------------------------------------------------------
-- game/init.lua : LE SEUL ENDROIT À MODIFIER POUR VOTRE JEU.
--
-- Tout le reste du template (main.lua, conf.lua, domain/, core/,
-- adapter/, base.lua) est figé : dupliquez le projet et travaillez
-- uniquement dans src/game/. Les fichiers de config et de setup
-- ci-dessous constituent le point d'entrée du projet.
--
-- game.config : fenêtre (appliquée au boot par l'adapter).
-- game.setup  : initialisation du gameplay (entités, bindings, calques).
--------------------------------------------------------------------
local game = {}

game.config = {
  title = "Love2D Web Template",
  width = 960,
  height = 540,
  resizable = true,
  vsync = 1,
}

function game.setup()
  local engine = core.engine

  -- Bindings projet
  engine.addBind("escape", "quit")
  engine.addBind("w", "up")
  engine.addBind("a", "left")
  engine.addBind("s", "down")
  engine.addBind("d", "right")

  -- Joueur (démo) : remplacez par vos propres entités
  local player = core.entities.add({
    x = 0, y = 0, w = 40, h = 40, shape = "rectangle",
    color = {0.2, 0.9, 0.4},
    speed = 260,
    update = function(self, dt)
      local dx, dy = 0, 0
      if love.keyboard.isDown(engine.getBindOf("left"))  then dx = dx - 1 end
      if love.keyboard.isDown(engine.getBindOf("right")) then dx = dx + 1 end
      if love.keyboard.isDown(engine.getBindOf("up"))    then dy = dy - 1 end
      if love.keyboard.isDown(engine.getBindOf("down"))  then dy = dy + 1 end
      dx, dy = domain.mathx.normalize(dx, dy)
      self.x = self.x + dx * self.speed * dt
      self.y = self.y + dy * self.speed * dt
      core.camera.mode = {"follow", self}
    end,
    collide = function(self, other)
      core.camera.shake(6, 0.3)
    end
  })
  game.player = player

  -- Obstacles de démo
  for i = 1, 6 do
    core.entities.add({
      x = domain.mathx.prandom(-300, 300), y = domain.mathx.prandom(-220, 220),
      w = 30, h = 30, shape = "rectangle",
      color = {0.9, 0.5, 0.2},
      angle = domain.mathx.prandom(0, math.pi)
    })
  end

  -- HUD de démo
  engine.addDrawFunction(function()
    local api = core.api()
    api.origin()
    api.setColor(1, 1, 1)
    api.print("ZQSD/WASD pour bouger, touchez les caisses.", 12, 12)
  end, 9)

  -- Émetteur de particules de démo
  local sparkTimer = 0
  engine.addUpdateFunction(function(dt)
    sparkTimer = sparkTimer - dt
    if sparkTimer <= 0 then
      sparkTimer = 0.4
      core.particles.add({
        x = player.x, y = player.y,
        nudge = 24, size = 4, timeLeft = 0.8,
        color = {domain.mathx.rng(), domain.mathx.rng(), domain.mathx.rng()}
      })
    end
  end)
end

return game
