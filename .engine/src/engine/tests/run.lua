--------------------------------------------------------------------
-- run.lua : runner des tests du TEMPLATE (Lua pur, aucun LÖVE requis).
-- Lancé par scripts/test.sh depuis la racine du projet.
--
--   scripts/test.sh              # tout
--   scripts/test.sh unit         # seulement les unitaires
--   scripts/test.sh regression   # non-régression (golden file)
--   scripts/test.sh integration  # intégration
--   scripts/update-golden.sh     # régénère le golden (après revue)
--
-- Les tests propres au PROJET vivent dans tests/ (à la racine) :
-- ils peuvent réutiliser ce harness via require("engine.tests.lib.harness").
--------------------------------------------------------------------

-- Résolution de la racine : le dossier qui contient game/, tests/ et
-- .engine/. On sonde le parent du chemin de script, le CWD et le
-- parent du CWD (lancement depuis n'importe où).
local script = arg[0] or ".engine/src/engine/tests/run.lua"
local scriptDir = script:match("^(.-)[^/\\]+$") or ""
local candidates = {}
if scriptDir ~= "" then
  table.insert(candidates, (scriptDir:gsub("%.engine/tests[/\\]$", "")))
  table.insert(candidates, scriptDir)
end
table.insert(candidates, "./")
table.insert(candidates, "../")
local root = "./"
for _, dir in ipairs(candidates) do
  local probe = io.open(dir .. ".engine/src/engine/run.lua", "r")
  if probe then
    probe:close()
    root = dir
    break
  end
end
package.path = table.concat({
  root .. ".engine/src/?.lua",
  root .. ".engine/src/?/init.lua",
  root .. "game/?.lua",
  root .. "tests/?.lua",
  root .. "?.lua",
  package.path,
}, ";")

-- Racine exportée pour les modules de test (golden check, etc.).
_TESTS_ROOT = root

-- Engine d'abord (les tests y font référence via les globals
-- domain/core fournis par engine/init.lua).
require("engine")

local harness = require("engine.tests.lib.harness")

local mode = arg[1] or "all"
local suites = {}

if mode == "all" or mode == "unit" then
  table.insert(suites, {"unit/mathx", "engine.tests.unit.mathx_test"})
  table.insert(suites, {"unit/geometry", "engine.tests.unit.geometry_test"})
  table.insert(suites, {"unit/state", "engine.tests.unit.state_test"})
  table.insert(suites, {"unit/camera", "engine.tests.unit.camera_test"})
  table.insert(suites, {"unit/entities", "engine.tests.unit.entities_test"})
  table.insert(suites, {"unit/particles", "engine.tests.unit.particles_test"})
  table.insert(suites, {"unit/ui", "engine.tests.unit.ui_test"})
  table.insert(suites, {"unit/audio", "engine.tests.unit.audio_test"})
  table.insert(suites, {"unit/engine", "engine.tests.unit.engine_test"})
  table.insert(suites, {"unit/binds", "engine.tests.unit.binds_test"})
end
if mode == "all" or mode == "regression" then
  table.insert(suites, {"regression/golden", "engine.tests.regression.golden_test"})
end
if mode == "all" or mode == "integration" then
  table.insert(suites, {"integration/boot", "engine.tests.integration.boot_test"})
  table.insert(suites, {"integration/compat", "engine.tests.integration.compat_test"})
end
if mode == "golden" then
  -- Mode spécial : (re)génère le golden file de non-régression.
  -- Équivalent à scripts/update-golden.sh, en Lua pur.
  local simulation = require("engine.tests.regression.simulation")
  simulation.writeGolden(root .. ".engine/src/engine/tests/golden/golden.txt")
  print("Golden file écrit : " .. root .. ".engine/src/engine/tests/golden/golden.txt")
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
