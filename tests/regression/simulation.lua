--------------------------------------------------------------------
-- tests/regression/simulation.lua : simulation de référence partagée
-- entre le test de non-régression (comparaison) et update-golden.sh
-- (génération du golden file). Un seul endroit pour le scénario.
--------------------------------------------------------------------
local mock = require("tests.lib.mock_backend")
local deterministic = require("tests.lib.deterministic")

local simulation = {}

-- Retourne le condensat (string) de la simulation déterministe.
function simulation.snapshot()
  local m = mock.new({width = 960, height = 540})
  core.attach(m.backend)

  local restoreRng = deterministic.install(42)
  local engine = core.engine
  engine.init(function()
    engine.addBind("w", "up")
    engine.addBind("a", "left")
    engine.addBind("s", "down")
    engine.addBind("d", "right")
    engine.addBind("escape", "quit")

    core.entities.add({
      x = 0, y = 0, w = 40, h = 40, shape = "rectangle", speed = 100,
      update = function(self, dt)
        local t = engine.simTime or 0
        if t < 1 then
          self.x, self.y = self.x + 50 * dt, self.y + 50 * dt
        else
          self.x, self.y = self.x - 80 * dt, self.y + 20 * dt
        end
        core.camera.mode = {"follow", self}
      end,
      collide = function(self, other)
        core.camera.shake(4, 0.2)
      end,
    })

    for i = 1, 5 do
      core.entities.add({
        x = domain.mathx.prandom(-200, 200),
        y = domain.mathx.prandom(-200, 200),
        w = 20, h = 20, shape = "rectangle",
        angle = domain.mathx.prandom(0, math.pi),
      })
    end

    local emitTimer = 0
    engine.addUpdateFunction(function(dt)
      emitTimer = emitTimer - dt
      if emitTimer <= 0 then
        emitTimer = 0.25
        core.particles.add({
          x = domain.mathx.prandom(-50, 50),
          y = domain.mathx.prandom(-50, 50),
          nudge = 20, size = 5, timeLeft = 0.5,
          color = {domain.mathx.rng(), domain.mathx.rng(), domain.mathx.rng()},
        })
      end
    end)
  end)

  local simTime = 0
  for frame = 1, 120 do
    local dt = 1 / 60
    simTime = simTime + dt
    engine.simTime = simTime
    engine.update(dt)
    m.advance(dt)
    engine.draw()
  end
  restoreRng()

  local lines = {}
  table.insert(lines, string.format("time=%.6f", simTime))
  table.insert(lines, string.format("entities=%d", core.entities.count()))
  table.insert(lines, string.format("particles=%d", core.particles.count()))
  for i, e in ipairs(core.entities.list) do
    table.insert(lines, string.format("e%d=%.4f,%.4f", i, e.x or -1, e.y or -1))
  end
  table.insert(lines, string.format("camera=%.4f,%.4f", core.camera.x, core.camera.y))
  table.insert(lines, string.format("drawOps=%d", #m.log))
  return table.concat(lines, "\n") .. "\n"
end

-- Écrit le golden file.
function simulation.writeGolden(path)
  local f = assert(io.open(path, "w"), "impossible d'écrire : " .. path)
  f:write(simulation.snapshot())
  f:close()
end

-- Compare au golden file existant. Retourne true si identique.
-- En cas de différence, retourne false + message détaillé.
function simulation.checkGolden(path)
  local f = io.open(path, "r")
  if not f then
    return false, "golden file absent : lancez scripts/update-golden.sh"
  end
  local golden = f:read("*a")
  f:close()
  local current = simulation.snapshot()
  if golden == current then return true end
  local gi, ci = {}, {}
  local idx = 1
  for line in golden:gmatch("[^\n]+") do gi[idx] = line; idx = idx + 1 end
  local idx2 = 1
  for line in current:gmatch("[^\n]+") do ci[idx2] = line; idx2 = idx2 + 1 end
  local firstDiff = "inconnu"
  for k = 1, math.max(#gi, #ci) do
    if gi[k] ~= ci[k] then
      firstDiff = string.format("ligne %d : golden=%q / actuel=%q",
        k, tostring(gi[k]), tostring(ci[k]))
      break
    end
  end
  return false, "RÉGRESSION DÉTECTÉE (ou golden obsolète) — " .. firstDiff
end

return simulation
