-- .luacheck.lua : configuration du linter luacheck.
-- Installation : luarocks install luacheck  (ou dnf install lua-luacheck)
-- Exécution   : scripts/lint.sh   (ou : luacheck game tests .engine)

-- Standard : LuaJIT (LÖVE) = dialecte 5.1 ; les tests tournent aussi
-- sur lua5.1+ (le runner accepte luajit ou lua).
std = "lua51+love"

-- Globals fournies par le template :
--   domain/core   : chargés globalement par require("engine")
--   façade base   : API historique (.engine/src/base.lua)
--   main          : module game historique
--   _TESTS_ROOT   : exporté par le runner de tests
globals = {
  "domain", "core", "main", "_TESTS_ROOT",
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
-- volontairement dynamiques ; les tests exposent des helpers globaux.
ignore = {
  "212/self",   -- self inutilisé dans certains callbacks (style historique)
  "542",        -- if/else vides attendus dans les mocks
}

-- Le dossier .engine est figé : on le lint quand même (il est couvert
-- par la CI du template), mais ses warnings ne bloquent pas votre jeu.
-- dist/ (builds) n'est jamais linté.
exclude_files = { "dist/*" }

cache = true
