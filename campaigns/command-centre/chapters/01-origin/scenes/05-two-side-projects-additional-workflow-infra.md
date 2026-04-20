---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 05
title: "Two side-projects — additional workflow infra"
status: in-progress
date_opened: 2026-04-20
characters:
  - "[[prince]]"
artifact_format: none
tags:
  - side-project
  - infra
  - workflow
---

# Scene 05 — Two side-projects — additional workflow infra

*Chapter 1 — Origin · Campaign: [[command-centre]]*

One-line summary: capture and review two recently built side-projects that add workflow infrastructure, iterate decisions in tandem, and record any carry-over patterns for the BorAI monorepo.

---

## Set the Stage

### How did we get here?
Two small workflow-focused projects were built recently to help personal productivity and the BorAI developer experience: lightweight infra that automates parts of the day-to-day (repo scaffolding, CI helpers, local runners, deploy shortcuts). They live outside the chapter's client work but affect how future scenes ship and how the monorepo is managed.

### Where are we going?
Review both projects in parallel, run their workflows where possible, capture gaps and integration points, and decide what stays as a personal tool vs what should be absorbed into BorAI as shared infra.

### State of the world (project context)
- BorAI monorepo present at `~/code/BorAI/`.
- Chapter 1 constraints: discipline-first, manual proof; these side-projects are internal aids, not client deliverables.
- No CI-standard for sibling apps yet; infra projects aim to reduce friction and standardise common ops.

### State of the hero ([[prince]])
Tired but optimistic; built two tools to reduce friction. Wants reduced context-switching; needs clear decisions so the tools don't create more cognitive debt.

### State of the protagonist ([[prince]])
Has the local code and CLI entrypoints for both side-projects. Ready to run them, take notes, and decide which parts are mission-critical for BorAI.

### This moment in relation to goals
These side-projects could either accelerate Chapter 2 (webapp) by reducing operational friction or become tech debt. The scene tests whether they earn their place in the shared monorepo.

### Why now?
The tools were just built and are fresh — running them now catches issues early and prevents them from becoming conventions by accident.

---

## Progress the moment

### Goal for this session
- Run both side-project workflows end-to-end (smoke test).
- Capture any conflicting assumptions, pin decisions, and list tasks to integrate useful pieces into BorAI.
- Produce a short implementation plan: keep, adapt, or archive per project.

### Moment-by-moment capture
- [x] Scene opened and Set Stage recorded — Set Stage signed off; BorAI scaffolds committed (BorAI commit 05e1409). (2026-04-20)
- [x] study-buddy — an Obsidian vault used as the data/curriculum for a study platform (flashcards, quizzes) — scaffolded as `~/code/BorAI/apps/study-buddy`; Vault README copied into project. (2026-04-20)
- [x] ai-swarm-infra — local LLM distributed-system tooling for running models on an intranet — scaffolded as `~/code/BorAI/ops/ai-swarm-infra`; placeholder Python skeleton created. (2026-04-20)
- [ ] Note overlaps (shared scripts, config, env var conventions).
- [ ] Decide per-project outcome: keep / adapt into BorAI / archive.

### What's changing?
- Potential new defaults for CI, scaffolding, or local-run patterns.
- Decisions here will influence how future sibling apps are scaffolded and how onboarding works.

---

## Conclude

*Filled at end of session.*

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format
*Thread / newsletter / video / essay / none.*

---

## Notes
- Replace "Project A/Project B" placeholders with the projects' real names and repo paths when provided.
