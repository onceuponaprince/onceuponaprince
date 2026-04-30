---
type: campaign
campaign: emotional-ux
title: "Emotional UX"
status: in-progress
date_opened: 2026-04-21
graduated_from: "research/emotional-ux-pilot/"
date_graduated: 2026-04-30
thesis_one_liner: "Warmth markers in LLM outputs are load-bearing UX primitives, not stylistic decoration."
universe: "yurika, the-guild, agency"
tags:
  - campaign
  - research
  - llm-ux
  - lateral-graduated
---

# Campaign: Emotional UX

*A living research campaign. Started lateral at `research/emotional-ux-pilot/` on 2026-04-21 as a one-episode pilot. Graduated to its own campaign 2026-04-30 when Episode 2's dispatch committed — ahead of the verdict-gated trigger the dispatch originally proposed, on the founder's call.*

## Thesis (claim under test)

> **Warmth markers in LLM outputs — hedges, mirroring, insight footers, acknowledgements, structural rhythm — are load-bearing UX primitives, not stylistic decoration.**

If the claim holds, the implication is that current-generation LLM "warmth" is doing real work — reducing cognitive load, calibrating trust, sustaining session length — and stripping it degrades the surface. If it falls, warmth is texture without function and can be removed without cost. Null is the third honest call.

## Episodes

Each episode lives in `ep<N>/` (or — if this campaign reorganises later — under `episodes/`). Each opens a question; the test answers it; the synthesis stands as the episode's load-bearing record.

| # | Episode | Status | Verdict |
|---|---|---|---|
| 1 | [Pilot — warmth as mechanism](pilot.html) | Shipped 2026-04-21 | Premise made explicit. Five mechanisms named. Pilot earns a second episode. |
| 2 | [Ep2 — ablation on a real product surface](ep2/episode.md) | Dispatched 2026-04-27, in flight | TBD — load-bearing / decorative / null. |

## Pilot

`pilot.html` at the campaign root carries Episode 1's publishable artefact. Single self-contained HTML, hybrid essay + three interactives (warm/cold viewer, mechanism spotter, warmth slider). Episode 2's measured-data slider replaces the projected curve once Ep2's verdict commits.

## Decisions

`decisions/` (not yet present) will hold ADRs distilled from the research. None yet — Ep1 was a premise-builder, Ep2 is forming. The first ADR likely lands when Ep2's verdict commits.

## Sources

`research-notes.md` at the campaign root holds Episode 1's backing brief (Gemini, Phase 4.1 of the original two-task-force dispatch). Citations are approximations and should be verified before publication. Episode 2's source material lives in `ep2/`.

| Episode | Source | Date | Status |
|---|---|---|---|
| 1 | Gemini (research-notes.md) | 2026-04-21 | Captured |
| 2 | BorAI session telemetry (planned) | TBD | Pre-registered — see `ep2/pre-registration.md` |

## Method

This campaign uses the `living-research` skill (`~/.claude/skills/living-research/`) for episode dispatch and synthesis where the question demands cold multi-source rounds. Episode 1's pilot bypassed the full living-research scaffold (single-source brief plus playground HTML). Episode 2 follows the skill more closely: dispatched 2026-04-27 with taxonomy, instrumentation spec, pre-registration, and a warmth-stripper post-processing layer all staged before any A/B run.

This campaign is the second living-thread to graduate (after `agent-architecture/`). Unlike agent-architecture, which graduated *after* its second episode synthesised, this thread graduated *at dispatch*. The decision is documented; the verdict is still pending.

## Voice and posture

British English, sophisticated, declarative. No marketing speak. Verdicts are direct calls — load-bearing / decorative / null — no consensus-safe hedges. Pre-registration discipline applies: directional predictions land before data, no retro-fitting once results are in.

## Out of scope (campaign-wide)

- Model-architecture research (how LLMs produce warmth at the weights level)
- Persona design (system-prompt tone tuning as a product feature)
- Sycophancy as a *correctness* problem — this campaign treats sycophancy only as an adjacent failure mode of warmth, not as the central question

This campaign is about *whether warmth markers carry functional load on real product surfaces*, not about how warmth is generated or whether it produces ethically clean responses.
