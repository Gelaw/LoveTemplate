--------------------------------------------------------------------
-- tests/unit/ui_test.lua : tests UNITAIRES — hit-test UI (core).
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")
local mock = require("engine.tests.lib.mock_backend")

harness.describe("core.ui", function()

  local m = mock.new()
  core.attach(m.backend)

  local function freshUI()
    core.ui.clear()
    return core.ui.add({
      x = 10, y = 10, w = 100, h = 50,
      draw = function(self) end,
    })
  end

  harness.it("getElementOn trouve un point dans l'élément", function()
    local el = freshUI()
    harness.assert_eq(core.ui.getElementOn(50, 30), el)
  end)

  harness.it("getElementOn ignore un point hors de l'élément", function()
    freshUI()
    harness.assert_nil(core.ui.getElementOn(500, 500))
  end)

  harness.it("hit-test récursif : enfant trouvé avant parent", function()
    core.ui.clear()
    local parent = core.ui.add({
      x = 0, y = 0, w = 200, h = 200,
      draw = function(self) end,
      children = {
        {x = 100, y = 100, w = 50, h = 50, draw = function(self) end},
      },
    })
    local found = core.ui.getElementOn(120, 120)
    harness.assert_eq(found, parent.children[1])
  end)

  harness.it("mousePress/Release déclenche onClick si pressé dedans", function()
    local clicked = false
    core.ui.clear()
    core.ui.add({
      x = 0, y = 0, w = 50, h = 50,
      onClick = function(self) clicked = true end,
      draw = function(self) end,
    })
    harness.assert_true(core.ui.mousePress(10, 10, 1))
    harness.assert_true(core.ui.mouseRelease(10, 10, 1))
    harness.assert_true(clicked)
  end)

  harness.it("mouseRelease hors de l'élément : pas de onClick", function()
    local clicked = false
    core.ui.clear()
    core.ui.add({
      x = 0, y = 0, w = 50, h = 50,
      onClick = function(self) clicked = true end,
      draw = function(self) end,
    })
    core.ui.mousePress(10, 10, 1)
    core.ui.mouseRelease(500, 500, 1)
    harness.assert_false(clicked)
  end)

  harness.it("onPress appelé au press, onClick seulement au release", function()
    local pressed, clicked = false, false
    core.ui.clear()
    core.ui.add({
      x = 0, y = 0, w = 50, h = 50,
      onPress = function(self) pressed = true end,
      onClick = function(self) clicked = true end,
      draw = function(self) end,
    })
    core.ui.mousePress(10, 10, 1)
    harness.assert_true(pressed)
    harness.assert_false(clicked)
    core.ui.mouseRelease(10, 10, 1)
    harness.assert_true(clicked)
  end)

  harness.it("élément caché : ni hit ni draw", function()
    core.ui.clear()
    local el = core.ui.add({
      x = 0, y = 0, w = 50, h = 50, hidden = true,
      onClick = function(self) end, draw = function(self) end,
    })
    harness.assert_nil(core.ui.getElementOn(10, 10))
  end)

  harness.it("tooltip : mouseMoved sélectionne l'élément survolé", function()
    core.ui.clear()
    local el = core.ui.add({
      x = 0, y = 0, w = 50, h = 50,
      tooltip = {drawTooltip = function(self) end},
      draw = function(self) end,
    })
    harness.assert_true(core.ui.mouseMoved(10, 10, 0, 0))
    harness.assert_eq(core.ui.mouseover, el)
  end)

  harness.it("widget button : onClick déclenché au clic, draw produit rectangle+printf", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.ui.clear()
    local clicked = 0
    local btn = core.ui.button(10, 10, 120, 40, "Jouer", {onClick = function() clicked = clicked + 1 end})
    harness.assert_eq(btn.x, 10)
    harness.assert_eq(btn.w, 120)
    -- clic dedans -> onClick
    core.ui.mousePress(20, 20, 1)
    core.ui.mouseRelease(20, 20, 1)
    harness.assert_eq(clicked, 1)
    -- draw : rectangle + texte centre
    m2.reset()
    core.ui.draw()
    harness.assert_true(m2.count("rectangle") >= 1)
    harness.assert_true(m2.count("printf") >= 1)
  end)

  harness.it("widget button : hover change la couleur quand la souris est dessus", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.ui.clear()
    local btn = core.ui.button(0, 0, 100, 40, "Go", {color = {1, 0, 0}, hoverColor = {0, 1, 0}})
    core.engine.mouseX, core.engine.mouseY = 50, 20 -- souris sur le bouton
    m2.reset()
    core.ui.draw()
    -- le fond hover (0,1,0) doit etre pose avant le rectangle
    local sawHover = false
    for _, entry in ipairs(m2.log) do
      if entry:find("setColor%(0, 1, 0") then sawHover = true end
    end
    harness.assert_true(sawHover)
    core.engine.mouseX, core.engine.mouseY = nil, nil
  end)

  harness.it("widget label : draw appelle printf avec le texte et l'alignement", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.ui.clear()
    local lbl = core.ui.label(5, 5, "Score: 42", {align = "center", w = 200})
    m2.reset()
    core.ui.draw()
    local sawText = false
    for _, entry in ipairs(m2.log) do
      if entry:find("printf%(Score: 42") then sawText = true end
    end
    harness.assert_true(sawText)
  end)

  harness.it("defaultDrawTooltip : dessine le texte du tooltip sous la souris", function()
    local m2 = mock.new()
    core.attach(m2.backend)
    core.engine.mouseX, core.engine.mouseY = 100, 100
    core.ui.defaultDrawTooltip({tooltip = "Indice !"})
    local saw = false
    for _, entry in ipairs(m2.log) do
      if entry:find("print%(Indice") then saw = true end
    end
    harness.assert_true(saw)
    core.engine.mouseX, core.engine.mouseY = nil, nil
  end)

  harness.it("engine.mouseX/Y remis a nil par engine.init", function()
    core.engine.mouseX, core.engine.mouseY = 12, 34
    core.engine.init(function() end)
    harness.assert_nil(core.engine.mouseX)
    harness.assert_nil(core.engine.mouseY)
  end)
end)

return harness
