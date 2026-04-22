---
title: "Command Centre v2 — Schema, Rituals, Backfill"
date: 2026-04-22
status: approved
scope: vault-upgrade
supersedes:
  - "`feedback_brainstorming_question_grouping.md` (memory entry — promoted to CLAUDE.md)"
  - "`.claude/commands/capture.md` (slash command — folded into CLAUDE.md workflows)"
  - "`.claude/commands/status.md` (slash command — folded into CLAUDE.md session-open ritual)"
---

# Command Centre v2 — Schema, Rituals, Backfill

## Context

Scene 2b-01 (`study-buddy → teenyweeny.studio` pivot) surfaced a consistent pattern: the vault's **capture log is doing the work of a richer schema**. Pre-artifact specs, external blockers, and superseded direction all lived as prose under *Moment-by-moment*. Two design specs sit side by side in `docs/superpowers/specs/` with no frontmatter link from the scene. A mid-scene handle pivot got captured as a nested bullet rather than a named beat.

This upgrade promotes what the captures are already carrying into structure — frontmatter keys, named rituals, codified patterns — and slims the tooling that had grown heavier than its payload (the `/capture` and `/status` sub-agent skills).

## Thesis alignment

*Build should feel like play. Play should write the story.* Every item in the pack is a promotion from prose (where the play happens) into structure (which makes the story legible) — never a new ceremony. The pack argues the thesis by making the narrative of a scene more recoverable without making the work of a scene heavier.

## Scope

Six items, shipped as one atomic commit.

### 1. Frontmatter additions (scene schema)

Three new keys added to the scene frontmatter contract documented in `CLAUDE.md`:

| Key | Type | Semantics |
|-----|------|-----------|
| `spec_file` | string or `null` | Path to the current (active) design spec that drove the scene. Mirrors `artifact_file`. Null when no spec precedes the scene's work. |
| `blockers` | string[] | External dependencies gating scene close. Prose descriptors, not IDs. Empty list when none. |
| `supersedes` | (string \| wikilink)[] or `null` | Older specs, scenes, patterns, or artifacts that this scene's work replaces. Null when none. |

Rationale for `spec_file` remaining singular: when multiple specs appear in a scene (the 2b-01 case), the older ones are *superseded*, not co-active. `supersedes` is the right slot for them.

### 2. Pivot protocol (CLAUDE.md)

New subsection under *The scene structure*. A mid-scene event qualifies as a pivot when it breaks register, handle, architecture, or audience — not when it only adjusts copy.

Pivots get a named heading inserted between *Progress the moment* and *Conclude*:

```
## Pivot — YYYY-MM-DD
- **Trigger:**
- **Old → New:**
- **Carries forward:**
- **Supersedes:**
```

Rule: if a pivot breaks the scene's *premise* (not just its surface), it demands a new scene rather than a beat within the existing one.

### 3. Codified patterns (CLAUDE.md *Named patterns* section, new)

Three patterns elevated to named rules:

- **Superseded-spec pattern.** When a spec is rewritten mid-scene, the old file stays in place under its original date-stamped name. The two files together *are* the decision.
- **Forward-only rename.** Renames of handles, products, or characters apply to new artifacts only. Concluded scenes retain their original references as historical record.
- **Single atomic scene commit.** One scene's work ships as one commit where possible. If splitting is necessary, split by beat, not by file.

### 4. Clarifying-loop pacing (CLAUDE.md)

Reconciles the global CLAUDE.md (*sequential different clarifying questions until go*) with the memory entry (*batch three at a time*). Rule:

> Default to six questions in two sub-batches of three per round. Continue rounds until *go / ready / continue / proceed / do it*. Simple factual lookups bypass the loop entirely.

Memory entry `feedback_brainstorming_question_grouping.md` becomes redundant and is removed in the same commit.

### 5. Slash command slim

Delete `.claude/commands/capture.md` and `.claude/commands/status.md`. Their one-line capabilities fold into existing CLAUDE.md workflows:

- `/capture` → *Capturing during work* already documents the rules; mildly expanded to absorb the *match existing entry shape* and *don't prompt for more* beats.
- `/status` → *Session open ritual* already covers reading campaign / chapter / in-progress scene. Duplicate sub-agent dispatch removed.

Other slash commands (`archetype-check`, `conclude`, `new-campaign`, `new-chapter`, `new-character`, `new-scene`, `publish`, `set-stage`) remain.

### 6. Backfill

Eight scene files and `templates/scene-template.md` get the three new frontmatter keys. Most scenes receive null / empty values. Two files under `campaigns/command-centre/chapters/01-origin/scenes/` (`05-source-ai-swarm-infra-catalogue.md` and `05-source-study-buddy-catalogue.md`) are source-catalogue documents filed alongside scenes for proximity — they have no scene structure or frontmatter and are skipped. Known non-trivial case:

- **Scene 2b-01** (`campaigns/command-centre/chapters/02b-products-that-sell/scenes/01-study-buddy-waitlist-landing.md`):
  - `spec_file: "docs/superpowers/specs/2026-04-22-teenyweeny-studio-landing-design.md"`
  - `blockers:` — domain registration, Supabase project creation, Resend sending-domain verification, Vercel project link, BorAI `apps/study-buddy/` landing route scaffold.
  - `supersedes: ["docs/superpowers/specs/2026-04-21-study-buddy-landing-design.md"]`

## Out of scope

- **Repeated skill-list dumps.** Upstream Claude Code issue, nothing addressable from inside the vault. Logged at `docs/upstream-issues.md` with today's date.
- **Conclude-as-assembly-not-authorship.** An observation, not a rule. When 2b-01 concludes, the Conclude block assembles from the captures rather than being re-authored. No rule needed.

## Commit strategy

Single atomic commit.

```
docs(command-centre): v2 — frontmatter, pivot protocol, rules, pacing, command slim, backfill

Six changes, one pack. Schema: add spec_file, blockers, supersedes to
scene frontmatter. Protocol: pivot heading with trigger / old→new /
carries / supersedes. Rules: superseded-spec, forward-only rename,
single atomic scene commit. Pacing: six questions in two sub-batches
of three per clarifying round. Slim: drop /capture and /status as
standalone skills; fold into CLAUDE.md workflows. Backfill: all ten
existing scenes + scene template.

Memory entry feedback_brainstorming_question_grouping.md removed;
rule now lives in project CLAUDE.md. Upstream issue (repeated
skill-list dumps) logged at docs/upstream-issues.md.
```

## Decisions resolved

- **Spec location:** `docs/superpowers/specs/` (consistent with existing product specs; vault-upgrade specs share the shelf).
- **Memory housekeeping:** same-pass (remove `feedback_brainstorming_question_grouping.md` in the v2 commit).
