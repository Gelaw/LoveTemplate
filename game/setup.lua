--------------------------------------------------------------------
-- game/setup.lua : configuration + initialisation du PROJET.
-- ★ LE SEUL FICHIER À MODIFIER pour votre jeu (avec les modules que
-- vous ajoutez dans game/ et les tests dans tests/).
-- Tout le reste (.engine/, scripts/) est le template figé.
--------------------------------------------------------------------
local setup = {}

-- Config fenêtre, appliquée par game/conf.lua puis l'adapter au boot.
setup.config = {
  title = "Love2D Web Template",
  width = 960,
  height = 540,
  resizable = true,
  vsync = 1,
}

-- Initialisation du gameplay : entités, bindings, calques, UI...
function setup.run()
  local engine = core.engine

  -- Bindings projet — en TOUCHES (lettres produites). Réglé pour AZERTY
  -- (ZQSD) : un joueur QWERTY changera ici pour WASD (ou prévoyez un
  -- écran d'options). Voir la note dans .engine/src/core/engine.lua.
  engine.addBind("escape", "quit")
  engine.addBind("z", "up")
  engine.addBind("q", "left")
  engine.addBind("s", "down")
  engine.addBind("d", "right")

  -- Joueur (démo) : remplacez par vos propres entités
  local player = core.entities.add({
    x = 0, y = 0, w = 40, h = 40, shape = "rectangle",
    color = {0.2, 0.9, 0.4},
    speed = 260,
    update = function(self, dt)
      local dx, dy = 0, 0
      -- isBindDown : union du suivi événementiel et du polling isDown.
      if engine.isBindDown("left")  then dx = dx - 1 end
      if engine.isBindDown("right") then dx = dx + 1 end
      if engine.isBindDown("up")    then dy = dy - 1 end
      if engine.isBindDown("down")  then dy = dy + 1 end
      dx, dy = domain.mathx.normalize(dx, dy)
      self.x = self.x + dx * self.speed * dt
      self.y = self.y + dy * self.speed * dt
      core.camera.mode = {"follow", self}
    end,
    collide = function(self, other)
      core.camera.shake(6, 0.3)
    end
  })
  setup.player = player

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
    api.print("ZQSD pour bouger, touchez les caisses.", 12, 12)
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

return setup
