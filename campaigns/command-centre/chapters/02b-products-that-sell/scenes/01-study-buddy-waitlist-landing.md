---
campaign: "[[command-centre]]"
chapter: "02b-products-that-sell"
scene: 01
title: "study-buddy waitlist landing"
status: in-progress
date_opened: 2026-04-21
date_concluded: 
characters:
  - "[[prince]]"
  - "[[resource-curator]]"
artifact_format: 
artifact_file: 
tags:
  - chapter-2b
  - study-buddy
  - landing-page
  - waitlist
  - commercial
---

# Scene 2b-01 — study-buddy waitlist landing

*Chapter 2b — Products that sell · Campaign: [[command-centre]]*

First scene of the products-that-sell branch. The landing page goes up before the product exists — waitlist first, build second, per founder framing.

---

## Set the Stage

### How did we get here?

Scene 05 produced the full catalogue for study-buddy: a functional definition, a problem statement, a landscape scan, a fit argument, four weighed architectural alternatives (A runtime-import client-side, B static bundle, C server-side persist, D headless-CMS-backed) with Architecture A selected, a target user (the Resource Curator), an MVP feature set, a pricing-posture decision (Option I free OSS vs Option II free-core + branded-players), a 90-day timeline, and a four-signal decision framework for *when to start the build*. What the catalogue did not produce: a single line of UI. The scaffold at `apps/study-buddy/` on `feature/study-buddy` has `jszip`, `gray-matter`, `localforage`, a parser stub, and nothing a user can see. The founder's declared intent for Chapter 2b: landing page first, product to sell.

### Where are we going?

A live landing page at its own URL, capturing waitlist signups, framed around the Resource Curator. Emails into Supabase via Resend double-opt-in (the Misled pattern, inheritable). The page promises the product before building it: *turn your Obsidian vault into a studyable experience without forcing your audience to install Obsidian.* The waitlist is not a vanity metric — it is the material the decision framework's Shareability Signal (*five unprompted URL requests in thirty days*) can finally fire against. No shareable URL meant the signal could not fire. A shareable URL is this scene's actual deliverable.

### State of the world (project context)

BorAI monorepo. `apps/study-buddy/` scaffolded on `feature/study-buddy` — parser stub, no UI. Scene 04's Misled build established the house pattern for brand-forward landing pages: Next.js 15 + Tailwind, hand-rolled components (no shadcn), Supabase + Resend double-opt-in, dashboard-Git deploy integration, pre-push hook catching lint + typecheck before it burns a remote build cycle. All of this is inheritable; none of it is automatic — the pattern has to be explicitly reapplied, not assumed.

Study-buddy has no domain yet — decision pending between dedicated (`studybuddy.xyz` / similar; separate identity) and subdomain (`study.yurika.space`; inherited identity). No design direction committed yet either — the catalogue named the Resource Curator audience but not the visual register.

### State of the hero ([[resource-curator]])

The Resource Curator. Has a large specialised Obsidian vault on a niche topic — blockchain engineering, comedy writing, art history, a legal sub-specialism. Has spent hundreds of hours curating it. Wants to distribute the vault as a studyable experience without forcing recipients to install Obsidian, install plugins, or trust a proprietary platform with private notes. Dominant objection: *I already tried Anki and Obsidian's spaced-repetition plugin; what's different here?* What earns their attention: (a) the zero-install posture — recipients can study the vault in any browser; (b) the privacy posture — the vault never leaves the device; (c) the distribution posture — their vault can ship with their brand, not the platform's. The landing page's job is to land those three at reading pace, not bury them in copy.

The character file `[[resource-curator]]` does not yet exist. Unresolved wikilink — archetype needs drafting, ideally during or immediately after this scene so it is ready for Scene 2b-02 onwards.

### State of the protagonist ([[prince]])

Wants this product to sell, not just ship. Carrying the commercial intent declared at the start of the session: *a landing page and a product to sell.* Knows Scene 05's decision framework was supposed to gate the build, and has chosen to open the commercial track first as a signal-generation mechanism — the landing is what lets Shareability and Tutor Pull fire at all. Brings the Misled Y2K-rave stack knowledge hot in head — but the register should not inherit the Y2K aesthetic. Study-buddy's audience is older than Misled's by five to fifteen years; the visual register leans editorial and clean, closer to a scholarly tool than a streetwear launch.

### This moment in relation to goals

Chapter 2b's first scene. The landing is the gate — no landing, no signal, no framework. With a landing live, the framework turns from theory into instrumentation. Subsequent scenes (parser + flashcard renderer, pricing, first sale) all depend on this one's output: a URL and a waitlist count.

### Why now?

Because the landing is the gate. Because the founder has declared commercial intent for 2b and the landing is the cheapest surface to express it on. Because Misled's backend patterns are hot in head and inheritable this week, less so a month from now. Because Chapter 2a opens in the same session and will pull attention if the commercial track does not open decisively first.

---

## Progress the moment

### Goal for this session

- Domain decision made (dedicated vs yurika subdomain) and registered if needed.
- `apps/study-buddy/` scaffold extended with landing route. Reuses Misled's Supabase + Resend + cron patterns; no shadcn.
- Landing copy drafted, Resource-Curator-facing, editorial register.
- Waitlist form wired end-to-end (confirm email received by a real inbox).
- Preview URL live. Smoke-test passes — *the URL you plan to send, not the URL you assume is serving* (Scene 04's load-bearing lesson).
- `[[resource-curator]]` archetype character file drafted (parallel track or immediately after).

### Moment-by-moment capture

- [ ] Scene opened, Set Stage signed off.

### What's changing?

- 

---

## Conclude

*Filled at end of session.*

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format
*Thread / newsletter / video / essay / none.*

---

## Notes
- The `[[resource-curator]]` character file needs drafting — archetype for study-buddy's audience across Chapter 2b. Best written alongside or immediately after this scene, before Scene 2b-02 opens.
