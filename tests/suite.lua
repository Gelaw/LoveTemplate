--------------------------------------------------------------------
-- tests/suite.lua : liste des modules de test PROJET, charg\u00e9e par le
-- runner du template (.engine/src/engine/tests/run.lua) quand il tourne
-- en mode integration/all.
--
-- Pour ajouter un test : cr\u00e9ez tests/mon_test.lua (qui retourne le
-- harness, voir tests/README.md) et ajoutez simplement "mon_test" ici.
-- Aucun fichier du template (.engine/) n'a besoin d'\u00eatre modifi\u00e9.
--------------------------------------------------------------------
return {
  "setup_test",
  "state_test",
  "input_test",
}
