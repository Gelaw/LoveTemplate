--------------------------------------------------------------------
-- examples/snake/snake.lua : logique pure du snake (AUCUN love.*,
-- AUCUNE dependance moteur) : grille, serpent, nourriture, regles.
-- C'est le pattern recommande : toute la logique metier testable en
-- Lua nu (voir examples/snake/snake_test.lua), le rendu vit a cote
-- dans snake_setup.lua.
--------------------------------------------------------------------
local snake = {}

-- Directions : vecteurs unitaires (x, y)
snake.DIRS = {
  up = {x = 0, y = -1}, down = {x = 0, y = 1},
  left = {x = -1, y = 0}, right = {x = 1, y = 0},
}

-- Fabrique un nouvel etat de partie.
-- cols/rows : taille de la grille ; rng : fonction aleatoire injectee
-- (domain.mathx.rng en prod, RNG seed en test -> deterministe).
function snake.new(cols, rows, rng)
  cols = cols or 20
  rows = rows or 15
  rng = rng or math.random
  local s = {
    cols = cols, rows = rows, rng = rng,
    -- serpent : liste de segments {x,y}, tete en [1]
    body = {{x = math.floor(cols / 2), y = math.floor(rows / 2)}},
    dir = snake.DIRS.right,
    pendingDir = nil,     -- direction demandee (appliquee au prochain tick)
    food = nil,
    score = 0,
    gameover = false,
    tick = 0,             -- compteur de pas (utile en test)
  }
  s.food = snake.placeFood(s)
  return s
end

-- Place la nourriture sur une case libre (hors serpent).
function snake.placeFood(s)
  local occupied = {}
  for _, seg in ipairs(s.body) do occupied[seg.x .. "," .. seg.y] = true end
  local free = {}
  for x = 1, s.cols do
    for y = 1, s.rows do
      if not occupied[x .. "," .. y] then table.insert(free, {x = x, y = y}) end
    end
  end
  if #free == 0 then return nil end -- grille pleine : victoire
  return free[1 + math.floor(s.rng() * #free)]
end

-- Change de direction (jamais a 180 degres : ignorer si oppose).
function snake.setDir(s, name)
  local d = snake.DIRS[name]
  if not d then return end
  local cur = s.pendingDir or s.dir
  if d.x == -cur.x and d.y == -cur.y then return end -- demi-tour interdit
  s.pendingDir = d
end

local function sameCell(a, b) return a.x == b.x and a.y == b.y end

-- Un pas de jeu. Retourne la liste des evenements :
-- {"eat"} si nourriture mangee, {"gameover"} si mort.
function snake.step(s)
  local events = {}
  if s.gameover then return events end
  if s.pendingDir then
    s.dir = s.pendingDir
    s.pendingDir = nil
  end
  local head = s.body[1]
  local nx = head.x + s.dir.x
  local ny = head.y + s.dir.y
  -- murs -> mort
  if nx < 1 or ny < 1 or nx > s.cols or ny > s.rows then
    s.gameover = true
    table.insert(events, "gameover")
    return events
  end
  -- nourriture ? (on teste AVANT d'ajouter la tete : la queue bouge apres)
  local willEat = s.food ~= nil and nx == s.food.x and ny == s.food.y
  -- morsure sur soi-meme : on ignore la queue si elle va partir (pas de croissance)
  local limit = willEat and #s.body or (#s.body - 1)
  for i = 1, limit do
    if s.body[i].x == nx and s.body[i].y == ny then
      s.gameover = true
      table.insert(events, "gameover")
      return events
    end
  end
  table.insert(s.body, 1, {x = nx, y = ny})
  if willEat then
    s.score = s.score + 10
    table.insert(events, "eat")
    s.food = snake.placeFood(s)
  else
    table.remove(s.body) -- la queue avance
  end
  s.tick = s.tick + 1
  return events
end

function snake.head(s) return s.body[1] end

return snake
