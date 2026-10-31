# examples/snake — un mini-jeu complet, pattern recommande

Lancer depuis la racine du template :

```bash
love examples/snake        # desktop (LÖVE 11.x dans le PATH)
```

(En web : copiez le contenu de `snake_setup.lua` dans votre `game/setup.lua`,
le packaging ne prend que `game/`.)

## Ce que l'exemple montre

| Fichier | Pattern |
|---|---|
| `snake.lua` | **Logique pure** (zéro `love.*`, zéro moteur) : grille, serpent, nourriture, règles. RNG **injecté** → testable en Lua nu. |
| `snake_test.lua` | Tests unitaires de cette logique (RNG seedé → déterministe), déclarés dans `tests/suite.lua`. |
| `snake_setup.lua` | Le `setup.run()` du jeu : entités, HUD calque 9, bindings clavier **ZQSD + manette** (`addPadBind`), **letterbox**, gameover + restart. |
| `main.lua` | Point d'entrée minimal pour lancer l'exemple seul (`love examples/snake`). |

Pour prototyper votre propre concept : copiez `snake.lua` comme base de
logique pure + son test, puis adaptez `snake_setup.lua` dans `game/setup.lua`.
