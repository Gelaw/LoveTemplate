function love.conf(t)
  t.window.title = "Love2D Web Template"
  t.window.width = 960
  t.window.height = 540
  t.window.resizable = true
  t.window.vsync = 1
  -- IMPORTANT (compatibilite web) : le paquet npm love.js embarque
  -- LÖVE 11.4. Si t.version est superieur (ex. "11.5"), le jeu affiche
  -- un avertissement "may not be compatible" au lancement dans le
  -- navigateur. Le jeu tourne quand meme ; mettez la version du build
  -- love.js que vous utilisez pour eviter l'avertissement, ou gardez
  -- votre version desktop ici si vous ne visez que le desktop.
  t.version = "11.4"
  -- Sur le web (love.js), love.thread n'est pas disponible en mode
  -- compatibilite ; gardez t.thread et t.audio.mixwithbackground
  -- simples si vous visez le build web.
  t.modules.thread = true
end
