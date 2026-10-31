--------------------------------------------------------------------
-- game/main.lua : point d'entrée du JEU — partie TEMPLATE, ne le modifiez pas.
-- Votre logique vit dans game/setup.lua.
--
-- Layout du dépôt :
--   game/    → VOTRE projet (setup.lua, vos modules, vos assets)
--   tests/   → VOS tests (dépendent de game/)
--   .engine/ → le moteur du template (figé, ne jamais modifier)
--
-- Deux contextes d'exécution :
--   dev    : `love game` → .engine/src/engine/ est le FRÈRE du dossier
--            de jeu, requêtable comme "engine.*" via le path ci-dessous
--   .love  : archive → engine/ est EMBARQUÉ tel quel à la racine
--            (le packaging copie .engine/src/engine/ -> engine/)
--------------------------------------------------------------------

local source = love.filesystem.getSource()
-- Rend "engine.*" et "setup" requêtables. Redondant dans le .love
-- (le packaging reproduit la même arborescence), indispensable en
-- dev — et inoffensif dans les deux cas.
package.path = source .. "/?.lua;" ..
               source .. "/../.engine/src/?.lua;" ..
               source .. "/../.engine/src/?/init.lua;" ..
               package.path

require("engine")
local adapter = require("engine.adapter.love2d")
local setup = require("setup")

-- ---- Callbacks LÖVE : traduction vers l'adapter, config via setup ----
function love.load(arg)
  adapter.boot(setup.run, setup.config)
end

function love.update(dt)            adapter.update(dt) end
function love.draw()                adapter.draw() end
function love.keypressed(...)        adapter.keypressed(...) end
function love.mousepressed(...)      adapter.mousepressed(...) end
function love.mousereleased(...)     adapter.mousereleased(...) end
function love.mousemoved(...)        adapter.mousemoved(...) end

-- Error handler : en web (love.js), une erreur Lua n'apparait que dans
-- la console du navigateur, invisible pour un prototyper. On l'affiche
-- a l'ecran (fond sombre + texte rouge + stacktrace) pour la voir
-- directement dans le canvas, desktop comme web.
function love.errorhandler(msg)
  local trace = debug.traceback(tostring(msg), 2)
  return function()
    love.graphics.origin()
    love.graphics.setBackgroundColor(0.1, 0.05, 0.05)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("ERREUR Lua :", 20, 20, love.graphics.getWidth() - 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(trace, 20, 60, love.graphics.getWidth() - 40, "left", 0, 1, 1.2)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("(desktop : Ctrl+C / fermeture fenetre pour quitter ; web : rechargez la page)", 20, love.graphics.getHeight() - 30)
    love.graphics.present()
  end
end
