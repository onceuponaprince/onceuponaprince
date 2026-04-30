# Pre-registration — Episode 2 ablation hypotheses

**Locked: 2026-04-27. Predictions written before any A/B run. Retro-fitting forbidden by dispatch.**

This file is the contract. Whatever Episode 2 (or Episode 3, if substrate forces deferral) measures, the predictions below are what it is measured against. The file is not edited after the lock date except to flag a result against the prediction it was registered to test.

## Top-level claim

Warmth markers in LLM outputs are load-bearing UX primitives, not stylistic decoration. *Load-bearing* means: stripping a primitive degrades a measurable session metric in the predicted direction.

## Family of directional predictions

Each primitive has its own prediction. They are not all expected to land the same way. The pilot HTML's section "What would falsify it?" is the source for the four core predictions; this file extends them with primitive five (rhythm) and locks each as a directional hypothesis with a stated null.

### Prediction 1 — Hedges

**Directional:** Sessions with hedges stripped show *increased* over-reliance, measured as: lower rate of users questioning a model recommendation, higher rate of users acting on a recommendation without follow-up. (Note: this is the opposite-direction effect of what one would naively expect; hedges are not friction, they are calibration.)

**Null:** No measurable difference in over-reliance proxy between warm and hedge-stripped sessions.

**Falsifying outcome:** hedge-stripped sessions show *fewer* over-reliance signals than warm. Would suggest hedges create over-reliance via false-humility signal rather than reducing it via calibration.

### Prediction 2 — Acknowledgements

**Directional:** Sessions with acknowledgements stripped show *higher withdrawal rate*, particularly when the user's previous turn was misframed or the model needed to redirect. Acknowledgements absorb the friction of being-told-no.

**Null:** Withdrawal rate is unchanged.

**Falsifying outcome:** acknowledgement-stripped sessions show *lower* withdrawal. Would suggest acknowledgements are interpreted as evasion or condescension.

### Prediction 3 — Insight footers / asides

**Directional:** Sessions with footers stripped show *shorter session length and lower turn count*. Asides surface adjacent relevance the user had not yet thought to ask; remove them and the user reaches a stopping point faster.

**Null:** Session length and turn count unchanged.

**Falsifying outcome:** footer-stripped sessions show *longer* sessions. Would suggest footers were noise the user was working around.

### Prediction 4 — Mirroring

**Directional:** Sessions with mirroring stripped show *increased time-to-task-completion*, measured as turns-to-resolution on a fixed task. Mirroring lowers the cost of clarification by establishing shared lexicon early.

**Null:** Turns-to-resolution unchanged.

**Falsifying outcome:** mirror-stripped sessions resolve *faster*. Would suggest mirroring is a stalling pattern, not a clarification one.

### Prediction 5 — Structural rhythm

**Directional:** Sessions with rhythm flattened show *higher withdrawal rate*, particularly in sessions over 4 turns. Rhythm modulates cognitive load over the length of a multi-turn read.

**Null:** Withdrawal rate unchanged.

**Falsifying outcome:** rhythm-flattened sessions show *lower* withdrawal. Would suggest rhythm is decorative and short flat sentences are easier to read.

## Effect-size pre-registration

Effect-size threshold below which a directional finding is treated as null:

- Session length: <10% relative change (cross-arm) — null.
- Turn count: <0.5 turns mean delta — null.
- Withdrawal rate: <3 percentage points absolute delta — null.
- Time-to-task-completion: <15% relative change — null.

Any directional finding inside the null band is reported as null, not as a small-but-real effect. The point is to avoid spinning noise as signal.

## Sample-size note

These thresholds presume a self-experiment of n≥30 sessions per arm or external cohort of n≥100. With smaller n, every finding is exploratory and the pre-registration is consulted as a guide to interpretation, not a contract.

## Standing aside until M2 unblocks

This file is locked even though M2 is blocked. Pre-registration before substrate is the only way the contract holds: the predictions exist independent of when the run happens. When the run happens, the predictions are already here. The dispatch's rule against retro-fitting is honoured by this file existing now.
