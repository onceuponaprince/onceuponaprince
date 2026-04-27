# BorAI Spore — high-value feature list

**Date:** 2026-04-27
**Status:** Living document (research in progress)
**Source spec:** [`specs/2026-04-27-borai-spore-design.md`](specs/2026-04-27-borai-spore-design.md)
**Source plan:** [`plans/2026-04-27-borai-monorepo-migration.md`](plans/2026-04-27-borai-monorepo-migration.md)

This file aggregates feature ideas and signals to fold into BorAI Spore (v0.1 → v1.0). It seeds with Prince's direct design notes, then merges findings from three external research delegates (Perplexity, Grok, ChatGPT) on (a) feature ideas from famous AI agent toolkits and (b) token-conservation repos and strategies.

---

## Prince's seed insights (2026-04-27, in-conversation)

### S1 — Single-prompt-file dispatch for multi-agent calls

**Pattern:** When the agent dispatches the same task to multiple delegates (Perplexity, Grok, ChatGPT, etc.), it writes ONE prompt as a `.md` file on disk and links every CLI call to that file. No copy-pasted prompt strings across N invocations.

**Why this matters:**
- Stops prompt drift across delegates — every model gets exactly the same instruction.
- The prompt becomes a git-trackable artifact, reviewable and reusable.
- Multi-agent dispatch becomes a Unix-style pipe: `cli --prompt-file=brief.md` is composable, replayable, and easy to diff.
- A failed delegate run can be replayed by re-pointing at the same file — no state loss.

**How to apply in Spore:**
- Promote this to a first-class primitive: a **`Brief`** object that `spore-orchestra` and `spore-client` both understand.
- Add `--prompt-file <path>` to all delegate CLI shims (`ask-perplexity-cli`, `ask-grok-cli`, `ask-chatgpt`/`codex`) and to Spore's own headless mode (`borai-spore -p`).
- Spore's TUI gains a `/dispatch <brief.md> --to perplexity,grok,chatgpt` command that fans out and gathers responses.
- Telemetry records the brief file's content hash → cross-delegate response comparison becomes a one-liner.

**Staging:** v0.1 (the file-based brief is mechanical); v0.2 promotes Brief to a typed Rust struct in `spore-orchestra`.

---

### S2 — Walkie-Talkie extension: child CLIs can use Claude Code skills

**Pattern:** Today the "walkie-talkie" pattern (e.g. `ask-grok-cli`'s `read_file` JSON request → Claude fetches → Grok continues) is one-way: the child can request files. Extend it so any child CLI process spawned by Spore can also invoke Claude Code skills (`Skill` tool calls) on the parent's behalf.

**Why this matters:**
- Skills today are siloed in the parent Claude Code conversation. A delegated CLI (Grok, Perplexity, even Spore-as-server) can't tap `ask-perplexity` or `delegate-agent` or `superpowers:*`.
- Granting children skill access turns Spore into a true orchestrator: a Grok session can request "use the `claude-api` skill on this code" and get expert output, not just file content.
- This is the missing primitive for cross-delegate reasoning chains (Grok plans → asks for `superpowers:writing-plans` skill output → ChatGPT implements).

**How to apply in Spore:**
- Extend the walkie-talkie JSON protocol with a new request type: `{ "type": "invoke_skill", "skill": "<name>", "args": "<...>" }`.
- Parent Spore process (the orchestrator) intercepts the request, runs the skill, returns the skill body/output as the response.
- Permission gating: `spore-config` adds a `child_skill_access` allowlist per delegate (deny-by-default; opt-in per skill).
- Implemented in `spore-tools` (new `WalkieTalkie` tool variant) + `spore-skills` (the resolver already has the registry).

**Staging:** v0.2 (needs the trait surface to settle first); v0.3 expands to capability-gated skill invocation matching the `capabilities:` frontmatter from §7.3 of the spec.

---

### S3 — First-class Ollama controls (model lifecycle, run-through-agent)

**Pattern:** Ollama has rich CLI surface beyond chat: `ollama pull`, `ollama list`, `ollama run`, `ollama show`, `ollama ps`, `ollama rm`, model parameter overrides (`/set parameter num_ctx 8192`, etc.), Modelfile authoring. Spore's manager mode currently treats Ollama as a single endpoint; expose its full lifecycle.

**Why this matters:**
- The user owns local model selection and lifecycle. The boss/tool framing in the spec (§1.1.5, "Local Ollama is the boss") is hollow if you can't pull/swap models from inside Spore.
- Switching managers mid-session (e.g. drop from `qwen3.6:35b` to `qwen3.6:7b` to save VRAM) is a normal workflow and should be a single slash command, not a restart.
- Running an Ollama model "through an agent" (Spore's full agent loop wrapping a local model end-to-end, with Spore's tools/skills/permissions) is the natural extension of manager mode and is the v0.3 routing-algorithm playground.

**How to apply in Spore:**
- New slash commands in TUI (v0.1):
  - `/ollama list` → `ollama list` passthrough, formatted as a table
  - `/ollama pull <model>` → progress-streamed pull
  - `/ollama swap <model>` → swap manager model mid-session (rebuild `OllamaManagerPlanner`)
  - `/ollama show <model>` → show Modelfile + parameters
  - `/ollama ps` → currently-loaded models + VRAM usage
  - `/ollama rm <model>` → free disk
  - `/ollama param <key> <value>` → session-scoped override (`num_ctx`, `temperature`, etc.)
- New mode flag (v0.3): `borai-spore --through ollama:<model>` runs a local model THROUGH the full Spore agent loop (tools, skills, permissions, telemetry) — turns any local model into a Claude-Code-shaped agent.
- `spore-providers/src/ollama.rs` grows an `OllamaAdmin` struct alongside `OllamaClient` for the lifecycle calls.

**Staging:** v0.1 (slash commands are thin wrappers around `ollama` CLI); v0.3 (`--through` mode + parameter introspection).

---

## Research-derived features and signals

### A. From famous AI agent toolkits

*(Pending — to be filled by Perplexity + Grok + ChatGPT delegated research)*

### B. Token conservation repos and strategies

*(Pending — to be filled by Perplexity + Grok + ChatGPT delegated research)*

---

## Synthesis (final priority list)

*(Pending — populated after sections A and B converge.)*
