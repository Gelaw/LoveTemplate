# Love2D Web Template

Template de projet [LÖVE](https://love2d.org/) (Lua) prêt pour le web, basé sur
[love.js](https://github.com/Davidobot/love.js) (port Emscripten/WebAssembly
de LÖVE 11.5).

## Quickstart (5 minutes)

```bash
git clone <ce repo> monjeu && cd monjeu
scripts/run.sh            # lance le jeu en desktop (nécessite love 11.x)
# ... éditez game/setup.lua : c’est le SEUL fichier prévu pour votre jeu ...
scripts/test.sh           # valide que votre game/ ne casse pas le moteur
scripts/web.sh monjeu     # build web -> dist/web/
scripts/serve.sh          # puis ouvrir http://localhost:8000
```

Règle d’or : vous ne modifiez **que** `game/` et `tests/`. `.engine/` (moteur)
et `scripts/` (outillage) restent figés — un merge depuis l’upstream du
template restera sans conflit. Voir `examples/snake/` pour un mini-jeu
complet (logique pure testable + rendu + manette + letterbox).

## Choix de l'integration web

Trois options ont ete considerees :

| Option | LÖVE | Verdict |
|---|---|---|
| **love.js (Davidobot, paquet npm)** | 11.5 | **Retenu.** Maintenu, API a jour, s'utilise via `npx love.js` sans compiler. Le meme `.love` marche desktop + web. |
| [LoveWebBuilder](https://schellingb.github.io/LoveWebBuilder/) (schellingb) | 0.11.1 | Ecarte : base sur un vieux port pre-11.0, dependances d'API cassees. |
| love.js standalone (2dengine) | 11.5 | Ecarte ici : lecteur de `.love` autonome pratique pour tester, mais moins integre a un pipeline de build. |

Limites connues de love.js : pas de threads en mode compatibilite (`-c`),
pas de shaders (rely on fixed pipeline), audio stream parfois capricieux,
`love.system.getOS()` renvoie `"Web"`.

**Version LÖVE embarquee : 11.4.** Le paquet npm `love.js` compile LÖVE
11.4, pas 11.5. Si `src/conf.lua` declare `t.version = "11.5"`, le jeu
affiche au lancement web l'avertissement :

> This game indicates it was made for version '11.5' of LOVE. It may not
> be compatible with the running version (11.4).

Le jeu fonctionne malgre tout ; `conf.lua` est regle sur `"11.4"` pour
supprimer l'avertissement. Si vous developpez en desktop avec LÖVE 11.5,
gardez en tete que le web reste en 11.4 (API quasi identique).

## Structure

```
LoveTemplate/
├── game/                    # ★ VOTRE JEU — le seul dossier à modifier
│   ├── main.lua             #   point d'entrée (TEMPLATE, ne pas toucher)
│   ├── conf.lua             #   config LÖVE (TEMPLATE, applique setup.config)
│   ├── setup.lua            #   ★ config fenêtre + initialisation du gameplay
│   └── state.lua            #   exemple : état de jeu pur (score, vies)
├── tests/                   # ★ VOS tests (dépendent de game/ ; voir tests/README.md)
│   └── suite.lua            #   liste des tests projet charges par scripts/test.sh
├── scripts/                 # outillage (build/run/test/lint, ne pas toucher)
│   ├── run.sh               #   lance le jeu (dev)
│   ├── watch.sh             #   relance auto le jeu quand un .lua change
│   ├── check.sh             #   syntaxe de tous les .lua (luac -p)
│   ├── test.sh              #   suite de tests (lua pur, aucun LÖVE requis)
│   ├── lint.sh              #   lint statique (luacheck, config .luacheck.lua)
│   ├── update-golden.sh     #   régénère le golden file (après revue)
│   ├── package.sh           #   construit dist/<nom>.love
│   ├── web.sh               #   construit dist/web/ (HTML/JS) via love.js
│   ├── serve.sh             #   serveur local (test navigateur)
│   └── clean.sh              #   supprime dist/
├── .engine/                 # le MOTEUR du template — FIGÉ, ne jamais modifier
│   └── src/engine/
│       ├── init.lua         #   charge les couches (expose globals domain/core)
│       ├── base.lua         #   façade compat API historique
│       ├── domain/          #   COUCHE DOMAINE — 100% pure, zéro LÖVE
│       │   ├── mathx.lua    #     math pures, RNG injecté pour les tests
│       │   └── geometry.lua #     hitbox, intersections, entitiesCollide
│       ├── core/            #   COUCHE CORE — moteur, backend injecté
│       │   ├── engine.lua   #     boucle, 9 calques, bindings, safeLoad
│       │   ├── camera.lua   #     follow/moveTo/shake (via backend)
│       │   ├── entities.lua #     registre, update, collisions (-> domain)
│       │   ├── particles.lua#     effets particules (via backend)
│       │   ├── ui.lua       #     hiérarchie UI, hit-test souris
│       │   └── audio.lua    #     musiques + effets (via backend)
│       ├── adapter/
│       │   └── love2d.lua   #     SEUL fichier touchant love.*
│       └── tests/           #   tests DU MOTEUR (unit/golden/intégration)
├── examples/                # mini-jeux d’exemple complets (voir examples/snake/)
├── .luacheck.lua            # config du linter
├── .gitignore
└── README.md
```

**Règle d'or** : tout ce qui est projet vit dans `game/` et `tests/`.
Le dossier `.engine/` (le moteur du template) et `scripts/` sont figés :
dupliquez le repo, travaillez dans `game/`, et un merge depuis
l'upstream du template restera sans conflit. Vous n'avez jamais besoin
d'ouvrir `.engine/` — tout y est documenté et testé de son côté.

## Architecture : domain / core / adapter

Le projet suit une séparation en trois couches, pensée pour la testabilité :

```
┌───────────────────────────────────────────────┐
│ main.lua (TEMPLATE) → game/ (VOTRE PROJET)    │
└─────────────┬─────────────────────────────────┘
              │ utilise
┌─────────────▼──────────────┐  ┌──────────────────────────────┐
│ CORE (moteur)              │  │ ADAPTER (love2d.lua)         │
│ engine, camera, entities,  │◄─│ SEUL endroit qui touche      │
│ particles, ui, audio       │  │ love.* ; fournit le backend  │
└─────────────┬──────────────┘  └──────────────────────────────┘
              │ dépend de        (en test : mock_backend.lua)
┌─────────────▼──────────────┐
│ DOMAIN (pur)               │
│ mathx, geometry, state     │  ← zéro dépendance, testable avec
│ règles, scoring, IA...     │    du Lua nu, sans moteur graphique
└────────────────────────────┘
```

**Règles de dépendance** (à faire respecter en code review) :
- `domain/` ne fait JAMAIS de `require` vers core, adapter ni love.*
- `core/` peut requérir domain, mais touche l'extérieur UNIQUEMENT via
  `core.api()` (le backend injecté par l'adapter)
- `adapter/love2d.lua` est le SEUL fichier autorisé à référencer `love.*`
- `game/` contient toute la logique projet ; `main.lua` (template) se contente
  de câbler les couches et de déléguer à `game.setup` / `game.config`

**Pourquoi** : chaque couche est testable isolément avec un coût différent.
Le domain se teste avec du Lua nu (rapide, exhaustif), le core avec un
backend mock (logique moteur), l'adapter est mince donc peu testé, et
l'intégration bout-en-bout se fait via le boot complet.

## Prerequis

| Usage | Outil | Rôle |
|---|---|---|
| `scripts/run.sh` | [LÖVE 11.x](https://love2d.org/) (`love` dans le PATH) | dev desktop |
| `scripts/check.sh` | `luac` (avec le paquet `lua`/`luajit`) | check syntaxique |
| `scripts/lint.sh` | [luacheck](https://github.com/lunarmodules/luacheck) (`luarocks install luacheck` ou `dnf install lua-luacheck`) | lint statique : globals indéfinis, variables inutilisées, etc. (config `.luacheck.lua`) |
| `scripts/test.sh` | `luajit` ou `lua` | suite de tests (le script auto-detecte) |
| `scripts/package.sh` | `zip` | packaging `.love` |
| `scripts/web.sh` | [Node.js](https://nodejs.org/) >= 12 (`npx`) | build web — le paquet npm `love.js` (moteur LÖVE 11.5 en WebAssembly) est telecharge par `npx --yes` au premier build, rien a compiler |
| `scripts/serve.sh` | `python3` | serveur local statique (obligatoire : le WASM ne charge pas en `file://`) |

Le minimum pour le web seul : `nodejs` + `zip` + `python3`.

### Fedora / RHEL (dnf)

```bash
# le minimum pour build web + servir en local
sudo dnf install nodejs zip python3

# + dev desktop et tests
sudo dnf install love luajit
```

Si le RPM `love` de votre Fedora est trop ancien, le RPM officiel
(love-11.5-1.x86_64.rpm sur love2d.org) s'installe pareil :
`sudo dnf install ./love-*.rpm`.

## Utilisation

```bash
# 1. Dev : lancer le jeu
scripts/run.sh
scripts/watch.sh            # idem, mais relance auto a chaque sauvegarde de .lua

# 2. Verifier la syntaxe
scripts/check.sh

# 2b. Lancer la suite de tests (lua pur, aucun LÖVE requis)
scripts/test.sh              # tout : unit + regression + integration
scripts/test.sh unit         # seulement les unitaires

# 2c. Lint statique (requiert luacheck)
scripts/lint.sh

# CI : GitHub Actions lance check + tests (lua5.1 ET luajit) + lint
# a chaque push/PR — voir .github/workflows/ci.yml

# 3. Construire le .love (distribuable desktop)
scripts/package.sh monjeu        # -> dist/monjeu.love

# 4. Construire la version web (HTML/JS)
scripts/web.sh monjeu            # -> dist/web/ (index.html, game.js, .data)

# 5. Tester dans le navigateur
scripts/serve.sh                 # http://localhost:8000

# Nettoyer
scripts/clean.sh
```

Le build web (`dist/web/`) est statique : deposez-le sur n'importe quel
hebergeur statique (GitHub Pages, itch.io, Netlify...). Sur itch.io, cochez
« this game will be played in the browser » et uploadez le zip de `dist/web`.

## API fournie par base.lua

### Boucle / calques
- `addDrawFunction(fn, layer)` — dessine sur un calque 1 (fond) a 9 (UI)
- `addUpdateFunction(fn)` — callback d'update (recoit `dt`)
- `applyParams(table, params)` — copie les champs de `params` dans `table`

### Camera
- `camera` (x, y, scale, angle), `camera.mode = {"follow", entite}`
- `cameraShake(intensite, duree)` — secousses

### Entites
- `core.entities.add(entite)` — champs : `x, y, w, h, angle, shape,
  color, update(dt), draw(), collide(other), terminated` (mettre
  `terminated = true` dans un callback le retire au prochain update)
- `core.entities.remove(e)` / `core.entities.each(fn)` (itère sur un
  snapshot, safe si la liste change) / `core.entities.find(pred)` —
  ex. taguer `tag = "player"` puis
  `core.entities.find(function(e) return e.tag == "player" end)`
- Collisions par intersection des segments des hitboxes (pas de detection
  quand une entite est entierement dans une autre)

### Particules
- `table.insert(particuleEffects, pe)` — champs : `x, y, nudge, size,
  timeLeft, color`, callback optionnel `onTermination()`

### UI
- `core.ui.add(element)` — champs : `x, y, w, h, hidden, children,
  draw(), onClick(), onPress(), tooltip`
- Widgets prêts à l’emploi : `core.ui.button(x, y, w, h, text, {onClick=...})`
  (hover auto) et `core.ui.label(x, y, text, {align=...})`
- `core.engine.mouseX, mouseY` — dernière position souris (écran), mise à
  jour par l’adapter ; utile pour du hover custom

### Audio
- `audioManager:loadMusic(name, path)` / `:playMusic(music)` /
  `:toggleMute()` / `:changeMusicVolume(v)`
- `audioManager:loadSoundEffect(name, path)` / `:playSound(sound)` /
  `:toggleMuteSE()` / `:changeSEVolume(v)`

### Sprites (images)
- Entité avec `image = core.api().newImage("src/mon.png")` : rendue par le
  dessin par défaut de `core.entities` (`w`/`h` = taille cible, sinon taille
  native centrée ; `scale` pour zoomer en plus).

### Persistance
- `state.save(s, "fichier.txt")` / `state.load(s, "fichier.txt")` (exemple
  `game/state.lua`) : sérialisation via `domain.serialize` (pur, testable),
  écriture via `core.api().writeFile` = `love.filesystem.write` (marche
  desktop **et** web).

### Affichage fenêtre
- `core.engine.letterbox = true` + `core.engine.virtualWidth/virtualHeight`
  (960x540 par défaut) : le rendu est centré et mis à l’échelle dans la
  fenêtre avec bandes noires — un HUD en coordonnées fixes n’est jamais coupé.

### Animations

### Divers
- `addPadBind(button, action)` / `getPadBindOf(action)` — bindings manette
  (boutons LÖVE : `"a"`, `"dpup"`, `"leftshoulder"`…) ; `isBindDown` fait
  l’union clavier + manette. Fonctionne desktop et web.
- `addBind(key, action)` / `getBindOf(action)` / `isBindDown(action)` —
  bindings clavier en TOUCHES (lettre produite : "z" = Z sur AZERTY).
  Approche volontairement naïve : les scancodes (position physique) se
  sont révélés non fiables selon plateformes (polling SDL/Wayland
  incomplet en layout non-QWERTY, scancodes web dérivés du caractère).
  La démo est réglée ZQSD ; un joueur QWERTY re-binde en WASD (ou
  prévoyez un écran d'options). `isBindDown` fait l'union du suivi
  événementiel (keypressed/keyreleased) et du polling isDown.
- `safeLoadAndRun(file)` — charge un .lua sans crasher (niveaux, scripts)
- Math : `math.dist, math.angle, math.clamp, math.round, math.normalize,
  math.prandom, math.sign, math.rsign, lerp, cerp`, etc.
- Geometrie : `checkIntersect`, `findIntersect`, `get_closest_point`

## Stratégie de tests

Trois familles de tests, toutes exécutables SANS LÖVE (`scripts/test.sh`),
car le backend graphique est mocké et le RNG est injecté/seedé :

| Famille | Où | Quoi | Quand l'écrire |
|---|---|---|---|
| **Unitaires** | `.engine/src/engine/tests/unit/*_test.lua` | Une fonction d'un module domain/core isolée (clamp, dist, hit-test UI, cycle de vie particule...) | En même temps que la fonction (TDD possible, le domain tourne en Lua nu) |
| **Non-régression** | `.engine/src/engine/tests/regression/` + golden file | Une simulation déterministe complète (RNG seedé, dt fixe) produisant un snapshot d'état final comparé au golden file | Dès qu'il y a du gameplay ; mettre à jour UNIQUEMENT via `scripts/update-golden.sh` après revue manuelle du nouveau snapshot |
| **Intégration** | `.engine/src/engine/tests/integration/` (moteur) ; `tests/setup_test.lua` (PROJET : charge le vrai game/setup.lua) | L'assemblage complet : boot engine + projectSetup + 60 frames update/draw, interactions croisées (collisions dans la boucle, UI consommée, caméra follow, façade compat) | Quand on ajoute un sous-système ou une interaction entre deux couches |

### Où tester quoi (guide)

- **Logique de gameplay, règles, scoring, physique pure** → nouveau module
  dans `game/` (comme l'exemple `state.lua`) + test dans `.engine/src/engine/tests/unit/` (moteur) ou `tests/` (projet).
  Le RNG doit passer par `domain.mathx.rng` pour rester déterministe en test
  (voir `.engine/src/engine/tests/lib/deterministic.lua`).
- **Comportement moteur (boucle, calques, culling, collisions, UI, audio)**
  → test dans `.engine/src/engine/tests/unit/` avec `mock_backend` : on attache le mock via
  `core.attach(m.backend)` et on vérifie soit l'état, soit les opérations
  enregistrées (`m.count("rectangle")`).
- **Changements volontaires de comportement gameplay** → mettre à jour le
  golden : `scripts/update-golden.sh`, RELIRE le snapshot, committer.
- **Nouvel adapter (autre moteur que LÖVE)** → écrire un adapter et un
  `tests/integration/boot_test` équivalent ; le reste de la suite ne change pas.

### Conventions

- Un fichier de test par module source ; nom : `<module>_test.lua`.
- Le runner (`tests/run.lua`) découvre rien tout seul : ajouter la ligne
  `table.insert(suites, ...)` dans la bonne famille.
- Les tests ne touchent JAMAIS `love.*` (sinon ils ne tourneraient que
  sous LÖVE) ; tout passe par `core.attach(mock_backend)`.
- Les tests de non-régression utilisent des dt FIXES (1/60) et un RNG seedé :
  jamais de `os.time()` ni de vrai `love.timer`.

## Notes web

- `love.timer.getTime` et le gameplay ne changent pas ; le canvas s'adapte
  a la taille du navigateur.
- La demo (`game/setup.lua`) n'utilise que des formes vectorielles : aucun asset
  requis, elle tourne telle quelle desktop et web.
- Pour un jeu reel, remplacez `projectSetup()` et ajoutez vos assets dans
  `src/` (ils seront inclus dans le `.love` puis dans le `.data` web).


## FAQ prototypage

**Q : ma boucle de jeu tourne à 60 fps fixe, comment faire un pas de temps variable ?**
R : `engine.addUpdateFunction(function(dt) ... end)` reçoit déjà `dt` en secondes
(flottant). Accumulez-le (`acc = acc + dt; while acc >= STEP do ... end`) comme dans
`examples/snake/snake_setup.lua`.

**Q : je veux un écran menu / pause / gameover.**
R : un simple champ `mode = "menu"|"play"|"gameover"` dans votre `game/state.lua`,
testé par vos `addUpdateFunction`/`addDrawFunction`. Voir le pattern gameover+restart
de `examples/snake/`.

**Q : comment déboguer en web ?**
R : `scripts/web.sh` + `scripts/serve.sh`, puis F12. Depuis cette version, une erreur
Lua s’affiche aussi **dans le canvas** (`love.errorhandler` dans `game/main.lua`).

**Q : relancer le jeu à chaque sauvegarde, c’est pénible.**
R : `scripts/watch.sh` (surveille les mtimes, sans dépendance).

**Q : fullscreen / écran retina ?**
R : ajoutez `fullscreen = true` / `highdpi = true` / `msaa = 8` dans `setup.config`
(`game/setup.lua`) — passé à `love.conf` et à `love.window.setMode`.
