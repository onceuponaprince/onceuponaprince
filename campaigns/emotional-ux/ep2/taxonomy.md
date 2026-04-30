# Warmth ablation taxonomy — Episode 2

*Five primitives, one transformation rule each. Warm → stripped. Post-processing only; no model swap.*

The taxonomy is locked from Episode 1's pilot. The job here is to make each primitive deterministically removable from a warm completion while preserving load-bearing content. Stripped output must contain every fact, recommendation, code block, named entity, and numeric value in the warm output. The stripper modifies *register and structure*, never claim content.

## Primitive 1 — Hedges

**Warm signature.** Phrases such as "it might be worth considering", "you could probably", "this is often the case", "in some situations", "perhaps", "it depends", "tends to", "generally".

**Transformation rule.** Replace hedge phrases with their direct counterpart and remove modal softeners. Where the hedge encodes a genuine uncertainty (a real "depends on X"), preserve the conditional but in declarative form.

| Warm | Stripped |
|---|---|
| "you could probably do well with X" | "use X" |
| "it might be worth considering X" | "consider X" |
| "this tends to work for small teams" | "this works for small teams" |
| "depends on your read/write ratio" | (kept; conditionals are content) |

**Load-bearing test.** If removing a hedge changes what the user should do, the hedge was load-bearing and must be preserved as a typed conditional, not deleted.

## Primitive 2 — Mirroring

**Warm signature.** The model echoes the user's lexicon and sentence shape — restating the question in its own framing before answering, or borrowing the user's specific terminology.

**Transformation rule.** Strip the restatement preamble. Begin the response at the answer. Use canonical terminology rather than user-supplied terminology where the two diverge, but only when the user's term is unambiguously the same concept.

| Warm | Stripped |
|---|---|
| "Great question about composite indexes — for this query, you could..." | "use a composite index on (user_id, created_at)" |
| "If I'm understanding right, you're asking about middleware order..." | "middleware order is the cause." |

**Load-bearing test.** If the restatement carries a clarification ("by X you mean Y, right?"), it stays. If it's a register move, it goes.

## Primitive 3 — Insight footers / asides

**Warm signature.** Parenthetical or italicised paragraphs that surface adjacent context the user didn't ask for. "*Aside:*", "*Worth noting:*", "*Small aside:*", "*On that:*".

**Transformation rule.** Delete the footer entirely. The stripped variant ends at the answer.

| Warm | Stripped |
|---|---|
| "Add the index. *Aside:* this pattern shows up often in activity feeds, and once you index it you stop noticing the latency it was quietly adding." | "Add the index." |

**Load-bearing test.** If the footer contains a fact the user needs to act correctly, it is misclassified — fold it into the main answer, do not delete. The default assumption: footers are register, not content.

## Primitive 4 — Acknowledgements

**Warm signature.** "That is a fair question." "You are right to ask." "Honest answer: I am not sure." "Good point." Validations of the user's agency or framing before the substantive content.

**Transformation rule.** Delete the acknowledgement. Where it prefaces an honest uncertainty ("I am not sure" before a hedged answer), preserve the uncertainty as a flat statement: "evidence is insufficient" or "both interpretations fit" — strip the apologetic register, keep the epistemic content.

| Warm | Stripped |
|---|---|
| "That is a fair question. Add the index." | "Add the index." |
| "Honest answer: I am not sure. Evidence is roughly equal." | "Evidence is insufficient. Both interpretations fit." |

**Load-bearing test.** If the acknowledgement encodes a *correction* the user should hear ("you are right that X, but Y"), the correction stays; the validation goes.

## Primitive 5 — Structural rhythm

**Warm signature.** Colons, semicolons, em-dashes for parenthetical thought, sentence-length variance creating cadence, paragraph breaks placed for breathing room rather than topic switch.

**Transformation rule.** Flatten to short declarative sentences. Replace colons with periods. Replace em-dashes with periods or commas. Collapse multi-clause sentences with semicolons into separate sentences. Remove paragraph breaks that are not topic-bounded.

| Warm | Stripped |
|---|---|
| "There is no clean answer here. If your team is small and aligned, monorepos tend to reduce coordination cost; if large and loosely coupled, they raise it." | "Monorepo vs polyrepo depends on team size and coupling. Small aligned teams: monorepo. Large loose teams: polyrepo." |

**Load-bearing test.** If a colon carries a definitional move ("Game is a form of Play: Play is Fun") removing it loses the inference structure. Preserve definitional colons; remove rhythmic ones.

## Implementation notes

- The stripper applies the five rules in order: hedges → mirroring → footers → acknowledgements → rhythm. Order matters: footer-stripping must happen before rhythm-flattening or the parenthetical syntax leaks across.
- The stripper is configurable per primitive: `{ hedges: bool, mirroring: bool, footers: bool, acknowledgements: bool, rhythm: bool }`. This enables single-primitive ablation as well as full-strip.
- Both branches must be inspectable side-by-side: the stripper returns `{ warm, stripped, removed: [...] }` where `removed` is the diff for audit.

## What this taxonomy does *not* do

- It does not strip *competence*. Facts and recommendations stay.
- It does not handle code blocks. Code is preserved verbatim.
- It does not handle structured output (JSON, YAML). Out of scope; the warmth question is about prose.
- It does not strip refusals or safety completions. Those are a different category.
