--------------------------------------------------------------------
-- core/camera.lua : caméra + secousses.
-- N'utilise pas love.graphics directement : les transformations
-- passent par core.api() (le backend peut être un mock de test).
--------------------------------------------------------------------
local camera = {
  x = 0, y = 0, scale = 1, angle = 0, mode = nil,
  shaker = { steps = {}, n = 1, stepTimer = 0, shakeTimer = 0 },
  boxSize = 100,
}

-- Applique la transformation caméra via le backend graphique.
function camera:apply()
  local api = core.api()
  local shaker = self.shaker
  if shaker.steps[shaker.n] then
    local c = shaker.stepTimer - shaker.steps[shaker.n].time
    api.translate(c * shaker.steps[shaker.n].dx, c * shaker.steps[shaker.n].dy)
  end
  api.rotate(self.angle)
  api.scale(self.scale, self.scale)
  api.translate(-self.x, -self.y)
end

function camera:update(dt)
  local shaker = self.shaker
  shaker.shakeTimer = shaker.shakeTimer - dt
  if shaker.shakeTimer <= 0 then
    shaker.steps = {}
    shaker.n = 1
    shaker.stepTimer = 0
  elseif shaker.steps[shaker.n] then
    shaker.stepTimer = shaker.stepTimer + dt
    if shaker.stepTimer >= shaker.steps[shaker.n].time then
      shaker.stepTimer = shaker.stepTimer - shaker.steps[shaker.n].time
      shaker.n = shaker.n % #shaker.steps + 1
    end
  end
  if self.mode == nil then return end
  if self.mode[1] == "follow" then
    if self.mode[2].x and self.mode[2].y then
      self.x, self.y = self.mode[2].x, self.mode[2].y
    end
  end
  if self.mode[1] == "moveTo" then
    if self.mode[2].x and self.mode[2].y then
      self.x, self.y = self.mode[2].x, self.mode[2].y
      self.mode = nil
    end
  end
end

-- Secousse aléatoire (via le RNG du domain pour la déterminabilité en test).
function camera.shake(intensity, duration)
  local mathx = domain.mathx
  camera.shaker.shakeTimer = duration
  for i = 1, 10 do
    camera.shaker.steps[i] = {
      dx = mathx.rsign() * intensity / 2,
      dy = mathx.rsign() * intensity / 2,
      time = 0.1
    }
  end
end

return camera
