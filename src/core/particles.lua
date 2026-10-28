--------------------------------------------------------------------
-- core/particles.lua : effets particulaires.
-- Durée de vie et onTermination ici ; le dessin passe par le backend.
--------------------------------------------------------------------
local particles = { list = {} }

function particles.add(pe)
  table.insert(particles.list, pe)
  return pe
end

function particles.clear()
  particles.list = {}
end

function particles.count()
  return #particles.list
end

-- Dessin par défaut : étoile à 8 branches animée par le temps.
function particles.defaultDraw(pe)
  local api = core.api()
  api.setColor(pe.color)
  api.translate(pe.x, pe.y)
  local t = api.getTime()
  for i = 1, 8 do
    api.push()
    api.translate(math.cos(60 * t + 10 * i) * pe.nudge / 2, math.sin(40 * t + 60 * i) * pe.nudge / 2)
    api.rotate(math.sin(t + 69 * i))
    api.polygon("fill", {pe.size, 0, 0, pe.size, -pe.size, 0, 0, -pe.size})
    api.pop()
  end
end

function particles.draw(width, height, camera)
  local api = core.api()
  for pe, particuleEffect in pairs(particles.list) do
    if math.abs(particuleEffect.x - camera.x) <= .75 * width / camera.scale
      and math.abs(particuleEffect.y - camera.y) <= .75 * height / camera.scale then
      api.push()
      if particuleEffect.draw then
        particuleEffect:draw()
      else
        particles.defaultDraw(particuleEffect)
      end
      api.pop()
    end
  end
end

-- Décrémente timeLeft, appelle onTermination, supprime les mortes.
function particles.update(dt)
  local list = particles.list
  for pe = #list, 1, -1 do
    local particuleEffect = list[pe]
    particuleEffect.timeLeft = particuleEffect.timeLeft - dt
    if particuleEffect.timeLeft <= 0 then
      if particuleEffect.onTermination then particuleEffect:onTermination() end
      table.remove(list, pe)
    end
  end
end

return particles
