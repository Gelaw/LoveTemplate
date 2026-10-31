--------------------------------------------------------------------
-- examples/snake/main.lua : point d'entree pour lancer l'exemple snake
-- seul : `love examples/snake` (depuis la racine du template).
-- En .love/web, ce dossier n'est PAS package (package.sh ne zippe que
-- game/ + engine/) : c'est un exemple de lecture, pas un build.
--------------------------------------------------------------------
local source = love.filesystem.getSource()
package.path = source .. "/?.lua;" ..
               source .. "/../../?.lua;" ..
               source .. "/../../.engine/src/?.lua;" ..
               source .. "/../../.engine/src/?/init.lua;" ..
               package.path

require("engine")
local adapter = require("engine.adapter.love2d")
local setup = require("examples.snake.snake_setup")

function love.load(arg)
  adapter.boot(setup.run, setup.config)
end

function love.update(dt)            adapter.update(dt) end
function love.draw()                adapter.draw() end
function love.keypressed(...)        adapter.keypressed(...) end
function love.mousepressed(...)      adapter.mousepressed(...) end
function love.mousereleased(...)     adapter.mousereleased(...) end
function love.mousemoved(...)        adapter.mousemoved(...) end
