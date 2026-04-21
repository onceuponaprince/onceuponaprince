---
title: Misled — Task 7 handoff
date: 2026-04-21
session_handing_off: build session 2026-04-21 (Tasks 4–6 + Y2K v2 + deploy + hooks)
session_picking_up: Task 7 (deploy preview + share with client)
branch: feature/misled-ethos-page (BorAI)
last_commit: c69a238 (docs: README updated with current apps + pre-push hook section)
preview_url: https://misled.vercel.app/
---

# Task 7 handoff — misled ethos page

*Read this top-to-bottom before doing anything. It captures everything the next session needs to start cold and pick up Task 7 without re-discovering state.*

---

## TL;DR for the next session

- **Where we are:** Tasks 1–6 of the [implementation plan](/docs/superpowers/plans/2026-04-20-misled-ethos-page.md) are shipped. Branch `feature/misled-ethos-page` at `c69a238` deploys cleanly to `https://misled.vercel.app/` via Vercel's dashboard Git integration.
- **What Task 7 is:** the deploy + share-preview-with-client step. Mostly: smoke-test the preview yourself, draft the message to the client, send it.
- **Major decisions made (don't re-litigate):** dashboard Git integration over CLI; gold-primary palette over multi-neon; Anton + Press Start 2P + VT323 + Space Grotesk + Space Mono + Syne typography stack; one-Win95-block-per-section rhythm; pre-push hook is load-bearing.
- **What's blocked:** nothing technical. The next session decides on the message + sends it. The client's reply gates Phase 3 (copy iteration) and the eventual domain registration.

## Bootstrap commands for the new session

```bash
cd ~/code/BorAI
git status                                # should be clean on feature/misled-ethos-page
git log --oneline -5                      # last commit should be c69a238
git config core.hooksPath                 # should print: .githooks
pnpm --filter misled dev                  # local on http://localhost:3001
```

Vault:

```bash
cd ~/code/build-in-public
git log --oneline -5
ls campaigns/command-centre/chapters/01-origin/scenes/
```

The capture for this session is appended to `04-misled-ethos-page.md`'s Moment-by-moment block and What's changing? block but the Conclude block is still empty — that's intentional, Conclude lands when the *scene* concludes (after Task 7 ships), not at every session boundary.

## State of the live page

Visit `https://misled.vercel.app/` — what you should see, top to bottom:

1. **TopToolbar** — Win95 chrome strip with sigil, DECKS / APPAREL / ACADEMY / CONTACT bevelled buttons, gold-on-black `VISITORS // 000356.5` counter (right).
2. **Hero** — vaporwave sunset gradient (sky cyan → hot pink → astral violet → void), centred sun-glow halo behind sigil, cyan perspective grid floor (4s pan loop), Press Start 2P `> SIGNAL ACQUIRED` eyebrow, glitched `DON'T BE MISLED.` headline (pink + cyan offset shadows), VT323 `[ EST. LONDON // FIRST DROP INCOMING_]` with blinking cursor.
3. **Marquee** — VT323 22px gold-glow ticker scrolling 22s, gold border block above + below.
4. **Manifesto** — `BRAND_IDENTITY.TXT` Win95 dialog (gold titlebar, traffic-light controls), PDF-condensed copy, gold-bordered pull-quote, gold "Get on the list. Be there when we drop." closer.
5. **Tease** — `DROP_INCOMING.EXE` Win95 dialog (pink titlebar variant), centred copy, VT323 `[ AWAITING SIGNAL // PRESS ANY KEY_]`.
6. **Subscribe** — `JOIN_LIST.EXE` Win95 dialog (cyan titlebar variant), bevel-inset email field with VT323 placeholder, Press Start 2P "TRANSMIT" button. Submit → 700ms fake delay → swap to ConfirmPanel showing email + blinking cursor.
7. **Floating sticker** — pink-shadowed "⚠ UNDER CONSTRUCTION ⚠" rotated -6°, pinned bottom-right.
8. **StatusBar** — fixed bottom bar: copyright, last-updated, gold-on-black visitor counter, "best viewed 1024×768" with blinking cursor.

Site-wide: CRT scanlines (3px alternating, multiply blend). Dashed gold focus rings. Dark void everywhere except hero gradient.

## Task 7 — what the plan actually says

From `docs/superpowers/plans/2026-04-20-misled-ethos-page.md` lines ~769–787:

> **Task 7: Deploy preview for client review**
>
> 1. Push branch (already pushed; this is a no-op now that dashboard Git integration auto-deploys)
> 2. Verify Vercel preview built — open Vercel dashboard for `misled-landing`, wait for the preview deploy on the branch, note the URL
> 3. Smoke test preview — hero renders, manifesto scrolls, tease visible, form accepts input + shows pending state, no console errors
> 4. Share preview URL with client — send URL + one-line note: *"Day 3 static — reading this for voice and feel, not polish. Real hero + final copy land later."*

The plan's note copy is from before we did the Y2K pivot. **Update the message** to reflect what the client will actually see — the page is no longer "static placeholder" but a full Y2K rave/tech aesthetic experience. See "Suggested client message" below.

## Open questions for the next session

1. **Client comms format.** Does the client want a short Slack/WhatsApp link with one line, an email with screenshots, or a Loom walkthrough? The plan defaults to "URL + one-line note" but a Y2K-coded design is opinionated enough that a 60-second Loom might land better. Ask the founder which.
2. **What feedback are we soliciting?** The plan implies "voice and feel." But we should be specific: do we want the client's reaction to (a) the Y2K aesthetic dominance — too much / not enough? (b) the manifesto copy condensation — voice right? (c) the typography choice — Anton speaks to the audience? Ranked feedback prompt > "let me know what you think."
3. **Domain decision gate.** `misled.london` registration was deferred until client signs off on the ethos page. Task 7's smoke test passing isn't sign-off — that's a separate ask. The next session should not register the domain unless the founder explicitly says go.
4. **Mobile viewport check.** I verified markup renders but couldn't visually confirm mobile layout. The Win95 chrome + sticker overlap could be tight on a 375px iPhone width. The next session should open the preview on a real phone before sending the link.

## Suggested client message (draft)

The client is Misled's founder. They are a London-based skater + brand operator, not a typical SaaS founder. Register: direct, no "as discussed," no "kindly find attached." Treat them like a peer:

```
Misled ethos page is live — preview link below.

  https://misled.vercel.app/

Day 3 build. Y2K rave/tech aesthetic — vaporwave horizon, OS chrome,
scanlines. Copy is condensed from the PDF; final pass after your read.

Worth your read:
  - Does the Y2K dial feel right, or push it harder/softer?
  - Manifesto copy — your voice, or am I off?
  - Typography (Anton + pixel fonts for chrome) — speak to the audience?

Hero will become a real WebGL scene (Maxime Heckel fork) in the next
build cycle. Form is wired but not yet connected to the email backend.
```

Adjust as the founder prefers. Don't send without their final pass.

## What's NOT done yet (post-Task 7)

For situational awareness — these are the things Task 7 doesn't cover but are queued in the plan:

- **Phase 3 — Copy iteration (Tasks 8–10):** adapt manifesto copy for the web, finalise tease copy, write the pre-launch sequence emails. Gated on client feedback from Task 7.
- **Phase 4 — Real hero (Tasks 11–14):** fork Maxime Heckel's `linear-vaporwave-react-three-fiber`, wire as dynamic-import client component, poster fallback for mobile + reduced-motion. The current hero is a static placeholder despite looking finished.
- **Phase 5 — Subscribe backend (Tasks 21–24):** Supabase table + Resend double-opt-in + cron deletion of unconfirmed rows older than 7 days. Form currently logs to console and silently drops honeypot trips.
- **Phase 6 — Sanity (Tasks 15–18):** move manifesto + tease copy out of hardcoded React strings into Sanity Studio. Client gets edit access.
- **Phase 7+ — Sentry, GA, defensive domains, custom domain wiring, sigil/logo final art replacement, accessibility audit, lighthouse perf pass, launch checklist.**

The two things most likely to come back from client feedback as urgent:
1. Copy edits to the manifesto (Phase 3)
2. Aesthetic intensity adjustment — dial Y2K up/down per their read

## Things the next session should NOT do

- **Don't register the domain** without explicit founder sign-off.
- **Don't merge `feature/misled-ethos-page` to main.** This branch is the live preview source; merging would tie misled to main's deploy cycle and we'd lose the ability to push WIP to preview without risking the production-coded branch.
- **Don't bypass the pre-push hook** unless something is genuinely broken on prod. The hook exists *because* we burned a Vercel build cycle on a 5-second-fixable lint error.
- **Don't rewrite the Y2K aesthetic** based on the client's first reaction — let them sit with it for at least 24 hours. First reactions to opinionated design are often "this is too much," and second reactions after living with it are often "actually this is right."

## File index for the next session

Production code:
- `apps/misled/app/{layout,page,globals.css}` — root + composition + tokens
- `apps/misled/components/{hero,marquee,manifesto,tease-block,subscribe-form,top-toolbar,status-bar,construction-sticker}.tsx`
- `apps/misled/styles/y2k-tokens.css` — Y2K design tokens (Rave/Tech, brand-overridden)
- `apps/misled/lib/y2k-tokens.ts` — TS mirror of the same
- `apps/misled/tailwind.config.ts` — extended with Y2K shadows / colours / fonts
- `apps/misled/INFRA.md` — deploy runbook (dashboard Git integration)

Vault:
- `campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md` — active scene
- `references/misled/y2k-design-system/STYLE-GUIDE.md` — director's brief
- `references/misled/y2k-design-system/y2k-misled-reference.html` — standalone "if it were 1999" HTML
- `references/misled/Misled - The Brand.pdf` — original brand manifesto from client
- `docs/superpowers/plans/2026-04-20-misled-ethos-page.md` — 30-task plan (we're between Task 6 and Task 7)
- `docs/superpowers/specs/2026-04-20-misled-ethos-page-design.md` — spec

Monorepo infra:
- `BorAI/.githooks/pre-push` — lint + typecheck gate
- `BorAI/README.md` — updated with current app inventory + hook docs
