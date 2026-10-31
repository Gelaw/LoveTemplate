--------------------------------------------------------------------
-- game/conf.lua : configuration LÖVE — partie TEMPLATE, ne le modifiez pas.
-- La config fenêtre vit dans game/setup.lua (setup.config) ; ce fichier
-- se contente de l'appliquer. LÖVE charge conf.lua avant main.lua :
-- le require aménage le path pour trouver .engine/ et setup.
--------------------------------------------------------------------
package.path = ".engine/src/?.lua;.engine/src/?/init.lua;./?.lua;" .. package.path
local ok, setup = pcall(require, "setup")

function love.conf(t)
  local config = (ok and setup and setup.config) or {}
  t.window.title = config.title or "Love2D Web Template"
  t.window.width = config.width or 960
  t.window.height = config.height or 540
  t.window.resizable = config.resizable ~= false
  t.window.vsync = config.vsync or 1
  -- Pass-through optionnel depuis setup.config (tous faux/nil par defaut) :
  if config.fullscreen then t.window.fullscreen = true end
  if config.highdpi then t.window.highdpi = true end
  if config.msaa then t.window.msaa = config.msaa end
  if config.display then t.window.display = config.display end
  -- IMPORTANT (compatibilité web) : le paquet npm love.js embarque
  -- LÖVE 11.4. Si t.version est supérieur (ex. "11.5"), le jeu affiche
  -- un avertissement "may not be compatible" au lancement dans le
  -- navigateur. Le jeu tourne quand même ; mettez la version du build
  -- love.js que vous utilisez pour éviter l'avertissement, ou gardez
  -- votre version desktop ici si vous ne visez que le desktop.
  t.version = "11.4"
  -- love.thread désactivé : le build web (love.js, mode compatibilité)
  -- n'a pas de threads. Réactivez-le si votre jeu en a besoin ET si
  -- vous visez uniquement le desktop.
  t.modules.thread = false
end
