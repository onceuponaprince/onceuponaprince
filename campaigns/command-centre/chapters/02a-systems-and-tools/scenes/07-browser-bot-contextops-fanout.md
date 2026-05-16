---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 07
title: "browser-bot contextops fan-out"
status: in-progress
date_opened: 2026-05-14
date_concluded:
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: "/home/onceuponaprince/code/borai/docs/superpowers/plans/2026-05-14-context-hygiene-pivot-roadmap.md"
blockers: []
supersedes: null
artifacts:
  - format: essay
    file: "[[07-browser-bot-contextops-fanout-essay]]"
  - format: thread
    file: "[[07-browser-bot-contextops-fanout-thread]]"
tags:
  - chapter-2a
  - browser-bot
  - contextops
  - borai
  - spore
  - fanout-research
  - context-hygiene
---

# Scene 2a-07 - browser-bot contextops fan-out

*Chapter 2a - Systems and tools · Campaign: [[command-centre]]*

*The browser-bot stops being a clever scraping surface and becomes a product instrument: three web-model providers receive the same BorAI ContextOps research brief, their answers and failures become a feature list, and the first bug is exactly the kind of bug the product is supposed to make legible.*

---

## Set the Stage

### How did we get here?

Scene 06 closed the handoff-board pattern: parallel agents, isolated worktrees, contract-freeze before dispatch, and a Rust DePIN substrate landed inside the monorepo. It also retired the old local `~/borai.cc` checkout and made `~/code/borai` the canonical place for BorAI work.

The next session moved one layer up. The pivot document in BorAI named the new product category as ContextOps: context hygiene, context packs, curation queue, local nodes, and proof-of-curation receipts. The first implementation slice landed inside Spore as a `spore-hygiene` crate and a `/v1/hygiene/analyze` endpoint. The product had its first atom.

Then the integration seam surfaced. The Rust session API only bridged to `borai-cc` when metadata said `via = "borai-cc"`, while the browser helper emitted `via = "browser"`. The gateway and the browser sidecar were both present, but they disagreed on the spell that opened the door.

### Where are we going?

This scene turns the seam into a working route and uses the route as a research instrument.

The destination is not merely "browser-bot can call Perplexity". The destination is sharper: browser-bot fan-out becomes a ContextOps workflow. One brief goes out to multiple provider surfaces. The results come back with provenance. Failures are not embarrassment; they are product data. The feature list is derived from the run, not invented in a vacuum.

### State of the world (project context)

In `~/code/borai`, Spore now has:

- a hygiene analyzer,
- context-pack data types,
- curation queue draft types,
- a direct hygiene endpoint,
- OpenAI-compatible hygiene preflight headers,
- a fixed browser bridge metadata contract.

The sidecars are live:

- `borai-cc` router on `localhost:4000`,
- `browser-bot` on `localhost:5500`,
- registered browser-bot workspaces for `perplexity`, `gemini`, and `grok`.

The fan-out run produced three different kinds of truth:

- Perplexity returned a full answer with route provenance.
- Gemini returned a usable but truncated answer.
- Grok returned the prompt rather than a synthesis after first failing at the browser-driver layer.

That last result matters. An HTTP 200 is not a useful response. The system needs to know the difference.

### State of the hero ([[solo-thesis-holder]])

The hero is the solo founder with too many models, too many tabs, and no reliable way to know which provider actually gave signal. They do not want a dashboard of green checks. They need a machine that can say: this answer is usable, this one is stale, this one echoed your prompt, and this provider path needs repair before you trust it.

The objection is obvious: "Why not just ask Perplexity directly?" The answer this scene has to earn is that asking directly gives an answer; the Command Centre gives a run, a trace, a comparison, and a story-shaped artefact afterwards.

### State of the protagonist ([[prince]])

The protagonist is no longer simply wiring tools together. He is debugging the grammar of a product category while using the unfinished product to research itself. That is a higher-friction state than normal coding, but it is also the exact kind of friction the thesis depends on. The tool should make the work feel like play, but not by making it weightless. It should turn the friction into scenery.

### This moment in relation to goals

Chapter 02a is about systems and tools becoming the infrastructure beneath the product. Scene 07 is the bridge between "the swarm can build code" and "the swarm can generate market intelligence with provenance". It inherits Scene 06's parallelism but applies it to research rather than implementation.

Campaign-level, this scene advances the product from private founder infrastructure towards a visible buyer-facing promise: ContextOps is not an abstraction. It is the act of cleaning, routing, comparing, and recording context as work happens.

### Why now?

Because the browser-bot path was already live, and because the first hygiene slice made the next missing thing obvious. If BorAI is going to sell context hygiene, it must treat its own research runs as context objects with quality, provenance, and failure modes. The fan-out is not a stunt. It is the smallest possible demonstration of the product's claim.

---

## Progress the moment

### Goal for this session

- [x] Fix the Rust-to-browser-bot metadata contract.
- [x] Verify the fix with targeted Rust tests.
- [x] Run a browser-bot fan-out research brief to Perplexity, Gemini, and Grok.
- [x] Create a ContextOps feature list from the fan-out.
- [x] Decide whether Grok's prompt-echo failure is a scene blocker or a carried-forward product bug.

### Moment-by-moment capture

- [x] Patched `BoraiCcClient::browser_metadata()` to emit canonical `via = "borai-cc"`.
- [x] Made the Spore session provider selection backwards-compatible with `via = "browser"`, `via = "cli"`, `via = "swarm"`, provider-only metadata, and workspace-only metadata.
- [x] Verified `spore-server` still passes its route, auth, rate-limit, OpenAI-validation, and hygiene tests.
- [x] Verified the BorAI CC provider metadata test sends `{"via":"borai-cc","provider":"claude"}`.
- [x] Confirmed `borai-cc` and `browser-bot` health endpoints were live.
- [x] Created browser-bot workspaces: `borai-perplexity`, `borai-gemini`, `borai-grok`.
- [x] Sent the same ContextOps research prompt to Perplexity, Gemini, and Grok through `/ask`.
- [x] Perplexity returned a full prioritised 90-day roadmap.
- [x] Gemini returned a useful but truncated three-phase roadmap.
- [x] Grok failed once at the browser-driver layer, then returned the prompt as the apparent response on retry.
- [x] Patched browser-bot to reject prompt echoes and empty extraction as failed model responses.
- [x] Patched Gemini handling with longer response stabilization, SPA navigation tolerance, and a fresh-profile retry for stale profiles.
- [x] Patched Grok handling to detect the logged-out landing page before it can echo the submitted prompt.
- [x] Retested Gemini through `/ask`; it returned a complete three-priority ContextOps answer via `playwright`.
- [x] Retested Grok through `/ask`; it now fails explicitly with `login required` rather than returning the prompt.
- [x] Completed Grok interactive login through noVNC with `selenium_uc`.
- [x] Verified the reusable Grok Selenium profile had the signed-in editor and no sign-in/sign-up links.
- [x] Reran the original ContextOps research brief through Grok; it returned a usable answer via `selenium_uc`.
- [x] Filed the derived feature list at `/home/onceuponaprince/code/borai/docs/superpowers/plans/2026-05-14-contextops-feature-list.md`.
- [x] Added the Character Registry and shared skill-resource model to the build-in-public engine docs, with the BorAI repo kept as the canonical implementation source.

### What's changing?

- Browser-bot is no longer treated as a provider convenience. It is now part of the ContextOps evidence chain.
- "Successful request" and "usable response" split into two separate states, and logged-out pages become first-class failures rather than malformed answers.
- The feature list inherits a new P0: response-quality validation for browser-bot.
- The build-in-public engine gains a stronger pattern: research fan-out can create roadmap artefacts when the run itself is captured.
- The character layer splits in two: vault characters remain narrative continuity, while Spore runtime characters become operational continuity with resolved skills, permissions, and shared resource handles.

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

---

## Notes

The Grok run is valuable precisely because it failed in a product-shaped way. If a provider path returns the prompt as the latest response, a naive browser automation layer will count success. A ContextOps layer cannot. It has to know when the context loop has collapsed into a mirror.

The retry fixed the mirror. Grok became usable after an explicit Selenium noVNC login and profile verification. Gemini also moved from "usable but truncated" to usable, with a scratch-profile retry for stale browser state.
