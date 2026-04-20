---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 04
title: "misled ethos page"
status: in-progress
date_opened: 2026-04-20
date_concluded: 
characters:
  - "[[misled-founder]]"
  - "[[misled-audience-archetype]]"
artifact_format: 
artifact_file: 
tags:
  - client-work
  - landing-page
  - chapter-1
  - r3f
  - brand-movement
---

# Scene 04 — misled ethos page

*Chapter 1 — Origin · Campaign: [[command-centre]]*

Second paid-client deliverable of Chapter 1 — the scene structure meets a brand-movement vertical with r3f in the hero and an audience that will read every word for corniness.

---

## Set the Stage

### How did we get here?
Scene 02 shipped Talk with Flavour's preview URL. Scene 03 closed the first real feedback loop — Nathan's V1 review triggered a category shift (videographer → media platform) and a V2 preview. Two proof points on a single client is enough; Chapter 1 needs a second client to test whether the method generalises. Misled — a London-based skateboard and streetwear movement brand — is that second client, deliberately different from Nathan's service-vertical positioning. Brand materials are in: the PDF manifesto, two design-reference HTMLs (`misled-design.html`, `misled-alternative.html`), logo, sigil. Hero is specified to fork Maxime Heckel's `linear-vaporwave-react-three-fiber` scene.

### Where are we going?
The **ethos page** — Stage 1 of a three-stage launch (ethos → tease → pre-order) — live on `misled.london`. Production-grade foundation (Sanity for the manifesto, Supabase + Resend for double-opt-in capture, Sentry, Vercel Analytics) that the later stages inherit without plumbing twice. Exit criteria: r3f hero real on desktop with poster fallback on mobile, manifesto live from Sanity, a first subscriber confirmed end-to-end, client logged into the studio.

### State of the world (project context)
BorAI monorepo at `~/code/BorAI/` — `apps/talk-with-flavour/` is live. Semantic theme-token system (surface / ink / accent as CSS vars) established in Scene 02, inheritable. Misled lands as `apps/misled`. Brand materials sit at `references/misled/`. Spec at `docs/superpowers/specs/2026-04-20-misled-ethos-page-design.md`; implementation plan at `docs/superpowers/plans/2026-04-20-misled-ethos-page.md` (30 tasks across 9 phases). Build strategy: Approach 2 — visible-first (static by Day 3, r3f by Day 7, wired by Day 10, ship Day 14).

### State of the hero ([[misled-audience-archetype]])
The ethos page doesn't serve the client, it serves the client's audience: young, underrepresented people in London, sixteen to twenty-four, pressured by social media and algorithmic expectation into performing someone else's idea of authenticity. They've been sold to before and know the shape of it. They'll read every word for corniness — brands claiming to *stand for* something are the default object of suspicion. The page's job is to make them feel *seen* rather than *addressed*, and to hand them a single field to hold the belonging. Wants: cool gear. Needs: proof the brand isn't another algorithmic trap. Dominant objection: *is this just streetwear cosplaying as a movement*.

### State of the protagonist ([[prince]])
Just shipped Scene 02's preview. Taking on a second client while BorAI itself is still young — context-switch cost is real. Comfortable with the British-editorial register TWF needed; Misled's register is different — younger, more declarative, closer to *movement* than *brand*. r3f is new ground for this codebase — the first WebGL surface in BorAI — so whatever perf-and-fallback pattern lands here becomes the default for any future 3D work.

### This moment in relation to goals
Chapter 1's arc is *manual-proof through client work*. Scene 02 gave proof-1 in a service vertical (restaurant video); Scene 03 closed the feedback loop on that same client. Scene 04 is proof-2 in a brand-movement vertical — deliberately different enough that if the structure holds here too, the method generalises rather than fits one kind of client. Proof-2 also forces r3f and Sanity into the BorAI monorepo, which means every future sibling app inherits the patterns set now.

### Why now?
The client is ready. Brand materials are in, domain available, spec and plan signed off the same day. Scene 03's category-shift work left the stack knowledge hot and the voice-muscle warm. Firing Scene 04 now compounds that momentum rather than letting it cool. Chapter 1 still has a fifth scene to close after this.

---

## Progress the moment

### Goal for this session
Task 1 — scaffold `apps/misled` in BorAI with Next.js 15 + Tailwind, local dev server running, first Vercel preview deployed.

### Moment-by-moment capture

- [x] Scene opened, Set Stage signed off
- [x] Spec written (`docs/superpowers/specs/2026-04-20-misled-ethos-page-design.md`)
- [x] Implementation plan written (`docs/superpowers/plans/2026-04-20-misled-ethos-page.md`) — 30 tasks, 9 phases, visible-first strategy
- [x] Stack decision: **no shadcn/ui** — hand-rolled Tailwind components on brand-forward client work; shadcn stays for internal surfaces. Saved to memory.
- [x] **Task 1 shipped** — `apps/misled` scaffolded in BorAI on `feature/misled-ethos-page`. Two commits: `168f4351` (initial scaffold, Next.js 15 + Tailwind, placeholder page) and `7fdccc0` (code-quality fixes from review loop).
- Review loop caught three monorepo-hygiene issues the implementer missed on first pass: version pins had diverged from `apps/talk-with-flavour` (mis-pinned `next`, `@types/*`, `tailwindcss`, etc.), `typedRoutes` was still under `experimental` (Next 15.5+ moved it to top-level stable), and ESLint config was missing entirely. Design decision formalised: **sibling-app pin divergence inside the monorepo is a bug, not a preference.** The monorepo is a single contract; apps that drift silently become debugging tax. Default for any future BorAI sibling app: match the eldest sibling's pins unless there's a stated reason not to.
- Meta-observation: the spec → plan → implementer → spec-review → code-quality-review flow caught three real issues on a task this mechanical. The two-stage review isn't overhead on simple tasks — it's the only way simple tasks don't quietly erode the monorepo's coherence over time. Worth keeping the two-stage discipline even when the task looks like pure scaffold.
- [x] **Task 2 prep** — `INFRA.md` committed (`c70c60e`). Vercel CLI already authenticated as `onceuponame`; project `misled-landing` in the BorAI team ready to link. Four interactive steps surface to the founder for manual execution (link, first preview, register `misled.london`, check defensive domains).
- Rebased `feature/misled-ethos-page` onto `main` to pick up the `.vercel` / `.env*.local` ignore rules TWF V2 added; force-with-lease pushed (`b05f4b5`).
- **Vercel CLI deploy dead-ended.** Running `vercel` from `apps/misled` hung on "Uploading [===]" — pnpm-hoisted `node_modules` symlinks resolve to the workspace store at upload time, so the tarball isn't app-sized, it's monorepo-sized. Running from monorepo root is also blocked: `BorAI/.vercel/` is already linked to `talk-with-flavour`, so `vercel` from root targets the wrong project.
- **Pivot: dashboard Git integration.** Sibling TWF has no `.vercel/project.json` at all — it deploys purely via Vercel's Git webhook with Root Directory `apps/talk-with-flavour`. Applied the same pattern to misled: connect repo, set Root Directory `apps/misled`, include files outside root, save. No CLI upload. Every push builds. Stale `apps/misled/.vercel/` removed. **House pattern for all future BorAI sibling apps: dashboard Git integration, not CLI.**
- **Task 2 shipped** — First preview URL: `https://misled.vercel.app/`. Scaffold renders.
- **Task 2 scope descoped on purpose.** Domain registration (`misled.london`) and defensive-domain checks (`misled.co.uk`, `misled.com`, `misled.shop`) deferred until the client has reviewed stage-1 ethos page. No point spending on domains before the work the domain points at exists and has been signed off. Client-feedback gate added to the infra plan.

### What's changing?

- The BorAI monorepo gets its first WebGL app. Whatever r3f pattern lands here (dynamic import with `ssr: false`, poster fallback, performance monitor, reduced-motion gate) becomes the house pattern for any future 3D work across the monorepo.
- The stack diverges further from the `yurika-web-template` skill defaults. Scene 02 dropped shadcn + Zustand + React Query for editorial reasons. Scene 04 formalises that: brand-forward client work does not reach for shadcn. Memory updated.
- **Deploy pattern standardised.** TWF's dashboard-Git-integration approach (no CLI, no local `.vercel/project.json` per app, rootDir set per project) is now the explicit house default — the CLI path is only a fallback for emergencies. Any subsequent BorAI sibling inherits this without re-discovering it. Saves every future app ~30 min of the same dead-end I just walked.

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
