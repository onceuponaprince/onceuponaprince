# Instrumentation spec — Episode 2

*What would be wired to the BorAI staging schema if M2 (surface choice) unblocked. Today: specced, not wired.*

The dispatch instructed: "reuse BorAI Inbox staging schema where it covers; add new event types only where it does not." This file works that contract. Schema reference: `/home/onceuponaprince/code/build-in-public/references/borai-staging-schema.md`.

## What the schema already covers

The existing event type `metric_alert` (written by `product-kill-signals`) carries `metric_name`, `metric_value`, `threshold_crossed`. For an ablation A/B, every per-session result is structurally a metric crossing or not crossing a threshold. The schema covers it.

`metric_alert` reused fields:
- `metric_name` — values: `session_length_seconds`, `turn_count`, `task_completed`, `withdrawn`
- `metric_value` — the per-session number or boolean
- `threshold_crossed` — for an ablation, this carries the variant label rather than a true threshold name (acceptable; pre-registered)

## What needs adding (deferred until M2 unblocks)

Three optional frontmatter fields on `metric_alert` events are needed to disambiguate ablation runs from production metrics:

```yaml
ablation_variant: warm | stripped | hedges-stripped | mirroring-stripped | footers-stripped | acknowledgements-stripped | rhythm-stripped
ablation_session_id: <uuid>          # links turns within a session
ablation_run_id: <uuid>              # links sessions within a run
```

These are optional. Existing `metric_alert` consumers ignore them. The `product-kill-signals` skill's writes are unaffected. Backwards-compatible.

## What does *not* need adding

- No new event type. `session_complete` was considered and rejected: it would duplicate what a final per-session `metric_alert` carries.
- No new priority levels. Ablation events use `priority: normal` and `requires_approval: false` — they are data, not content.
- No new `event_type` enum value. Ablation runs hide inside `metric_alert` because that is exactly what they are: per-session metric crossings.

## Per-session event shape (when wired)

For each ablation session:

```yaml
---
event_type: metric_alert
product: <surface-slug>              # e.g. borai-spore, study-buddy
timestamp: <ISO8601 UTC>
source_skill: emotional-ux-ablation
priority: normal
requires_approval: false
approval_status: n/a
metric_name: session_length_seconds
metric_value: "247"
threshold_crossed: "n/a"             # ablation runs do not cross thresholds; this field carries variant
ablation_variant: warm
ablation_session_id: <uuid>
ablation_run_id: <uuid>
---

(body optional; if present, contains a redacted transcript fragment)
```

One file per metric per session. A 10-session A/B with 4 metrics produces 40 files. The `_index.json` aggregation handles the volume cleanly.

## Withdrawal as a signal

Withdrawal is the most contested signal. It is not natively defined for any current BorAI surface. When M2 unblocks, withdrawal must be operationalised before any run, and pre-registered. Candidate definitions:

1. *Hard withdrawal:* user closes the surface (CLI exit, tab close, explicit /quit).
2. *Soft withdrawal:* no further turn within N seconds of the model's response (N pre-registered per surface; default 60s for chat-style, 300s for read-style).
3. *Sentiment withdrawal:* user's next turn registers negative sentiment via a downstream classifier. Most expensive; deferred.

The pre-registration file commits to *hard withdrawal* as primary, *soft withdrawal* as secondary, *sentiment* as exploratory.

## Why nothing is wired today

There is no surface to wire to. Instrumentation specced ahead of need is forward-staging, not procrastination — the moment a surface lands, the wiring is a translation job, not a design job. The shape is locked.
