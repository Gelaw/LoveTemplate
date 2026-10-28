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

-- Branche le backend et initialise l'engine avec la config du projet.
function adapter.boot(projectSetup)
  core.attach(adapter.buildBackend())
  local api = core.api()
  api.setFont(api.newFont(11))
  api.setBackgroundColor(.4, .4, .4)
  core.engine.init(projectSetup)
end

-- ---- Callbacks LÖVE (traduction d'événements) ----

function adapter.load(arg)
  adapter.boot(main.projectSetup)
end

function adapter.update(dt)
  core.engine.update(dt)
end

function adapter.draw()
  core.engine.draw()
end

function adapter.keypressed(key)
  if key == core.engine.getBindOf("quit") then
    love.event.quit()
  end
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
