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

  harness.it("letterbox inactif par defaut : pas d'origin/setBackgroundColor de letterbox", function()
    local m2 = mock.new({width = 960, height = 540})
    core.attach(m2.backend)
    engine.width, engine.height = 960, 540
    engine.letterbox = nil
    m2.reset()
    engine.draw()
    harness.assert_eq(m2.count("origin"), 0)
    harness.assert_eq(m2.count("setBg"), 0)
  end)

  harness.it("letterbox actif : origin + scale(min) + centrage, fond noir", function()
    local m2 = mock.new({width = 1920, height = 540}) -- canvas 2x plus large
    core.attach(m2.backend)
    engine.width, engine.height = 1920, 540
    engine.virtualWidth, engine.virtualHeight = 960, 540
    engine.letterbox = true
    m2.reset()
    engine.draw()
    harness.assert_true(m2.count("origin") >= 1)
    harness.assert_true(m2.count("scale") >= 1)
    harness.assert_true(m2.count("setBg") >= 1)
    -- scale = min(1920/960, 540/540) = 1 ; centrage x = (1920-960*1)/2 = 480
    local saw480 = false
    for _, entry in ipairs(m2.log) do
      if entry:find("translate%(480") then saw480 = true end
    end
    harness.assert_true(saw480)
    engine.letterbox = nil
  end)

  harness.it("engine.init remet letterbox a nil", function()
    engine.letterbox = true
    engine.init(function() end)
    harness.assert_nil(engine.letterbox)
  end)
end)

return harness
