--------------------------------------------------------------------
-- tests/unit/engine_test.lua : tests UNITAIRES — orchestrateur :
-- calques, bindings, chargement sûr.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("core.engine", function()

  local m = mock.new()
  core.attach(m.backend)
  local engine = core.engine

  harness.it("addBind/getBindOf", function()
    engine.addBind("x", "actionX")
    harness.assert_eq(engine.getBindOf("actionX"), "x")
    harness.assert_nil(engine.getBindOf("inconnue"))
  end)

  harness.it("addUpdateFunction : appelée par update(dt)", function()
    local got = nil
    local function cb(dt) got = dt end
    engine.addUpdateFunction(cb)
    engine.update(0.123)
    harness.assert_eq(got, 0.123)
  end)

  harness.it("safeLoadAndRun : chunk fourni par le backend", function()
    local ran = false
    m.loadedFiles["scenario.lua"] = function() ran = true end
    local ok = engine.safeLoadAndRun("scenario.lua")
    harness.assert_true(ok)
    harness.assert_true(ran)
  end)

  harness.it("safeLoadAndRun : erreur de chunk sans crash", function()
    m.loadedFiles["bad.lua"] = function() error("boom") end
    local ok, err = engine.safeLoadAndRun("bad.lua")
    harness.assert_false(ok)
    harness.assert_true(tostring(err):find("boom") ~= nil)
  end)

  harness.it("safeLoadAndRun : fichier manquant sans crash", function()
    local ok, err = engine.safeLoadAndRun("absent.lua")
    harness.assert_false(ok)
  end)

  harness.it("draw exécute les calques dans l'ordre via push/pop", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    local order = {}
    engine.addDrawFunction(function() table.insert(order, "fond") end, 1)
    engine.addDrawFunction(function() table.insert(order, "haut") end, 9)
    m2.reset()
    engine.draw()
    harness.assert_eq(order[1], "fond")
    harness.assert_eq(order[2], "haut")
    harness.assert_true(m2.count("push") >= 2)
  end)
end)

return harness
