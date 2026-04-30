# Emotional UX — Episode 2

*Ablation study. Pre-registered. Status: structurally null.*

**Date opened:** 2026-04-27
**Dispatch source:** `../ep2-dispatch.md`
**Episode type:** ablation-study (pilot follow-on)
**Final verdict:** null-by-non-execution. Hypothesis stands. Surface does not.
**Graduation:** not triggered. Per dispatch rule, M8 is gated on a non-null M7 verdict.

---

## Milestone log

### M1 — Lock the ablation taxonomy. **Done.**

The five primitives from the pilot are reused as-is. One transformation rule per primitive, warm → stripped, defined in `taxonomy.md` (this directory). Cold output is constrained to preserve the load-bearing content of the warm output: facts, recommendations, code, named entities. No model swap; the stripper is a deterministic post-processor over completed warm text.

### M2 — Choose the BorAI surface. **Blocked.**

**Reason:** BorAI does not currently expose a live LLM-mediated session surface that produces turn-by-turn text a user reads and can abandon mid-session. State of the inventory at 2026-04-27:

- `agents/spore/` is a Phase 0 placeholder. The CLI is unimplemented; the README points at a design spec scheduled for Plan 2 build.
- `apps/study-buddy/` is a stub `dev-server.js` returning the literal string `"study-buddy placeholder"`.
- `apps/misled/` and `apps/talk-with-flavour/` are Next.js landing pages with no chat surface.
- `inbox/events/` is empty (`.gitkeep` only).
- The `build-in-public-engine` skill produces drafts staged to BorAI inbox, but the surface is single-shot generation with founder-as-reviewer, not multi-turn user session. Withdrawal events, turn count, and task-completion signals are not defined for it.

A candidate slate was considered:

| Candidate | Verdict | Why |
|---|---|---|
| `agents/spore/` TUI session | Defer | No implementation yet; ablation needs a real surface |
| `apps/study-buddy/` study session | Defer | Placeholder; no LLM call exists |
| `build-in-public-engine` draft loop | Reject | Single-shot, not multi-turn; user is founder-as-reviewer not session-mid-flight |
| Vault staging events flow | Reject | Not LLM-mediated text the user reads turn-by-turn |
| External shadow on a third-party surface | Defer | Out of scope; the brief specifies BorAI |

**Escalation:** the dispatch's first open question (does BorAI surface session-completion / withdrawal signals natively, or does the instrumentation phase need new event types) resolves to: **neither, because the surface does not yet exist.** The instrumentation spec at `instrumentation-spec.md` is forward-staged for whichever surface unblocks first. No event types added to the schema until a surface lands; the schema's `metric_alert` covers what would be needed in a thin form, and three new optional fields are specced contingent on M2 unblocking.

### M3 — Build the warmth-stripper. **Done, surface-agnostic.**

Single-file JS module at `warmth-stripper.js`. Pure function: takes the warm completion string and a config flag set, returns the stripped string. No model dependency. Strips per the five rules in `taxonomy.md`. Reversible inspection: both branches (warm input, stripped output) preserved on the same object. Ready to bolt onto whatever surface lands in a future M2.

### M4 — Wire instrumentation. **Specced, not wired.**

`instrumentation-spec.md` defines:
- which existing BorAI staging-schema fields are reused for an ablation run
- which three optional fields would be added to the `metric_alert` event type when M2 unblocks (`variant`, `turn_count`, `withdrawal_reason`)
- which new event type would be added (`session_complete`) only if the chosen surface's session model genuinely cannot be expressed as a `metric_alert` per-session. Default: don't add it.

No schema mutation today. The schema is the contract; mutating it speculatively is worse than waiting.

### M5 — Pre-register the hypothesis. **Done. Locked before any data.**

See `pre-registration.md` in this directory. Predictions are directional, the null is named, and the file is committed before any A/B execution. If a future M6 run occurs, results are compared against this file unedited. Retro-fitting predictions is forbidden by dispatch and by structure: the file is the contract.

### M6 — Run the A/B. **Blocked on M2.**

No surface, no run. A self-experiment (n=1) was considered against the build-in-public-engine draft loop, but rejected: the surface is single-shot, not multi-turn, so session length and withdrawal cannot be measured. Forcing the experiment on a surface that doesn't fit the instrumentation would produce a number without the property the number is supposed to have.

### M7 — Synthesise the verdict. **Done. Structural null.**

The verdict is **null-by-non-execution**. Not a measured null (the warmth markers' deltas were small or zero). Not a load-bearing or decorative finding either. The honest call: the question is well-formed, the instruments are built, the predictions are locked, and the surface required to run the test does not yet exist on the host platform.

This is distinct from the three calls the dispatch named (load-bearing / decorative / null-as-measured). It is a fourth state — *deferred-by-substrate* — and the only honest reading of the present situation. Recovering it as "we proved warmth needs a real product to test on" would be marketing language. The structural shape is: pilot Episode 1 stood up a hypothesis; Episode 2 was dispatched into a substrate not yet ready for it.

### M8 — Graduate the thread. **Not triggered.**

Per dispatch rule: graduation is conditional on M7 being non-null. M7 is null. The thread stays in `research/emotional-ux-pilot/`. No `campaigns/emotional-ux/` directory created. No chapter-1 opened. The pilot remains the standalone Episode 1; this Episode 2 stands as the deferred sibling.

### M9 — Promote the warmth slider with measured data. **Blocked.**

There is no measured data to replace the projected curve with. The slider in `pilot.html` remains a thought experiment, properly labelled. Touching the HTML to fake a "measurement" would corrupt the pilot. Untouched.

---

## Artefacts produced

All three are deliverables per dispatch. Drafted *after* the M7 verdict landed (above), written in sober register about a structural null. None recover the situation as a positive finding.

- `artefacts/newsletter.md` — long-form, mechanism-by-mechanism, leading with the structural null.
- `artefacts/thread.md` — five-beat thread mapped to the Conclude block. One specific fact per beat. Hooks on the substrate, not on a measured effect.
- `artefacts/essay.md` — the literary read. Why the substrate gap is itself a finding. No marketing register.

---

## Open questions — escalation summary

The dispatch named three open questions for escalation. Status:

1. **Does BorAI currently surface session-completion / withdrawal signals natively?** Answered structurally: *neither natively nor cheaply, because the surface itself does not exist yet.* Schema additions held until M2 unblocks.
2. **Founder-only (n=1) or external cohort?** Moot until M2 unblocks. When it does: founder-only first, by default; external cohort only if there's a public-facing surface to shadow-mode against. Escalate when M2 closes.
3. **On graduation, what is the chapter-1 title?** Moot — graduation not triggered. The placeholder `01-warmth-as-mechanism` stands until a non-null M7 lands in a future episode.

---

## What changes for the next episode

Episode 2 stops here, formally null-by-non-execution. Episode 3 opens when at least one BorAI surface ships with multi-turn LLM-mediated text and instrumentable session events. The taxonomy, the stripper, the instrumentation spec, and the pre-registration file all carry forward. They were the work; they're done; they wait.
