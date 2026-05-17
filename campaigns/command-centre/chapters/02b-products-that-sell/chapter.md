---
campaign: "[[command-centre]]"
chapter: 02b
title: "Products that sell"
status: in-progress
date_opened: 2026-04-21
date_concluded: 
climax_artifact: 
tags:
  - chapter
  - chapter-2b
  - products
  - commercial
---

# Chapter 02b — Products that sell

*Campaign: [[command-centre]] · Runs concurrently with [[02a-systems-and-tools]]*

## Arc

From catalogue to commerce. Scene 05 produced a full catalogue for study-buddy — a spec, an architectural analysis of four alternatives, a decision framework with four behavioural signals. Chapter 2b opened by trying to make that catalogue meet the market through teenyweeny.studio.

The chapter now has a second product track. marrk.space has moved into BorAI as a separate durable user-facing vault product: capture, vaults, graph-style tagging, backend persistence, permissions, bots, browser extension, deterministic vault chat, diagnostics, analytics, and beta deployment scaffolding. This does not replace study-buddy/teenyweeny. It gives the chapter a parallel commercial question: *can BorAI's vault substrate become a product people return to?*

Scenes follow the commercial journey:

1. **Landing + waitlist** — promises the product before the product exists; captures commercial intent.
2. **Parser + flashcard renderer** — the MVP teenyweeny promised.
2b. **marrk.space as BorAI vault wedge** — a separate product lane: AI memory vault for everything you save, with BorAI as substrate.
4. **Pricing + commercial packaging** — catalogue's Option I (free, OSS only) vs Option II (free core + custom-branded players for curators), plus marrk.space's later credit-led agent monetisation track once beta value is proven.
5. **First sale attempt** — chapter climax.

The first sale is this chapter's **climax**.

## Thesis progress

Chapter 1 tested whether the method produces publishable narrative. Chapter 2b tests whether the method produces *saleable* product. A narrative that sells is a narrative that works. If study-buddy attracts paying curators (per catalogue Option II: free core + branded players), the build-in-public loop has closed all the way round. If it does not, the chapter's honest Conclude is the more valuable artifact.

## Scenes

- [x] **01 — teenyweeny.studio waitlist landing** — Landing page + waitlist capture on a real domain, before any product build. Classic BIP sequence; matches founder's *landing before build* framing. (Project handle pivoted from `study-buddy` to `teenyweeny.studio` mid-scene on 2026-04-22 — see scene capture for the register and palette consequences.)
- [ ] **02 — Parser + flashcard renderer** — The MVP teenyweeny promised. Day 1-30 of the catalogue's 90-day timeline. Runtime-import architecture per Scene 05's commitment (*vault as user data, not system data*).
- [ ] **02b — marrk.space borai vault wedge** — marrk.space is migrated into `~/code/borai/apps/marrk-space` as a separate durable user-facing vault product. Commercial proof narrows around the beta loop: capture saved material, search it, synthesise it, and return.
- [ ] **04 — Pricing and commercial packaging** — Catalogue's Option I or Option II, chosen and defended, with marrk.space's credit-led agent monetisation kept behind beta validation.
- [ ] **05 — First sale attempt** — Chapter 2b's climax. Thesis test: does the method produce commerce?

## Climax

The first paid curator. Whether that is a Custom Branded Player commission (Option II) or a community-validation event that earns the way to one (Option I), the close of this chapter is the commercial proof the chapter set out to seek.

## Constraints for this chapter

- **Runs in parallel with [[02a-systems-and-tools]].** Scenes may cross-reference; neither chapter blocks the other.
- **Landing before build.** No MVP code ships before a waitlist exists. This inverts the catalogue's 90-day timeline deliberately — the landing is Day 0, not Day 61.
- **Honour the decision framework.** Scene 05's four behavioural signals (shareability, parser stability, tutor pull, mobile friction) are tracked through the chapter and named in Conclude blocks. The landing page's job is to generate signal.
- **No shadcn/ui.** Brand-forward commercial work. Hand-rolled Tailwind per memory.
- **Runtime-import is load-bearing.** The privacy posture (vault never leaves the browser) is a commercial proposition, not a technical preference. Marketing copy has to carry it without sounding like a feature list.

## Carry-over to Chapter 3

- *(Filled at chapter close)*
