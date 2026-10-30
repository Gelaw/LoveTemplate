--------------------------------------------------------------------
-- engine/init.lua : racine du MOTEUR du template (dossier .engine/).
-- Charge la couche domain (pure) puis la couche core (backend injecté).
-- L'adapter (adapter/love2d.lua) est chargé par game/main.lua au boot.
--
-- Ce dossier (.engine/) est la partie FIGÉE du template : un projet
-- ne le modifie jamais. Toute la logique projet vit dans game/.
--
-- Dépendances entre couches :
--   domain  : pur, zéro LÖVE, testable en Lua nu
--   core    : orchestration, touche l'extérieur via core.api()
--   adapter : seul endroit qui touche love.* (chargé au boot)
--
-- Les modules sont exposés dans les globals `domain` et `core` ;
-- les tests du template sont requêtables sous "engine.tests.*".
--------------------------------------------------------------------
require("engine.domain")
require("engine.core")
