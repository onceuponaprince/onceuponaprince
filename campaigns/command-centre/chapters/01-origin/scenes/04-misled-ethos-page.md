---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 04
title: "misled ethos page"
status: concluded
date_opened: 2026-04-20
date_concluded: 2026-04-21
characters:
  - "[[misled-founder]]"
  - "[[misled-audience-archetype]]"
artifact_format: thread, essay
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
- [x] **Task 3 shipped** — typography + palette tokens at `6563c74`. **Anton** (display, condensed bold caps with loose 0.04em tracking) + **Space Grotesk** (body) + **Space Mono** (mono), wired via `next/font/google` as `--font-display/body/mono`. Palette: gold (`#FFB800`) primary accent on void (`#0D0015`) ground, offwhite (`#F0E6FF`) ink, vaporwave secondary (pink/cyan/violet) reserved for accent moments. Three font choices presented; option A (Anton-led) won — speaks to Black British youth typographically without leaning on the obvious cosplay fonts. Loose tracking is the move; without it Anton's condensed letterforms collapse into a slab.
- **TWF's semantic-token system ported cleanly.** RGB-triple CSS vars (`--surface`, `--ink`, `--accent`) → Tailwind colour mapping via `<alpha-value>` slot — same architecture, different brand values. Second instantiation confirms it as a **BorAI house pattern**, not a TWF one-off. Any future sibling inherits the shape; the values flex per-brand.
- **Rebased onto main** before continuing — main had moved 6 commits (ai-swarm-infra scaffold + polish, study-buddy scaffold + parser, Python bytecode ignore). Two trivial conflicts: `pnpm-lock.yaml`'s `apps/study-buddy: {}` entry (kept) and `.gitignore` (kept both python-bytecode and ops-inbox blocks). Misled work now sits cleanly on top of all parallel ops scaffolding.
- [x] **Task 4 shipped** — static hero with sigil at `a1b2fd0`. 90vh dark section, four-layer gradient/grid overlay, centred sigil with gold glow, "DON'T BE MISLED." headline (uppercase from base h1 rule + Anton + loose tracking), subhead in `text-ink-muted`, `rise-in` entry animation. Sigil compressed 5.9MB → 33.9KB at 480×480 via sharp; serves through `next/image` at 2.5KB at displayed width.
- [x] **Task 5 shipped** — manifesto + tease + footer at `9f142d7`. Editorial layering via surface/raised/mid bg rhythm, gold mono eyebrows, gold-bordered pull-quote in manifesto, Win95-titlebar tease block, MISLED wordmark in footer with mono visitor counter.
- **Y2K v1 attempt didn't read.** First pass at vaporwave styling (scanlines, perspective grid, marquee, win95 chrome) felt close but not period-correct enough — the references (`misled-design.html`, `misled-alternative.html`) push much harder on chrome bevels, hard offset shadows, pixel typography, and floating ornaments than the soft Tailwind-shadow translation I'd done.
- **Pivoted to the `/y2k-design-agent` skill** — Rave/Tech subtype, brand-overridden Acid Gold palette (the skill defaults to acid green; we substituted the brand's gold). Skill produced its mandated four-part deliverable: design tokens (CSS + TS at `apps/misled/styles/y2k-tokens.css` and `apps/misled/lib/y2k-tokens.ts`), written style guide (`references/misled/y2k-design-system/STYLE-GUIDE.md`), standalone HTML reference (`references/misled/y2k-design-system/y2k-misled-reference.html` — the "if it were 1999" canonical version), live React rewrite (TopToolbar + new Hero with vaporwave sunset + glitched headline + cyan perspective grid floor + sun-glow halo, Marquee with VT323 22px gold-glow ticker, Manifesto wrapped as `BRAND_IDENTITY.TXT` Win95 dialog, TeaseBlock as `DROP_INCOMING.EXE` with pink titlebar, Footer replaced by fixed-bottom StatusBar, floating UNDER CONSTRUCTION sticker). Press Start 2P + VT323 added via `next/font` as `--font-pixel` and `--font-vt`. Y2K skill output shipped at `136c661`.
- [x] **Task 6 shipped** — subscribe form UI shell as `JOIN_LIST.EXE` Win95 dialog at `95e90cd`. Cyan titlebar to vary from gold (manifesto) and pink (tease). Bevel-inset email field with VT323 placeholder. Press Start 2P "TRANSMIT" button with shadow-bevel ↔ shadow-bevel-pressed depression on hover/active. Honeypot kept off-screen (`left: -9999px`) rather than `display:none` so naive bots fill it; tripping it triggers fake-success silent drop. Four-state machine (idle/submitting/pending_confirm/error); pending_confirm replaces the form with a `ConfirmPanel` echoing the submitted email + blinking cursor.
- **Vercel build failed twice** — first on `pnpm-lock.yaml` drift inherited from main (study-buddy's `package.json` had four deps not in the lockfile because the rebase resolution kept main's `apps/study-buddy: {}` entry — the drift existed on main before I branched), second on `react/jsx-no-comment-textnodes` lint error from a literal `// ONE EMAIL TO CONFIRM` decorative text node in the form (ESLint reads it as an attempted JSX comment). Lockfile fixed via `pnpm install --lockfile-only` at `5e19a8b`; lint fixed by wrapping the text in `{'...'}` at `5db3d89`.
- **Pre-push hook installed** at `.githooks/pre-push` to fail fast on lint + typecheck before pushing. Wired via root `prepare` script that runs `git config core.hooksPath .githooks` on `pnpm install` — no husky, no extra deps. Bypass with `--no-verify` for emergencies. Turbo cache makes lint near-zero on re-runs (4.7s first run, 52ms cached).
- **Cherry-picked the lockfile + hook commits to `main`** so the drift fix and the hook propagate to all future branches without re-discovery (`f14f79f`, `b441937`, `58d2095` on main). README updated with current app inventory + hook section + bypass guidance.
- **Vercel preview live** at `https://misled.vercel.app/` — the Y2K rave/tech aesthetic deployed end-to-end. Branch `feature/misled-ethos-page` at `c69a238`.
- **Phase 5 backend shipped** (2026-04-21, two-task-force dispatch session): Supabase `subscribers` table migration (`001_subscribers.sql`), Resend double-opt-in flow (API routes for subscribe + confirm page, inline Y2K HTML email template), Vercel Cron at 03:00 UTC for 7-day unconfirmed cleanup, form submit rewired from fake `setTimeout` to real `fetch('/api/subscribe')` with honeypot preserved. Three commits on `feature/misled-ethos-page`: `3f173ef` migration + env scaffolding, `e81898f` Resend flow, `02b7bc2` cron. React Email dropped in favour of inline HTML to save two deps. Lint + typecheck green.
- **Smoke-test surfaced a deploy mismatch** (2026-04-21): `https://misled.vercel.app/` production deploys from `main`, not from `feature/misled-ethos-page`. The live URL still serves the pre-Task-1 `coming soon` placeholder. The Y2K work is on the feature branch only and loads on its own Vercel-generated per-branch preview URL. The "don't merge to main" rule remains intact; the fix is a Vercel dashboard branch flip, which Prince decides. Task 7's client message was drafted with a `{{PREVIEW_URL}}` placeholder rather than a hardcoded URL until this resolves.
- [x] Session-close analysis requested (2026-04-21): run token-usage, memory-leakage, scope-refinement, and sub-agent delegation rating; append to `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`; close session. Analysis appended; PROGRESS.md updated; session closed.

### What's changing?

- The BorAI monorepo gets its first WebGL app. Whatever r3f pattern lands here (dynamic import with `ssr: false`, poster fallback, performance monitor, reduced-motion gate) becomes the house pattern for any future 3D work across the monorepo.
- The stack diverges further from the `yurika-web-template` skill defaults. Scene 02 dropped shadcn + Zustand + React Query for editorial reasons. Scene 04 formalises that: brand-forward client work does not reach for shadcn. Memory updated.
- **Deploy pattern standardised.** TWF's dashboard-Git-integration approach (no CLI, no local `.vercel/project.json` per app, rootDir set per project) is now the explicit house default — the CLI path is only a fallback for emergencies. Any subsequent BorAI sibling inherits this without re-discovering it. Saves every future app ~30 min of the same dead-end I just walked.
- **BorAI now has a load-bearing pre-push hook.** `pnpm lint` + `pnpm --filter "./apps/*" typecheck` run before every push; bypass via `--no-verify`. Cherry-picked to main so all sibling branches inherit it. The Vercel-build-failure class of error (lint, type, frozen-lockfile drift) gets caught locally before it burns a remote build cycle. Every future BorAI sibling app gets this for free on its first push.
- **The `/y2k-design-agent` skill is the path for any future brand-forward client work needing a strong period aesthetic.** The four-part deliverable shape (tokens → style guide → standalone HTML reference → live React rewrite) is the right shape: tokens are the production primitive, the guide is the director's brief any future designer can read, the standalone HTML is the canonical "if it were 1999" version that doesn't decay with framework upgrades, and the React rewrite is what actually ships. When a future client wants 80s, brutalist, swiss-modern, etc., we look for a skill of equivalent depth — and if one doesn't exist, that's a flag to either build it or do the work without skill scaffolding.

---

## Conclude

### How is now different from the start?

We started with a PDF brief and a hollow shell. The site was a `coming soon` placeholder with no pulse. Now: it is a functional engine. Supabase is live. The Resend double-opt-in flow handles confirmations through a custom API route and an inline Y2K-styled email template. The scanlines, the typography, the Win95 chrome are all in sync with a backend that will actually accept and remember a user. `https://misled.vercel.app/` serves the ethos page publicly, and the client has a URL that reads like a final product, not a mock.

### What are the consequences?

The client has a preview URL that feels like a final product. The infrastructure is self-cleaning: a Vercel Cron job purges unconfirmed subscriber rows every seven days. A pre-push hook guards against the trivial lint errors that previously burned build cycles. The production-branch retarget landed as a dashboard flip, not a git merge, and a deployment promotion closed the loop — no feature-branch-to-main merge needed to ship Task 7. The rule stays intact: `feature/misled-ethos-page` remains the live source; `main` is configuration only. Stage 2 of the three-stage launch (ethos → tease → pre-order) has a foundation to build on.

### What did we learn?

Defaults are dangerous. The Vercel production branch did not align with momentum: it had to be named and chosen. A pretty interface is no shield for sloppy devops: documentation and hooks are the only things that stop play from turning into mess. The load-bearing lesson is simpler still: smoke-test the URL you plan to send, not the URL you assume to be serving. A twenty-second curl earlier in the session would have caught the deploy mismatch before the backend work began. The handoff's `preview_url: https://misled.vercel.app/` had been true once; state drifts, and a plan is only as good as its most recently-verified assumption.

### Progress to thesis

Build should feel like play. Play should write the story. The play was the typographic and aesthetic stack: Anton, Press Start 2P, VT323, the vaporwave horizon lifted from Maxime Heckel, scanlines layered on CRT. The story is the resulting system: an opinionated surface that now persists real users, sends real emails, and cleans up after itself. The aesthetic shaped the architecture. The backend exists only to support the world the frontend invented.

### Progress to goal

Chapter 1's goal is *from insight to manual proof on real client work*. Scene 04 was always the one that had to carry the proof: the client work, shipped, end-to-end. That is what this session delivered. Not theory, not internal infra: a live site for a paying client, with a working subscriber flow and a distinctive voice. The preview URL is the evidence. Mobile check passed on a real phone. The remaining work (register the domain on client sign-off, send the message, publish the artifact) is downstream of the proof, not part of it.

### Next scene

**[[06-chapter-1-close-weekly-synthesis]]** — Chapter 1's final scene. Weekly synthesis, stepping back from individual client work to notice what the method produced in the round. Scene 05 (two side-projects) already concluded earlier this session. The branch for Misled can merge into the main narrative on Prince's decision; it does not require its own scene.

### Artifact format

**Thread + essay.** The thread compresses the five-beat arc of the session and lands on the deploy-mismatch lesson — a clean, shareable lesson that travels alone. The essay takes the longer arc: why 'build should feel like play' showed up literally in this scene, why the Y2K choice was load-bearing rather than decorative, and why the most honest lesson (smoke-test the URL you intend to send) is not advice anyone wants to learn the hard way.
*Thread / newsletter / video / essay / none.*

---

## Notes
