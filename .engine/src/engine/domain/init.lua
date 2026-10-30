--------------------------------------------------------------------
-- domain/init.lua : couche DOMAINE — 100% pure, zéro dépendance LÖVE.
-- Toute la logique testable sans moteur graphique vit ici :
-- math, géométrie, état du jeu, règles, IA, scores, niveaux...
-- Ne jamais importer love.* ni core.* depuis ce dossier.
--------------------------------------------------------------------
domain = {}

-- Compat LuaJIT / Lua 5.3+ (math.atan2 supprimé en Lua 5.3 ;
-- LÖVE utilise LuaJIT qui l'a, les tests peuvent tourner en 5.3+).
if not math.atan2 then
  math.atan2 = function(y, x) return math.atan(y, x) end
end

-- Import via le préfixe complet "domain.<module>" (fonctionne aussi
-- que domain soit chargé par require("engine.domain") ou directement).
local function import(module)
  return require("engine.domain." .. module)
end

domain.mathx    = import("mathx")
domain.geometry = import("geometry")
domain.state    = import("state")

-- Helper historique : copie les champs de params dans t.
function domain.applyParams(t, params)
  if params then
    for p, parameter in pairs(params) do t[p] = parameter end
  end
  return t
end

-- Merge les fonctions mathx dans math (compat base.lua)
for k, v in pairs(domain.mathx) do math[k] = math[k] or v end

return domain
