# BorAI Inbox Staging Schema

This document defines the contract every skill must follow when writing events to the BorAI inbox. The schema is shared across `build-in-public-engine`, `validation-sprint`, `product-kill-signals`, `hackathon-radar`, `funding-tracker`, and `portfolio-curator`.

BorAI reads from this inbox to populate Yuri's dashboard. Any skill that breaks the schema breaks the dashboard.

## Location

All events are written to `$BORAI_INBOX_PATH`, which defaults to `${MONOREPO_ROOT}/ops/borai-inbox/`. The directory is tracked in the monorepo's git history so every event has version history and Yuri's approvals/rejections are diffable alongside the code changes they correspond to.

Rationale for this location (inside the monorepo, under `ops/`):
- Not `apps/` because inbox is state, not a deployable app.
- Not `packages/` because it's not imported code.
- `ops/` is the conventional third category for operational infrastructure.
- When BorAI the dashboard app is built, it can live at `apps/borai-web/` in the same monorepo and read the inbox via filesystem (no network roundtrip, no sync issues).

```
$BORAI_INBOX_PATH/
├── _schema.md          # this file's authoritative copy (keep synced)
├── _index.json         # running index of all events, updated on each write
├── events/             # active events
│   └── {timestamp}_{event_type}_{product_slug}.md
└── archive/            # events moved here after Yuri acts on them
```

## Event file naming

`{ISO8601 timestamp with dashes instead of colons}_{event_type}_{product_slug}.md`

Examples:
- `2026-04-17T14-30-00Z_content-draft_airdrop-works.md`
- `2026-04-18T09-00-00Z_funding-deadline_k-startup-grand-challenge.md`
- `2026-04-18T16-00-00Z_idea-killed_yet-another-chrome-ext.md`

Timestamps must be UTC. Product slugs must match the Yurika Forge project folder name exactly (no spaces, lowercase, dashes).

## Event file structure

Every event file is Markdown with YAML frontmatter. The frontmatter is required; the body is optional but typically present.

### Required frontmatter fields

```yaml
---
event_type: <enum>                  # see event types below
product: <slug>                     # Yurika Forge project slug, or "portfolio" for cross-project
timestamp: <ISO8601 UTC>
source_skill: <skill-name>          # which skill produced this
priority: <normal|needs-attention|urgent>
requires_approval: <true|false>
approval_status: <pending|approved|rejected|n/a>
---
```

### Optional frontmatter fields

```yaml
expires_at: <ISO8601 UTC>           # when this event goes stale
target_platforms: [twitter, medium] # content_draft only
language: <en|ko|en+ko>             # content_draft only
deadline: <ISO8601 UTC>             # funding_deadline, hackathon_opportunity
event_start_date: <ISO8601 UTC>     # hackathon_opportunity — optional, used by hackathon-radar for two-signal dedup when the event start differs from the application deadline
amount: <string>                    # funding_deadline — e.g., "₩100M" or "£50k"
region: <string>                    # funding_deadline — UK, Korea, Nigeria, Europe, etc.
metric_name: <string>               # metric_alert — e.g., "landing_conversion_rate"
metric_value: <string>              # metric_alert — e.g., "2.1%"
threshold_crossed: <string>         # metric_alert — e.g., "below 5%"
```

**Note on `event_start_date` vs `deadline`**: for most events these are the same date, and `deadline` alone is sufficient. They diverge when the application deadline precedes the event (common for ETHGlobal IRL hackathons: apply 3 weeks before the event dates). In those cases, `deadline` holds the application cutoff and `event_start_date` holds the actual event start. The `hackathon-radar` skill uses both fields together for dedup: a candidate event whose name matches an existing one but whose `event_start_date` is far off is treated as a distinct event, not a duplicate.

## Event types

Valid values for `event_type`:

| Event type | Written by | Purpose |
|---|---|---|
| `idea_validated` | validation-sprint | Validation sprint passed; idea enters Yurika Forge pipeline |
| `idea_killed` | validation-sprint | Validation sprint failed; idea goes to graveyard |
| `product_launched` | yurika-product-launch (hook) | A Yurika Forge product went live |
| `metric_alert` | product-kill-signals | A product's metric crossed a threshold |
| `content_draft` | build-in-public-engine | A build-in-public post needs Yuri's approval |
| `failure_post_placeholder` | build-in-public-engine | Prince needs to fill in a failure narrative |
| `funding_deadline` | funding-tracker | A grant deadline is approaching |
| `hackathon_opportunity` | hackathon-radar | A relevant hackathon is open |
| `portfolio_tier_change` | portfolio-curator | A product changed portfolio tier |

## Priority levels

- **normal** — default; shows up in Yuri's regular queue
- **needs-attention** — surfaces in a priority lane; time-sensitive but not urgent
- **urgent** — pins to the top of Yuri's dashboard; urgent deadline or live-production issue

## Approval flow

1. Skill writes event with `approval_status: pending`, `requires_approval: true`.
2. Yuri sees it in BorAI, acts on it (approve / reject / edit).
3. BorAI updates `approval_status` and moves the file to `archive/`.
4. If Prince has automation downstream (auto-post, auto-apply, etc.), it reads only `approved` events from archive.

Events with `requires_approval: false` (like `failure_post_placeholder`) bypass the approval flow — they're prompts or notifications, not content.

## The _index.json format

Every write updates `_index.json`. BorAI polls this file; it should not read directory listings.

```json
{
  "last_updated": "2026-04-17T14:30:00Z",
  "events": [
    {
      "filename": "2026-04-17T14-30-00Z_content-draft_airdrop-works.md",
      "event_type": "content_draft",
      "product": "airdrop-works",
      "timestamp": "2026-04-17T14:30:00Z",
      "source_skill": "build-in-public-engine",
      "priority": "normal",
      "requires_approval": true,
      "approval_status": "pending",
      "expires_at": "2026-04-19T14:30:00Z"
    }
  ]
}
```

Skills append to `events` array and update `last_updated`. Don't rewrite the whole file from scratch — read, append, write. Skills should not remove items from `events`; only BorAI does that when archiving.

## Example event files

### content_draft (build-in-public-engine)

```markdown
---
event_type: content_draft
product: airdrop-works
timestamp: 2026-04-17T14:30:00Z
source_skill: build-in-public-engine
priority: normal
requires_approval: true
approval_status: pending
expires_at: 2026-04-19T14:30:00Z
target_platforms: [twitter, medium, blog]
language: en
---

## Context

Monday metric post. 342 wallet connects in the first 24 hours of airdrop-works launch.

## Canonical draft

342 wallet connects in the first 24 hours. The number I was expecting was 80.

[...full draft here...]

## Twitter/X thread version

1/ 342 wallet connects in 24 hours. Expected: 80.

2/ [...]

## Medium version

[...full Medium version with subtitle and tags...]

## Blog version

[...]
```

### funding_deadline (funding-tracker, future)

```markdown
---
event_type: funding_deadline
product: portfolio
timestamp: 2026-04-17T09:00:00Z
source_skill: funding-tracker
priority: needs-attention
requires_approval: false
approval_status: n/a
deadline: 2026-03-24T16:00:00Z
amount: "₩100M"
region: Korea
---

## 예비창업패키지 (Pre-Startup Package) — closes March 24

Up to ₩100M for pre-entrepreneurs with innovative tech or business models.

**Eligibility**: no business registration at time of application.
**Application**: K-Startup portal.
**Next steps**: [...]
```

## Writing events from a skill — the protocol

1. Compute the filename: `{timestamp}_{event_type}_{product_slug}.md`.
2. Write the file to `$BORAI_INBOX_PATH/events/`.
3. Read `$BORAI_INBOX_PATH/_index.json`.
4. Append the new event's metadata to the `events` array.
5. Update `last_updated`.
6. Write `_index.json` back.
7. Report to Prince: "Staged {event_type} for {product} at {filename}. Approval status: {status}."
