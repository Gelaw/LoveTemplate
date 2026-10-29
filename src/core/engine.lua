--------------------------------------------------------------------
-- core/engine.lua : orchestrateur — boucle, calques de rendu,
-- bindings clavier, chargement sûr de scripts.
-- C'est le "scheduler" : il appelle domain/core/particles/ui mais
-- n'implémente aucune règle métier ni aucun appel LÖVE direct.
--------------------------------------------------------------------
local engine = {
  draws = {},     -- 9 calques de rendu (1 fond -> 9 UI)
  updates = {},   -- callbacks d'update
  bindings = {},  -- action -> touche
  width = 0, height = 0,
  gameover = false,
  projectSetup = nil, -- fourni par main.lua (logique spécifique projet)
}

for i = 1, 9 do engine.draws[i] = {} end

-- Enregistre un callback de dessin sur un calque (défaut 5).
function engine.addDrawFunction(draw, layer)
  layer = layer or 5
  table.insert(engine.draws[layer], draw)
end

function engine.addUpdateFunction(update)
  table.insert(engine.updates, update)
end

function engine.addBind(key, action)
  engine.bindings[action] = key
end

function engine.getBindOf(action)
  return engine.bindings[action]
end

-- Charge et exécute un fichier Lua sans crasher (niveaux, scripts éditables).
-- En test, le backend fournit un loader mémoire ; en prod, love.filesystem.
function engine.safeLoadAndRun(name)
  local ok, chunk, result
  ok, chunk = pcall(core.api().loadFile, name)
  if not ok then return false, chunk end
  ok, result = pcall(chunk)
  if not ok then return false, result end
  return true, result
end

-- Initialisation : dimensionne le canvas via le backend, monte les
-- couches entités/particules/UI, puis appelle projectSetup() du projet.
function engine.init(setup)
  local api = core.api()
  engine.width = api.getWidth()
  engine.height = api.getHeight()
  engine.projectSetup = setup
  -- remise à zéro complète (un init doit pouvoir être rappelé,
  -- notamment entre deux tests)
  engine.draws = {}
  for i = 1, 9 do engine.draws[i] = {} end
  engine.updates = {}
  engine.bindings = {}
  engine.gameover = false
  engine.simTime = 0
  -- caméra remise à zéro : un init doit être totalement reproductible
  -- (les tests manipulent camera.scale/mode, il ne faut pas qu'ils fuient
  -- dans les snapshots suivants)
  core.camera.x, core.camera.y = 0, 0
  core.camera.scale, core.camera.angle = 1, 0
  core.camera.mode = nil
  core.camera.shaker = { steps = {}, n = 1, stepTimer = 0, shakeTimer = 0 }
  core.entities.clear()
  core.particles.clear()
  core.ui.clear()
  engine.addDrawFunction(function(w, h, cam)
    core.entities.draw(engine.width, engine.height, cam)
  end, 5)
  engine.addDrawFunction(function(w, h, cam)
    core.particles.draw(engine.width, engine.height, cam)
  end, 6)
  engine.addDrawFunction(function()
    core.ui.draw()
  end, 9)
  engine.addUpdateFunction(function(dt)
    core.entities.update(dt)
  end)
  engine.addUpdateFunction(function(dt)
    core.particles.update(dt)
  end)
  if setup then setup() end
end

-- Un pas d'update. gameover coupe toute la logique.
function engine.update(dt)
  if engine.gameover then return end
  for u, update in pairs(engine.updates) do
    if type(update) ~= "function" then
      core.api().quit()
    end
    update(dt)
  end
  core.camera:update(dt)
end

-- Une frame de rendu : transformation caméra puis tous les calques.
function engine.draw()
  local api = core.api()
  api.translate(engine.width / 2, engine.height / 2)
  core.camera:apply()
  for l, layer in pairs(engine.draws) do
    for d, draw in pairs(layer) do
      if type(draw) ~= "function" then
        api.quit()
      end
      api.push()
      draw(engine.width, engine.height, core.camera)
      api.pop()
    end
  end
end

return engine
