# tests/ — les tests de VOTRE jeu

Ce dossier contient les tests propres au projet (ils peuvent dépendre de
`game/`). Le template fournit tout l'outillage : exécutez-les via

```bash
scripts/test.sh          # lance aussi les tests du moteur (.engine/)
```

## tests/setup_test.lua

Le test d'intégration PROJET : il charge le vrai `game/setup.lua` et
vérifie que l'initialisation de votre projet ne casse pas le moteur
(config exposée, calques enregistrés, bindings présents, 60 frames sans
crash, gameplay réactif aux binds). **Si vous remplacez la démo par
votre jeu, adaptez ce test** — c'est lui qui protège l'assemblage
game/ + .engine/.

Pour écrire un autre test, réutilisez le harness du template :

```lua
local harness = require("engine.tests.lib.harness")

harness.describe("mon module", function()
  harness.it("fait quelque chose", function()
    harness.assert_eq(2 + 2, 4)
  end)
end)

return harness
```

et ajoutez simplement `"mon_test"` dans `tests/suite.lua` : le runner du
template charge cette liste automatiquement. **Aucun fichier de
`.engine/` n’a besoin d’être modifié** (repli sur une liste interne si
`tests/suite.lua` est absent).

## Familles de tests (rappel)

| Famille | Où | Quoi |
|---|---|---|
| Unitaires | `*_test.lua` | fonction isolée (domain pur ou core mocké) |
| Non-régression | golden file | simulation déterministe, snapshot comparé |
| Intégration | boot complet | engine + setup, frames, interactions croisées |

Le détail de la stratégie vit dans le README racine.
