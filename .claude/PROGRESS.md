# Session handoff — 2026-05-02 reconciliation · ep2 substrate plan needs a structural call · task graph rebuilt

Read BEFORE the standard session-open ritual. This file replaces the 2026-05-01 task graph after a substrate-reality audit found three structural drift points.

## TL;DR

2026-05-02. Four commits today: `dd130d1` (warmth-stripper test fixture, mine), then `afe561a` + `3aacaca` + `a3d76ab` (chapter-02a restructure + two new in-progress scenes, from a parallel session that landed during this reconciliation). Vault pushed to `origin/main` mid-session — HEAD now ahead of remote by the parallel session's three commits + this PROGRESS update. Two prior 2026-05-02 commits also already synced (`82958b5` ep2 addendum trio refresh, `ade9ea2` web-framework primaries).

The session's load-bearing work was **reconciliation, not implementation.** The 2026-05-01 task graph carried three claims that no longer hold:

1. **`spore` is no longer Phase 0.** The 15-crate Rust workspace is scaffolded at v0.1a (scaffold + providers + skill loader). The 42KB design spec is locked at `~/code/borai/docs/superpowers/specs/2026-04-27-borai-spore-design.md`. PROGRESS task `#21` (spec) is done; `#22`–`#24` are mid-implementation, not greenfield.
2. **`study-buddy` is misframed as an ep2 substrate.** The scaffold under `~/code/borai/apps/study-buddy/` builds a vault-import → flashcards/quizzes pipeline (a Resource Curator), not a multi-turn LLM-mediated session. There is no chat surface in the product as currently designed. Tasks `#27`–`#32` plan against a product that doesn't exist in this shape.
3. **ep2's null verdict was hardware-caused, not substrate-deferred.** The "null-by-non-execution" framing in `ep2/episode.md` is post-hoc rationalisation — laptop crashes interrupted the run. The hypothesis was testable; the hardware did not cooperate. (Saved to memory: `project_emotional_ux_ep2_null_was_hardware.md`.)

The combination of (2) and (3) means **the two-substrate convergence test in PROGRESS task `#5` may not be the right plan.** It needs a founder call before further build-out.

## What's actually true (state as of 2026-05-02)

### emotional-ux campaign

- `campaigns/emotional-ux/` — graduated from `research/` on 2026-04-30. `research/` directory empty.
- `ep2/warmth-stripper.js` — built, surface-agnostic JS module. **Lives in the vault, not yet in a place either substrate can import.**
- `ep2/warmth-stripper.test.js` — committed today (`dd130d1`). 10 tests pin both register-only stripping (5 mechanical pairs) and load-bearing preservation (4 pairs sourced from vault material + 1 audit trail test). Run via `node --test campaigns/emotional-ux/ep2/warmth-stripper.test.js` from the vault root.
- `ep2/taxonomy.md`, `ep2/instrumentation-spec.md`, `ep2/pre-registration.md` — all locked. Pre-registration discipline holds: predictions land before data.
- `ep2/episode.md` — M7 verdict reads "null-by-non-execution / deferred-by-substrate." This framing is *post-hoc*; the actual cause was hardware interruption. The taxonomy + stripper + pre-registration are intact, but the episode file's reasoning doesn't reflect that.
- Three artefact drafts (`ep2/artefacts/{essay,newsletter,thread}.md`) — drafted under the post-hoc framing. Will need a re-read before any external publication, since the framing they argue for isn't the truth of what happened.

### agent-architecture campaign

- Episode 2 addendum dispatch landed `0c4eec9` (2026-05-01). Trio refreshed `82958b5` (2026-05-02). Three artefacts staged at `artifacts/agent-architecture/02-addendum-{essay,newsletter,thread}.md`.
- Web-framework primary sources added in `ade9ea2` (2026-05-02).
- `pilot.html` topology switcher (carried from 2026-04-30) — still pending.

### spore (`~/code/borai/agents/spore/`)

- 15-crate Rust workspace, v0.1a status.
- Phase 12 fills out the dispatcher per Cargo.toml comments. Spore-server, spore-client are explicitly Plan 2c. Spore-telemetry is Plan 2b.
- spore-tui has `lib.rs` + `mod app, mod input, mod render` skeleton. "Polish lands v0.2."
- spore-session has `lib.rs` + `mod store, mod memory, mod claude_md`. "v0.2 promotes session storage to SQLite."
- The TUI multi-turn loop is *partially scaffolded*, not running. Building a session a user can sit inside for 5+ turns is the gating work for any ep2 run on spore.

### study-buddy (`~/code/borai/apps/study-buddy/`)

- Scaffold for `VaultImporter.tsx` + `importer.ts` + `parse.ts` + `storage.ts`. README explicit: "scaffold, not runnable. Next.js shell deferred to a future scene."
- Product is **client-side pipeline** (JSZip → gray-matter → localforage → flashcards/quizzes). **No LLM session at the user-facing level.**
- Original design spec (`~/code/borai/docs/superpowers/specs/2026-04-21-study-buddy-landing-design.md`) is for a landing page. Catalogued under chapter 02b-products-that-sell, not as a research substrate.
- **Implication:** running the ep2 ablation here would require adding a chat-with-vault feature that isn't part of the product as currently scoped. Either the product changes, or study-buddy isn't the right second substrate.

## The substrate decision the founder needs to make

PROGRESS 2026-05-01 said *"build BOTH `agents/spore/` and `apps/study-buddy/` deliberately for ep2's pre-registered protocol. Warmth-stripper extracted as a shared dependency so both surfaces converge on identical transformation rules — agreement vs divergence between them only carries signal if the strip is held constant."*

That plan rests on study-buddy having a chat surface. It doesn't. Three coherent paths forward — pick one before further substrate work:

**Path A — Single-substrate: spore only.** Drop the two-substrate convergence test. Run ep2 on spore once `spore-tui` + `spore-providers` + `spore-session` carry a multi-turn loop. Loses the agreement/divergence signal between substrates; gains a faster path to a real verdict. Honest answer if hardware stability is the binding constraint.

**Path B — Reframe study-buddy.** Add a "chat with your vault" feature to study-buddy as a product feature, not just an ep2 substrate. Increases scope. Justified if the chat-with-vault feature is independently desirable. Decision is product-strategic, not research-driven.

**Path C — Pick a different second substrate.** `apps/talk-with-flavour/` and `apps/misled/` are landing pages, not session surfaces. The `build-in-public-engine` skill is single-shot. Neither natural fit. A new third-party surface (e.g. shadowing an open-source chat app) is out-of-scope per ep2-dispatch.

**Recommendation: Path A, defer the convergence question to Episode 3.** The hardware-crash context makes substrate redundancy attractive in principle, but the right time to add a second substrate is *after* the first run produces a verdict — not before. Pre-registration was for ep2 as it stands, not for a synthetic between-surface comparison.

The founder makes the call. This file is the brief.

## Reconciled task graph (rebuilt 2026-05-02)

### Done since 2026-05-01

- `#6` Dispatch agent-architecture ep2 addendum artefacts — refreshed `82958b5`. External publication status pending; artefacts staged at `artifacts/agent-architecture/02-addendum-*.md`.
- `#20` Build warmth-stripper module — exists at `campaigns/emotional-ux/ep2/warmth-stripper.js`, locked since 2026-04-30. **Note:** module lives in the vault. For spore (Rust) to use it, needs a port or shell-out. For study-buddy (TS) to use it, needs an ESM relocation.
- `#21` Read/finalize spore TUI design spec — spec exists at `~/code/borai/docs/superpowers/specs/2026-04-27-borai-spore-design.md` (42KB) + sub-spec on routing (58KB).
- New: warmth-stripper test fixture pinning conservative behaviour (`dd130d1`).

### Reframed (waiting on Path A/B/C decision)

- `#22` Spore TUI core — multi-turn loop, prompt/response history. Crate scaffold exists; loop implementation pending. *Independent of substrate decision — useful for spore even if ep2 runs elsewhere.*
- `#23` Wire LLM calls into spore — spore-providers crate exists; integration pending.
- `#24` Instrument session events in spore per `ep2/instrumentation-spec.md`. Spore-telemetry crate is Plan 2b.
- `#25` Integrate warmth-stripper as variant toggle in spore — needs Rust port or JS shell-out decision.
- `#26` Run ep2 on spore — gated on `#22`–`#25` and on Path-decision.

### Drop pending Path-decision

- `#27` Spec study-buddy as a real product (chat surface) — *only if Path B chosen*. Currently designed as Resource Curator without chat.
- `#28` Build study-buddy frontend — *only if Path B chosen*.
- `#29` Build study-buddy backend — *only if Path B chosen*.
- `#30` Instrument study-buddy session events — *only if Path B chosen*.
- `#31` Integrate stripper in study-buddy — *only if Path B chosen*.
- `#32` Run ep2 on study-buddy — *only if Path B chosen*.

### ai-swarm pipeline (carried, hardware-day)

```
#15 Ryzen docker  ──┐
#16 MBP docker    ──┼──> #17 LAN ──> #18 Round-trip ──┬──> #13 PR ────┐
                                                       └──> #19 Tutorials ──┴──> #14 Conclude → #4 Close-out
```

- `#15` [pending] Docker + Ollama on Ryzen (Coder) — qwen2.5-coder:7b
- `#16` [pending] Docker + Ollama on MBP (Reviewer) — llama3.2:3b
- `#17` [pending] Verify LAN reachability — Coder + Reviewer from Orchestrator [blocked by #15, #16]
- `#18` [pending] First end-to-end round-trip [blocked by #17]
- `#19` [pending] Update bootstrap tutorials — docker-first canonical [blocked by #18]
- `#13` [pending] Open + merge PR — feature/ai-swarm-infra-impl → main [blocked by #18]
- `#14` [pending] Conclude scene 02a-01 [blocked by #19, #13]
- `#4` [pending] ai-swarm scene 02a-01 close-out rollup [blocked by #14]

**Hardware-stability flag:** the same crashes that interrupted the ep2 run will likely interrupt these. Defer until hardware is stable.

### Chapter 02a restructure (2026-05-02 parallel-session work)

Three commits landed during this reconciliation session (`afe561a`, `3aacaca`, `a3d76ab`) that I did not make. Chapter 02a was restructured to insert two new scenes:

- `02a-04-borai-graph-ship-retroactive.md` — `status: in-progress`. Retroactive scene to house `artifacts/borai-graph-ship/` (research-paper, twitter-thread, retrospective) shipped 2026-04-23 outside the scene lifecycle.
- `02a-05-claude-code-edge-bridge.md` — `status: in-progress`. Hybrid scene picking up three open beats from the borai-graph-ship retrospective: custom Ollama image (rider), `borai-graph-query` CLI (rider), host-side bridge (central beat).

Previously-planned scenes shifted: scrapers→delegate-agent (04→06), two-layer orchestration pattern (05→07), Command Centre webapp MVP (06+→08+). `02a-02`'s "Unblocks Scene 04" pointer updated to "Scene 06"; `02a-06`'s "Scene 05 flagged as dead" disambiguated to "Chapter 1 Scene 05 flagged as dead".

**Two scenes are now simultaneously in-progress in chapter 02a** (alongside the pre-existing `02a-01-ai-swarm-hello-world`). Per CLAUDE.md scene workflow, "If there are zero or more than one [in-progress scenes], ask which" — next session-open should expect to disambiguate.

### Carried from 2026-04-30 (scenes / artefacts)

- `pilot.html` topology switcher (interactive #1 of 5) for `campaigns/agent-architecture/`. Self-contained single-file HTML matching `campaigns/emotional-ux/pilot.html` style tokens.
- Scene 2a-02 closure brief at `docs/handoffs/2026-04-24-scene-2a-02-closure-brief.md`.
- Scene 2b-01b — teenyweeny URL ship. Still unopened.
- Scene 04 client message + 04 artefact + misled.london registration.
- Scene 05 / 2a-03 artefact external posts — `status: shipped` flips when each goes up.

### Documentation drift

- `ep2/episode.md` carries the post-hoc "deferred-by-substrate" framing. The hardware-crash context isn't in the file. Either rewrite the M7 section or leave it and let the next episode supersede.
- `ep2/artefacts/*.md` (essay, newsletter, thread) argue the post-hoc framing as the load-bearing claim. Re-read before publishing.
- `campaigns/emotional-ux/campaign.md` — "graduates ahead of verdict" line still inaccurate; founder accepted in 2026-05-01.

## Best next steps (ordered)

**1. Make the Path A/B/C call on ep2 substrate.** Reading time: ~5 minutes (this file). Decision blocks roughly half the task graph below.

**2. Audit `ep2/artefacts/*.md` against the hardware-crash truth.** If publishing externally, the framing has to change. If not publishing (artefacts wait for Episode 3), leave them and note the deferral.

**3. If Path A: continue spore implementation.** Tasks `#22` (TUI loop), `#23` (LLM wiring), `#24` (instrumentation) are the load-bearing chain. None are greenfield — the scaffold + spec carry most of the design weight.

**4. Relocate warmth-stripper out of the vault.** The JS module belongs in `~/code/borai/` somewhere both surfaces (Rust + TS) can reach. Cleanest: a `packages/warmth-stripper/` workspace package. Or a Rust port as `crates/spore-warmth/` if Path A locks in spore-only.

**5. Defer hardware-day work (`#15`/`#16`).** Same instability that crashed ep2 will crash Docker pulls. Stable hardware first.

**6. Schedule a 2-week check-in agent** (via `/schedule`) to re-evaluate substrate state after the founder's call lands. Likely candidates by then: spore session loop running, warmth-stripper relocated, hardware stability resolved.

## Active tooling state (carried)

- **Ollama (containerised in BorAI-graph stack):** running, `nomic-embed-text` cached, healthy.
- **Gemini CLI:** AUTHED. Quota-rate-limited under load.
- **Perplexity / ChatGPT / Copilot CLI / Cursor / Grok skills:** see 2026-04-30 PROGRESS for state.
- **Anthropic API key:** NOT set. Graph runs rules-only by design.

## Landmines (carried, full list in 2026-04-30 PROGRESS git history)

- **Docker cache masks source edits.** Default to `build --no-cache` in `ops/borai-graph/`.
- **BorAI pre-push hook** needs `node_modules` in worktree.
- **Skill-list dumps re-injected per session** as system reminders. Logged at `docs/upstream-issues.md`.
- **`/etc/gitconfig` permission denied** for `gh pr create` — prefix with `GIT_CONFIG_NOSYSTEM=1`.
- **Vault git status shows R + ?? for the same path** when a rename is staged and the original path gets a fresh untracked file.
- **Hardware crashes interrupted the ep2 run.** Likely affects any multi-hour task. Bias toward short, resumable work units until resolved.

## Session-open ritual for the next session

1. Read `CLAUDE.md` at vault root.
2. Read this file (`PROGRESS.md`).
3. Read `campaigns/command-centre/campaign.md`.
4. **First decision: Path A / B / C on ep2 substrate.** Don't proceed past this without it.
5. Greet with one line naming the chosen path and the next concrete task.

## Out-of-scope but noted

- Push of working tree to `origin/main` — done this session, HEAD synchronised at `dd130d1`.
- The campaign.md "graduates ahead of verdict" line — founder accepted the inaccuracy 2026-05-01.
- The grok rename in working tree (carried from 2026-05-01) — still pending; clean tree as of this session's commit.
