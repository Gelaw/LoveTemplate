-- .luacheck.lua : configuration du linter luacheck.
-- Installation : luarocks install luacheck  (ou dnf install lua-luacheck)
-- Exécution   : scripts/lint.sh   (ou : luacheck game tests .engine)

-- Le std lua51+love n'existe pas dans toutes les versions de luacheck :
-- on déclare lua51 et on déclare love.* comme globals à la main.
std = "lua51"

-- Globals fournies par le template :
--   domain/core : chargés globalement par require("engine")
--   love        : l'API LÖVE (le std love n'étant pas garanti)
--   façade base : API historique (.engine/src/engine/base.lua)
--   main        : module game historique
--   _TESTS_ROOT : exporté par le runner de tests
globals = {
  "love",
  "domain", "core", "main", "_TESTS_ROOT",
  -- façade base.lua (API historique)
  "applyParams", "addDrawFunction", "addUpdateFunction",
  "addBind", "getBindOf", "cameraShake",
  "camera", "entities", "particuleEffects",
  "uis", "mouseover", "pressed",
  "UIMouseMoved", "UIMousePress", "UIMouseRelease",
  "audioManager", "basicEntityDraw", "basicParticuleEffectDraw",
  "getPointsGlobalCoor", "checkIntersect", "findIntersect",
  "get_closest_point", "safeLoadAndRun",
}

-- Les callbacks d'entités (entity.draw, ui.onClick...) sont
-- volontairement dynamiques ; le self inutilisé est un style assumé
-- des callbacks LÖVE (function(self, dt) sans toujours utiliser self).
ignore = {
  "212/self",   -- argument self inutilisé dans les callbacks
  "212",        -- autres arguments inutilisés (callbacks LÖVE : x, y, button...)
  "211",        -- variables locales inutilisées (destructuring d'API)
  "542",        -- if/else vides attendus dans les mocks
}

-- dist/ (builds) n'est jamais linté.
exclude_files = { "dist/*" }

cache = true
