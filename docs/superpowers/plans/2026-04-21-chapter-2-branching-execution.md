# Chapter 2 branching execution — plan

*Date: 2026-04-21 · Spec: [2026-04-21-chapter-2-branching-split-design.md](../specs/2026-04-21-chapter-2-branching-split-design.md) · Campaign: [[command-centre]]*

Synthesised from `.claude/PROGRESS.md`, memory pointers, and the two-task-force + client-message handovers.

## This session — orchestrator drives

1. **Scene 06** (Chapter 1 close — weekly synthesis). Thin scene. Draft Conclude mechanically from the five prior Conclude blocks. Ship today.
2. **Scaffold Chapter 2a** — `chapters/02a-systems-and-tools/chapter.md` with arc + scene checklist.
3. **Scaffold Chapter 2b** — `chapters/02b-products-that-sell/chapter.md` with arc + scene checklist.
4. **Update campaign.md** — Chapters section reflects 2a/2b branch; Chapters 3–5 stay reserved.
5. **Open Scene 2a-01** — `ai-swarm-hello-world`. Set Stage drafted from the two-task-force handover. Today's work is the single Coder→Reviewer round-trip across the cluster (Ryzen + MBP + this machine).
6. **Open Scene 2b-01** — `study-buddy-waitlist-landing`. Set Stage drafted from Scene 05's study-buddy catalogue + decision framework. Landing page ships before the product build per founder framing.
7. Commit each structural change atomically.

## Prince's queue (external, blocks publication but not build)

Pulled forward from `docs/handoffs/2026-04-21-two-task-force-dispatch-close.md` and `docs/handoffs/2026-04-21-misled-client-message-draft.md`:

- **Mobile viewport check** at 375px on a real phone — Win95 chrome + sticker overlap tight at that width.
- **Misled client message send.** Draft at `docs/handoffs/2026-04-21-misled-client-message-draft.md`. URL already resolved. Voice pass + send.
- **External publish Scene 04 artifacts.** On post, flip `04-misled-ethos-page.md` `status: concluded → shipped`.
- **External publish Scene 05 artifacts.** Same flip for `05-two-side-projects-additional-workflow-infra.md`.
- **Swarm worker-node bootstraps.** Three tutorials at `BorAI/ops/ai-swarm-infra/bootstrap/`. Run Ryzen (Coder) + MBP (Reviewer) + Linux (Orchestrator). After that, `uv run python main.py "..."` closes the loop — this *is* Scene 2a-01's conclusion moment, so the bootstraps gate the scene's close, not its open.
- **Swarm PR to main.** `feature/ai-swarm-infra-impl` after first end-to-end run. Merge via `gh pr merge --merge --delete-branch` to preserve the parallel-track graph.
- **`misled.london` registration.** Deferred until client signs off on ethos page.
- **Emotional-UX pilot verification** — poke `research/emotional-ux-pilot/pilot.html`. If it lands, Episode 2 becomes new campaign `campaigns/emotional-ux/`.

## Future scenes (not this session)

- **2a-02** — Grok scraper integration into delegate-agent routing. Replaces the exhausted xAI credit path Scene 05 flagged as dead.
- **2a-03** — Two-layer orchestration-pattern scene (raw material in the two-task-force delegation-learning log).
- **2a-04+** — Command Centre webapp MVP. Set Stage + Conclude only. Chapter 2a's climax.
- **2b-02** — study-buddy parser + flashcard renderer. The MVP the landing promised.
- **2b-03** — pricing and commercial packaging. Catalogue's Option I (free OSS only) or Option II (free core + branded-players).
- **2b-04** — first sale attempt. Chapter 2b's climax.

## Cross-references worth naming

- Scene 06 should cite the two-task-force delegation-learning log as evidence the system "sort of works" — the premise of the branching split. Keep the citation short; the log lives in `docs/handoffs/`.
- 2a-01 and 2b-01 both inherit BorAI monorepo conventions (pre-push hook, dashboard-Git deploy). Reference Scene 02's deploy-pattern artifact and Scene 04's pre-push-hook capture.
- The orchestration-architecture scene (2a-03 candidate) compiles cleanly from the two-task-force handoff's session analysis + delegation learning log. Flag as ready-to-open when bandwidth fits.

## Constraints carried from memory

- Local preview before any Vercel deploy (hook at `~/.claude/hooks/vercel-preview-guard.sh` enforces).
- No shadcn/ui on brand-forward client work. Command Centre webapp's internal-tooling register may use it; study-buddy landing (brand-forward) does not.
- CSS keyframes for above-the-fold entry animations on both 2a and 2b landing/hero surfaces.
- Clarifying questions batched three at a time, not one at a time.
- Post-file-write: summary in prose, not re-rendered markdown previews.
