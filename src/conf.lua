function love.conf(t)
  t.window.title = "Love2D Web Template"
  t.window.width = 960
  t.window.height = 540
  t.window.resizable = true
  t.window.vsync = 1
  t.version = "11.5"
  -- Sur le web (love.js), love.thread n'est pas disponible en mode
  -- compatibilite ; gardez t.thread et t.audio.mixwithbackground
  -- simples si vous visez le build web.
  t.modules.thread = true
end
