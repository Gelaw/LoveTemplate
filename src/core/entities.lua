--------------------------------------------------------------------
-- core/entities.lua : registre d'entités, update, collisions, culling.
-- Les collisions pures sont déléguées à domain.geometry (testables).
-- Le rendu passe par core.api() (backend).
--------------------------------------------------------------------
local entities = { list = {} }

-- Ajoute une entité (x, y, w, h, angle, shape, color, update, draw,
-- collide, terminated...) et la retourne.
function entities.add(entity)
  table.insert(entities.list, entity)
  return entity
end

function entities.clear()
  entities.list = {}
end

function entities.count()
  return #entities.list
end

-- Rendu avec culling caméra. backendWidth/Height = dimensions du canvas.
function entities.draw(width, height, camera)
  local api = core.api()
  for e, entity in pairs(entities.list) do
    if math.abs(entity.x - camera.x) <= .75 * width / camera.scale
      and math.abs(entity.y - camera.y) <= .75 * height / camera.scale then
      api.push()
      if entity.draw then
        entity:draw()
      else
        entities.defaultDraw(entity)
      end
      api.pop()
    end
  end
end

-- Dessin par défaut (formes vectorielles) via le backend.
function entities.defaultDraw(entity)
  local api = core.api()
  if entity.color then
    api.setColor(entity.color)
  else
    api.setColor({0.8, 0.3, 1})
  end
  api.translate(entity.x, entity.y)
  if entity.angle then api.rotate(entity.angle) end
  if entity.shape == "rectangle" then
    local w, h = entity.w or entity.width, entity.h or entity.height
    api.rectangle("fill", -w / 2, -h / 2, w, h)
  elseif entity.shape == "circle" then
    api.circle("fill", 0, 0, entity.radius)
  end
end

-- Update : callbacks d'entités + détection de collisions par paires,
-- puis suppression des entités marquées terminated.
function entities.update(dt)
  local list = entities.list
  for e = #list, 1, -1 do
    local entity = list[e]
    if entity.update then
      entity:update(dt)
    end
    if entity.collide then
      for e2 = e + 1, #list do
        local entity2 = list[e2]
        if domain.geometry.entitiesCollide(entity, entity2) then
          entity2:collide(entity)
          -- la 1re collision a pu retirer collide de l'entité
          if entity.collide then
            entity:collide(entity2)
          end
        end
      end
    end
    if entity.terminated == true then
      table.remove(list, e)
    end
  end
end

return entities
