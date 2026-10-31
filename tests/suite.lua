--------------------------------------------------------------------
-- tests/suite.lua : liste des modules de test PROJET, chargée par le
-- runner du template (.engine/src/engine/tests/run.lua) quand il tourne
-- en mode integration/all.
--
-- Pour ajouter un test : créez tests/mon_test.lua (qui retourne le
-- harness, voir tests/README.md) et ajoutez simplement "mon_test" ici.
-- Aucun fichier du template (.engine/) n'a besoin d'être modifié.
--------------------------------------------------------------------
return {
  "setup_test",
  "state_test",
  "input_test",
  -- Les exemples vit aussi dans le projet : leur logique pure est testee ici.
  "examples/snake/snake_test",
}
