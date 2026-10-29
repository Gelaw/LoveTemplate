--------------------------------------------------------------------
-- adapter/love2d.lua : ADAPTER LÖVE — seul fichier du projet autorisé
-- à toucher l'API `love.*`. Il construit le "backend" injecté dans
-- core, et traduit les événements LÖVE vers core/engine + core/ui.
-- Pour porter le projet sur un autre moteur, écrire un autre adapter.
--------------------------------------------------------------------
local adapter = {}

-- Construit le backend injecté dans core (indirection LÖVE <-> core).
function adapter.buildBackend()
  local g = love.graphics
  return {
    -- graphique
    setColor     = function(...) g.setColor(...) end,
    translate    = function(...) g.translate(...) end,
    rotate       = function(...) g.rotate(...) end,
    scale        = function(...) g.scale(...) end,
    push         = function() g.push() end,
    pop          = function() g.pop() end,
    origin       = function() g.origin() end,
    polygon      = function(...) g.polygon(...) end,
    rectangle    = function(...) g.rectangle(...) end,
    circle       = function(...) g.circle(...) end,
    print        = function(...) g.print(...) end,
    newFont      = function(...) return g.newFont(...) end,
    setFont      = function(f) g.setFont(f) end,
    setBackgroundColor = function(...) g.setBackgroundColor(...) end,
    getWidth     = function() return g.getWidth() end,
    getHeight    = function() return g.getHeight() end,
    newQuad      = function(...) return g.newQuad(...) end,
    draw         = function(...) g.draw(...) end,
    -- temps
    getTime      = function() return love.timer.getTime() end,
    -- clavier (polling scancode ; les événements passent par adapter.key*)
    isScancodeDown = function(scancode) return love.keyboard.isScancodeDown(scancode) end,
    -- fenêtre
    setFullscreenMode = function() love.window.setMode(0, 0) end,
    quit         = function() love.event.quit() end,
    -- fichiers
    loadFile     = function(name) return love.filesystem.load(name) end,
    -- audio
    newSource     = function(path, type) return love.audio.newSource(path, type) end,
    pauseAll      = function() love.audio.pause() end,
  }
end

-- Branche le backend, applique la config fenêtre du projet (game.config)
-- et initialise l'engine avec le setup du projet (game.setup).
function adapter.boot(projectSetup, config)
  core.attach(adapter.buildBackend())
  local api = core.api()
  if config then
    if config.title then love.window.setTitle(config.title) end
    love.window.setMode(config.width, config.height, {
      resizable = config.resizable,
      vsync = config.vsync,
    })
  end
  api.setFont(api.newFont(11))
  api.setBackgroundColor(.4, .4, .4)
  core.engine.init(projectSetup)
end

-- ---- Callbacks LÖVE (traduction d'événements) ----
-- (main.lua délègue directement à adapter.* ; voir src/main.lua)

function adapter.load(arg)
  local game = require("game")
  adapter.boot(game.setup, game.config)
end

function adapter.update(dt)
  core.engine.update(dt)
end

function adapter.draw()
  core.engine.draw()
end

function adapter.keypressed(key, scancode)
  -- Les événements portent toujours le bon SCANCODE (position physique),
  -- même quand le polling Wayland échoue sur certains layouts : on
  -- alimente le suivi événementiel du moteur.
  if scancode then core.engine.onBindPressed(scancode) end
  if scancode == core.engine.getBindOf("quit") then
    love.event.quit()
  end
end

function adapter.keyreleased(key, scancode)
  if scancode then core.engine.onBindReleased(scancode) end
end

function adapter.mousepressed(x, y, button)
  core.ui.mousePress(x, y, button)
end

function adapter.mousereleased(x, y, button)
  core.ui.mouseRelease(x, y, button)
end

function adapter.mousemoved(x, y, dx, dy)
  core.ui.mouseMoved(x, y, dx, dy)
end

return adapter
