--------------------------------------------------------------------
-- tests/lib/deterministic.lua : RNG déterministe (seed fixe) pour
-- brancher dans domain.mathx.rng afin de rendre les tests reproductibles.
--
-- Portabilité : Lehmer RNG (state * 48271) % 2147483647. Le produit
-- max (48271 * 2147483646 ≈ 1.04e14) reste sous 2^53, donc le calcul
-- est EXACT aussi bien en double (LuaJIT/Lua 5.1) qu'en entier 64 bits
-- (Lua 5.3+) : même séquence sur tous les interpréteurs.
--------------------------------------------------------------------
local deterministic = {}

local MODULUS = 2147483647 -- 2^31 - 1 (premier de Mersenne)
local MULTIPLIER = 48271  -- racine primitive de MODULUS

function deterministic.newRng(seed)
  seed = seed or 42
  -- Lehmer exige 1 <= state <= MODULUS-1
  local state = (seed % (MODULUS - 1)) + 1
  local rng = function(a, b)
    state = (state * MULTIPLIER) % MODULUS
    local r = state / MODULUS -- [0, 1)
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
