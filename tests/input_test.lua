--------------------------------------------------------------------
-- tests/input_test.lua : INTÉGRATION — chaîne d'input complète.
-- Reproduit le chemin de prod avec le VRAI setup du projet :
--   touche tenue (love.keyboard.isDown en prod)
--     -> adapter backend isKeyDown
--     -> engine.isBindDown(action)
--     -> update du joueur (game/setup.lua)
--     -> déplacement effectif de l'entité
--
-- Chaque direction ZQSD est testée individuellement, plus les cas
-- limites : relâchement, diagonales, touches parasites.
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("intégration : chaîne d'input complète (ZQSD)", function()

  local m = mock.new()
  core.attach(m.backend)
  local engine = core.engine

  local ok, setup = pcall(require, "setup")
  harness.it("setup.lua chargé (pré requis de la batterie)", function()
    harness.assert_true(ok)
  end)

  -- Prépare un boot frais et retourne le joueur.
  local function bootFresh()
    m.held = {}
    engine.init(setup.run)
    return core.entities.find(function(e) return e.tag == "player" end)
  end

  local cases = {
    {key = "z", action = "up",    axis = "y", sign = -1},
    {key = "q", action = "left", axis = "x", sign = -1},
    {key = "s", action = "down", axis = "y", sign =  1},
    {key = "d", action = "right",axis = "x", sign =  1},
  }

  for _, c in ipairs(cases) do
    harness.it("touche '" .. c.key .. "' tenue -> le joueur va vers " .. c.action, function()
      local player = bootFresh()
      local start = player[c.axis]
      m.held[c.key] = true
      for i = 1, 30 do engine.update(1 / 60) end
      local moved = (player[c.axis] - start) * c.sign
      harness.assert_true(moved > 100,
        string.format("deplacement attendu >100 vers %s, obtenu %.1f", c.action, moved))
    end)

    harness.it("touche '" .. c.key .. "' relâchée -> le joueur s'arrête net", function()
      local player = bootFresh()
      m.held[c.key] = true
      for i = 1, 30 do engine.update(1 / 60) end
      m.held[c.key] = nil
      local frozen = player[c.axis]
      for i = 1, 15 do engine.update(1 / 60) end
      harness.assert_approx(player[c.axis], frozen, 1e-9)
    end)
  end

  harness.it("diagonale z+d : le joueur avance en x ET y", function()
    local player = bootFresh()
    local x0, y0 = player.x, player.y
    m.held["z"] = true
    m.held["d"] = true
    for i = 1, 30 do engine.update(1 / 60) end
    -- normalisation diagonale : chaque composante vaut speed*dt*sqrt(2)/2
    -- 30 frames * (260/60) * 0.707 ≈ 92 : seuil à 80 (au-delà du bruit,
    -- en-deçà de la vitesse pleine qui prouverait une norme incorrecte)
    harness.assert_true(player.x - x0 > 80, "dx attendu >80 (mvt diagonal)")
    harness.assert_true(y0 - player.y > 80, "dy attendu >80 (vers le haut)")
    -- et la norme vaut la vitesse pleine (normalisation correcte) :
    -- 260 px/s * 0.5 s = 130, ni plus (norme non corrigée), ni moins
    local dist = math.sqrt((player.x - x0)^2 + (player.y - y0)^2)
    harness.assert_approx(dist, 130, 0.5)
  end)

  harness.it("touche parasite (non bindée) : aucun mouvement", function()
    local player = bootFresh()
    local x0, y0 = player.x, player.y
    m.held["a"] = true -- pas un bind de la démo
    for i = 1, 30 do engine.update(1 / 60) end
    harness.assert_approx(player.x, x0, 1e-9)
    harness.assert_approx(player.y, y0, 1e-9)
  end)

  harness.it("aucune touche : aucun mouvement", function()
    local player = bootFresh()
    local x0, y0 = player.x, player.y
    for i = 1, 30 do engine.update(1 / 60) end
    harness.assert_approx(player.x, x0, 1e-9)
    harness.assert_approx(player.y, y0, 1e-9)
  end)

  harness.it("chaîne isBindDown -> isKeyDown : le polling voit bien chaque bind", function()
    bootFresh()
    for _, c in ipairs(cases) do
      harness.assert_eq(engine.getBindOf(c.action), c.key)
      m.held[c.key] = true
      harness.assert_true(engine.isBindDown(c.action))
      m.held[c.key] = nil
      harness.assert_false(engine.isBindDown(c.action))
    end
  end)
end)

return harness
