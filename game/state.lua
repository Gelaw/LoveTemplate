--------------------------------------------------------------------
-- game/state.lua : EXEMPLE d'état de jeu pur (orienté données).
-- Ici vit la logique métier : règles, scoring, progression, victoire.
-- Pattern recommandé : cet état est une table plate sérialisable
-- (JSON-like), qu'on peut sauvegarder, recharger et tester sans LÖVE.
--
-- C'est un module PROJET (pas du moteur) : le moteur ne connaît pas
-- la notion d'état de jeu — libre à vous d'en faire une state machine
-- complète, ou de le supprimer si votre jeu n'en a pas besoin.
--------------------------------------------------------------------
local state = {}

-- Fabrique un nouvel état de jeu. Params optionnels pour les tests.
function state.new(params)
  params = params or {}
  local s = {
    score = params.score or 0,
    lives = params.lives or 3,
    time = params.time or 0,
    level = params.level or 1,
    gameover = params.gameover or false,
    -- liste plate d'événements du dernier update (utile en tests)
    events = {},
  }
  return s
end

-- Un pas de logique pur : avance le temps, gère les règles.
-- Retourne la liste des événements produits (pour assertions).
function state.update(s, dt)
  local events = {}
  if not s.gameover then
    s.time = s.time + dt
  end
  s.events = events
  return events
end

-- Ajoute du score avec plancher à zéro.
function state.addScore(s, points)
  s.score = math.max(0, s.score + points)
  return s.score
end

-- Perd une vie ; déclenche gameover à zéro.
function state.loseLife(s)
  s.lives = s.lives - 1
  if s.lives <= 0 then
    s.lives = 0
    s.gameover = true
    return true
  end
  return false
end

-- Réinitialisation (nouvelle partie).
function state.reset(s, params)
  local fresh = state.new(params)
  for k, v in pairs(fresh) do s[k] = v end
  return s
end

return state
