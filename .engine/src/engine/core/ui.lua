--------------------------------------------------------------------
-- core/ui.lua : système d'UI (hiérarchie, hit-test souris, tooltips).
-- Rendu via backend ; hit-test 100% géométrique donc testable.
--------------------------------------------------------------------
local ui = { list = {}, mouseover = nil, pressed = nil }

function ui.add(element)
  table.insert(ui.list, element)
  return element
end

function ui.clear()
  ui.list = {}
  ui.mouseover = nil
  ui.pressed = nil
end

-- Dessin récursif d'un élément et de ses enfants.
function ui.drawElementAndChildren(element)
  local api = core.api()
  if not element.hidden and element.draw then
    api.push()
    if element.x and element.y then
      api.translate(element.x, element.y)
    end
    element:draw()
    if element.children then
      for c, child in pairs(element.children) do
        ui.drawElementAndChildren(child)
      end
    end
    api.pop()
  end
end

-- Couche UI complète (appelée sur le calque 9 par engine).
function ui.draw()
  local api = core.api()
  api.origin()
  for u, element in pairs(ui.list) do
    ui.drawElementAndChildren(element)
  end
  if ui.mouseover then
    if ui.mouseover.drawTooltip then
      ui.mouseover:drawTooltip()
    else
      ui.defaultDrawTooltip(ui.mouseover)
    end
  end
end

-- Hit-test : élément (ou enfant) le plus profond sous (x, y).
function ui.getElementOn(x, y)
  local element
  for u, elem in pairs(ui.list) do
    element = ui.getElementOrChildOn(elem, x, y)
    if element then return element end
  end
end

function ui.getElementOrChildOn(element, x, y)
  local w = element.w or element.width
  local h = element.h or element.height
  if not element.hidden and element.x and element.y and w and h then
    if x >= element.x and x <= element.x + w and y >= element.y and y <= element.y + h then
      if element.children then
        for c, child in pairs(element.children) do
          local found = ui.getElementOrChildOn(child, x - element.x, y - element.y)
          if found then
            found.px, found.py = x - element.x - child.x, y - element.y - child.y
            return found
          end
        end
      end
      return element
    end
  end
end

-- Les 3 fonctions suivantes retournent true si l'UI a consommé l'événement.
function ui.mouseMoved(x, y, dx, dy)
  ui.mouseover = nil
  local element = ui.getElementOn(x, y)
  if not ui.pressed and element and element.tooltip then
    ui.mouseover = element
    return true
  end
  return false
end

function ui.mousePress(x, y, button)
  ui.pressed = nil
  local element = ui.getElementOn(x, y)
  if element and (element.onClick or element.onPress) then
    if element.onPress then element:onPress() end
    ui.pressed = element
    return true
  end
  return false
end

function ui.mouseRelease(x, y, button)
  local element = ui.getElementOn(x, y)
  if element and element.onClick and ui.pressed == element then
    element:onClick()
  end
  ui.pressed = nil
  return (element ~= nil)
end

-- ============================================================
-- Widgets prets a l'emploi (construits sur ui.add + hit-test) :
-- label (texte) et button (rectangle + texte + onClick + hover).
-- ============================================================

-- Label : texte simple en (x, y). opts: color, w (largeur de wrap pour
-- "center"/"right"), align ("left"/"center"/"right").
function ui.label(x, y, text, opts)
  opts = opts or {}
  local el = {
    x = x, y = y, w = opts.w or 400, h = opts.h or 20,
    text = text, color = opts.color or {1, 1, 1}, align = opts.align or "left",
    draw = function(self)
      local api = core.api()
      if self.color then api.setColor(self.color) end
      api.printf(self.text, self.x, self.y, self.w, self.align)
    end,
  }
  return ui.add(el)
end

-- Button : rectangle + texte centre + onClick + hover (couleur changee).
-- opts: color (fond), hoverColor, textColor, onClick.
function ui.button(x, y, w, h, text, opts)
  opts = opts or {}
  local el = {
    x = x, y = y, w = w, h = h,
    text = text,
    color = opts.color or {0.25, 0.45, 0.8},
    hoverColor = opts.hoverColor or {0.35, 0.55, 0.95},
    textColor = opts.textColor or {1, 1, 1},
    onClick = opts.onClick,
    draw = function(self)
      local api = core.api()
      local isHover = core.engine.mouseX and core.ui.getElementOn(core.engine.mouseX, core.engine.mouseY) == self
      api.setColor(isHover and self.hoverColor or self.color)
      api.rectangle("fill", self.x, self.y, self.w, self.h)
      api.setColor(self.textColor)
      api.printf(self.text, self.x, self.y + self.h / 2 - 6, self.w, "center")
    end,
  }
  return ui.add(el)
end

-- Tooltip par defaut pour un element : affiche element.tooltip en
-- dessous de la souris (utilise par ui.draw si element.tooltip existe).
function ui.defaultDrawTooltip(element)
  local api = core.api()
  if not element.tooltip then return end
  local mx, my = core.engine.mouseX or 0, core.engine.mouseY or 0
  api.setColor(0.1, 0.1, 0.12, 0.9)
  api.rectangle("fill", mx + 12, my + 12, 8 + #element.tooltip * 6, 18)
  api.setColor(1, 1, 1)
  api.print(element.tooltip, mx + 16, my + 15)
end

return ui
