--------------------------------------------------------------------
-- tests/regression/golden_test.lua : NON-RÉGRESSION.
-- Rejoue la simulation de référence (tests/regression/simulation.lua)
-- et compare l'état final au golden file validé (tests/golden/).
-- - Changement de comportement VOLONTAIRE : scripts/update-golden.sh
-- - Échec inattendu : régression détectée.
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local simulation = require("tests.regression.simulation")

local GOLDEN_PATH = "tests/golden/golden.txt"

harness.describe("non-régression (golden file)", function()

  harness.it("la simulation est déterministe (2 exécutions identiques)", function()
    local a = simulation.snapshot()
    local b = simulation.snapshot()
    harness.assert_eq(a, b)
  end)

  harness.it("l'état final correspond au golden file", function()
    local ok, msg = simulation.checkGolden(GOLDEN_PATH)
    if not ok then
      error(msg)
    end
  end)
end)

return harness
