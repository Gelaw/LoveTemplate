--------------------------------------------------------------------
-- domain/serialize.lua : (de)serialisation pure de tables plates
-- (valeurs : nil, bool, number, string, table imbriquee).
-- Format texte lisible, sans dépendance externe (JSON-like maison) :
--   {"score"=10,"lives"=3,"name"="abc","nested"={"a"=1}}
-- Zéro LÖVE : testable en Lua nu. L'échappement des strings couvre
-- les guillemets, backslash et sauts de ligne.
--------------------------------------------------------------------
local serialize = {}

local function quote(str)
  return '"' .. str:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r") .. '"'
end

local function encode(value)
  local t = type(value)
  if t == "nil" then
    return "nil"
  elseif t == "boolean" then
    return tostring(value)
  elseif t == "number" then
    return string.format("%.17g", value)
  elseif t == "string" then
    return quote(value)
  elseif t == "table" then
    local parts = {}
    -- cles triees pour un output deterministe (utile en test/golden)
    local keys = {}
    for k in pairs(value) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do
      local key = type(k) == "string" and quote(k) or ("[" .. encode(k) .. "]")
      table.insert(parts, key .. "=" .. encode(value[k]))
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  error("serialize: type non supporté : " .. t, 2)
end

function serialize.encode(t)
  return encode(t)
end

-- Parseur recursif minimal pour le format produit par encode().
local function parse(str, pos)
  local function skipWs(p)
    while p <= #str and str:sub(p, p):match("%s") do p = p + 1 end
    return p
  end
  local function parseValue(p)
    p = skipWs(p)
    local c = str:sub(p, p)
    if c == "{" then
      local t = {}
      p = skipWs(p + 1)
      if str:sub(p, p) == "}" then return t, p + 1 end
      while true do
        p = skipWs(p)
        local key
        if str:sub(p, p) == '"' then
          local s, e = str:find('"', p + 1, true)
          local raw = str:sub(p + 1, (s or 0) - 1)
          key = raw:gsub("\\n", "\n"):gsub("\\r", "\r"):gsub('\\"', '"'):gsub("\\\\", "\\")
          p = (s or #str) + 1
        elseif str:sub(p, p) == "[" then
          key, p = parseValue(p + 1)
          p = skipWs(p)
          assert(str:sub(p, p) == "]", "']' attendu")
          p = p + 1
        else
          local s = p
          while p <= #str and not str:sub(p, p):match("[%s,}=]") do p = p + 1 end
          key = str:sub(s, p - 1)
        end
        p = skipWs(p)
        assert(str:sub(p, p) == "=", "'=' attendu")
        local v
        v, p = parseValue(p + 1)
        t[key] = v
        p = skipWs(p)
        local sep = str:sub(p, p)
        if sep == "," then p = p + 1
        elseif sep == "}" then return t, p + 1
        else error("',' ou '}' attendu, obtenu '" .. sep .. "'") end
      end
    elseif c == '"' then
      local i = p + 1
      local out = {}
      while i <= #str do
        local ch = str:sub(i, i)
        if ch == "\\" then
          local nxt = str:sub(i + 1, i + 1)
          if nxt == "n" then table.insert(out, "\n")
          elseif nxt == "r" then table.insert(out, "\r")
          elseif nxt == '"' then table.insert(out, '"')
          elseif nxt == "\\" then table.insert(out, "\\")
          else table.insert(out, nxt) end
          i = i + 2
        elseif ch == '"' then
          return table.concat(out), i + 1
        else
          table.insert(out, ch)
          i = i + 1
        end
      end
      error("string non terminee")
    else
      local s = p
      while p <= #str and not str:sub(p, p):match("[%s,}]") do p = p + 1 end
      local raw = str:sub(s, p - 1)
      if raw == "nil" then return nil, p
      elseif raw == "true" then return true, p
      elseif raw == "false" then return false, p
      else
        local n = tonumber(raw)
        assert(n, "valeur non reconnue : " .. raw)
        return n, p
      end
    end
  end
  local v, p = parseValue(skipWs(pos or 1))
  return v, p
end

function serialize.decode(str)
  local v = parse(str)
  return v
end

return serialize
