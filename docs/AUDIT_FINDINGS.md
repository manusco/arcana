---
summary: First-principles product and code audit of Arcana (Flutter web trick-taking game)
read_when:
  - Planning UX, onboarding, or copy work on Arcana
  - Fixing game-logic or deployment bugs
  - Prioritizing the next sprint
last_updated: 2026-07-11
---

# Arcana: First-Principles Audit

Audit of the Flutter/Dart game at `D:\Dev\Arcana` ("Arcana: The Game of Prophecy"). Read-only
review of the code, copy, tests, and deploy pipeline against the soul (`premium, atmospheric,
dark fantasy, precision over power`) and the Game Design Document. Nothing in the code was
changed; this file is the only artifact written.

Method: static reading of every file under `lib/`, `test/`, `web/`, plus `pubspec.yaml` and the
deploy workflow, cross-checked against `docs/specs/GAME_DESIGN_DOCUMENT.md`. `flutter analyze`
and `flutter test` were run (results in the Tooling section).

---

## 0. Verdict at a glance

- **Languages**: English and German. Full parity (67 keys each, no key missing in either
  direction, verified by script). Copy is well written and on-tone.
- **Onboarding**: A genuine, well-structured rules dialog exists and it explains the Prophecy
  mechanic clearly. But it is opt-in behind a small `?` icon and never surfaced on first run, and
  several downstream states (round scoring, game over, legal-move feedback) give a new player
  almost no explanation of *why* things happened. So the teaching moment exists but the learning
  loop is broken after it.
- **Game logic**: The trick-taking engine and the prophecy scoring are correct and internally
  consistent. I traced trump, lead-suit, Arcanum, Shadow, and all-Shadow tricks by hand and they
  follow the GDD. The real defects are around the edges: the AI bid is never clamped to the number
  of tricks available, bot `skillLevel` is dead (has zero effect), and there are two unused
  parallel bot definitions.
- **Visual craft**: Above default-Flutter. Real atmosphere work (felt table, vignette, wood
  border, glowing active-player rings, Cinzel/Playfair headings, custom card faces). It is a green
  card-table look, not the "obsidian/midnight, glassmorphism, neon suit glow" the GDD specifies,
  and it is built for landscape desktop with no responsive/portrait handling.
- **Biggest single miss**: The **Game Over state has no UI**. When the game ends the board just
  freezes with a tiny "Game Over!" chip. No winner, no final ranking, no play-again, and the saved
  high score is never shown because the high-scores button is commented out.

---

## 1. First-time clarity (the most important thing)

**What a new player sees on launch**: a setup dialog auto-opens with the logo, a EN/DE flag
toggle, a name field, a player-count stepper (2 to 6), a Start button, and a small amber `?` icon
in the title row.

**The good**: tapping `?` opens `_showRulesDialog`, which is genuinely strong. It covers the goal,
the three card types, the four steps (Deal, Trump, Prophecy, Action), the follow-suit rule, the
Arcanum-beats-Trump hierarchy, and the scoring, all localized in both languages, with a themed
mystical frame. The Prophecy mechanic is stated plainly: "predict exactly how many tricks you will
win each round. Accuracy is everything." For a trick-taking-plus-prediction game, this is the
right content.

**The problems**:

1. **The rules are opt-in and easy to miss.** The `?` is a 20px icon in a dialog title. A new
   player is far more likely to hit Start than to read the rules. There is no "How to Play"
   button, no first-run auto-open of the rules, and no persisted "seen the rules" flag.
2. **The game's own title is never shown.** `game_title` ("Arcana: The Game of Prophecy" /
   "Arcana: Das Spiel der Prophezeiung") exists in translations but is never rendered. The setup
   dialog header just says "Start New Game". The one-line hook that tells a stranger what this is
   is missing from the UI.
3. **No teaching during play.** Once the game starts there is no reminder of the objective, no
   tooltip on the Prophecy step, and no indication of which cards are legal to play (see 2.3).
4. **The learning loop never closes.** A new player learns by seeing consequences. Here the
   round-scoring feedback and the game-over result (sections 2.4 and 2.5) are effectively absent,
   so a first-timer finishes a round with no clear idea of whether their prophecy paid off or why.

**Onboarding verdict**: There *is* a teaching moment and it is good, so this is not a from-scratch
build. The work is to (a) surface it on first run and via a visible button, and (b) close the loop
with real round-end and game-end feedback.

---

## 2. The core loop, state by state

### 2.1 Setup / Start
Player job: pick name, language, player count, start. Clear and obvious. Minor: the player-count
stepper allows 2 to 6 but a new player is not told that fewer players means a much longer game (2
players runs 30 rounds, the last dealing 30 cards each). Consider a one-line hint or a default of
4 (already the default) with a "recommended" tag.

### 2.2 Bidding / Prophecy
Player job: choose how many tricks to win. A draggable overlay shows numbered buttons 0..round,
with the illegal "hook" bid disabled (grey) when the human is the last bidder. The hand and the
trump card are both visible while bidding, which is correct. Two issues:
- The overlay is **draggable** (`onPanUpdate` moves it). This is an odd, undiscoverable
  interaction that mostly creates a way to accidentally shove the panel off-screen. Recommend a
  fixed, centered position.
- There is **no explanation of why a bid is disabled**. A new player sees one greyed button and no
  reason. A one-line caption ("The last bid cannot make the table's total equal the number of
  tricks") would teach the hook rule in context.

### 2.3 Playing tricks
Player job: tap a card to play it. The current player gets a glowing gold ring; the trick builds
in the center with per-seat rotation. Problems:
- **No indication of which cards are legal.** Illegal taps are rejected with a terse "Invalid
  Move!" status chip. `CardWidget.isSelected` is never set true from the screen, so there is no
  selected/legal styling at all. A new player will tap an off-suit card, get "Invalid Move!", and
  not understand the follow-suit rule. Dim or disable illegal cards, or highlight legal ones.
- **The status chip is small and bottom-right** (12px). Turn prompts ("Your turn to play!"),
  trick results ("Nea won the trick!"), and errors all flash in the same tiny corner. Important
  feedback is under-weighted.

### 2.4 Round scoring
Player job: none (auto-advances after 3 seconds). This is a **feedback gap**. At round end the
code computes each player's delta (20 + 10*tricks on a correct prophecy, -10 per trick off
otherwise) but **shows no round summary**. The only signal is the small "won / predicted" badge on
each avatar and the cumulative score line. A new player never sees "You predicted 2, won 3, -10".
Add a round-result panel that, per player, shows predicted vs won and the points gained or lost,
with a short beat before the next round.

### 2.5 Game over
Player job: unclear, because **there is no Game Over UI at all**. `build()` has no branch for
`GamePhase.GAME_OVER`. When the game ends the board stays on screen with empty hands and a tiny
"Game Over!" chip. Consequences:
- No winner is announced, no final ranking, no "You placed Nth" (the `_getPlacementText` helper
  that would do this exists but is dead code, never called, and returns hardcoded English).
- The final score **is** saved to high scores, but the player cannot see it because the
  high-scores button is commented out (see 2.6). So the game ends in a dead end.
- Play-again is only reachable via the small refresh icon top-right.
This is the highest-impact fix in the report: build a real end screen with final standings, the
human's placement, the high-score board, and a prominent "Play Again".

### 2.6 High scores
`HighScoreService` correctly saves and ranks scores in `shared_preferences` (top 100, per-env
key). `HighScoreWidget` renders a themed top-5 board with a proper empty state. But **the entire
feature is unreachable from the UI**: the only caller of `onShowHighScores` is a commented-out
`TextButton` in the setup dialog (`game_screen.dart` ~lines 966-970). Scores are written and never
read by a human. Uncomment/rewire the button and show the board on game over.

---

## 3. Copy and i18n

**Parity**: verified by script. EN and DE each define 67 keys; the only asymmetry is the block
marker itself (`'en'` vs `'de'`). No missing translations either direction. This is good hygiene.

**Tone**: on-brand and clear. "In this mystical contest, victory does not go to the one with the
strongest hand, but to the one who can see the future." / "Do you have the sight to master the
Arcana?" The German is idiomatic and matches register. The rules stay clear about the actual
mechanics, which is exactly right for a game that is easy to mis-teach.

**Concrete fixes**:

1. **En-dashes in `suits_title`** (both languages): `'The Suits (1–13)'` and `'Die Farben (1–13)'`
   use the en-dash character `–`. Replace with a hyphen:
   - EN: `The Suits (1-13)`
   - DE: `Die Farben (1-13)`
2. **Hardcoded, unlocalized UI strings** that bypass the localization service:
   - `game_screen.dart:617` `Text("TRUMP", ...)` -> add key `trump_label` (EN "Trump" / DE
     "Trumpf"). Note the in-game label says "TRUMP" but the rules call it "Trump/Trumpf"; unify.
   - `game_screen.dart:853` `const Text("Close")` in the scoreboard dialog -> add key `close` (EN
     "Close" / DE "Schließen").
   - `card_widget.dart` card faces render literal `"ARCANUM"` and `"SHADOW"` (split across lines,
     so easy to miss). German players see English card names while the rules dialog calls them
     "Arcanum" / "Schatten". Consider localizing, or accept them as stylized proper nouns and make
     that a deliberate decision.
   - `_getPlacementText` (dead code) returns hardcoded "2ND PLACE" etc. If revived for the
     game-over screen, localize it.
3. **`game_title` is defined but never displayed.** Surface it (setup dialog subtitle and/or the
   browser is a separate matter, see section 6).
4. **Unused keys** worth auditing: `rules`, `dealer`, `high_scores` (only used by the unreachable
   widget). Not harmful, but they signal features that were wired and then hidden.

No slop, no filler, no banned marketing phrases in the copy. The writing quality is a genuine
strength; the gaps are structural (strings that never reach a screen), not stylistic.

---

## 4. Game logic correctness

I read `game_service.dart`, `ai_service.dart`, `game_viewmodel.dart`, and all models, and traced
the rules by hand. **Core verdict: the trick engine and scoring are correct.**

**Verified correct**:
- **Card comparison** (`Card.beats`): Arcanum > Trump > lead-suit > off-suit, with "first Arcanum
  wins" and "first Shadow wins an all-Shadow trick" both handled. I traced trump-over-lead,
  higher-trump-over-trump, off-suit-cannot-win, Shadow-led (lead suit set by first non-Shadow),
  and all-Shadow tricks. All match the GDD.
- **Follow-suit** (`isValidMove`): Arcanum/Shadow always legal; must follow lead color if holding a
  NUMBER card of it; otherwise free. Correct. Guards against playing before an Arcanum trump color
  is chosen.
- **Scoring** (`finishRound`): correct prophecy = 20 + 10*won; wrong = -10 * |predicted - won|.
  Matches the GDD exactly.
- **Round count / game end**: rounds run until the deck is exhausted (`60 ~/ players`), the
  final round has no trump, and the game-over trigger fires after the correct last round for every
  player count from 2 to 6. The insufficient-cards guard in `startRound` is a belt-and-suspenders
  that never trips because the game-over check precedes it.
- **The hook rule** (last bidder cannot make the total equal the trick count) is enforced for both
  the human (disabled button) and bots (bid adjustment).

**Real defects**:

1. **AI bid is not clamped to `[0, hand.length]`.** `AiService.calculateBid` returns
   `(expectedTricks + riskFactor).round()`. With the aggressive bot Nero (`riskFactor: 0.5`), a
   near-maximal hand can round to **more tricks than exist that round** (for example two Arcanums
   in a 2-card round: expected 2.0 + 0.5 = 2.5 -> bids 3). The bot then announces an impossible
   prophecy it is guaranteed to miss. Not a crash, but it visibly breaks AI credibility and the
   "precision" fantasy. The last-bidder adjustment does not fix it for non-last bidders. Fix: clamp
   the returned bid to `0..hand.length`. (A symmetric negative-bid underflow is possible if any
   `riskFactor <= -0.5`; current configs bottom out at -0.3 so it is latent, but the clamp closes
   both ends.)
2. **Bot `skillLevel` is inert.** `BotPlayer.skillLevel` is stored (values 1-3 in the configs) but
   **never read anywhere in `AiService`**. Every bot plays with identical logic; only `riskFactor`
   (a bid-rounding nudge) differentiates them. The advertised personalities ("The Pro" vs "Chaotic"
   vs "Cautious") are almost entirely cosmetic. Either wire `skillLevel` into search depth /
   card-counting / error rate, or stop advertising distinct skill tiers.
3. **Two parallel, conflicting bot definitions; one is dead.** `models/bot_character.dart` defines
   six rich `BotCharacter` archetypes (Magnus/Pythia/Nero/Aura/Varius/Sol, with German archetype
   names and descriptions) but is **never imported**. The actual bots come from a hardcoded
   `botConfigs` map in `game_viewmodel.dart` with different names (Mio/Nea/...) and different risk
   values (for example Nero is 0.35 in the model but 0.5 in the viewmodel). Pick one source of
   truth; delete or wire up the other.
4. **Dead `Player` API.** `HumanPlayer.makePrediction/playCard` throw `UnimplementedError` and
   `BotPlayer.makePrediction/playCard` implement a *different, simpler* heuristic than `AiService`
   and are never called. Confusing for a maintainer who may assume `BotPlayer.makePrediction` is
   the live AI. Remove or reconcile.

**Edge cases checked and OK**: prophecy of 0 (allowed, scores 20 on success), last card / empty
hand (round-end keyed off the trick-completing player's empty hand, which is safe because deals are
even), tie tricks (impossible: the first-played card wins ties by the strict `>` in `beats`),
empty trick (guarded with an exception, only reachable via misuse).

**Portability note (not a web bug, but a soul mismatch)**: `high_score_service.dart` imports
`package:web/web.dart` and reads `web.window.location.hostname` at the top level. This compiles for
web (the deploy target) but **will fail to compile for Windows or mobile**, both of which the soul
and GDD list as targets. If cross-platform is real, gate this behind a conditional import or a
platform check.

---

## 5. Visual craft and UX

**Does it deliver "premium, atmospheric, dark fantasy / tarot"?** Partly. It is clearly beyond a
default Flutter app: felt-green table with a radial vignette, an 8px wood-grain border, glowing
gold rings on the active player, dealer/starter badges, Cinzel and Playfair Display headings, and
hand-built card faces with corner pips, center suit glyphs, and Arcanum/Shadow icons. Cards fade
and slide in; the trick fans with slight rotation. There is real "juice" intent here.

**Where it diverges from the stated soul**:
- The GDD asks for "deep charcoal, obsidian, midnight blue" backgrounds with "neon/glowing" suit
  accents and "glassmorphism". The actual table is bright casino green (`#1B5E20`/`#2E7D32`). It
  reads as a generic card table, not a tarot/obsidian altar. The rules and high-score dialogs *do*
  hit the intended purple-black glassmorphism, so the design language exists but is not applied to
  the main board.
- Card faces are clean but plain white with playing-card pips (hearts/spades/clubs/diamonds mapped
  onto Blood/Spirit/Nature/Light). They do not read as "tarot/arcana". This is the single biggest
  lever for the premium feel.
- A remote felt texture is loaded from `transparenttextures.com` via `Image.network` on every
  build. On web this is a runtime network dependency for a decorative overlay (silently blank if it
  fails or is blocked). Bundle the texture as an asset instead.

**Responsiveness**: This is a **landscape desktop layout** with fixed `Align` positions and fixed
sizes (cards 80px, center 300x300, hand 130px tall). There is no `LayoutBuilder`/`MediaQuery`
adaptation and no portrait handling. On a phone-width portrait viewport the edge-seated player
widgets and the 300x300 center trick area will crowd or overlap. The hand is a horizontal
`ListView` so it at least scrolls. For a game that "targets mobile", this needs a portrait layout
or an orientation lock. The web `manifest.json` even declares `portrait-primary`, which fights the
landscape design.

---

## 6. Accessibility

- **Semantics**: Good foundation. `CardWidget`, color buttons, and language buttons are wrapped in
  `Semantics` with localized labels (this was deliberate, per the `.Jules/palette.md` journal).
- **Color is not the only channel**: suits use distinct glyphs (heart/spade/club/diamond) plus the
  color, so colorblind players can still tell them apart. Good.
- **Zoom disabled**: `web/index.html` sets `maximum-scale=1.0, user-scalable=no`. This blocks
  pinch-zoom, an accessibility regression. Remove `maximum-scale`/`user-scalable=no`.
- **Contrast**: white text on dark panels is fine. The amber-on-white Light suit (`#FFA000`
  diamond on a white card) is the weakest pairing; verify against WCAG. Disabled grey bid buttons
  on black are low-contrast but they are non-interactive.
- **Tap targets**: cards (80x120) and color circles (60x60) are comfortable; bid buttons (50x50)
  and language flags (~40px) are near the 48px floor. Nudge the flags up.
- **Status feedback**: the single small status chip is the only channel for turn/trick/error
  messages and is not announced assertively; screen-reader and low-vision players will miss it.

---

## 7. Build, deploy, and config

- **Flutter channel / SDK**: workflow uses `subosito/flutter-action@v2` with `channel: 'stable'`
  and no pinned version, so builds float with whatever stable is current. `pubspec` requires Dart
  `^3.10.1`. Pinning a Flutter version in CI would make builds reproducible.
- **Deploy base-href mismatch (verify urgently)**: the workflow builds with
  `flutter build web --release --base-href /` but deploys to `server-dir: /arcana/`. I confirmed
  the built `build/web/index.html` contains `<base href="/">`. **If the game is served from a
  subpath like `https://domain.tld/arcana/`, a base href of `/` makes the browser request
  `flutter_bootstrap.js` and all assets from the domain root, which 404, giving a blank white
  page.** This only works if `/arcana/` on All-Inkl is actually a subdomain document root. Given
  the task describes it as `/arcana/`, this is a likely production breakage. Fix if subpath:
  `--base-href /arcana/`.
- **Unbranded PWA manifest**: `web/manifest.json` still has the Flutter defaults: `name` and
  `short_name` "magic_cards", `description` "A new Flutter project.", and `theme_color`/
  `background_color` `#0175C2` (Flutter blue, not the dark theme). For a web game the install
  prompt, splash color, and app name all use these. Rebrand to "Arcana", a real description, and a
  dark theme color. Also reconcile `orientation: portrait-primary` with the landscape layout.
- **HTML head**: `web/index.html` has a real `<title>Arcana</title>` and a basic description
  ("Arcana - A strategic card game"). For share previews, add Open Graph / Twitter card tags
  (title, description, an image) so the link renders as more than a bare URL.
- **App/package name**: `pubspec.yaml` `name: magic_cards` and `description: "A new Flutter
  project."` are still scaffolding defaults. Cosmetic, but it leaks into the manifest and
  test imports.
- **Dependencies**: reasonable and current-ish (`provider`, `shared_preferences`, `google_fonts`,
  `flutter_animate`, `web`). The prior QA report flags `google_fonts` 6 -> 7 as a major bump; test
  before upgrading. `google_fonts` fetches fonts at runtime on first launch (no bundled font
  assets in `pubspec`), which adds a first-load network dependency and a flash of fallback font on
  web; consider bundling Cinzel/Playfair/Roboto.

---

## 8. Tooling results

_Environment: a Flutter SDK is present at `D:\src\flutter`, but the toolchain does not run in
this audit environment: `flutter --version`, `flutter analyze`, and `flutter test` were all
launched and never returned (they hang during startup/compilation). This is an environment
limitation, not a code fault._

- **`flutter analyze`**: could not run (Flutter tooling unavailable here). Findings in this report
  come from static reading of the source, cross-checked against the GDD.
- **`flutter test`**: could not run (same reason). The CI workflow (`.github/workflows/deploy.yml`)
  runs `flutter build web --release` on every push to `main`, so a full build is the de facto gate;
  a compile-breaking change would fail that build.

What static reading covers that analyze would flag: the deprecated `withOpacity` calls noted in the
older HEALTH report appear already migrated to `withValues` throughout the current UI code. The
test suite on disk is small: `test/game_test.dart` (card/trick/deck logic), `test/ai_strategy_test.dart`
(bid and play heuristics), `test/card_widget_test.dart` (card rendering). Coverage gaps worth
closing later: full round/game-over flow, the AI overbid edge (section 4, defect 1), and DE/EN
key parity (a trivial test could assert both maps have identical key sets).

Prior in-repo reports (`docs/reports/HEALTH-2026-01-09.md`) claimed tests pass (13/13) and that
`flutter analyze` once reported ~149 issues dominated by `withOpacity` deprecations and
`avoid_print`; treat those numbers as stale given the `withValues` migration.

---

## 9. Prioritized changes (ranked by impact on a new player and on correctness)

1. **[Game Over] add** a real end screen: final standings, the human's placement, the high-score
   board, and a prominent "Play Again". Today the game dead-ends on a tiny "Game Over!" chip.
2. **[High scores] change** the commented-out button back on (setup dialog) and show the board on
   game over. The feature is fully built and currently invisible.
3. **[Round scoring] add** a per-round result panel: for each player show predicted vs won and the
   points delta (for example "You: predicted 2, won 3 -> -10"). Closes the learning loop.
4. **[Deploy] verify/change** the base-href. If served from `domain.tld/arcana/`, build with
   `--base-href /arcana/`; a `/` base href will render a blank page from a subpath.
5. **[Playing] add** legal-move affordance: dim or disable cards that cannot be played, instead of
   only rejecting the tap with "Invalid Move!". Teaches follow-suit in context.
6. **[Onboarding] add** a visible "How to Play" button in the setup dialog and auto-open the rules
   on first run (persist a flag). The rules are good but hidden behind a small `?`.
7. **[Game logic] change** `calculateBid` to clamp the result to `0..hand.length` so bots (notably
   Nero) cannot announce more tricks than exist.
8. **[Copy] change** the two en-dashes in `suits_title` to hyphens: "The Suits (1-13)" /
   "Die Farben (1-13)".
9. **[Copy] add** localization keys for the hardcoded `"TRUMP"` and `"Close"` strings (and decide
   whether card-face "ARCANUM"/"SHADOW" should localize).
10. **[Visual] change** the main table from casino green toward the GDD's obsidian/midnight
    glassmorphism (the rules/high-score dialogs already show the target look), and rework card
    faces toward a tarot/arcana treatment. Highest lever for the "premium" goal.
11. **[Responsiveness] add** a portrait/mobile layout (or orientation lock). The fixed-position
    landscape board will crowd on a phone, yet mobile is a stated target.
12. **[Bidding] change** the draggable prophecy overlay to a fixed centered panel, and add a
    one-line caption explaining why a bid is disabled (the hook rule).
13. **[Game logic] change/remove** the dead and conflicting bot definitions: either wire
    `skillLevel` and `BotCharacter` into real behavior, or delete `bot_character.dart` and the
    unused `BotPlayer.makePrediction/playCard` and keep one source of truth for personalities.
14. **[Config] change** the PWA manifest and `pubspec` off the "magic_cards / A new Flutter
    project" defaults; set a dark `theme_color`, real name/description, and add Open Graph tags to
    `index.html`.
15. **[A11y] change** `web/index.html` to allow zoom (drop `maximum-scale=1.0, user-scalable=no`),
    and bundle the felt texture and fonts as assets instead of fetching them at runtime.

---

*Honest bottom line: the engine is sound and the writing is good. The gap between this and a
"premium, atmospheric" shippable game is mostly in the states around the core loop (teach, score,
end) and in dressing the main board to match the soul, not in the trick-taking math.*
