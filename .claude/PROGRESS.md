# Session handoff — 2026-05-01 close · ai-swarm pivot landed · ep2 substrate plan locked · 26-task graph rebuilt

Read BEFORE the standard session-open ritual. This queue carries cross-scene work the ritual (which lands on the active in-progress scene) won't surface on its own.

## TL;DR

2026-05-01. Four commits today: emotional-ux graduation (`745d8d8`), agent-architecture ep2 addendum dispatch (`0c4eec9`), superpowers docs (`90ff8a8`), and the ai-swarm pivot beat (`e242616`). Vault HEAD: `e242616`, ahead of origin/main by 4 commits — push was not part of this session's scope.

Three pillars of today's pass:

1. **emotional-ux graduated.** `research/emotional-ux-pilot/` → `campaigns/emotional-ux/` per the per-thread-graduation rule. Episode 2 self-concluded with a *null-by-non-execution* verdict — hypothesis stands, surface does not. Pre-registration locked, taxonomy locked, three artefacts drafted under `ep2/artefacts/`. Campaign.md frame says "graduates ahead of verdict" — technically inaccurate (ep2 has a verdict, just null), founder accepts the inaccuracy rather than fold a fix-up commit.

2. **ai-swarm scene 02a-01 pivoted.** Native Ollama per OS → Docker container running Ollama on each machine. Same image, same `OLLAMA_HOST=0.0.0.0:11434`, same `ollama pull` commands inside the container. Three OS-specific bootstrap tutorials remain valid as native fallbacks but are no longer the canonical path. Scene stays `status: in-progress`; pivot beat committed at `e242616`.

3. **Episode 2 substrate plan locked.** Founder's call (5.3.c + 5a.i+ii + 5b.ii): build BOTH `agents/spore/` (TUI substrate) AND `apps/study-buddy/` (real-product substrate, not minimum-for-ep2) deliberately for ep2's pre-registered protocol. Warmth-stripper extracted as a shared dependency so both surfaces converge on identical transformation rules — agreement vs divergence between them only carries signal if the strip is held constant.

## Task graph (26 tasks, no cycles)

To resume: this graph is authoritative. `TaskList` returns the same shape. Cross-thread blockers correctly modelled — pick any task with no `blocked by` annotation to start.

### Completed (today)

- `#1` Commit 2 — agent-architecture ep2 addendum dispatch (`0c4eec9`)
- `#2` Add `session-analysis-*` gitignore pattern
- `#3` Commit 3 — superpowers docs (feature-list + ghostroute prior art) (`90ff8a8`)

### Docker pipeline → ship scene

```
#15 Ryzen docker (qwen2.5-coder:7b)  ──┐
#16 MBP docker (llama3.2:3b)         ──┼──> #17 Verify LAN ──> #18 Round-trip ──┬──> #13 PR ────┐
                                                                                 └──> #19 Update tutorials ──┴──> #14 Conclude scene ──> #4 Close-out rollup
```

- `#15` [pending] Docker + Ollama on Ryzen (Coder) — qwen2.5-coder:7b
- `#16` [pending] Docker + Ollama on MBP (Reviewer) — llama3.2:3b
- `#17` [pending] Verify LAN reachability — Coder + Reviewer from Orchestrator [blocked by #15, #16]
- `#18` [pending] First end-to-end round-trip — orchestrator dispatches to Coder and Reviewer [blocked by #17]
- `#19` [pending] Update bootstrap tutorials — docker-first canonical, native as fallback [blocked by #18]
- `#13` [pending] Open + merge PR — feature/ai-swarm-infra-impl → main [blocked by #18]
- `#14` [pending] Conclude scene 02a-01 — write five Conclude answers + artefact [blocked by #19, #13]
- `#4`  [pending] ai-swarm scene 02a-01 — close out scene (rollup) [blocked by #14]

### Substrate-build → ep2 resolution

Shared dependency `#20` (warmth-stripper) feeds both family's stripper-toggle steps so the transformation rules stay identical across surfaces.

```
                                           ┌──> #25 stripper toggle (also <- #20) ──> #26 ep2 run on spore ──┐
#21 spore spec ──> #22 core ──> #23 LLM ──> #24 instrument ──┘                                                 │
                                                                                                               ├──> #5 Resolve ep2
                                                                                                               │
#27 study-buddy spec ──┬──> #28 frontend ──┐                                                                  │
                       └──> #29 backend ───┴──> #30 instrument ──> #31 stripper toggle (also <- #20) ──> #32 ep2 run on study-buddy ──┘

#20 warmth-stripper (no blockers) ─────────────────────────────────────────────────────────────────────┘ (feeds #25 + #31)
```

- `#20` [pending] Build warmth-stripper module per taxonomy.md transformation rules
- `#21` [pending] Read/finalize spore TUI design spec — multi-turn LLM-mediated TUI
- `#22` [pending] Build spore TUI core — multi-turn loop, prompt/response history [blocked by #21]
- `#23` [pending] Wire LLM calls into spore — model dispatch + history threading [blocked by #22]
- `#24` [pending] Instrument session events in spore per ep2 instrumentation-spec.md [blocked by #23]
- `#25` [pending] Integrate warmth-stripper as variant toggle in spore [blocked by #24, #20]
- `#26` [pending] Run ep2 on spore — n≥30 sessions per arm, all five primitives [blocked by #25]
- `#27` [pending] Spec study-buddy as a real product — multi-turn study session surface
- `#28` [pending] Build study-buddy frontend — Next.js + Tailwind per BorAI stack [blocked by #27]
- `#29` [pending] Build study-buddy backend — LLM-mediated multi-turn session API [blocked by #27]
- `#30` [pending] Instrument session events in study-buddy per ep2 instrumentation-spec.md [blocked by #28, #29]
- `#31` [pending] Integrate warmth-stripper as variant toggle in study-buddy [blocked by #30, #20]
- `#32` [pending] Run ep2 on study-buddy — n≥30 sessions per arm, all five primitives [blocked by #31]
- `#5`  [pending] Resolve emotional-ux ep2 — both spore and study-buddy substrates run pre-reg [blocked by #26, #32]

### Downstream (no graph slot)

- `#6` [pending] Dispatch agent-architecture ep2 addendum artefacts (downstream)

### Unblocked next session — pick any of these

- `#6`  Dispatch agent-architecture ep2 addendum artefacts
- `#15` Docker + Ollama on Ryzen — needs hardware
- `#16` Docker + Ollama on MBP — needs hardware
- `#20` Build warmth-stripper — pure code, no surface dep
- `#21` Read/finalize spore TUI design spec — pure design
- `#27` Spec study-buddy as a real product — pure design

Highest-leverage unblocked task is `#21` (spore spec): unblocks the longest downstream chain (5 tasks), and `agents/spore/` may already have design notes worth reading before drafting fresh.

## Working tree state at close

```
 M campaigns/agent-architecture/sources/2026-04-27-grok.md
?? campaigns/agent-architecture/sources/2026-04-27-grok-failed-attempts.md
```

Drive-by: looks like a forward-only rename in progress — original grok source split into a "failed attempts" companion file with a fresh grok.md being rewritten. Unrelated to today's commits. Resume by inspecting both files to decide whether this is a clean split commit or whether the rewrite is mid-thought.

Vault HEAD `e242616` ahead of `origin/main` by 4 commits — push deferred.

## Recent commits (for context)

```
e242616 pivot(02a/01): containerise LLM runner across all three machines
90ff8a8 docs(superpowers): ghostroute prior-art + feature-list update
0c4eec9 docs(campaigns/agent-architecture): episode 02 addendum dispatch
745d8d8 docs(campaigns/emotional-ux): graduate from research/ — ep2 dispatched
d4c00e9 docs(progress): 2026-04-30 close — vault schema + commit discipline rationalised
0933aa4 conclude(02b/01): backfill artefact drafts and migrate frontmatter
```

## Cross-scene carries (from 2026-04-30, still open)

These are not in the task graph. They live here because they predate the rebuild and require human judgement to schedule.

### pilot.html — topology switcher (interactive #1 of 5)

Per the synthesis's commitment paragraph in `campaigns/agent-architecture/episodes/01-context-and-granularity.md` (graduated this session — path may have changed; verify). Self-contained single-file HTML, hybrid essay + interactive, matching `campaigns/emotional-ux/pilot.html`'s style tokens. Switcher should manipulate the four-axis policy (not just agent count) and surface a live SVG topology diagram.

### ghostroute uncommitted patches

```
~/code/ghostroute/ask-grok-cli/src/config/mod.rs       # RESPONSE_TIMEOUT_MS + RESPONSE_SELECTOR
~/code/ghostroute/ask-grok-cli/src/automation/response.rs  # whitespace-collapse comparison fix
```

Plus prior session's two uncommitted patches (`typing.rs` newline normalisation, `main.rs` context paste). Clean three-commit pass when next in ghostroute. Could fold into Scene 2a-02's *ghostroute retroactive docs* trailing beat.

### Strategic next — Vespa-style ranking

See `2026-04-30 PROGRESS` git history for full detail. Headline: BM25 + RRF as the next major scene; smart chunk-collapsing + query-aware `max_results` as riders.

### Scenes carrying

- **Scene 2a-02 closure** — brief at `docs/handoffs/2026-04-24-scene-2a-02-closure-brief.md`. Fast-travel-cli first-run + ghostroute retroactive docs. Either beat closes the scene independently; both required.
- **Scene 2b-01b** — teenyweeny URL ship. Still unopened. Chapter 2b *landing before build* rule blocks Scene 2b-02 until this lands.
- **Scene 04 client message + 04 artefact + misled.london registration** — open.
- **Scene 05 / 2a-03 artefact external posts** — `status: shipped` flips when each goes up.

## Active tooling state (carried)

- **Ollama (containerised in BorAI-graph stack):** running, `nomic-embed-text` cached, healthy. Note: this is *not yet* the home-cluster Ollama — that's what tasks #15/#16 set up.
- **Gemini CLI:** AUTHED. Quota-rate-limited under load.
- **Perplexity / ChatGPT / Copilot CLI / Cursor / Grok skills:** see 2026-04-30 PROGRESS for state — none touched today.
- **Anthropic API key:** NOT set. Graph runs rules-only by design.

## Landmines (repeat offenders, carried)

Trimmed list — full set in 2026-04-30 PROGRESS git history.

- **Docker cache masks source edits.** Default to `build --no-cache` when the change is in `ops/borai-graph/`.
- **BorAI pre-push hook** needs `node_modules` in worktree.
- **Skill-list dumps re-injected per session** as system reminders. Logged at `docs/upstream-issues.md`.
- **`/etc/gitconfig` permission denied** for `gh pr create` — prefix with `GIT_CONFIG_NOSYSTEM=1`.
- **Vault git status shows R + ?? for the same path** when a rename is staged and the original path gets a fresh untracked file. That's today's grok state — not a corruption.

## Session-open ritual for the next session

1. Read `CLAUDE.md` at vault root.
2. Read this file (`PROGRESS.md`) — task graph above is authoritative.
3. Read `campaigns/command-centre/campaign.md`.
4. Run `TaskList` to confirm graph state matches the snapshot here.
5. Greet with one line naming the chosen unblocked task (recommend `#21` spore spec unless hardware-day, in which case `#15` + `#16` in parallel).
6. If touching the graph: `cd ~/code/BorAI-graph && docker compose ps` for stack state.

## Out-of-scope but noted

- The grok rename in working tree — flagged not folded.
- Push of 4 unsynced commits to `origin/main` — deferred.
- The campaign.md "graduates ahead of verdict" line — founder accepts the inaccuracy.
