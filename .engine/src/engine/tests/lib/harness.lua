--------------------------------------------------------------------
-- tests/lib/harness.lua : mini framework de tests maison (zéro dépendance).
-- Usage :
--   local t = require("engine.tests.lib.harness")
--   t.describe("mathx.clamp", function()
--     t.it("clamp au minorant", function()
--       t.assert.eq(domain.mathx.clamp(0, -5, 5), 0)
--     end)
--   end)
--------------------------------------------------------------------
local harness = {
  passed = 0, failed = 0,
  current = "?",
  errors = {},
}

function harness.describe(name, fn)
  local prev = harness.current
  harness.current = name
  local ok, err = pcall(fn)
  if not ok then
    harness.failed = harness.failed + 1
    table.insert(harness.errors, string.format("[%s] ERREUR: %s", name, tostring(err)))
  end
  harness.current = prev
end

function harness.it(desc, fn)
  local ok, err = pcall(fn)
  if ok then
    harness.passed = harness.passed + 1
  else
    harness.failed = harness.failed + 1
    table.insert(harness.errors, string.format("[%s] %s\n    %s", harness.current, desc, tostring(err)))
  end
end

function harness.assert_eq(actual, expected)
  if type(actual) == 'number' and type(expected) == 'number' then
    if math.abs(actual - expected) < 1e-9 then return true end
  end
  if actual == expected then return true end
  error(string.format("attendu: %s, obtenu: %s (%s)",
    tostring(expected), tostring(actual), harness.current), 2)
end

function harness.assert_true(v)
  if v then return true end
  error("attendu: vrai, obtenu: " .. tostring(v), 2)
end

function harness.assert_false(v)
  if not v then return true end
  error("attendu: faux, obtenu: " .. tostring(v), 2)
end

function harness.assert_nil(v)
  if v == nil then return true end
  error("attendu: nil, obtenu: " .. tostring(v), 2)
end

function harness.assert_approx(actual, expected, eps)
  eps = eps or 1e-6
  if math.abs(actual - expected) <= eps then return true end
  error(string.format("attendu ~%s (±%s), obtenu %s",
    tostring(expected), tostring(eps), tostring(actual)), 2)
end

function harness.report()
  print(string.rep("-", 60))
  if #harness.errors > 0 then
    print("ÉCHECS :")
    for _, e in ipairs(harness.errors) do
      print("  " .. e)
    end
    print(string.rep("-", 60))
  end
  print(string.format("Tests : %d réussis, %d échoués",
    harness.passed, harness.failed))
  return harness.failed == 0
end

return harness
