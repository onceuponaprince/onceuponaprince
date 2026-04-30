---
campaign: "[[command-centre]]"
chapter: "02b-products-that-sell"
scene: 01
title: "study-buddy waitlist landing"
status: concluded
date_opened: 2026-04-21
date_concluded: 2026-04-22
characters:
  - "[[prince]]"
  - "[[resource-curator]]"
spec_file: "docs/superpowers/specs/2026-04-22-teenyweeny-studio-landing-design.md"
blockers: []
supersedes:
  - "docs/superpowers/specs/2026-04-21-study-buddy-landing-design.md"
artifacts:
  - format: thread
    file: "[[01-study-buddy-waitlist-landing-thread]]"
  - format: essay
    file: "[[01-study-buddy-waitlist-landing-essay]]"
tags:
  - chapter-2b
  - teenyweeny-studio
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

- [x] Scene opened, Set Stage signed off (2026-04-21).
- [x] `[[resource-curator]]` archetype drafted and committed — the Chapter 2b hero now has a character file with wound/want/need/weakness + five product-decision constraints.
- [x] Landing design spec drafted at `docs/superpowers/specs/2026-04-21-study-buddy-landing-design.md` while founder works the ai-swarm bootstraps in parallel. Covers: (1) four founder-gated decisions (domain, product name, waitlist infra, visual register) with recommendations, (2) seven-section component architecture inheriting Misled's shape, (3) full landing copy Resource-Curator-facing in editorial register, (4) voice notes for Chapter 2b as a whole, (5) build sequence for the BorAI session when Prince is next available.
- Recommendation staked on domain: `studybuddy.page` primary, `studybuddy.xyz` fallback. Recommendation staked on visual register: Instrument Serif + Cabinet Grotesk + deep-green accent (`#1F4028` family) — shares zero register with Misled's Y2K gold, reads scholarly rather than startup-y.
- **What the orchestrator cannot do alone:** purchase the domain, create the Supabase project, verify the Resend sending domain, link the Vercel project, extend `apps/study-buddy/` inside BorAI with the landing route. These items gate scene close and are queued for a BorAI session.
- [x] **2026-04-22 — Project handle pivoted: `study-buddy` → `teenyweeny.studio`.** Founder directives: (1) the URL is the wordmark — no separate brand name, the domain is the brand; (2) visual register rewritten away from editorial-scholarly toward zine — monospace headers, dotted/dashed rules, photocopier grain, single bold accent; (3) palette moves off deep-green; new accent rust (`#B7410E` family) on cream surface; (4) landing copy preserved verbatim — the arguments (privacy, zero-install, distribute-under-your-own-brand) hold regardless of register; only the wordmark and product-name mentions swap; (5) rename applies forward only — Scene 05 catalogue and Chapter 1 references stay as historical *study-buddy*; (6) project still lives at `apps/study-buddy/` on `feature/study-buddy` inside BorAI for now (rename of branch + directory is a BorAI-session decision, not a vault decision).
- [x] New design spec written at `docs/superpowers/specs/2026-04-22-teenyweeny-studio-landing-design.md`. The 2026-04-21 spec is left in place as the superseded version — a record of the editorial-scholarly direction that was considered and rejected, useful for the Conclude block's "what we learned" beat.
- **2026-04-22 — Honest note on the deciding input.** The pivot to `teenyweeny.studio` happened because the founder already owned the domain. No creative-discovery process behind the name, no shortlist, no availability sweep. Owning it was the whole reason. Worth marking honestly because it cuts against the 2026-04-21 spec's careful *studybuddy.page recommended* reasoning — the deciding input was an existing asset, not a deliberation outcome. The orchestrator's domain analysis was real work that did not get used.

### What's changing?

- The chapter now has its hero as a character file, not only as a catalogue description. Future Chapter 2b scenes can reference `[[resource-curator]]` as an authoritative constraint source.
- The landing's visual register is named — and then re-named. First pass: editorial, scholarly, deep-green accent. Second pass (2026-04-22): zine, monospace, rust accent, URL-as-wordmark. The pivot is itself the most interesting decision of the scene — the editorial register read like a small-press publisher; the zine register reads like a curator's own workshop. The latter sits closer to the Resource Curator's actual self-image: practitioner first, polish second.
- The project handle is now `teenyweeny.studio`. The domain *is* the brand. There is no separate wordmark to commission, no name to defend in copy, no logo to design — the URL does the work. This is a Chapter 2b commitment with downstream consequences: Scene 2b-02's MVP player UI inherits the same register; pricing copy in 2b-03 carries the same wordmark posture.
- Scene 05's catalogue and Chapter 1 references retain *study-buddy* as historical record. Forward-looking artifacts (this scene's capture, Chapter 2b's scene list, the new design spec) use *teenyweeny.studio*.

---

## Conclude

### How is now different from the start?

At Set Stage: `apps/study-buddy/` scaffolded inside BorAI with parser stub and no UI; no domain, no design direction, no character file, no URL. Now: the Resource Curator has a character file; two design specs sit in the repo (the 2026-04-21 editorial-scholarly direction, superseded; the 2026-04-22 zine direction, current); the project handle is `teenyweeny.studio` with the URL doing the work of a wordmark. What has *not* changed: the landing page does not exist. No URL, no waitlist, no signal.

### What are the consequences?

Chapter 2b's downstream scenes inherit the teenyweeny.studio wordmark and zine register — the MVP UI in 2b-02 and the pricing page in 2b-03 carry the same visual commitment, so those decisions don't reopen. The superseded 2026-04-21 spec becomes the first instance of the superseded-spec pattern in this vault — the two files together read as the decision itself. The external-dependency queue is now legible as `blockers:` frontmatter; the scene cannot ship to `shipped` until those land. Chapter 2b's *landing before build* rule holds the line: no Scene 2b-02 until a URL exists.

### What did we learn?

Four beats, sober.

1. **The deciding input was an owned asset, not a deliberation outcome.** The orchestrator produced a careful domain recommendation (studybuddy.page > studybuddy.xyz). The founder pivoted to teenyweeny.studio because he already owned it. Real work went unused. Worth naming because it shows where design authority actually lives in a solo build — the founder's asset register, not the orchestrator's analysis.
2. **A landing page without a URL is not a landing page.** The declared deliverable was a live URL that would let the Shareability signal fire. Specs shipped instead. The instrumentation remains unfireable. The scene produced a plan to ship; it did not ship.
3. **The zine register is cheaper to commit to than the editorial register was.** URL-as-wordmark means no logo to commission, no separate brand name to defend, no two-word mark to source fonts for. The pivot reduced Chapter 2b's design surface — though the reduction was a side-effect of the asset-ownership input, not a deliberate design call.
4. **Superseded specs earn their keep when kept in place.** The 2026-04-21 spec, left beside the 2026-04-22, turns the pivot into a visible decision rather than a silent overwrite. Use again.

### Progress to thesis

*Play should write the story.* The scene produced story — a publishable pivot with a deciding input that runs against the orchestrator's recommendation. Two specs in the repo, a register rewritten, a domain-as-brand commitment, an honest note about unused analysis. Beat material.

But Chapter 2b's thesis-progress test — *does the method produce a saleable product?* — this scene cannot answer. The narrative is running ahead of the product. That is the chapter's chosen pattern; the scene honours it but also inherits its cost. No URL means no signal, which means commercial proof sits one scene further out than the chapter arc implied on paper.

### Progress to goal

Seven goals declared at Set Stage: domain decided + registered, landing route extended, copy drafted, waitlist wired, preview URL live, smoke-test passing, Resource Curator archetype drafted.

What landed: the archetype. Domain was decided (twice) but not registered. Copy was drafted (twice, once editorial, once zine). Landing route, waitlist wiring, preview URL, smoke-test — none. Score: 1 of 7 met. The other six need a BorAI session: the founder inside `apps/study-buddy/`, registering the domain, running the Supabase and Resend setup, linking Vercel, scaffolding the route.

### Next scene

**Scene 2b-01b — ship the URL.** Founder-led BorAI session: register teenyweeny.studio, create Supabase project, verify Resend sending domain, link Vercel, scaffold landing route per the 2026-04-22 spec. The chapter's *landing before build* rule makes Scene 2b-02 (Parser + flashcard renderer) unreachable until this lands. Parallel-track work on [[02a-systems-and-tools]] remains legitimate but doesn't advance this chapter.

### Artifact format

Essay (Prince's blog register), with a thread variant. The essay sits on the long beat — design authority and the deciding-input lesson. The thread compresses to the pivot and the superseded-spec pattern. Both formats carry the scene's honest shape without adding optimism.

---

## Notes
- The `[[resource-curator]]` character file needs drafting — archetype for study-buddy's audience across Chapter 2b. Best written alongside or immediately after this scene, before Scene 2b-02 opens.
