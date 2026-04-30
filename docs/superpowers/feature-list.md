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

### S4 — `ask-perplexity-cli`: thread-read mode (recover timed-out research)

**Pattern:** Today `ask-perplexity-cli` always *types* the prompt and *waits* for rendering. When Perplexity Deep Research takes longer than the 5/30-min wait window, the CLI errors out with `answer-not-rendered` even though the answer IS visible in the browser. Add a read-only mode that **navigates to a known thread and scrapes the rendered DOM** — no typing, no waiting on a fresh prompt.

**Why this matters:**
- Burnt research is lost research. A 12-minute deep dive that times out after 5 mins of wait wastes a paid query.
- Mirrors the `fast-travel-cli` pattern (Gemini-conversation reader): read an existing AI conversation; do not initiate a new one.
- Lets us replay any prior thread by slug, not just continue (`--thread`) — sometimes you want the *answer*, not a follow-up turn.

**How to apply:**
- New flag: `ask-perplexity-cli --read-thread <slug-or-url>`. Skips the type-prompt path; navigates to `https://www.perplexity.ai/search/<slug>` (or full URL); waits for `.answer` selector with a configurable `--wait-ms` (default 30s); parses + emits same JSON shape as a fresh query.
- Reuses existing `parse::parse()` and `types::PerplexityResult` — same output contract, only the input path differs.
- Implementation: extract `automation::scrape::scrape_once` into `scrape_fresh` and `scrape_existing`; main.rs branches on `args.read_thread.is_some()`.
- Estimated effort: S (~150 LOC, 1-2 hours, no new deps).

**Staging:** Ship as part of the next ask-perplexity-cli release; not Spore-blocking.

---

### S5 — `ask-perplexity-cli --search-threads`: stop creating new instances

**Pattern:** Right now every new query creates a fresh Perplexity thread. Continuing prior research means remembering the slug. Add the ability to **search Perplexity's library for matching past threads** — title + snippet match — and return their slugs so the user (or Spore) can continue with `--thread <slug>` instead of re-running the same prompt and burning a fresh paid call.

**Why this matters:**
- Avoids accidental duplicate research (re-asking a question you already explored last week).
- Avoids context-window thrashing: continuing a thread keeps Perplexity's internal context; a new thread starts cold and re-fetches sources.
- Matches Spore's "every cent measured" stance — repeated identical queries are a measurable waste.

**How to apply:**
- New flag: `ask-perplexity-cli --search-threads "<query>" [--limit N]`. Navigates to `https://www.perplexity.ai/library` (or the discover URL with the search applied); scrapes the list of threads; emits JSON list of `{slug, title, snippet, last_updated}`.
- Combine with `--read-thread` for the recover-old-research workflow:
  ```bash
  slug=$(ask-perplexity-cli --search-threads "borai spore tokens" --limit 1 | jq -r '.[0].slug')
  ask-perplexity-cli --read-thread "$slug"
  ```
- Estimated effort: S-M (~250 LOC; needs one new HTML selector for the library view).

**Staging:** Ship alongside `--read-thread`; both flags compose into a "context-recall" workflow.

---

### S6 — Promote chromiumoxide CLIs to a shared-browser daemon (cross-cutting)

**Pattern:** ask-perplexity-cli, ask-grok-cli, and fast-travel-cli all spawn their own headed Chromium and collide on `/tmp/chromiumoxide-runner/SingletonLock`. Instead, run **one persistent browser daemon** (`ghostroute-browserd`) that exposes a thin local HTTP/socket API, and rewrite each CLI as a client. Eliminates the lockfile race, removes the per-call ~3-5s browser startup cost, and lets multiple CLIs run truly in parallel.

**Why this matters:**
- Already cost real time today during the multi-agent fan-out for the BorAI feature research.
- Prerequisite for an "agent swarm" UX where Spore dispatches `Brief` files to N delegates simultaneously.
- The daemon is also the natural place to add cookie-rotation, per-domain throttling, and recording for replay.

**How to apply:**
- New crate `ghostroute-browserd` (axum + chromiumoxide). Endpoints: `POST /sessions/{domain}` (boot or attach), `POST /scrape` (run a typed scrape script), `POST /thread/read`, `POST /thread/search`.
- ask-perplexity-cli, ask-grok-cli, fast-travel-cli each grow a `--via-daemon` flag (default off in v0.1; default on in v0.2 once stable).
- Daemon owns `/tmp/chromiumoxide-runner-shared/`; CLIs hold no Chromium state.

**Staging:** Defer to ghostroute v0.3 (after Spore v0.1 ships) — out of scope for the Spore migration but worth recording.

---

### S7 — `spore-scrape`: heuristic + user-assisted auto-selector discovery

**Pattern:** Stop hand-writing CSS/XPath selectors for every chat-UI provider. Combine two cheap techniques:
- **Path A — DOM heuristic discovery.** Walk the DOM; find the longest sequence of sibling elements with a repeating shape (same tag, similar class signature, alternating role markers). That sequence is almost certainly the conversation-turn list. Score candidates by length × depth × presence of role-distinguishing markers (data attributes, alternating classes). If one candidate dominates, emit a selector pair (wait/extract) and write to a profile registry.
- **Path C — User-assisted point-and-click.** When the heuristic finds ≥2 plausible candidates, fall back to `--discover --visible`: open the page, instruct the user "click a user message, then click an assistant message," capture the click event paths in JS, derive a selector from the lowest common ancestor + role-discriminating sibling. SelectorGadget-style.

**Why this matters:**
- Selector drift cost ~30 minutes in this very session (Phase 4 — the Gemini DOM had moved from `<user-query>`/`<model-response>` to `#chat-history` + `<message-content>` + `.markdown.markdown-main-panel`). Codex's session analysis flagged this directly: *"selectors should be runtime data with fallbacks and last-success timestamps, not code constants. The Gemini fix should have been a profile update, not a `main.rs` edit."*
- Each new provider Spore wants to ingest (Claude.ai, ChatGPT, Perplexity, Grok, plus future ones) currently costs a manual DOM-inspection round-trip with the user. With S7 the round-trip becomes one CLI invocation that writes a profile.
- Composes with the codex-recommended **selector profile registry** (Memory + ToolDispatcher trait integration). Profiles are runtime data: filename, domain, last-success timestamp, fallback selectors, content-shape hash for invalidation.

**How to apply:**
- New crate: `spore-scrape` (or fold into `ghostroute-browserd` from S6). Public surface:
  - `discover_selectors(url, cookies, opts) -> SelectorProfile`
  - `apply_profile(page, profile) -> Result<Vec<Message>>`
  - Profile shape: `{ provider, domain, wait_selector, extract_steps[], discovered_at, last_success_at, dom_hash }`.
- Heuristic algorithm (~300 LOC):
  1. Find candidate conversation roots: deepest single subtrees with ≥4 element children.
  2. Within each, find the longest run of sibling elements with cosine-similar class+tag signatures (cosine because chat UIs tag-randomize).
  3. Detect role markers: alternating `data-message-author-role` attributes, alternating class prefixes, alternating element types.
  4. Score = `length * depth * role_marker_strength`. Top-1 wins; ties trigger Path C.
- User-assisted mode (~200 LOC):
  - `fast-travel-cli --discover --visible <url>`. Page opens; status banner says "click user message".
  - JS injects a `click` listener that records `event.composedPath()` and freezes the page on first click.
  - Repeat for assistant message.
  - Compute LCA path; emit selector pair to profile registry.
- **Profile registry location:** `~/.config/spore-scrape/profiles/<provider-domain>.toml`. Each CLI in the ghostroute family reads from this registry instead of having selectors baked in.

**Staging:**
- **v0.2:** Ship `--dump-dom` in `fast-travel-cli` (the immediate diagnostic feature; ~50 LOC; landed alongside this spec).
- **v0.3:** Ship Path A heuristic alone. ~300 LOC. Solves the easy 70% of providers.
- **v0.4:** Ship Path C interactive fallback. Closes remaining 30%.
- **v1.0:** Promote profile registry to `spore-scrape` crate; integrate with Spore's `ToolDispatcher` and `Memory` per codex's session analysis recommendation.

**Anchored to session evidence:** the fast-travel-cli selector drift incident in Phase 4 of this session is the strongest possible justification — we paid for it in real wall-time and the user explicitly named the fix "selector drift" without me prompting.

---

### S8 — Persistent-profile mode + manual-CF-solve handshake

**Pattern:** Cloudflare's bot challenge cannot be defeated by JS stealth alone — the gate runs at the TLS-fingerprint layer, where chromiumoxide's network signature differs from real Chrome. Empirical evidence from this session: even with stealth flags (4 navigator overrides, removed `--enable-automation`, fixed viewport, scroll/settle jitter) and freshly-exported `__cf_bm` cookies, both the Perplexity homepage and a thread URL get gated by `Just a moment...` interstitials in both headed and headless modes.

The structural fix is **a persistent Chromium profile** that retains `cf_clearance` and other JA3-fingerprint-cleared state across runs. Combined with a one-time **manual-solve handshake** the first time a profile encounters CF, this turns Cloudflare from a recurring blocker into a one-off setup step.

**Why this matters:**
- Direct evidence: 4 dump-dom attempts on Perplexity in this session, all gated by CF, all with valid auth + bot-management cookies. The blocker is `cf_clearance` specifically, which can only be issued by Cloudflare to a fingerprint that matches a successful challenge solve.
- Without S8, fast-travel-cli (and by extension Spore's `spore-scrape` per S7) cannot reliably ingest from Perplexity, ChatGPT, or any other Cloudflare-fronted provider — which is most of them.
- Once solved per profile, the workflow becomes: `--init` (manual solve, ~30s, one-off) → headless runs forever (until profile cookies age out, ~weeks).

**How to apply:**
- Add `--profile-dir <path>` flag (default `~/.cache/fast-travel-cli/profiles/<provider>`). Maps to chromiumoxide's `BrowserConfig::user_data_dir(path)`.
- Add `--init` mode: opens `--visible` Chromium pointed at provider's bootstrap URL, prints `[fast-travel] Solve any Cloudflare/auth challenge in the window, then press Enter here.` to stderr, blocks on `stdin.read_line(...)`, captures and persists the resulting cookies into the profile dir.
- All subsequent runs against that provider reuse the profile via `user_data_dir`, inheriting `cf_clearance` automatically.
- Session-state file (`profile.json`) records: provider, last-success timestamp, profile directory, content-shape hash. Drives auto re-init on staleness.
- Fallback: if a non-init run hits the interstitial guard, error message includes `Run --init for {provider} once to solve the Cloudflare challenge interactively.`

**Estimated effort:** S-M (~150 LOC). chromiumoxide's `user_data_dir` is already supported; the new code is the `--init` interactive prompt + the staleness file format.

**Staging:**
- **v0.2 (this week):** Ship `--profile-dir` and `--init` in `fast-travel-cli`. Unblocks Perplexity, ChatGPT, and Claude scraping for any user willing to do a 30s one-time solve per provider.
- **v0.3:** Auto-detect staleness via the `profile.json` and prompt re-init proactively.
- **v0.5+:** Investigate `curl-impersonate` or `undetected-chromedriver`-equivalent in Rust as a longer-term path — they bypass the fingerprint detection itself rather than working around it.

**Anchored to session evidence:** 4 confirmed Cloudflare gates on Perplexity in this session, with cookies less than 5 minutes old in two cases. Stealth-only mitigation does not work for chromiumoxide-driven traffic against modern CF deployments.

---

## Research-derived features and signals

**Sources:**
- `codex exec` (gpt-5.4 xhigh) × 2 — toolkits + tokens (high-confidence, file-level citations)
- `ask-perplexity-cli` × 2 — toolkits + tokens (web-cited; toolkit response had rendering glitches at the tail)
- `ask-grok-cli` × 2 — toolkits + tokens (shorter, high-level)
- Gemini conversation `cdc5a82d8b3080ee` (37.7K, 8 messages) — fast-travel-cli was patched in this session (`#chat-history` + `message-content` + `.markdown.markdown-main-panel` selectors); see commit/diff in `~/code/ghostroute/fast-travel-cli/src/main.rs`. Domain: fine-tuning swarm pipeline (training-data agents), not agent CLI directly. 3 transferable signals extracted below.

Deduplicated and ranked across the 6 source files. Where two or more sources agreed, the feature is marked **★ consensus**.

### A. Features from famous AI agent toolkits

#### A.1 — Tier 1 (consensus, slot into v0.1)

- **★ Architect/Editor model split** (aider, Cline "Plan & Act"). Cheap planner + stronger executor. Spore: this is the formal name for the Pattern A+C "Ollama-as-manager" mode. Telemetry should record planner-vs-executor token splits separately.
- **★ Repo map** (aider). Tree-sitter symbol map under a token budget. Files: [`aider/repomap.py`](https://github.com/Aider-AI/aider/blob/main/aider/repomap.py). Spore: highest-leverage upgrade for local-model performance on real repos. Implement as a `ContextProvider` impl.
- **★ Repo brief microagent** (OpenHands). Auto-generated repo summary file always loaded as cheap standing context. Spore: low-LOC; emit on first session per repo, cache, invalidate on `git pull`.
- **★ Prompt cache accounting** (aider `--cache-prompts`, claude-cookbooks). Track which prompt regions are cacheable, hits/misses, keepalive cost. Spore: extend existing telemetry with `cache_region`, `cache_age_s`, `cache_hit_kind` (system/tools/messages).
- **★ Scoped permissions + doom-loop tripwire** (OpenCode). Per-tool/path `allow`/`ask`/`deny` plus guards for `external_directory` and repeated identical tool calls. Spore: drops directly into `StockPermissionResolver` (§12.2).
- **Blocking vs parallel guardrails** (OpenAI Swarm). Choose whether safety/budget checks run before or beside model/tool execution. Spore: blocking guardrails prevent paid calls before they happen; matches "spend nothing until Ollama approves."
- **Plan files mode** (OpenCode). Hard planning mode with writes limited to plan markdown. Spore: gives Ollama a zero-risk thinking lane and leaves a durable plan artifact (`/scene plan` slash command).

#### A.2 — Tier 2 (high value, v0.2)

- **★ Attachable memory blocks** (Letta, [docs](https://docs.letta.com/guides/agents/memory-blocks/)). Labeled, size-limited, shareable blocks pinned in context. Spore: best long-term context primitive for the campaigns/chapters/scenes ontology — each ontology node owns a memory block.
- **★ Context providers** (continue.dev). Pluggable providers for docs/code/web/issue context with `@`-style references. Spore: vault ontology becomes a first-class `ContextProvider` rather than ad-hoc prompt stuffing.
- **★ Event-sourced run log** (OpenHands). Typed append-only events with condensation summaries and state updates. Spore: replaces plain transcripts; unlocks replay, branch/resume, and serious observability.
- **Shadow checkpoints** (Cline). Snapshot workspace state after each action outside normal git history. Spore: enables aggressive autonomy with reversible state.
- **Risk analyzers + confirmation thresholds** (OpenHands). LOW/MEDIUM/HIGH risk scoring before tool execution. Spore: cleaner than ad-hoc approvals; slots into `PermissionResolver`.
- **Recipes + scheduler** (goose). Versioned YAML bundles of instructions + params + extensions; cron-style unattended runs. Spore: turns `serve` mode into a usable swarm job runner.
- **Handoff input filters** (OpenAI Swarm). Control exactly what transcript/context a delegated agent sees. Spore: essential for keeping specialist calls cheap and avoiding context leakage.
- **Trace spans for tools/handoffs/guardrails** (OpenAI Swarm, AgentScope OTLP). Structured traces instead of text logs. Spore: makes telemetry exportable via OpenTelemetry.
- **Auto lint/test repair loop** (aider). Run checks after edits; feed failures back automatically. Spore: turns cheap local edits into safer edits.
- **Diff reviewer with scoped rules** (Cursor). Review changed files using root and dir-local rule files. Spore: `/review` slash command + pre-commit mode.
- **Model roles** (continue.dev). Distinct `chat`/`edit`/`apply`/`embed`/`rerank` lanes. Spore: keeps paid models on narrow high-value work; good after the architecture stabilizes.
- **Prompt template files** (goose). Local editable system/task templates under user config. Spore: makes prompt orchestration inspectable, versionable, hackable without recompile.

##### A.2.5 — Cross-domain transferable signals (from the Gemini fine-tuning-swarm conversation)

The Gemini conversation was about building a 9-agent fine-tuning data pipeline, not an agent CLI — but three patterns transfer cleanly:

- **Role-keyed model allocation table**. Specific local model picks per role: routing/classification → Llama 3.2-1B (~700MB); structured-output cleaning → Mistral-7B; synthetic expansion → Llama 3.1-8B; safety/guardrails → Llama 3.2-3B; expensive evaluation → Llama 3.1-70B (only when flagged "Legendary"). Spore: ship a default `model_hint` lookup table mapping each `Planner`/`Memory`/`PermissionResolver`/etc role to a recommended Ollama model size + name. Lets a new user `borai-spore --through ollama:default` get sane choices without hand-tuning.
- **MPSC channels for "zero-cost parallelism"** in Rust. Tokio multi-producer single-consumer channels let one stage pull data while the next stage processes — keeps GPU at 100% utilization, prevents memory bloat. Spore: `spore-orchestra` pipeline already runs sequentially; the upgrade is to express stages as MPSC-connected tasks so Ollama-pre-shape, Claude-call, and Ollama-post-shape can pipeline when batching multiple Briefs.
- **"Selective high-mana usage" policy**. Cheap model handles common requests; expensive model is only "summoned" when the cheap model flags the request as `Legendary` (high-complexity). Spore: this is exactly the v0.3 routing-algorithm brainstorm output (spec §1.2). The Gemini framing — "Scout flags as Legendary → Oracle answers; otherwise Purifier handles it" — is a clean mental model for the routing rule's UX.

The other 90% of the Gemini conversation (Unsloth LoRA, DPO scoring, synthetic data augmentation, Redis-backed swarm orchestration) belongs to a future fine-tuning sub-project, not Spore v0.1–v1.0.

### A.3 — Tier 3 (compounding, v0.3+)

- **Session search** (Hermes Agent). Local FTS5 + LLM summarization across past sessions. Spore: stronger memory before vector infra is needed.
- **Skill distillation** (Hermes Agent). Promote successful multi-step solutions into reusable skills automatically. Spore: compounds a solo dev's habits into durable local leverage.
- **Sleep-time reflection** (Letta). Background agent updates memory while main session is idle. Spore: lets Ollama consolidate context off the critical path.
- **User-approved sidecar memories** (Cursor). Secondary model proposes persistent project memories for approval. Spore: better than blind auto-memory; compose with the existing memory system.
- **Sandbox option** (smolagents). Code actions execute locally or inside a secure sandbox. Spore: pairs naturally with capability tokens and scope-bound tools.
- **Conversation search as tool** (MemGPT/Letta). Old session history stays searchable even after compaction.
- **Selector-based group chat / handoffs** (AutoGen). Speaker selection and graph orchestration. Spore: only meaningful once Spore nodes routinely delegate to other Spore nodes (v1.0).
- **Persisted resumable flows** (CrewAI). Useful once scheduled jobs are mature.

### B. Token conservation repos and strategies

#### B.1 — Verified repos (≥1k stars/forks, with file-level citations)

| Rank | Repo | Stars / Forks | Lang | Concrete techniques (with file links) |
|---|---|---|---|---|
| 1 | [langchain-ai/langchain](https://github.com/langchain-ai/langchain) | 135k / 22.3k | Python | Token-budget message trimming ([`trim_messages`](https://github.com/langchain-ai/langchain/blob/master/libs/core/langchain_core/messages/utils.py)), rolling conversation summaries ([`ConversationSummaryBufferMemory.prune()`](https://github.com/langchain-ai/langchain/blob/master/libs/langchain/langchain/memory/summary_buffer.py)), retrieval-time contextual compression ([`ContextualCompressionRetriever`](https://github.com/langchain-ai/langchain/blob/master/libs/langchain/langchain/retrievers/contextual_compression.py)) |
| 2 | [vllm-project/vllm](https://github.com/vllm-project/vllm) | 78.3k / 16.1k | Python | Cross-request prefix/KV cache reuse, speculative decoding, quantized KV cache. Hash-based block caching with LRU eviction + optional `cache_salt` ([prefix-caching design](https://docs.vllm.ai/design/prefix_caching.html)). **Local-manager only**; doesn't reduce Claude billing. |
| 3 | [microsoft/autogen](https://github.com/microsoft/autogen) | 57.5k / 8.7k | Python | Sub-agent isolation via fresh chats + summary handoff. Conversation summarization/compaction. [`_summarize_chat`](https://github.com/microsoft/autogen/blob/main/autogen/agentchat/conversable_agent.py) with `summary_method="reflection_with_llm"\|"last_msg"`. |
| 4 | [mem0ai/mem0](https://github.com/mem0ai/mem0) | 54.1k / 6.1k | Python | Hierarchical memory, retrieval-only injection, entity-linked dedup, hybrid semantic/BM25 search ([`mem0/memory/main.py`](https://github.com/mem0ai/mem0/blob/main/mem0/memory/main.py)). Claims **90% lower token usage** + **91% faster responses** vs full-context baselines. |
| 5 | [run-llama/llama_index](https://github.com/run-llama/llama_index) | 49k / 7.3k | Python | Summary memory buffers ([`ChatSummaryMemoryBuffer`](https://github.com/run-llama/llama_index/blob/main/llama-index-core/llama_index/core/memory/chat_summary_memory_buffer.py)), prompt repacking to fit budget ([`PromptHelper.repack()`](https://github.com/run-llama/llama_index/blob/main/llama-index-core/llama_index/core/indices/prompt_helper.py)), sentence-level semantic compression ([`SentenceEmbeddingOptimizer`](https://github.com/run-llama/llama_index/blob/main/llama-index-core/llama_index/core/postprocessor/optimizer.py)) |
| 6 | [BerriAI/litellm](https://github.com/BerriAI/litellm) | 44.9k / 7.6k | Python | Anthropic cache-control injection (`anthropic_cache_control_hook.py`), cache breakpoint config, cost telemetry. Direct Spore-relevant for billing correctness. |
| 7 | [Aider-AI/aider](https://github.com/Aider-AI/aider) | 44k / 4.3k | Python | Token-budgeted repo maps ([`RepoMap.get_repo_map()`](https://github.com/Aider-AI/aider/blob/main/aider/repomap.py)), `--cache-prompts` for system prompt + repo map + read-only files, automatic chat-history summarization, weak-model pre-shaping ([`aider/models.py`](https://github.com/Aider-AI/aider/blob/main/aider/models.py)). |
| 8 | [anthropics/claude-cookbooks](https://github.com/anthropics/claude-cookbooks) | 41.6k / 4.6k | Jupyter | Anthropic prompt caching with **5-minute and 1-hour TTL**, cache breakpoints, system/message caching, sub-agent patterns ([`misc/prompt_caching.ipynb`](https://github.com/anthropics/claude-cookbooks/blob/main/misc/prompt_caching.ipynb), [`patterns/agents`](https://github.com/anthropics/claude-cookbooks/tree/main/patterns/agents)). |
| 9 | [microsoft/semantic-kernel](https://github.com/microsoft/semantic-kernel) | 27.8k / 4.6k | C# | First-class chat-history reducers as middleware: summarization, truncation, max-token reduction (`ChatHistorySummarizationReducer`). |
| 10 | [zilliztech/GPTCache](https://github.com/zilliztech/GPTCache) | 8k / 578 | Python | Embedding-based semantic cache for repeated tool results / deterministic subcalls. Best for repeatable lookups, not free-form Claude reasoning. |

#### B.2 — Frontier techniques (papers + Anthropic engineering posts, 2024–2026)

| # | Technique | Source | Difficulty | Measured value |
|---|---|---|---|---|
| 1 | **Anthropic prefix-stable cache planner** — version every injected block; order `tools → system → messages`; place `1h` TTL blocks before `5m`; add breakpoints every ~20 blocks; mutable retrieval/tool output stays in suffix. | [Anthropic prompt caching docs](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching), [token-saving updates](https://www.anthropic.com/news/token-saving-updates), [LMCache trace analysis](https://blog.lmcache.ai/en/2025/12/23/context-engineering-reuse-pattern-under-the-hood-of-claude-code/) | **Low** | **90% lower cost**, **85% lower latency** for long prompts (Anthropic). LMCache observed **92% prefix reuse** in Claude-Code-like traces. |
| 2 | **Token-efficient tool schemas** — compress tool names/descriptions/JSON; cache the `tools` prefix; translate compact internal schema to verbose local adapters. | [Anthropic token-saving updates](https://www.anthropic.com/news/token-saving-updates) | **Low** | High Spore-relevance: tools are pure prompt tax. |
| 3 | **Local prompt compression for dynamic suffixes** — LLMLingua-style compressor over retrieved chunks, tool logs, user-tail context before Claude. | [LLMLingua-2](https://llmlingua.com/llmlingua2.html) | **Medium** | Compose with prompt caching by compressing only the uncached suffix. |
| 4 | **Hierarchical memory with promotion rules** — sensory/working/topic-summary/long-term-semantic tiers with promotion thresholds. | [LightMem paper](https://huggingface.co/papers/2510.18866) | **Medium-High** | Good fit for vault context + multi-session memory. |
| 5 | **Hierarchical summary-tree RAG (RAPTOR)** — recursively cluster + summarize documents; retrieve leaf chunks AND higher-level summaries. | [RAPTOR paper](https://huggingface.co/papers/2401.18059) | **Medium** | **+20 absolute points on QuALITY** with GPT-4. |
| 6 | **Cross-query KV cache for the local manager** — reuse local-model KV state across requests/engines. | [LMCache repo](https://github.com/LMCache/LMCache), [paper](https://huggingface.co/papers/2510.09665) | **High** | **3–10x delay savings** (repo); **up to 15x throughput** (paper). Local latency/GPU win, not Claude tokens. |
| 7 | **Differential context updates** — maintain canonical prompt state; send only changed segments through a cache-aware assembler. | (composes with #1) | **Medium** | Maximizes prompt-cache hit rate by minimizing prefix churn. |
| 8 | **Attention/embedding-guided context pruning** — rank prior turns/tool outputs/vault snippets by estimated usefulness; keep only top budget-fitting set + tiny running summary. | (research-frontier; implementable in Rust with local embeddings) | **Medium** | Composes with cache by keeping the "instruction spine" fixed and pruning only volatile appendices. |

---

## Synthesis (final priority list)

Combining Prince's seed insights (S1–S6), the toolkit research (A), and the token research (B). Items in **bold** appeared in 2+ source files (high confidence).

### Final v0.1 (alpha) — token + safety win, no architecture change

1. **Anthropic cache breakpoint compiler with 5m/1h TTL planning** (B-frontier#1, codex-tokens, perp-tokens). Order `tools → system → messages`; mark stable layers (CLAUDE.md hierarchy, skills, vault-template) as `1h`-cached; mark mutable retrieval as `5m`. Measured 90% cost / 85% latency savings on long prompts. Implement in `spore-orchestra` as a `CachePlanner` step before `ModelClient::complete()`.
2. **Block hashing + versioned cache invalidation** (codex-tokens). SHA-256 each cacheable block; track `(block_id, content_hash)` in `~/.borai/telemetry/cache.jsonl`. Auto-invalidate when source file mtime changes.
3. **Compact tool schemas + cached `tools` prefix** (B-frontier#2). Strip verbose JSON; cache as a 1h-TTL block. Add a `--verbose-tools` flag for debugging.
4. **Token-aware prompt templating** (codex-tokens, perp-tokens). Drop optional sections (skill examples, full vault context) under a budget threshold. Promote/demote based on `token_budget` arg in the `Prompt` struct.
5. **Aider-style repo map** (A-Tier1, codex-toolkits). Tree-sitter parse → symbol-ranked tree → token-budgeted slice. New `ContextProvider` impl. Use [`tree-sitter` Rust crate](https://crates.io/crates/tree-sitter).
6. **OpenHands repo brief microagent** (A-Tier1, codex-toolkits). Auto-generate `~/.borai/projects/<hash>/repo-brief.md` on first session per repo; cache; invalidate on `git pull`. Always loaded as standing context.
7. **Architect/Editor split as Manager mode** (A-Tier1, **★ consensus**). Already in spec §6 as Pattern A+C; rename docs to use the industry-standard "architect/editor" framing for cross-toolkit users.
8. **Scoped permissions + doom-loop tripwire** (A-Tier1, codex-toolkits). Detect 3+ identical tool calls in a row → auto-block + offer `--reset-loop`. Compose with existing `permissions.allow/ask/deny`.
9. **Blocking guardrails before paid calls** (A-Tier1, codex-toolkits). Hard pre-flight: "is this turn within budget? does the prompt pass safety? are required skills available?" before any token leaves Spore.
10. **Per-call cache telemetry** (A-Tier1, codex-toolkits). Extend telemetry schema with `cache_region`, `cache_age_s`, `cache_hit_kind`, `cache_keepalive_cost_usd`.
11. **Plan-files mode** (A-Tier1, OpenCode). `borai-spore --mode plan` writes to scene plan markdown only, no other tool calls allowed. Slash command: `/scene plan`.
12. **S3 — first-class Ollama controls** (Prince-seed). `/ollama list`, `/ollama swap`, `/ollama pull`, `/ollama param` slash commands.
13. **S1 — Brief object as canonical multi-delegate input** (Prince-seed). New `Brief` struct in `spore-orchestra`; `--prompt-file` flag on headless mode and on every delegate CLI shim.

### v0.2 — context primitives + observability

14. **Letta-style attachable memory blocks** (A-Tier2, **★ consensus**). Each ontology node (campaign/chapter/scene/character) owns a labeled, size-limited memory block. Stored as files; indexed by `MEMORY.md`; pinnable per session.
15. **Continue-style context providers** (A-Tier2, **★ consensus**). Vault becomes a first-class `ContextProvider` impl with `@scene:01`, `@chapter:02b`, `@campaign:command-centre` references in TUI input.
16. **OpenHands event-sourced run log** (A-Tier2, codex-toolkits). Append-only typed events: `MessageReceived`, `PlanProposed`, `ToolCalled`, `ResponseGenerated`, etc. Replaces freeform session JSON. Enables replay/branch/resume.
17. **Risk analyzers** (A-Tier2, OpenHands). LOW/MEDIUM/HIGH classifier on tool calls; threshold-gated confirmation. Slots into `StockPermissionResolver`.
18. **Tool-result truncation with head/tail/middle + semantic shrink** (B#7-style, codex-tokens, perp-tokens). Long tool outputs (e.g., `git diff`, large file reads) get: head 2KB + tail 2KB + middle "[N lines elided]" by default; opt-in semantic shrink via local embedder.
19. **Retrieval-only injection for vault/skills/CLAUDE.md** (B-frontier#8, codex-tokens). Don't inject the whole CLAUDE.md hierarchy; embed-rank against the user prompt and inject only the top-K relevant blocks. Dedup by chunk hash and embedding hash.
20. **Goose-style recipes** (A-Tier2, codex-toolkits). Versioned YAML bundles for repeatable jobs. `borai-spore recipe run <name>`. Pairs with `serve` mode for cron-driven swarm jobs.
21. **OpenAI-style handoff input filters** (A-Tier2, codex-toolkits). When delegating to a sub-agent or another Spore (via `serve`), filter what transcript/context goes through. Default: system + last N turns + the explicit handoff brief.
22. **OpenAI/AgentScope trace spans** (A-Tier2, codex-toolkits). OTLP-compatible spans for tools/handoffs/guardrails. Telemetry becomes exportable to Honeycomb/Tempo/Jaeger.
23. **S2 — Walkie-Talkie skill invocation extension** (Prince-seed). Child CLIs can request `{ "type": "invoke_skill", "skill": "<name>", ... }`. Permission-gated via `child_skill_access` allowlist.
24. **S5 — `ask-perplexity-cli --search-threads`** (Prince-seed; ghostroute-scoped). Search past Perplexity threads to avoid duplicate research.

### v0.3 — heavier compaction + sub-agent isolation

25. **Rolling conversation compactor** (codex-tokens, perp-tokens). Keep system + recent N turns + local-summary of older turns. Triggered at 75% of token budget. Local Ollama generates the summary.
26. **Sub-agent isolation with summary-only handoff** (B-Tier1: autogen, A-Tier2: Swarm). Children get fresh context; parent receives only typed summary + explicit artifacts. Direct match for the future `spore-server`-as-provider topology.
27. **Hermes session search** (A-Tier3). Local FTS5 + summarization. `borai-spore search "<query>"` across all past sessions.
28. **Sleep-time reflection** (A-Tier3, Letta). Background Ollama agent updates memory blocks while main session is idle.
29. **Cline shadow checkpoints** (A-Tier2). Workspace snapshots after each tool call. Enables "undo" for autonomy-heavy runs without polluting git history.
30. **Aider auto lint/test repair loop** (A-Tier2). Run `pnpm lint && pnpm typecheck` after edits; feed failures back automatically.
31. **Continue model roles** (A-Tier2). Distinct `chat`/`edit`/`apply`/`embed`/`rerank` lanes, each with its own model_hint.
32. **Borai-graph retrieval engine in Rust** (existing v0.3 plan in spec §1.1). Now compose with #19 (retrieval-only injection) and #4 (LightMem-style hierarchical memory).
33. **S4 — `ask-perplexity-cli --read-thread`** (Prince-seed; ghostroute-scoped).

### v0.4–v1.0 — research-grade compounding

34. **Hierarchical memory with promotion rules** (B-frontier#4, codex-tokens). Working/episodic/semantic tiers + promotion thresholds. Compose with #14 memory blocks (each tier is its own block category).
35. **Differential context updates** (B-frontier#7, perp-tokens). Maintain canonical prompt state; send only changed segments through cache-aware assembler. Maximizes hit rate of #1.
36. **Hermes skill distillation** (A-Tier3). Promote successful multi-step solutions into reusable skills automatically.
37. **LLMLingua-style local prompt compressor** (B-frontier#3, codex-tokens). Apply only to the uncached suffix to compose with prompt caching.
38. **RAPTOR hierarchical summary-tree RAG** (B-frontier#5, codex-tokens). Cluster vault docs; retrieve both leaf chunks and parent summaries.
39. **LMCache cross-query KV cache for Ollama manager** (B-frontier#6, codex-tokens). Reuse local-model KV state across requests. **3-10x latency savings**. High implementation difficulty; defer until Spore-on-server is real.
40. **Cursor diff reviewer + scoped rules** (A-Tier2, codex-toolkits). `/review` slash command runs a sub-agent over changed files using root + dir-local rule files.
41. **AutoGen selector group chat** (codex-toolkits, A-Tier3). Speaker selection across multiple Spore nodes. Only meaningful at v1.0.
42. **S6 — `ghostroute-browserd` shared-browser daemon** (Prince-seed). Eliminates chromiumoxide SingletonLock collisions; powers true parallel delegate fan-out.

---

## Source-file inventory (for future synthesis re-runs)

```
/tmp/borai-research-toolkits.codex.txt       9.2K  (gpt-5.4 xhigh, 27 features across 12 toolkits)
/tmp/borai-research-toolkits.perplexity.json 18.1K (web-cited, ~60 features across 9 toolkits; tail glitched)
/tmp/borai-research-toolkits.grok.txt         1.2K (high-level summary, validates Tier-1 picks)
/tmp/borai-research-tokens.codex.txt          9.2K (gpt-5.4 xhigh, 10 verified repos + 6 frontier techniques + Top-10 staging)
/tmp/borai-research-tokens.perplexity.json   12.7K (3 verified repos + frontier signals; lower confidence)
/tmp/borai-research-tokens.grok.txt           2.6K (broad signals, validates v0.1 staging)
/tmp/borai-research-{toolkits,tokens}.md     ~7K   (canonical Briefs — re-pipe via `$(cat ...)` for re-runs)
/tmp/borai-research-gemini.md                37.7K (8 messages from fine-tuning-swarm conversation cdc5a82d8b3080ee; see A.2.5)
```

## fast-travel-cli — selector patch shipped this session

`~/code/ghostroute/fast-travel-cli/src/main.rs`:
- `wait_for_conversation` — anchors on `#chat-history`/`.chat-history` root; falls through to legacy `user-query`/`model-response`.
- `extract_conversation` — scopes queries to `#chat-history`; prefers new `<message-content>` shape with role inferred from presence of `.markdown.markdown-main-panel` (model) vs absence (user); falls back to legacy custom elements.

Compatible with both old and new Gemini DOM. Rebuilt via `cargo build --release`; binary at `~/code/ghostroute/fast-travel-cli/target/release/fast-travel-cli`. Validated against conversation `cdc5a82d8b3080ee` — extracted 8 messages cleanly.
