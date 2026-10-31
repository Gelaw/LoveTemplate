--------------------------------------------------------------------
-- tests/unit/serialize_test.lua : tests UNITAIRES — domaine pur
-- domain.serialize (encode/decode de tables plates, deterministe).
--------------------------------------------------------------------
local harness = require("engine.tests.lib.harness")

harness.describe("domain.serialize", function()

  harness.it("encode : types scalaires", function()
    harness.assert_eq(domain.serialize.encode({a = 1, b = "x", c = true, d = false}),
      '{"a"=1,"b"="x","c"=true,"d"=false}')
  end)

  harness.it("encode : cles triees (output deterministe)", function()
    harness.assert_eq(domain.serialize.encode({z = 1, a = 2, m = 3}),
      '{"a"=2,"m"=3,"z"=1}')
  end)

  harness.it("encode : table imbriquee", function()
    harness.assert_eq(domain.serialize.encode({outer = {inner = 42}}),
      '{"outer"={"inner"=42}}')
  end)

  harness.it("encode : echappement des strings (guillemets, backslash, saut de ligne)", function()
    local s = 'a"b\\c\nd'
    local encoded = domain.serialize.encode({v = s})
    harness.assert_eq(encoded, '{"v"="a\\"b\\\\c\\nd"}')
  end)

  harness.it("decode(encode(t)) == t (round-trip)", function()
    local t = {score = 123, lives = 3, name = 'jo"ueur\\1', flag = true, nested = {x = 1.5, y = -2}}
    local back = domain.serialize.decode(domain.serialize.encode(t))
    harness.assert_eq(back.score, 123)
    harness.assert_eq(back.lives, 3)
    harness.assert_eq(back.name, 'jo"ueur\\1')
    harness.assert_eq(back.flag, true)
    harness.assert_eq(back.nested.x, 1.5)
    harness.assert_eq(back.nested.y, -2)
  end)

  harness.it("decode : nil, false et 0 preservés", function()
    local back = domain.serialize.decode('{"a"=nil,"b"=false,"c"=0}')
    harness.assert_eq(back.b, false)
    harness.assert_eq(back.c, 0)
    harness.assert_true(back.a == nil)
  end)

  harness.it("decode : erreur sur entree invalide", function()
    local ok = pcall(domain.serialize.decode, '{"a"=???}')
    harness.assert_false(ok)
  end)

  harness.it("encode : nombre flottant round-trip precis", function()
    local back = domain.serialize.decode(domain.serialize.encode({pi = math.pi}))
    harness.assert_eq(back.pi, math.pi)
  end)
end)

return harness
