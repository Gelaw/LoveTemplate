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
    printf       = function(...) g.printf(...) end,
    newFont      = function(...) return g.newFont(...) end,
    newImage     = function(path) return g.newImage(path) end,
    setFont      = function(f) g.setFont(f) end,
    setBackgroundColor = function(...) g.setBackgroundColor(...) end,
    getWidth     = function() return g.getWidth() end,
    getHeight    = function() return g.getHeight() end,
    newQuad      = function(...) return g.newQuad(...) end,
    draw         = function(...) g.draw(...) end,
    -- temps
    getTime      = function() return love.timer.getTime() end,
    -- clavier (polling de la touche ; les événements passent par adapter.key*)
    isKeyDown = function(key) return love.keyboard.isDown(key) end,
    -- manette : premier joystick connecté (fonctionne desktop + web love.js)
    isPadDown = function(button)
      local joy = love.joystick.getJoysticks()[1]
      return joy ~= nil and joy:isGamepadDown(button)
    end,
    -- fenêtre
    setFullscreenMode = function() love.window.setMode(0, 0) end,
    quit         = function() love.event.quit() end,
    -- fichiers
    loadFile     = function(name) return love.filesystem.load(name) end,
    readFile     = function(name) return love.filesystem.read(name) end,
    writeFile    = function(name, data) return love.filesystem.write(name, data) end,
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
  -- CRITIQUE (inputs) : désactive le mode saisie texte/IME. Quand il est
  -- actif (paramètre d'accessibilité du système, appui long → caractères
  -- spéciaux...), l'IME consomme les touches avant le polling :
  -- isDown("z")/isDown("s")/isDown("d") restent false pendant que
  -- d'autres touches passent — symptôme vécu. Un jeu qui n'a pas de
  -- champ de saisie ne doit JAMAIS laisser le text input actif ;
  -- réactivez-le (love.keyboard.setTextInput(true)) autour d'un
  -- éventuel champ texte, puis re-désactivez.
  love.keyboard.setTextInput(false)
  if config then
    if config.title then love.window.setTitle(config.title) end
    love.window.setMode(config.width, config.height, {
      resizable = config.resizable,
      vsync = config.vsync,
      fullscreen = config.fullscreen == true,
      highdpi = config.highdpi == true,
    })
  end
  api.setFont(api.newFont(11))
  api.setBackgroundColor(.4, .4, .4)
  core.engine.init(projectSetup)
end

-- ---- Callbacks LÖVE (traduction d'événements) ----
-- (game/main.lua délègue directement à adapter.* ; la config et le
-- setup du projet passent par adapter.boot(setup.run, setup.config))

function adapter.update(dt)
  core.engine.update(dt)
end

function adapter.draw()
  core.engine.draw()
end

function adapter.keypressed(key, scancode)
  -- Seul usage événementiel : quitter. Le gameplay lit son état
  -- clavier exclusivement par polling (engine.isBindDown -> isDown).
  if key == core.engine.getBindOf("quit") then
    love.event.quit()
  end
end

function adapter.mousepressed(x, y, button)
  core.engine.mouseX, core.engine.mouseY = x, y
  core.ui.mousePress(x, y, button)
end

function adapter.mousereleased(x, y, button)
  core.ui.mouseRelease(x, y, button)
end

function adapter.mousemoved(x, y, dx, dy)
  core.engine.mouseX, core.engine.mouseY = x, y
  core.ui.mouseMoved(x, y, dx, dy)
end

return adapter
