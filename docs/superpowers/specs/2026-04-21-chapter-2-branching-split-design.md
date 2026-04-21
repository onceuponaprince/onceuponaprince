# Chapter 2 branching split — design

*Date: 2026-04-21 · Campaign: [[command-centre]] · Scope: campaign structure, not code.*

## Context

Chapter 1 — Origin concluded with five scenes (01–05), all sealed, all with artifacts drafted (external publication pending on 04 and 05). The chapter's designed climax — a weekly synthesis scene — is unshipped. Campaign.md originally scheduled Chapter 2 as *The ritual* — a single-arc Command Centre webapp MVP (Set Stage + Conclude only).

Two facts emerged at session open that reshape that plan:

1. **Scene 05 was mechanically incomplete.** It was framed as "two side-projects catalogued." In practice, `ai-swarm-infra` got polished (Python skeletons scaffolded but not runnable); `study-buddy` got catalogued + spec'd + handed a decision framework (no code shipped). Neither was built in the sense of *functionally executing* — one was scaffolded, one was documented. Unfinished work has to go somewhere.
2. **A new tool entered the codebase.** A Grok scraper CLI at `~/code/scraper/` — cookie-based reverse-API to `grok.com`. Purpose: unblock delegate-agent Grok routing that Scene 05 flagged as dead (xAI team credits exhausted). Command-centre / BorAI ops infrastructure.

Founder intent this session: *build as much as possible right now*. Specifically:
- Run ai-swarm-infra today across the home cluster (Ryzen Coder + MacBook Reviewer).
- Ship study-buddy as a landing page and a product to sell.
- Keep the weekly synthesis (Chapter 1 close) honest without blocking build work.

The shape that absorbs this is a **branching Chapter 2**. Two chapters, run in parallel, each with its own thesis beat. Maps onto the campaign's core metaphor — a player-driven game has branching narrative by construction.

## Design

### Chapter 2a — Systems and tools

**Arc:** *the infrastructure that makes the product possible.*

Command Centre is currently markdown + founder discipline. 2a installs the systems underneath. Three distinct tools are in scope:

1. **ai-swarm-infra** — Python skeletons become a running distributed swarm across the home cluster. Single Coder→Reviewer round-trip across the two-machine network is Scene 2a-01 (today's work).
2. **Grok scraper** — integrated into delegate-agent routing to replace the exhausted xAI credits. Unblocks the delegation pipeline Scene 05 flagged as dead.
3. **Command Centre webapp MVP** — the original Chapter 2 plan from campaign.md. Set Stage + Conclude only.

The webapp is the **climax** of 2a; ai-swarm + scraper are the scaffolding it rests on. Scenes run in dependency order where sensible (scraper and swarm before webapp) but can interleave as work actually happens.

**Thesis test:** does the build-in-public method produce internal infrastructure worth publishing about, with no external client? Chapter 1 leaned on client work for proof; 2a removes the client and tests whether the method still produces narrative.

### Chapter 2b — Products that sell

**Arc:** *from catalogue to commerce.*

Scene 05 produced a spec + architectural analysis + decision framework for study-buddy. Chapter 2b is execution — the catalogue meets the market. Scenes follow the commercial journey:

1. **Landing + waitlist** (Scene 2b-01) — promises the product before building it. Captures commercial intent.
2. **Parser + flashcard renderer** — the MVP the landing page promised.
3. **Pricing + commercial packaging** — catalogue's Option I (free, OSS only) vs Option II (free core + custom-branded players for curators).
4. **First sale attempt** — the thesis test.

**Thesis test:** does the method generate sellable product from internal tool-building?

### Parallelism and cross-references

2a and 2b run **concurrently**. Scenes from each may cross-reference the other (e.g. a 2b scene on landing page architecture may cite 2a's deploy patterns) but neither chapter blocks the other. Each scene still follows the standard scene structure — Set Stage, Progress, Conclude — and each produces its own artifact.

The branches are not required to close simultaneously. Chapter 3 opens after whichever branch closes first; the other branch continues to its own close on its own timeline. Each branch has its own close scene (analogous to Chapter 1's Scene 06 weekly synthesis).

### Chapter 1 close

**Scene 06 — Chapter 1 close — weekly synthesis** ships before 2a and 2b open. Lightweight scene (~30 minutes). Drafted mechanically from the five prior Conclude blocks. Tests whether the method can produce a chapter-close essay from stored Conclude state — itself a product-relevant experiment for the future webapp.

Without this scene, Chapter 1 loses its designed climax per campaign.md and violates the rule *every scene's Conclude gets published.*

### Directory structure

```
/campaigns/command-centre/chapters/
    01-origin/                       # existing — scene 06 added
    02a-systems-and-tools/           # new
        chapter.md
        scenes/
            01-ai-swarm-hello-world.md
    02b-products-that-sell/          # new
        chapter.md
        scenes/
            01-study-buddy-waitlist-landing.md
```

Scenes inside each chapter use local two-digit numbering (`01-...`, `02-...`). Artifact directories mirror the chapter slug (`artifacts/02a-systems-and-tools/`, `artifacts/02b-products-that-sell/`).

### Campaign.md update

The Chapters section of `campaigns/command-centre/campaign.md` is rewritten to reflect the branch:

- Chapter 1 — Origin (unchanged).
- **Chapter 2a — Systems and tools.** ai-swarm-infra, Grok scraper, Command Centre webapp MVP.
- **Chapter 2b — Products that sell.** study-buddy from catalogue to product-for-sale.
- Chapter 3 — reserved (originally *The watcher*; carries forward after 2a/2b close).
- Chapter 4 — reserved (originally *First followers*).
- Chapter 5 — reserved (originally *First player*).

## Out of scope for this design

- Specific scene sequencing inside 2a and 2b beyond the opening scene. Scenes are opened one at a time via the existing `set-stage` workflow.
- Merging 2a and 2b back into a single chapter. The branch is the design, not a temporary fork.
- Renaming or removing already-sealed Chapter 1 scenes.
- Changes to the scene structure (Set Stage + Progress + Conclude is unchanged).

## Build sequence after this design is approved

1. Open Scene 06 in Chapter 1 (thin weekly synthesis). Draft Conclude mechanically. Ship.
2. Create `02a-systems-and-tools/chapter.md`. Open Scene 2a-01 (`ai-swarm-hello-world`).
3. Create `02b-products-that-sell/chapter.md`. Open Scene 2b-01 (`study-buddy-waitlist-landing`).
4. Update `campaigns/command-centre/campaign.md` Chapters section to reflect the branch.
5. Commit the design doc and the structural changes.

## Open questions

None. Design approved 2026-04-21.
