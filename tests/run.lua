--------------------------------------------------------------------
-- tests/run.lua : runner principal (Lua pur, aucun LÖVE requis).
-- Exécution depuis la racine du projet :
--   lua tests/run.lua               (ou lua5.1/luajit)
--   lua tests/run.lua unit          (seulement les unitaires)
--   lua tests/run.lua regression
--   lua tests/run.lua integration
--   lua tests/run.lua golden        (génère tests/golden/golden.txt)
--------------------------------------------------------------------

-- Chemins : la racine est le dossier qui contient src/ et tests/,
-- quel que soit le CWD d'appel. On sonde : (1) le parent du chemin de
-- script (tests/..), (2) le CWD courant, (3) le parent du CWD (cas où
-- on lance "lua run.lua" depuis tests/).
local script = arg[0] or "tests/run.lua"
local scriptDir = script:match("^(.-)[^/\\]+$") or ""
local candidates = {}
if scriptDir ~= "" then
  table.insert(candidates, (scriptDir:gsub("tests[/\\]$", "")))
  table.insert(candidates, scriptDir)
end
table.insert(candidates, "./")
table.insert(candidates, "../")
local root = "./"
for _, dir in ipairs(candidates) do
  local probe = io.open(dir .. "src/domain/init.lua", "r")
  if probe then
    probe:close()
    root = dir
    break
  end
end
package.path = table.concat({
  root .. "src/?.lua",
  root .. "src/?/init.lua",
  root .. "?.lua",
  root .. "tests/?.lua",
  package.path,
}, ";")

-- Racine exportée pour les modules de test (golden check, etc.).
_TESTS_ROOT = root

-- Domain et core d'abord (les tests y font référence via les globals).
require("domain")
require("core")

local harness = require("tests.lib.harness")

local mode = arg[1] or "all"
local suites = {}

if mode == "all" or mode == "unit" then
  table.insert(suites, {"unit/mathx", "tests.unit.mathx_test"})
  table.insert(suites, {"unit/geometry", "tests.unit.geometry_test"})
  table.insert(suites, {"unit/state", "tests.unit.state_test"})
  table.insert(suites, {"unit/camera", "tests.unit.camera_test"})
  table.insert(suites, {"unit/entities", "tests.unit.entities_test"})
  table.insert(suites, {"unit/particles", "tests.unit.particles_test"})
  table.insert(suites, {"unit/ui", "tests.unit.ui_test"})
  table.insert(suites, {"unit/audio", "tests.unit.audio_test"})
  table.insert(suites, {"unit/engine", "tests.unit.engine_test"})
  table.insert(suites, {"unit/binds", "tests.unit.binds_test"})
end
if mode == "all" or mode == "regression" then
  table.insert(suites, {"regression/golden", "tests.regression.golden_test"})
end
if mode == "all" or mode == "integration" then
  table.insert(suites, {"integration/boot", "tests.integration.boot_test"})
  table.insert(suites, {"integration/compat", "tests.integration.compat_test"})
end
if mode == "golden" then
  -- Mode spécial : (re)génère le golden file de non-régression.
  -- Équivalent à scripts/update-golden.sh, en Lua pur.
  local simulation = require("tests.regression.simulation")
  simulation.writeGolden(root .. "tests/golden/golden.txt")
  print("Golden file écrit : " .. root .. "tests/golden/golden.txt")
  return
end

print("=== Template Love2D — Tests (" .. mode .. ") ===")
for _, suite in ipairs(suites) do
  local name, module = suite[1], suite[2]
  print(string.format("--- %s", name))
  local ok, err = pcall(require, module)
  if not ok then
    print(string.format("ERREUR DE CHARGEMENT : %s", tostring(err)))
    harness.failed = harness.failed + 1
    table.insert(harness.errors, "[" .. name .. "] " .. tostring(err))
  end
end

local success = harness.report()
if not success then os.exit(1) end
