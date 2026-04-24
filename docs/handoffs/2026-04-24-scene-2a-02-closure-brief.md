# 2026-04-24 — Scene 2a-02 closure brief

*Session target: close the two repo-level beats that scene 2a-02 left trailing, in one session at `~/code/`.*

---

## Context

- **Scene file:** `~/code/build-in-public/campaigns/command-centre/chapters/02a-systems-and-tools/scenes/02-reaching-past-claude.md`. Already `status: concluded`, `date_concluded: 2026-04-24`.
- **Scene artefacts:** `~/code/build-in-public/artifacts/02a-systems-and-tools/02-reaching-past-claude-{thread,essay,newsletter}.md`. Drafted and committed.
- **Scene's two child repos:**
  - `~/code/fast-travel-cli/` — Rust CLI that carries Gemini conversations into Claude via the CDP-scraped DOM.
  - `~/code/ghostroute/` — Node monorepo of side-LLM providers (Grok documented, Perplexity scaffolded, more pending).
- **Why this brief exists:** The scene's Conclude recorded the *breakthrough* work — the four-word Chrome-extension fix, the round-trip through the consent wall. The repo-level polish (the seven-commit build sequence on fast-travel-cli; the retroactive docs on ghostroute) was deferred to a fresh session. This is that session.

## Beat 1 — `fast-travel-cli` first-run + seven-commit build sequence

**cwd:** `~/code/fast-travel-cli/`

**Read first:**
1. `.claude/PROGRESS.md` in the repo — the session handoff from the scene 2a-02 breakthrough session.
2. `~/code/build-in-public/docs/superpowers/specs/2026-04-23-fast-travel-cli-design.md` — the design spec the CLI was rebuilt toward after deleting the Gemini-written scaffolding.

**State at start:**
- Rust CLI compiles. CDP-scraped DOM extraction works past the consent wall (the `cookie-master-key` Chrome extension was fixed in the scene to export `.google.com` cookies alongside `.gemini.google.com` ones).
- Scaffolding branch carries a round-trip working against at least one live Gemini URL.
- The "seven-commit build sequence" the handoff names is the intended atomic-commit shape for a clean first-run polish pass — cargo metadata, binary naming, error handling surface, stdout contract, any outstanding selectors, tests, README.

**What to do:**
1. Follow the PROGRESS.md's seven-commit sequence. Sequence matters — the atomic-commit pattern means each commit stands alone.
2. First-run against a live Gemini URL: confirm the CLI reads a real conversation, emits User/Model-alternating markdown on stdout, exits cleanly. Capture the command line you ran.
3. Any last fixes (selector drift, cookie path edge cases, error message polish) land as commits in the sequence, not as amendments to prior ones.
4. Push `main` when the sequence is complete.

**Acceptance:**
- Seven-commit atomic sequence on `main`.
- One clean first-run captured (command + truncated output or exit-status note).
- README covers install, first-run, cookie-export prerequisite, and the `cookie-master-key` dependency chain.

**Likely friction:**
- Cookie file freshness. The `cookie-master-key` extension must have exported cookies from an authenticated Gemini tab *after* the fix landed. If the cookie file is stale, re-export before running.
- Selector drift if Gemini shipped UI changes since the scene. If selectors break, capture the failure with `--visible` + diagnostics dump before patching.
- GDPR consent wall. If it reappears, cookie export was partial — re-run the extension on a fresh authenticated tab.

## Beat 2 — `ghostroute` retroactive docs

**cwd:** `~/code/ghostroute/`

**State at start:**
- Monorepo shape: providers under a top-level directory, one per side-LLM. Grok documented (main README covers the `POST /ask-grok` endpoint contract). Perplexity scaffolded, not documented. Others may exist in scaffolding state.
- Per PROGRESS.md: the architectural rationale landed in-scene but per-provider docs are incomplete.

**What to do:**
1. Read the repo structure first. Build a mental model of what providers exist and what state each is in — documented, scaffolded, skeleton, pending.
2. Repo-level README (if one exists, audit it; if not, draft it) should explain:
   - What ghostroute is (a context-hygiene layer / monorepo of provider adapters).
   - The provider contract — what input each adapter takes, what output shape it emits, what transport (HTTP, shell, stdio).
   - The add-a-provider walkthrough — dir shape, required files, test expectations.
3. Per-provider READMEs for any provider beyond Grok that merits one — at minimum, a stub naming the provider's state and the next beat that would make it runnable.
4. Align voice with scene 2a-02's essay (`artifacts/02a-systems-and-tools/02-reaching-past-claude-essay.md`) — British English, specific-over-abstract, no marketing register.
5. Commit per-document (README, per-provider doc, any code cleanups) as atomic commits. Push `main` when done.

**Acceptance:**
- Repo-level README reflects the monorepo-of-providers architecture, not just Grok's surface.
- Per-provider state is legible from the tree without running code.
- `main` pushed.

## Parallelism guidance

The two beats touch different repos and share no state. If your session supports subagents, dispatch them in parallel:
- One subagent: cwd `~/code/fast-travel-cli/`, execute Beat 1.
- One subagent: cwd `~/code/ghostroute/`, execute Beat 2.

The superpowers skill `dispatching-parallel-agents` is the right tool for this if available.

If sequencing instead: run Beat 1 first. Its first-run may need user interaction for fresh cookie export; Beat 2 is pure writing work that can fill gaps between Beat 1's commits.

## Closure in the vault

Once both beats land on their respective `main`s, do this in `~/code/build-in-public/`:

1. **Fill scene 2a-02's empty `artifact_file` frontmatter** — currently blank despite artefacts existing on disk. Should mirror scene 2a-03's shape:
   ```yaml
   artifact_file:
     - "artifacts/02a-systems-and-tools/02-reaching-past-claude-thread.md"
     - "artifacts/02a-systems-and-tools/02-reaching-past-claude-essay.md"
     - "artifacts/02a-systems-and-tools/02-reaching-past-claude-newsletter.md"
   ```

2. **Append a Notes line** to the scene file noting the repo-level closures:
   ```
   - Closed 2026-04-25 — fast-travel-cli seven-commit build sequence + first-run captured on main; ghostroute retroactive docs landed on main.
   ```
   (Adjust date if the session runs later.)

3. **One atomic commit** in the vault:
   ```
   git add campaigns/command-centre/chapters/02a-systems-and-tools/scenes/02-reaching-past-claude.md
   git commit -m "docs(scene-2a-02): fill artifact_file, close trailing repo beats"
   git push origin main
   ```

## Out of scope for this session

- Do not open scene 2a-04. The delegate-agent integration is its own scene.
- Do not touch the artefact drafts. They are shipped-once-external, not regenerated.
- Do not post externally. That is a separate flip — `status: concluded` → `status: shipped` happens when the thread / essay / newsletter actually go up on their destinations.
