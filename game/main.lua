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
function love.keyreleased(...)       adapter.keyreleased(...) end
function love.mousepressed(...)      adapter.mousepressed(...) end
function love.mousereleased(...)     adapter.mousereleased(...) end
function love.mousemoved(...)        adapter.mousemoved(...) end
