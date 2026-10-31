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
  root .. "examples/?.lua",
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
  table.insert(suites, {"unit/camera", "engine.tests.unit.camera_test"})
  table.insert(suites, {"unit/entities", "engine.tests.unit.entities_test"})
  table.insert(suites, {"unit/particles", "engine.tests.unit.particles_test"})
  table.insert(suites, {"unit/ui", "engine.tests.unit.ui_test"})
  table.insert(suites, {"unit/audio", "engine.tests.unit.audio_test"})
  table.insert(suites, {"unit/engine", "engine.tests.unit.engine_test"})
  table.insert(suites, {"unit/binds", "engine.tests.unit.binds_test"})
  table.insert(suites, {"unit/serialize", "engine.tests.unit.serialize_test"})
end
if mode == "all" or mode == "regression" then
  table.insert(suites, {"regression/golden", "engine.tests.regression.golden_test"})
end
if mode == "all" or mode == "integration" then
  table.insert(suites, {"integration/boot", "engine.tests.integration.boot_test"})
  table.insert(suites, {"integration/compat", "engine.tests.integration.compat_test"})
  -- Tests PROJET (dossier tests/ à la racine) : dépendent de game/
  -- La liste des tests projet vit dans tests/suite.lua (cote PROJET) :
  -- un fork ajoute tests/xxx_test.lua + une ligne la-bas, sans toucher
  -- .engine/. Repli sur la liste historique si suite.lua est absent.
  local projectTests = {"setup_test", "state_test", "input_test"}
  -- Charge tests/suite.lua (cote PROJET) : dofile natif d'abord, sinon
  -- repli sur load du contenu lu via io.open (certains environnements
  -- n'ont pas de dofile fichier fiable).
  local function loadSuite(path)
    local ok, listed = pcall(dofile, path)
    if ok and type(listed) == "table" then return listed end
    local f = io.open(path, "r")
    if not f then return nil end
    local data = f:read("*a")
    f:close()
    local chunk = load(data, "@" .. path)
    if not chunk then return nil end
    local ok2, res = pcall(chunk)
    if ok2 and type(res) == "table" then return res end
    return nil
  end
  for _, base in ipairs({root, "./", "../"}) do
    local listed = loadSuite(base .. "tests/suite.lua")
    if listed then projectTests = listed break end
  end
  -- La racine peut etre "./" ou un chemin relatif incomplet selon le
  -- lanceur : on resout chaque test en essayant root, ./ et ../.
  local function findTestFile(t)
    local rel = t:find("/") and (t .. ".lua") or ("tests/" .. t .. ".lua")
    for _, base in ipairs({root, "./", "../"}) do
      local f = io.open(base .. rel, "r")
      if f then f:close() return base end
    end
    return nil
  end
  for _, t in ipairs(projectTests) do
    if findTestFile(t) then
      table.insert(suites, {"project/" .. t:gsub("_test", ""), t})
    end
  end
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
