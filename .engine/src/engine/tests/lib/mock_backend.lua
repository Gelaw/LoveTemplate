--------------------------------------------------------------------
-- tests/lib/mock_backend.lua : backend de test pour core.
-- Rejoue l'interface de core.backend SANS LÖVE. Toutes les opérations
-- graphiques sont enregistrées (utile pour snapshot/déterminisme) ;
-- le temps est contrôlable ; l'audio produit des sources factices
-- dont on peut vérifier play/volume.
--------------------------------------------------------------------
local mock = { calls = {} }

function mock.new(config)
  config = config or {}
  local m = {
    time = config.time or 0,
    width = config.width or 960,
    height = config.height or 540,
    log = {},        -- séquence de toutes les opérations du backend
    drawCount = 0,
    quitters = 0,
    loadedFiles = config.loadedFiles or {}, -- nom -> chunk (pour loadFile)
  }

  local function record(op, ...)
    table.insert(m.log, string.format("%s(%s)", op, table.concat({...}, ", ")))
  end

  m.backend = {
    -- setColor accepte les deux formes LÖVE : table {r,g,b,a} ou 3-4 nombres
    setColor = function(...)
      local a = ...
      if type(a) == "table" then
        record("setColor", tostring(a[1]))
      else
        record("setColor", tostring(a))
      end
    end,
    translate = function(x, y) record("translate", tostring(x), tostring(y)) end,
    rotate = function(a) record("rotate", tostring(a)) end,
    scale = function(sx, sy) record("scale", tostring(sx), tostring(sy)) end,
    push = function() record("push") end,
    pop = function() record("pop") end,
    origin = function() record("origin") end,
    polygon = function(mode, pts) record("polygon", mode) end,
    rectangle = function(mode, x, y, w, h) record("rectangle", mode) end,
    circle = function(mode, x, y, r) record("circle", mode) end,
    print = function(text, x, y) record("print", tostring(text)) end,
    newFont = function(size) return {mock = true} end,
    setFont = function(f) record("setFont") end,
    setBackgroundColor = function(r, g, b) record("setBg") end,
    getWidth = function() return m.width end,
    getHeight = function() return m.height end,
    newQuad = function(x, y, w, h, sw, sh)
      return {x = x, y = y, w = w, h = h}
    end,
    draw = function(img, quad, x, y) record("draw") end,
    getTime = function() return m.time end,
    -- polling clavier : faux par defaut (les tests simulent plutot les
    -- evenements via engine.onBindPressed/onBindReleased, comme l'adapter
    -- reel avec love.keypressed/keyreleased).
    isKeyDown = function(key) return false end,
    setFullscreenMode = function() record("setMode") end,
    quit = function() m.quitters = m.quitters + 1 end,
    loadFile = function(name)
      local chunk = m.loadedFiles[name]
      if chunk then return chunk end
      error("fichier introuvable dans le mock: " .. name)
    end,
    newSource = function(path, type)
      return {
        mockSource = true, path = path, type = type,
        playing = false, volume = 1, looping = false, position = 0,
        play = function(s) s.playing = true end,
        pause = function(s) s.playing = false end,
        stop = function(s) s.playing = false; s.position = 0 end,
        seek = function(s, p) s.position = p end,
        setVolume = function(s, v) s.volume = v end,
        setLooping = function(s, l) s.looping = l end,
        isPlaying = function(s) return s.playing end,
        clone = function(s)
          local c = {}
          for k, v in pairs(s) do c[k] = v end
          return c
        end,
      }
    end,
    pauseAll = function() record("pauseAll") end,
  }

  -- Fait avancer le temps factice (déterministe).
  function m.advance(seconds)
    m.time = m.time + seconds
  end

  -- Renvoie le nombre d'appels à une opération (ex: "push").
  function m.count(op)
    local n = 0
    for _, entry in ipairs(m.log) do
      if entry:sub(1, #op) == op then n = n + 1 end
    end
    return n
  end

  function m.reset()
    m.log = {}
  end

  return m
end

return mock
