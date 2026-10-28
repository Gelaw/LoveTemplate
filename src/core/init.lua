--------------------------------------------------------------------
-- core/init.lua : couche CORE (moteur).
-- Dépend du domain (pur) mais jamais directement de LÖVE :
-- tout appel graphique/temps passe par le backend injecté
-- (core.backend), fourni par l'adapter (LÖVE desktop/web, ou un
-- mock pour les tests d'intégration).
--------------------------------------------------------------------
core = {}

-- Import via le préfixe complet "core.<module>" (fonctionne aussi
-- que core soit chargé par require("core") ou require("core.init")).
local function import(module)
  return require("core." .. module)
end

core.backend = nil -- injecté par l'adapter via core.attach(backend)

-- Injecte le backend (LÖVE réel en prod, mock dans les tests).
function core.attach(backend)
  core.backend = backend
  return backend
end

-- Accès protégé : erreur claire si l'adapter n'a pas attaché le backend.
function core.api()
  if not core.backend then
    error("core: aucun backend attaché — appelez core.attach(...) depuis l'adapter", 2)
  end
  return core.backend
end

core.camera   = import("camera")
core.entities = import("entities")
core.particles = import("particles")
core.ui       = import("ui")
core.audio    = import("audio")
core.engine   = import("engine")

return core
