--------------------------------------------------------------------
-- tests/lib/deterministic.lua : RNG déterministe (seed fixe) pour
-- brancher dans domain.mathx.rng afin de rendre les tests reproductibles.
--------------------------------------------------------------------
local deterministic = {}

function deterministic.newRng(seed)
  seed = seed or 42
  local state = seed
  local rng = function(a, b)
    -- Générateur congruentiel simple (suffisant pour les tests)
    state = (state * 1103515245 + 12345) % 2147483648
    local r = state / 2147483648 -- [0, 1)
    if a and b then
      return math.floor(r * (b - a + 1)) + a
    elseif a then
      return math.floor(r * a) + 1
    end
    return r
  end
  return rng
end

-- Branche le RNG dans domain.mathx (et retourne une fonction de restauration).
function deterministic.install(seed)
  local mathx = domain and domain.mathx
  if not mathx then error("domain.mathx non chargé — require domain d'abord") end
  local saved = mathx.rng
  mathx.rng = deterministic.newRng(seed)
  return function() mathx.rng = saved end
end

return deterministic
