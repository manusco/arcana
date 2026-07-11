# Current State

## Phase
Live and iterating.

## Status
v1.1.0 shipped and live at arcana.23moments.com (Flutter web, deployed via GitHub Action to All-Inkl). The trick engine and prophecy scoring are verified correct.

## This pass (2026-07-11, first-principles audit)
- Added a real Game Over screen (final standings, the player's placement, the high-score board, Play Again).
- Added per-round result feedback (predicted vs won tricks and the points delta), so the scoring is finally visible.
- First-run onboarding: the rules dialog opens automatically the first time, plus a visible How to Play button.
- Re-enabled the high-scores board (its button was commented out).
- Dimmed illegal cards during play instead of only rejecting the tap.
- Fixed an AI bug where a bot could bid more tricks than exist in the round.
- Localized the last hardcoded strings (both languages, 77 keys at parity).
- Bundled the felt texture locally, so the game makes no third-party runtime request for it.
- Real PWA manifest, pubspec, and Open Graph metadata; re-enabled zoom.

## Known limits
- The new game-over, round-feedback, and onboarding flows were shipped through the CI build gate but not playtested in this pass, since the Flutter toolchain was unavailable locally. Playtest them.
- `high_score_service.dart` imports `package:web` at the top level, which builds for web but breaks the Windows and mobile targets. Guard it behind a conditional import.

## Next
- The visual overhaul (obsidian glassmorphism, tarot card faces) and a portrait/mobile layout. Both need a working Flutter toolchain and a playtest. See FUTURE_IMPROVEMENTS.md.
- Give the bots real personalities (the rich `bot_character.dart` archetypes are never used).
