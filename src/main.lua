--------------------------------------------------------------------
-- main.lua : point d'entrée — mince.
-- Charge domain -> core -> adapter, et contient la logique PROJET
-- (projectSetup). Le reste du template est réutilisable tel quel.
--------------------------------------------------------------------
require("domain")
require("core")
local adapter = require("adapter.love2d")

main = {}

-- Logique spécifique au projet (démo) : bindings, entités, particules.
function main.projectSetup()
  local engine = core.engine
  engine.addBind("escape", "quit")
  engine.addBind("w", "up")
  engine.addBind("a", "left")
  engine.addBind("s", "down")
  engine.addBind("d", "right")

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
  main.player = player

  for i = 1, 6 do
    core.entities.add({
      x = domain.mathx.prandom(-300, 300), y = domain.mathx.prandom(-220, 220),
      w = 30, h = 30, shape = "rectangle",
      color = {0.9, 0.5, 0.2},
      angle = domain.mathx.prandom(0, math.pi)
    })
  end

  engine.addDrawFunction(function()
    local api = core.api()
    api.origin()
    api.setColor(1, 1, 1)
    api.print("ZQSD/WASD pour bouger, touchez les caisses.", 12, 12)
  end, 9)

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

-- ---- Branchement des callbacks LÖVE sur l'adapter ----
function love.load(arg)      adapter.load(arg) end
function love.update(dt)    adapter.update(dt) end
function love.draw()        adapter.draw() end
function love.keypressed(k) adapter.keypressed(k) end
function love.mousepressed(...)   adapter.mousepressed(...) end
function love.mousereleased(...)  adapter.mousereleased(...) end
function love.mousemoved(...)     adapter.mousemoved(...) end
