# tests/ — les tests de VOTRE jeu

Ce dossier contient les tests propres au projet (ils peuvent dépendre de
`game/`). Le template fournit tout l'outillage : exécutez-les via

```bash
scripts/test.sh          # lance aussi les tests du moteur (.engine/)
```

Pour écrire un test, réutilisez le harness du template :

```lua
local harness = require("engine.tests.lib.harness")

harness.describe("mon module", function()
  harness.it("fait quelque chose", function()
    harness.assert_eq(2 + 2, 4)
  end)
end)

return harness
```

et déclarez-le dans `.engine/src/engine/tests/run.lua` (suite `project`),
ou dans votre propre runner copié depuis celui du template.

## Familles de tests (rappel)

| Famille | Où | Quoi |
|---|---|---|
| Unitaires | `*_test.lua` | fonction isolée (domain pur ou core mocké) |
| Non-régression | golden file | simulation déterministe, snapshot comparé |
| Intégration | boot complet | engine + setup, frames, interactions croisées |

Le détail de la stratégie vit dans le README racine.
