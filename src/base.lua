--------------------------------------------------------------------
-- base.lua : façade de compatibilité.
-- L'ancien base.lua monolithique a été éclaté en domain/core/adapter.
-- Ce fichier ne fait qu'exposer l'API historique (addDrawFunction,
-- camera, entities, applyParams, math.*, etc.) pour que les anciens
-- modules marchent sans réécriture. Charger APRÈS core.
--------------------------------------------------------------------
require("domain")
require("core")

-- Helpers historiques ------------------------------------------------
applyParams = domain.applyParams

-- Loop / calques -----------------------------------------------------
addDrawFunction    = core.engine.addDrawFunction
addUpdateFunction  = core.engine.addUpdateFunction
addBind            = core.engine.addBind
getBindOf          = core.engine.getBindOf

-- Caméra ---------------------------------------------------------------
camera      = core.camera
cameraShake = function(intensity, duration) core.camera.shake(intensity, duration) end

-- Entités / particules (compat : tables globales historiques) ----------
entities         = core.entities.list
particuleEffects = core.particles.list

-- UI -------------------------------------------------------------------
uis       = core.ui.list
mouseover = nil -- géré par core.ui
function UIMouseMoved(x, y, dx, dy)  return core.ui.mouseMoved(x, y, dx, dy) end
function UIMousePress(x, y, button)  return core.ui.mousePress(x, y, button) end
function UIMouseRelease(x, y, button) return core.ui.mouseRelease(x, y, button) end

-- Audio ------------------------------------------------------------------
audioManager = core.audio

-- Dessins par défaut historiques ------------------------------------------
basicEntityDraw        = core.entities.defaultDraw
basicParticuleEffectDraw = core.particles.defaultDraw

-- Hitbox historique ------------------------------------------------------
getPointsGlobalCoor = domain.geometry.getPointsGlobalCoor
checkIntersect      = domain.geometry.checkIntersect
findIntersect       = domain.geometry.findIntersect
get_closest_point   = domain.geometry.get_closest_point

-- Chargement sûr ----------------------------------------------------------
safeLoadAndRun = core.engine.safeLoadAndRun

-- Géométrie dans l'espace global `math` (déjà mergé par domain/init) ------
-- math.dist, math.angle, math.clamp, ... : faits par domain.init.
