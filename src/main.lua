--------------------------------------------------------------------
-- main.lua : point d'entrée du TEMPLATE — ne modifiez pas ce fichier.
--
-- Le template est figé : dupliquez le projet et travaillez uniquement
-- dans src/game/ (game.config, game.setup, et vos modules).
-- Ce fichier ne fait que : charger les couches, câbler l'adapter LÖVE
-- et déléguer à game.
--------------------------------------------------------------------
require("domain")
require("core")
local adapter = require("adapter.love2d")
local game = require("game")

-- ---- Callbacks LÖVE : traduction vers l'adapter, config via game ----
function love.load(arg)
  adapter.boot(game.setup, game.config)
end

function love.update(dt)            adapter.update(dt) end
function love.draw()                adapter.draw() end
function love.keypressed(key)       adapter.keypressed(key) end
function love.mousepressed(...)      adapter.mousepressed(...) end
function love.mousereleased(...)     adapter.mousereleased(...) end
function love.mousemoved(...)        adapter.mousemoved(...) end
