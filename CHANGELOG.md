# Changelog

## 1.1.0 - 2026-07-11

First-principles audit pass. Findings in `docs/AUDIT_FINDINGS.md`. The trick engine and scoring were already correct; this pass closed the learning loop, added the missing end-of-game experience, and cleaned up copy, config, and a third-party request.

### Added
- A real Game Over screen: final standings, the player's placement, the high-score board, and a prominent "Play Again".
- Per-round result feedback: each player's predicted vs won tricks and the points delta, so the prophecy scoring is finally visible.
- First-run onboarding: the rules dialog opens automatically the first time, and a visible "How to Play" button is in setup.
- The high-scores board is reachable again (its button was commented out).
- Legal-move affordance: cards you cannot play are dimmed and disabled instead of only rejecting the tap.

### Fixed
- The AI could bid more tricks than exist in a round. The bid is now clamped to the hand size.
- Two en-dashes in the suit titles are now hyphens.
- Hardcoded UI strings ("TRUMP", "Close", the card-face labels) now go through the localization service, in both German and English.

### Changed
- The felt table texture is bundled locally instead of fetched from a third-party site at runtime, so the game makes no external request for it.
- Real app metadata: the PWA manifest and pubspec carry the game's real name and description and a dark theme, replacing the "magic_cards / A new Flutter project" defaults. The web page has a real description, Open Graph tags, and zoom is re-enabled for accessibility.

### Notes
- German and English are at full parity (77 keys each).
- The larger visual overhaul (obsidian glassmorphism, tarot card faces) and a portrait/mobile layout are deferred to a follow-up that can be playtested. See `FUTURE_IMPROVEMENTS.md`.
