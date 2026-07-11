# SEO Backlog: Arcana

Date: 2026-07-11. Owner: PIRATE GmbH. Arcana is a Flutter trick-taking card game ("The Game of Prophecy") shipped as a web build at `arcana.23moments.com`. Reference: `docs/AUDIT_FINDINGS.md`.

## SEO is a landing-surface concern only

Arcana is a game, not content, and it is a Flutter web app on top of that. The whole game renders into a canvas via `flutter_bootstrap.js`, so a crawler sees the `index.html` `<head>` and nothing else: no body text, no headings, no links. That makes the SEO surface tiny and fully defined. There is no content strategy to build and no keyword demand a solo card game needs. The honest scope is three things: keep the `index.html` head correct, describe the game once with schema, and make sure Arcana and its parent studio page do not compete for the same term.

## Current state

- Not a separate GSC property. `arcana.23moments.com` is a subdomain of `23moments.com`, which is a **domain** property in Search Console, so Arcana is already covered there. No separate verification needed.
- The `index.html` head is already improved (confirmed live 2026-07-11): a real `<title>Arcana</title>`, a `description` ("a strategic, mystical trick-taking card game of prophecy..."), full Open Graph (`og:title`, `og:description`, `og:url` = `https://arcana.23moments.com/`, `og:image` = `og-image.png`), a Twitter `summary_large_image` card, and PWA/apple-touch tags. For a shared link, this already renders a proper preview.
- Gaps: no structured data in the head (no JSON-LD), and per the audit the PWA `manifest.json` may still carry Flutter scaffold defaults ("magic_cards", "A new Flutter project.", theme color `#0175C2`).

## Core opportunity (honest)

The content-rich, indexable home for Arcana is not this app; it is the `23moments.com/arcana` marketing landing (pitch, rules, deck, real HTML). Discovery should route there. The app URL only needs a correct head and a clean canonical relationship. Both are small, one-time edits.

## Prioritized backlog

### On-page (the app shell)

1. **Keep the head as is; it is correct.** Title, description, OG, and Twitter tags are all present and on-tone. No further meta work is needed on the app.
2. **Rebrand the PWA `manifest.json`.** If it still holds the Flutter defaults, set `name`/`short_name` to "Arcana", a real `description`, a dark `theme_color` and `background_color` to match the game, and reconcile `orientation` with the actual layout. The install prompt, splash screen, and app name all read from this. Cosmetic for search, but it is the app's identity on install.
3. **Allow zoom.** `web/index.html` sets `maximum-scale=1.0, user-scalable=no`, an accessibility regression. Drop it. Not a ranking factor, but it is a cheap correctness fix in the same file.

### Structured data

4. **Add one `VideoGame` JSON-LD block to `index.html`.** `name` "Arcana", `description`, `genre` "trick-taking card game", `gamePlatform: "Web Browser"`, `playMode: SinglePlayer` (you play the computer), `applicationCategory: Game`, `publisher` (PIRATE GmbH / 23moments), `url` = `https://arcana.23moments.com/`. Since the head is the only thing a crawler reads on this Flutter app, this is the one meaningful structured-data placement. Validate in the Rich Results test.

### The canonical relationship to 23moments

5. **Defer to `23moments.com/arcana` as the content home.** Two URLs describe the same game: the app here and the marketing landing on 23moments (which has the crawlable copy). Pick the landing as the primary indexed target for "Arcana card game" and make this app either canonical to it or clearly the "play" endpoint, not a second content page. Also resolve the account-wide duplicate: `arcana.leanentrepreneur.com` appears as another copy of this subdomain in the GSC review and should be canonicaled or noindexed so the game's signal is not split across two subdomains. (This is the same decision tracked in the 23moments backlog, step 8; keep them in sync.)

## Measurement

- Nothing meaningful to track on the app URL itself; a Flutter canvas has almost nothing for Google to index, which is expected. The honest measure is on the `23moments.com/arcana` landing: is it indexed, and does "Arcana card game" surface it. Confirm via URL Inspection under the 23moments property. Volume will be small, and that is correct for a solo card game.

## Owner actions

- Decide Arcana's canonical home (step 5), in sync with the 23moments backlog.
- Confirm whether `arcana.leanentrepreneur.com` should exist; if not, retire or noindex it.
- Provide the `og-image.png` dimensions check (should be 1200x630) and confirm the manifest branding.
