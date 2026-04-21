# Session handoff — 2026-04-21 close

Read BEFORE the standard session-open ritual or immediately after. This is the queue of cross-scene work that the ritual (which lands on the active in-progress scene) will not surface on its own.

## TL;DR

Scene 05 concluded 2026-04-21. Chapter 1 in-progress. Scene 04 (Misled) is the next scene to progress. Three queued items from Scene 05 should happen in-flight alongside Scene 04.

## Queued from Scene 05

### 1. Thread artifact draft

- **Goal:** compressed, punchy, build-in-public thread for Twitter/X. Five-beat cadence (matches Scenes 02 and 03).
- **Source:** Conclude block of `[[05-two-side-projects-additional-workflow-infra]]`. NOT the catalogue source files directly.
- **Hook:** open with the orchestration-shape inversion (plan → execute → review flipped to review → synthesise → narrate mid-scene). Land on the decision framework as a shareable artefact in its own right.
- **Save to:** `/artifacts/01-origin/05-two-side-projects-additional-workflow-infra-thread.md` (confirm slug against prior scene artifacts; Scene 03's artifact was `03-when-the-clients-corrections-become-the-product`).
- **Delegate:** Gemini. Voice polish pass may be needed (Gemini defaults to mildly American register; enforce British English + de-corporatise in the prompt).

### 2. Essay artifact draft

- **Goal:** long-arc, reflective essay for Prince's blog.
- **Source:** Conclude block + `05-source-ai-swarm-infra-catalogue.md` + `05-source-study-buddy-catalogue.md` (both scene-adjacent in the scenes directory).
- **Hook:** runtime-import (vault as user data, not system data) as an architectural commitment more interesting than it appears. ai-swarm-infra's honest scaffold-state used as counterweight: not everything in `ops/` has to run yet.
- **Save to:** `/artifacts/01-origin/05-two-side-projects-additional-workflow-infra-essay.md`.
- **Delegate:** Gemini.

### 3. Vercel CI regression — talk-with-flavour on main

- **Issue:** `talk-with-flavour` Vercel deploy fails on `main` after Scene 05's study-buddy merge. `misled` was already failing pre-Scene-05 (Scene 04 WIP).
- **Likely cause:** `apps/study-buddy/package.json` declares `next`, `react`, `react-dom`, `typescript`, `@types/*` as dependencies but they are not installed (Chapter 1 constraint). `pnpm install` at workspace root fails; cascades into sibling deploys.
- **Production impact:** existing deployments stay live (Vercel does not auto-rollback on failure). New deploys break until fixed.
- **Fix options:**
    - (a) Install study-buddy's runtime deps. Crosses Chapter 1's "no webapp build" constraint. NOT recommended.
    - (b) Add `apps/study-buddy/vercel.json` with `ignoreCommand: "exit 0"` so Vercel skips this app's deploy until it is ready. RECOMMENDED. ~10 min.
    - (c) Move problematic deps into `devDependencies`. Weaker fix; may still fail.
    - (d) Add `apps/study-buddy` to the Vercel dashboard "Ignored Build Step" list. UI-only; no repo trace.

## State snapshot

### Vault

- Active campaign: `[[command-centre]]`
- Active chapter: `[[01-origin]]`
- Last concluded scene: `[[05-two-side-projects-additional-workflow-infra]]` (2026-04-21)
- In-progress scene: `[[04-misled-ethos-page]]`
- Chapter finale: Scene 06 (Chapter 1 close, weekly synthesis) after Scene 04 lands

### BorAI repo (separate repo: github.com/onceuponaprince/borai.cc)

- `main` at `35cc0a8` (post-Scene-05 merges)
- Feature branches `feature/ai-swarm-infra` and `feature/study-buddy`: merged via `gh pr merge --merge --delete-branch`
- Remaining local branch: `feature/misled-ethos-page` (pushed earlier this session)
- Merge commits preserving parallel-track graph on main: PR #1 (`ace243b`) and PR #2 (`35cc0a8`)

## Tooling state (for delegate-agent)

- **Cursor CLI (`agent`):** AUTHED. Available for multi-file edits.
- **Gemini CLI:** AUTHED. Available for synthesis and long-context work.
- **Grok (xAI API):** UNAVAILABLE — team credits exhausted at session start. Web search fallback worked. Check whether credits were topped up.
- **Copilot CLI:** available (not used this session).
- **gh (GitHub CLI):** snap-packaged; prefix `GIT_CONFIG_NOSYSTEM=1` before any gh command that internally calls git (hits `/etc/gitconfig` permission issue otherwise).

## Session close rituals performed

- Scene 05 Conclude block written, signed off, saved
- Frontmatter flipped: `status: concluded`, `date_concluded: 2026-04-21`, `artifact_format: thread, essay`
- Chapter 01-origin checklist updated (Scene 05 done; Scene 06 close slot added)
- Scene 05 Gemini catalogue outputs preserved as scene-adjacent source files (see `05-source-*.md`)
- Both BorAI PRs merged; branches deleted; main synced
- This handoff written and committed

## Session close rituals NOT performed (deliberate; queued above)

- Thread artifact draft
- Essay artifact draft
- Vercel CI regression fix
