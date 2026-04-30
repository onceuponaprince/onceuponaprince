# Emotional UX — Episode 2 dispatch

*Ephemeral. Generated 2026-04-27. Delete after agents consume.*

## Frame

Episode 1 (the pilot) staked a claim: warmth markers in LLM outputs — hedges, mirroring, insight footers, acknowledgements, structural rhythm — are load-bearing UX primitives, not stylistic decoration. Episode 2 tests the claim on a real product surface (BorAI) by ablating warmth and measuring whether session length, task completion, and withdrawal change. If warmth is load-bearing, stripped sessions degrade. If decorative, they don't. Null result is the honest third option.

If the verdict is non-null, the thread graduates from `research/emotional-ux-pilot/` to `campaigns/emotional-ux/`. If null, it stands down as a well-formed question that fell short.

## Host surface

BorAI. The specific BorAI surface is the first design choice — must produce LLM-mediated text a user reads turn-by-turn and can abandon mid-session, with session events already instrumented or cheaply instrumentable. Candidate surfaces: vault staging events, build-in-public engine drafts, scene-drafting flow.

## Milestones (high-level)

1. **Lock the ablation taxonomy.** Reuse the five primitives the pilot already named. Define one transformation rule per primitive (warm → stripped). Cold output must preserve load-bearing content. No model swap; post-processing only.
2. **Choose the BorAI surface.** One surface, not three. Criterion: instrumented session events exist or are cheap to add. Stage a candidate list, pick, justify.
3. **Build the warmth-stripper.** Post-processing layer between BorAI's LLM call and the user surface. Toggle warm / stripped at request level. Both branches must be inspectable side-by-side.
4. **Wire instrumentation.** Per-session: turn count, wall-clock duration, task-completion signal, withdrawal events, optional response sentiment. Reuse BorAI Inbox staging schema where it covers; add new event types only where it does not.
5. **Pre-register the hypothesis.** Directional predictions plus the null, written before any run. Pre-registration lands in the episode file ahead of data — no retro-fitting once results are in.
6. **Run the A/B.** Self-experiment first (founder, n=1 across multiple sessions). External cohort if available. Shadow-mode if a public-facing surface is in scope.
7. **Synthesise the verdict.** Three honest calls — load-bearing / decorative / null. Sober register, no marketing recovery if results disappoint.
8. **Graduate the thread.** If non-null: move to `campaigns/emotional-ux/`, open `campaign.md` and chapter `01-warmth-as-mechanism` (or equivalent). If null: archive in place, leave Ep1 as the standalone pilot.
9. **Promote the warmth slider.** Replace the pilot HTML's projected curve with measured data. Interactive ships into Ep2's pilot artefact.

## Artefacts

- **Newsletter** — long-form, mechanism-by-mechanism. The five primitives, the transformation per primitive, the measured deltas, the verdict. Lead with whichever mechanism produced the strongest effect (or the cleanest null).
- **Thread** — five-beat structure mapped to the Conclude block. Hook on the strongest measured effect or the strongest null. One specific number per beat. No hedging.
- **Essay** — the literary read. Why warmth might be load-bearing in human terms; why it might be a dark pattern; how the measured result lands between those two stories. Longer arc. No marketing register.

## Open questions for escalation

- Does BorAI currently surface session-completion / withdrawal signals natively, or does the instrumentation phase need new event types in the staging schema?
- Founder-only (n=1) or external cohort? The N decides self-experiment vs. study, which decides how strong the verdict can be.
- On graduation, what is the chapter-1 title? Candidate above is a placeholder.
