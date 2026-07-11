# Arcana - Forward Improvements

What would make this game great next. Not a log of what shipped (see `CHANGELOG.md` and `docs/AUDIT_FINDINGS.md`). The next bets, ranked. Most of these need a working Flutter toolchain to build and playtest, which was not available in the pass that produced this list.

## The one move that matters most
Make the board look like the game it wants to be. The rules and high-score dialogs already show the target: obsidian, glassmorphism, mystical. The main table is still casino green with plain playing-card faces. Reskinning the table to the dark tarot aesthetic and giving the cards a real tarot treatment is the single biggest lift from "a working card game" to "the premium, atmospheric experience" the vision names. Do it with a designer and a playtest, not blind.

## Priority 1: the experience the vision promises

**Reskin the table and the cards.** Move the board from green to the obsidian/midnight glassmorphism already used in the dialogs. Redraw the card faces as tarot-style Arcana rather than standard pips. This is the highest-value visual work and needs playtesting to get right.

**Add a portrait and mobile layout.** Mobile is a stated target, but the board is a fixed landscape layout that crowds on a phone. Either build a portrait layout or lock orientation with a clear "rotate your device" prompt. Test on a real phone.

**Juice the moments.** Winning a trick, revealing a prophecy result, and the game-over reveal deserve motion and sound. The felt, vignette, and glow are a good base; the interactions are still static.

## Priority 2: depth and replayability

**Give the bots real personalities.** `bot_character.dart` defines six rich archetypes that are never used; the live bots come from a separate hardcoded map and differ only by a bid nudge, and `skillLevel` is stored but never read. Wire one source of truth so the bots actually play differently, then the "who am I up against" choice matters.

**A short round-by-round history.** A player who just lost wants to see where it went wrong. A compact scoreboard across rounds (not just the current round panel) turns a loss into a lesson.

## Priority 3: correctness and cross-platform

**Fix the Windows and mobile build.** `high_score_service.dart` imports `package:web` at the top level, which compiles for web (the deploy target) but breaks the Windows and mobile builds the vision claims. Guard the web-only import behind a conditional import so the desktop and mobile targets build.

**Add a legal-move helper text.** The dimming shipped this pass shows which cards are playable. Pair it with a one-line reason when a bid or move is disabled, so the follow-suit and hook rules teach themselves.

## Priority 4: polish and reach

**A real app icon and share image.** A branded favicon and a designed 1200x630 Open Graph image (this pass generated a basic one from the logo) lift the browser tab and every shared link.

**Sound and music toggle.** Atmosphere for a tarot game is half audio. Even a single ambient track with a mute control changes the feel.

**Difficulty selection.** Once the bots have real personalities, let the player pick the table (easy, mixed, ruthless). This is the cheapest replayability lever a single-player card game has.

## Priority 5: housekeeping
- Remove the dead code the audit found: the unused `Player.makePrediction`/`playCard`, the unused locals in `ai_service.dart`, and either wire or delete `bot_character.dart`.
- Bundle the fonts as assets if any are still fetched at runtime, matching the felt texture that is now local.
