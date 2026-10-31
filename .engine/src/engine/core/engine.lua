--------------------------------------------------------------------
-- core/engine.lua : orchestrateur — boucle, calques de rendu,
-- bindings clavier, chargement sûr de scripts.
-- C'est le "scheduler" : il appelle domain/core/particles/ui mais
-- n'implémente aucune règle métier ni aucun appel LÖVE direct.
--------------------------------------------------------------------
local engine = {
  draws = {},     -- 9 calques de rendu (1 fond -> 9 UI)
  updates = {},   -- callbacks d'update
  bindings = {},  -- action -> touche clavier
  padBindings = {}, -- action -> bouton manette (ex. "a", "dpup", "leftshoulder")
  width = 0, height = 0,
  projectSetup = nil, -- fourni par main.lua (logique spécifique projet)
  -- Letterbox : nil (defaut, comportement historique) ou true pour
  -- adapter le rendu a la fenetre (voir engine.draw). virtualWidth/
  -- virtualHeight = resolution de reference du jeu (960x540 par defaut).
  letterbox = nil,
  virtualWidth = 960,
  virtualHeight = 540,
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

-- Bind manette : bouton LÖVE ("a", "b", "dpup", "leftshoulder"...).
-- isBindDown(action) fait l'union clavier + manette.
function engine.addPadBind(button, action)
  engine.padBindings[action] = button
end

function engine.getPadBindOf(action)
  return engine.padBindings[action]
end

function engine.getBindOf(action)
  return engine.bindings[action]
end

-- Un binding d'action est-il actif ?
-- Lecture UNIQUEMENT par polling (love.keyboard.isDown via le backend)
-- sur la TOUCHE (lettre produite). Approche volontairement minimale :
-- les couches événementielles et scancodes se sont révélées source de
-- comportements divergents entre plateformes (desktop Wayland vs web).
function engine.isBindDown(action)
  local api = core.api()
  local key = engine.bindings[action]
  if key and api.isKeyDown and api.isKeyDown(key) == true then
    return true
  end
  local pad = engine.padBindings[action]
  if pad and api.isPadDown and api.isPadDown(pad) == true then
    return true
  end
  return false
end

-- Bindings en TOUCHES (lettre produite par le clavier, ex. "z" sur un
-- AZERTY). Approche volontairement NAÏVE : on ignore la position physique
-- (scancodes) — les scancodes se sont révélés non fiables selon les
-- plateformes (polling SDL/Wayland incomplet sur layouts non-QWERTY,
-- scancodes web dérivés du caractère). Si votre jeu vise plusieurs
-- layouts, prévoyez un écran d'options pour re-binder les touches.

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
  engine.padBindings = {}
  engine.simTime = 0
  -- letterbox remis a nil : un init doit rester reproductible
  engine.letterbox = nil
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

-- Un pas d'update.
function engine.update(dt)
  for u, update in pairs(engine.updates) do
    if type(update) ~= "function" then
      core.api().quit()
    end
    update(dt)
  end
  core.camera:update(dt)
end

-- Une frame de rendu : transformation caméra puis tous les calques.
-- Si engine.letterbox est actif, le monde (taille virtuelle
-- engine.virtualWidth x engine.virtualHeight, ex. 960x540) est d'abord
-- centré et mis à l'échelle pour tenir dans le canvas réel, avec des
-- bandes noires autour : le HUD en coordonnées fixes n'est jamais coupé.
function engine.draw()
  local api = core.api()
  if engine.letterbox then
    local s = math.min(engine.width / engine.virtualWidth,
                       engine.height / engine.virtualHeight)
    api.origin()
    api.setBackgroundColor(0, 0, 0)
    api.translate((engine.width - engine.virtualWidth * s) / 2,
                  (engine.height - engine.virtualHeight * s) / 2)
    api.scale(s, s)
    api.translate(engine.virtualWidth / 2, engine.virtualHeight / 2)
  else
    api.translate(engine.width / 2, engine.height / 2)
  end
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
