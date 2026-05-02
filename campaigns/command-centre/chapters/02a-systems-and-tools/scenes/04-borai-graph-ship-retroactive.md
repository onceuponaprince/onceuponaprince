---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 04
title: "borai-graph-ship retroactive"
status: in-progress
date_opened: 2026-05-01
date_concluded: 
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: null
blockers: []
supersedes: null
artifacts:
  - format: essay
    file: "[[research-paper]]"
  - format: thread
    file: "[[twitter-thread]]"
tags:
  - chapter-2a
  - borai-graph
  - vault-hygiene
  - retroactive
---

# Scene 2a-04 — borai-graph-ship retroactive

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

*The borai-graph stack shipped on 2026-04-23 across PR #3 and PR #4 with three artefacts dropped into `artifacts/borai-graph-ship/` outside the scene lifecycle. This scene retroactively houses them — Set Stage today, Conclude same-day, the orphan filed.*

---

## Set the Stage

### How did we get here?

Two weeks ago, on 2026-04-23, the borai-graph stack shipped across two pull requests on `~/code/BorAI` (PR #3 — indexer + retrieval + dashboard; PR #4 — docker + starter kit), 50 commits to main, 103→107 tests passing. A 17-minute cold ingest produced a 3,760-node, 1.6M-edge graph over the vault, BorAI ops, and the user-level Claude Code skills. Three closing artefacts were drafted in the same session and committed straight to `artifacts/borai-graph-ship/` — a 2,500-word implementation-review research paper, a 14-post twitter thread, and a session retrospective with nine numbered improvements ranked by cost-to-value.

The scene that produced those artefacts was never opened. They went straight from session-output to artefact directory, bypassing Set Stage, capture, Conclude, and the `artifacts:` frontmatter that the schema requires every shipped artefact to be claimed by. Scene 03 (`near-proximal-and-the-stream`) consumed the retrospective as its `spec_file` two days later — but consuming a doc as a spec is not the same as producing it under a scene. The retrospective's authorship has no scene of record.

The orphan surfaced today during a session-status check that asked the question *what does `artifacts/borai-graph-ship/` belong to?* and found no answer.

### Where are we going?

A scene exists at `02a/04` that claims authorship of the borai-graph-ship artefacts. The `artifacts:` frontmatter lists `research-paper` (essay) and `twitter-thread` (thread). The retrospective is referenced in this Set Stage as the session's internal post-mortem doc — it does not enter the artefacts list because it is not one of the four shipped formats. The chapter checklist updates to insert this scene at slot 04 and renumbers the previously-planned scenes (Scrapers→delegate-agent and Two-layer orchestration pattern) to 06 and 07; webapp slips from 06+ to 08+. Scene concludes same-day, since the artefacts already exist and the scene's only work is the filing itself.

### State of the world (project context)

The vault sits at 142 indexed files / 3,916 nodes / 1.6M edges as of the last graph stats flush. PRs #3, #4, and #5 (the near/proximal split + four cheap riders from scene 03) are merged on `~/code/BorAI`. The borai-graph daemon is running locally and has been re-indexing this session's writes within seconds of save. The `artifacts/borai-graph-ship/` directory contains three files committed under `6b635de` (`docs(artifacts/borai-graph-ship): research paper, retrospective, twit...`) and has had no edits since.

Chapter 02a's checklist currently lists slots 04–06+ as Scrapers / Two-layer / webapp. The forward-only-rename pattern applies to the artefact filenames — they keep their original names (`research-paper.md`, `twitter-thread.md`, `retrospective.md`) rather than being renamed to the `NN-<scene-slug>-<format>.md` convention, since the files are already shipped and committed.

### State of the hero ([[solo-thesis-holder]])

The audience reading this vault as an operating manual. An orphaned artefact in an operating manual is the reader's first tripping point — *where did this come from? what was the session that produced it? what's the parent context?* The hero is reading a structure; orphans break the structure. Even if no external reader ever sees the vault, the founder *is* the eventual reader by way of the borai-graph index — and a query for borai-graph context will return artefacts disconnected from any scene narrative, which is precisely the failure mode the graph was built to prevent.

The universalisable beat for someone without these specific artefacts is the *act of retroactive vault hygiene* — the fact that systems built around lifecycles still produce orphans, and that the discipline of filing them is part of operating the system honestly. The scene lands for any reader who has shipped something outside their own intended workflow and felt the friction of having to reconcile after.

### State of the protagonist ([[prince]])

*TODO — founder to write.*

*Ask: 2-3 sentences on what this filing feels like today. Hygiene? Closure? Slight embarrassment that the orphan sat there for a week and a half? Audit-trail discipline ahead of someone reading the vault? The honest emotional register matters because this scene's whole premise is meta — it's about the act of filing, and the founder's relationship to that act is the scene's thesis.*

### This moment in relation to goals

A small scene with disproportionate audit value. Closing the orphan stops the precedent of orphan-creation; future ships go through the lifecycle by default because the alternative — having to come back and retroactively house them — is now visible as a discrete cost. The chapter checklist also tightens: slot 04 was vacant-but-planned for two weeks, and putting borai-graph-ship in it makes the chapter's actual narrative flow (three borai-graph scenes in a row before pivoting to scrapers) cohere with the chapter's actual history.

### Why now?

*TODO — founder to write.*

*Ask: the honest answer to why today, not yesterday and not next week. Was it the session-status check that surfaced it? Is there an external reader pending? Is this a vault-tidiness sweep before opening 2a-05? The Why-now answer determines whether this scene is hygiene, audit-prep, or something else — and the reader of the eventual artefact (if any) will feel the difference.*

---

## Progress the moment

### Goal for this session

- [ ] Scene 04 file written with full Set Stage (this commit).
- [ ] Founder fills *State of the protagonist* and *Why now?* TODO blocks.
- [ ] Chapter 02a checklist updated: insert 04 (this scene) + 05 (claude-code edge bridge), renumber Scrapers 04→06, Two-layer 05→07, webapp 06+→08+, update scene-02's "Unblocks Scene 04" pointer to "Unblocks Scene 06".
- [ ] Conclude block drafted same-day (the artefacts already exist; nothing else to ship).
- [ ] `status: concluded`, `date_concluded: 2026-05-01`, `artifacts:` frontmatter populated with research-paper (essay) + twitter-thread (thread).

### Moment-by-moment capture

- [x] Orphan surfaced during session-status check (2026-05-01).
- [x] Decision taken to file the orphan rather than leave it (2026-05-01) — see *Where are we going?* for the structural shape.
- [ ] Scene 04 + 05 set-stage commits land.
- [ ] Founder fills the two TODO blocks.
- [ ] Conclude commit lands.

### What's changing?

The chapter's actual narrative becomes legible. Before this scene, chapter 02a had three concluded scenes (01 in-progress, 02 + 03 concluded) and three planned slots (04 Scrapers, 05 Two-layer, 06+ webapp). The borai-graph work that scene 03 was actually downstream of had no visible parent in the chapter — the audit trail had a gap exactly where the highest-leverage infrastructure shipped. Filing the orphan turns the chapter's checklist into a true record of what the chapter has actually done.

The thesis beat: the lifecycle is not a ritual you can opt out of without paying for it later. The scenes you skip become the artefacts you have to come back and house. The scene that this scene supersedes (the un-opened ship-day session) was the cheaper version of this work, and it cost less precisely because it was never paid in the first place.

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
*Free space.*
