# BorAI Spore — design spec

**Scene:** `command-centre / 02b-borai-platform / 01-the-pivot` (scene file produced after this spec is approved)
**Date:** 2026-04-27
**Status:** Design approved; ready for Phase 0 + implementation plan.
**Supersedes:**
- `~/code/ai-swarm-infra/docs/superpowers/specs/2026-04-24-orchestra-design.md` — orchestra collapses into the `spore-orchestra` crate; the HTTP shim role moves to `spore-server`.
- `~/code/ai-swarm-infra/swarm-architecture.md` — original 3-node Python distributed-compute vision is realized differently via `spore-server` + `spore-client`.
- Triggers Rust-port path for `~/code/build-in-public/docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md` — Python implementation valid through v0.2; v0.3 ports retrieval engine to Rust as `crates/borai-graph`.

---

## 1. Purpose

BorAI Spore is the user-facing CLI of the BorAI platform — a Rust agent CLI built from scratch that takes the best of Claude Code, opencode, aider, OpenHands, and goose, and adds a distinctive headline:

> **The local Ollama model is the boss. Paid models like Claude are tools. Every cent is measured. The whole thing is a remote-callable swarm node.**

Spore is one of several distributable "seeds" of the BorAI ecosystem. Sister components in the BorAI monorepo:
- `graph/` — the local RAG knowledge graph (Python in v0.1/v0.2; Rust port in v0.3 lives at `crates/borai-graph`).
- `vault-template/` — the campaigns/chapters/scenes ontology starter.
- `skills-template/` — the starter skill bundle.
- `inbox/` — the event-staging directory; consumer daemon ships v0.3.
- `apps/` — first-party Next.js webapps (study-buddy, misled, talk-with-flavour) as platform reference implementations.

### 1.1 Headline differentiators

1. **Local-first orchestration.** Architecture v0.1 (passthrough); local-Ollama brain v0.3 after the routing-algorithm brainstorm.
2. **Composable agent loop.** Seven components are pluggable through Rust traits (v0.1) and WASM components (v0.3+).
3. **Hybrid skill ecosystem.** Drop-in-runs Claude Code skills as-is; native skills add `version`/`requires`/`capabilities`/`model_hint` frontmatter without losing backwards compatibility.
4. **Vault-native.** Reads BorAI campaigns/chapters/scenes ontology directly; ships `/scene new`, `/scene conclude`, `/chapter list`, `/campaign list` slash commands backed by `vault-template/templates/`.
5. **Ollama-as-manager (Pattern A + Pattern C).** Opt-in `--manager ollama:<model>` mode where the local Ollama drives the conversation as both `Planner` and `ConversationManager`, and Claude is exposed as a `claude.deep_thought` tool. When that tool fires, Ollama pre-shapes every Claude prompt and post-shapes every Claude response.
6. **Per-call telemetry.** Every paid LLM call is recorded as a JSON-line entry with token counts, cost, manager decision, pre/post-shape token deltas. `borai-spore stats` aggregates; `/usage` slash command shows session-scoped data in the TUI.
7. **Remote swarm node.** `borai-spore serve` exposes the agent loop over authenticated HTTP. Another Spore instance (or any HTTP client) can use this Spore as a model provider — the original ai-swarm-infra distributed-compute vision realized.

### 1.2 Non-goals (v0.1)

- **TUI polish.** Minimum viable in v0.1; refined v0.2.
- **WASM plugin loading.** Trait surface is in place from v0.1; the `wasmtime`-backed loader ships v0.3.
- **MCP support.** Deferred to v0.2 (`rmcp` Rust SDK).
- **OpenAI-compatible provider.** Anthropic + Ollama only in v0.1; OpenAI-compat (covers OpenRouter, LM Studio, vLLM, LiteLLM proxy) in v0.2.
- **Real local-model triage policy.** v0.1 ships a dumb escalation policy (manager calls Claude only on explicit `deep_thought` tool emission or `/escalate` slash command). The real routing algorithm is brainstormed and built in v0.3.
- **Rust port of borai-graph retrieval engine.** Python implementation stays canonical through v0.2; ported to `crates/borai-graph` in v0.3.
- **SQLite sessions.** JSON files in v0.1; SQLite via `rusqlite` in v0.2.
- **Inbox consumer daemon.** Spore writes events to `inbox/` in v0.1; the consumer that reads them ships v0.3.
- **Public open.** Closed beta to 6 named alpha users until v0.5; full public OSS open at v1.0 under Apache 2.0.
- **Windows.** macOS + Linux only in v0.1.

### 1.3 Primary callers of v0.1

- The developer in interactive TUI mode: `borai-spore`.
- The developer headless: `borai-spore -p "..."` with optional `--output-format stream-json`.
- 6 alpha users on Linux (x86_64/aarch64) and macOS (x86_64/aarch64).
- (Anticipated v0.2+) the future Command Centre webapp, calling `borai-spore serve` over HTTP.
- (Anticipated v0.2+) other Spore instances configured with the local Spore as a remote provider.

---

## 2. Staging

| Version | Scope | Realistic timeline |
|---|---|---|
| **v0.1** | Phase 0 migration + headless CLI + minimum-viable TUI + skill loader (CC compat + native ext) + vault parser + Anthropic + Ollama providers + Manager mode (Pattern A+C) + telemetry + hooks + file sessions + serve mode + client crate | ~10–14 focused days |
| **v0.2** | Graph wired via Python HTTP shim + MCP via `rmcp` + OpenAI-compat provider + SQLite sessions + TUI polish + slash command expansion | 2–3 weeks after v0.1 |
| **v0.3** | Rust port of borai-graph (`crates/borai-graph`) + real Ollama-backed triage in `spore-orchestra` (post routing-algorithm brainstorm) + WASM plugin loader wired for `Planner` slot + inbox consumer daemon | 4–6 weeks after v0.2 |
| **v0.4–v1.0** | Remaining 6 of 7 WASM plugin slots + webapp HTTP serve-mode integration + monorepo public open under Apache 2.0 | progressive |

---

## 3. Phase 0 — monorepo migration (precondition for v0.1)

Before Spore code is scaffolded, the existing four-sibling sprawl is consolidated.

### 3.1 Target layout

```
~/code/borai/                                ← new monorepo root
├── apps/                                    ← was BorAI/apps/
│   ├── study-buddy/
│   ├── misled/
│   └── talk-with-flavour/
├── agents/
│   └── spore/                               ← NEW: Rust agent CLI workspace
├── graph/                                   ← was BorAI/ops/borai-graph/ (Python)
├── vault-template/                          ← was BorAI-graph/starter-vault/
├── skills-template/                         ← was BorAI-graph/starter-skills/
├── inbox/                                   ← NEW physical home (was borai-inbox-stub Claude skill)
├── docs/
│   └── superpowers/
│       ├── specs/                           ← absorbs build-in-public/docs/superpowers/specs/
│       ├── plans/
│       └── superseded/                      ← orchestra design + 2025 swarm blueprint land here
├── docker-compose.yml                       ← merged from BorAI/ + BorAI-graph/
└── README.md
```

### 3.2 Migration steps (mechanical, ~1 day)

1. `git init ~/code/borai`.
2. For each source dir (BorAI, BorAI-graph, ai-swarm-infra, build-in-public/docs/superpowers), use `git subtree add --prefix=<dest> <src> <branch>` (or `git-filter-repo` per subdir for clean history).
3. Archive `BorAI-swarm-wt/` — it is a git worktree of `BorAI/`; redundant after consolidation.
4. Move `ai-swarm-infra/orchestra/` → `borai/docs/superpowers/superseded/orchestra-design-2026-04-24/` (design archive).
5. Move `ai-swarm-infra/swarm-architecture.md` → `borai/docs/superpowers/superseded/swarm-architecture-2025.md` with the banner specified in §13.
6. Update path references in `vault-template/CLAUDE.md` and `skills-template/README.md`.
7. Initial commit; push to GitHub as private repo `borai/borai`.

Migration does not have its own spec — it is mechanical and is folded into the v0.1 implementation plan as Phase 0.

---

## 4. Architecture

### 4.1 Crate layout (Rust workspace at `agents/spore/`)

```
agents/spore/
├── Cargo.toml                               # workspace root
├── crates/
│   ├── borai-spore/                         # the binary (CLI entry, mode dispatch)
│   ├── spore-agent/                         # 7 trait defs + stock impls (incl. Ollama-manager variant)
│   ├── spore-skills/                        # hybrid skill loader + Skill tool implementation
│   ├── spore-vault/                         # campaigns/chapters/scenes parser + slash commands
│   ├── spore-providers/                     # anthropic + ollama (v0.1); openai_compat (v0.2)
│   ├── spore-orchestra/                     # cache + triager + pipeline (passthrough v0.1)
│   ├── spore-tui/                           # ratatui surface
│   ├── spore-tools/                         # Read/Write/Edit/Bash + claude.deep_thought (manager mode)
│   ├── spore-hooks/                         # PreToolUse/PostToolUse/Stop dispatch
│   ├── spore-session/                       # JSON sessions, MEMORY.md, CLAUDE.md hierarchy
│   ├── spore-config/                        # settings.json hierarchy parsing
│   ├── spore-telemetry/                     # JSON-lines logger + aggregation queries
│   ├── spore-server/                        # axum HTTP server for `serve` mode
│   └── spore-client/                        # Rust client lib for cross-Spore RPC
├── tests/                                   # integration tests
└── README.md
```

Workspace deps (locked):
- Async + HTTP: `tokio`, `reqwest`, `eventsource-stream`
- Serialization: `serde`, `serde_json`, `serde_yaml`
- CLI: `clap`
- TUI: `ratatui`, `crossterm`
- Server: `axum`, `tower`, `tower-http`
- Concurrency primitives: `dashmap`
- Storage (v0.2): `rusqlite`
- Logging: `tracing`, `tracing-subscriber`
- Trait infra: `async-trait`
- Errors: `anyhow`, `thiserror`
- Misc: `colored`, `rand`

Rust edition 2024. MSRV: stable, current minus 2.

### 4.2 Component responsibilities

| Crate | Responsibility |
|---|---|
| `borai-spore` | CLI argument parsing (`clap`), mode dispatch (TUI / headless / serve / stats), top-level wiring of all other crates |
| `spore-agent` | The 7 agent-loop trait definitions and the v0.1 stock implementations of each |
| `spore-skills` | Skill discovery, frontmatter parsing (Claude Code + native extensions), registry build, lazy body load, `Skill` tool implementation |
| `spore-vault` | Vault detection (walking up from CWD), parsing campaigns/chapters/scenes, typed models, slash command implementations |
| `spore-providers` | `ModelClient` trait implementations: Anthropic (native), Ollama (native) |
| `spore-orchestra` | `Cache` and `Triager` trait implementations; pipeline that orchestrates cache lookup → context enrichment → triage → run. v0.1 ships passthrough impls (cache is no-op or in-memory; triager always escalates). |
| `spore-tui` | ratatui-based interactive surface |
| `spore-tools` | Built-in tool implementations: `Read`, `Write`, `Edit`, `Bash`, plus `claude.deep_thought` registered when manager mode is active |
| `spore-hooks` | `PreToolUse`, `PostToolUse`, `Stop` dispatch reading from `~/.claude/settings.json` and project `.claude/settings.json` |
| `spore-session` | Session JSON file IO, conversation history, `MEMORY.md` read/write, CLAUDE.md hierarchy resolution |
| `spore-config` | `settings.json` hierarchy parsing (global → workspace → project), permission allowlist resolution, env var overrides |
| `spore-telemetry` | JSON-lines logging of every paid LLM call; aggregation queries for `borai-spore stats` and `/usage` slash command |
| `spore-server` | axum HTTP server exposing `/v1/sessions`, `/v1/sessions/<id>/messages`, `/v1/sessions/<id>/events` (SSE), `/v1/stats`, `/v1/chat/completions`. Bearer-token auth via `tower-http`. |
| `spore-client` | Typed Rust client for `spore-server`'s HTTP API. Implements `ModelClient` so a Spore on machine A can register `spore://machine-b:7474` as a provider. |

### 4.3 Network topology

By default, `borai-spore` is a single-process binary. Three optional sidecars:
- **Local Ollama** (host-installed via `curl https://ollama.com/install.sh | sh`) at `http://127.0.0.1:11434` — required for manager mode.
- **Local borai-graph** (Python; v0.2+) at `http://127.0.0.1:7475` — adds context enrichment.
- **Remote Spore** (v0.1+) at `http(s)://<host>:7474` — when this Spore is configured to use another Spore as a provider.

`spore-server` mode binds to `127.0.0.1:7474` by default. Explicit `--bind 0.0.0.0:<port>` is required for LAN exposure; the binary refuses to bind to non-loopback without `--token-file` argument.

---

## 5. Agent loop — the 7 pluggable components

All trait definitions live in `spore-agent/src/traits.rs`. Stock implementations live alongside in `spore-agent/src/stock_*.rs`.

```rust
#[async_trait]
pub trait Planner: Send + Sync {
    async fn plan(&self, request: &Request, context: &Context) -> Result<Plan>;
}

#[async_trait]
pub trait ToolDispatcher: Send + Sync {
    async fn dispatch(&self, call: ToolCall, ctx: &mut Context) -> Result<ToolResult>;
}

#[async_trait]
pub trait ContextProvider: Send + Sync {
    async fn enrich(&self, request: &Request, budget: TokenBudget) -> Result<Vec<ContextChunk>>;
}

#[async_trait]
pub trait ModelClient: Send + Sync {
    async fn complete(&self, prompt: Prompt) -> Result<Completion>;
    async fn stream(&self, prompt: Prompt) -> Result<CompletionStream>;
}

#[async_trait]
pub trait Memory: Send + Sync {
    async fn recall(&self, query: &str, scope: MemoryScope) -> Result<Vec<MemoryEntry>>;
    async fn write(&self, entry: MemoryEntry) -> Result<()>;
}

#[async_trait]
pub trait ConversationManager: Send + Sync {
    async fn step(&mut self, msg: Message) -> Result<Vec<Event>>;
}

#[async_trait]
pub trait PermissionResolver: Send + Sync {
    async fn resolve(&self, action: &Action, ctx: &PermissionContext) -> Result<Decision>;
}
```

v0.1 ships stock implementations of all seven. The WASM loader that allows external `.wasm` plugin replacement of any one of them ships v0.3 for `Planner` first; remaining six follow in v0.4+. The trait surface is stable from v0.1 — plugins built later do not force core changes.

Stock impls (default mode, Claude-as-boss):
- `StockPlanner` — Claude-driven. Hands the conversation + tools to the model client.
- `StockDispatcher` — synchronous tool execution; respects permission resolver.
- `StockContextProvider` — vault-aware; injects scene/chapter/campaign context block when CWD is inside a vault. v0.2 adds graph chunks.
- `StockModelClient` — pluggable provider chain (Anthropic, Ollama).
- `StockMemory` — file-based; reads CLAUDE.md hierarchy, MEMORY.md, individual memory files.
- `StockConversationManager` — Claude is the conversation; manages history, retries, streaming.
- `StockPermissionResolver` — settings-driven allowlist + interactive prompt fallback.

---

## 6. Manager mode (Pattern A + Pattern C)

Activated by `--manager <provider>:<model>` flag. Default off. Example:

```
borai-spore --manager ollama:qwen3.6:35b-a3b-coding-q4_K_M
```

When active, two of the seven stock components are swapped:
- `OllamaManagerPlanner` replaces `StockPlanner`.
- `OllamaManagerConversationManager` replaces `StockConversationManager`.

### 6.1 Pattern A — boss/tool

- User messages land at the Ollama model.
- Ollama is the conversation. It maintains state, decides per-turn what to do.
- A new tool is registered in Ollama's tool registry: `claude.deep_thought(prompt: string, context_hint?: string) -> string`. This tool, when called, escalates to Claude.
- v0.1 escalation policy is dumb: Ollama escalates only when (a) it explicitly emits a `claude.deep_thought` tool call after its system prompt instructs it to do so for "questions requiring substantial reasoning," or (b) the user invokes the `/escalate` slash command which forces a passthrough turn.
- The real escalation policy is the v0.3 routing-algorithm brainstorm output.

### 6.2 Pattern C — pre/post shaping (every Claude call)

When `claude.deep_thought` fires, the call becomes a four-step chain:

1. **Pre-shape.** An Ollama call shapes the prompt for Claude. System prompt template (configurable):
   > Given this conversation state and the user question, produce the optimal Claude prompt: include only essential context, strip fluff, format clearly. Output the prompt only.
   Output: the shaped prompt.
2. **Claude responds** to the shaped prompt.
3. **Post-shape.** An Ollama call extracts the answer for integration. System prompt template:
   > Given this Claude response and the original user question, extract the integrated answer for the user. Discard reasoning that is not needed.
   Output: the integrated answer.
4. **Ollama presents** the integrated answer to the user as part of its turn.

Latency cost: roughly 2× a single Claude call (two extra Ollama hops; Ollama is local and fast). Token cost: typically 30–60% reduction in Claude tokens — the whole point. Telemetry records each step.

### 6.3 When manager mode is OFF

Default mode. `StockPlanner` + `StockConversationManager`. Claude is the conversation. No Ollama in the path. Acts like opencode/Claude Code.

---

## 7. Skill loader

### 7.1 Hybrid format

Native frontmatter (extends Claude Code's; all extensions optional):

```yaml
---
name: my-skill
description: One-line trigger description.
type: standard | always-on | flow
# Native extensions (omit any to remain Claude-Code-shaped):
version: 1.2.0                   # semver
requires: [other-skill, vercel:nextjs]   # cross-skill deps
capabilities: [read, write, bash, web_fetch]   # for permission gating
model_hint: opus | sonnet | haiku | local      # router hint, used in v0.3
---

Skill body content here.
```

A skill file with no native extensions parses identically to a Claude Code skill. This is the "drop-in" half of the hybrid pitch.

### 7.2 Loader logic

1. **Discover.** At session start, scan in this order:
   - `~/.claude/skills/`
   - `~/.claude/plugins/*/skills/`
   - Project-local `.claude/skills/` (relative to CWD)
   - `vault-template/skills-template/` if vault is detected
2. **Parse.** Read each skill's frontmatter; build registry: `HashMap<SkillName, SkillDescriptor>` where `SkillDescriptor { path: PathBuf, frontmatter: SkillFrontmatter, body_loaded: AtomicBool }`.
3. **Inject.** Build a compact `<available-skills>` block listing `name + description + type` for each skill; inject as a system-prompt prefix at session start. Mirrors Claude Code's `available-skills` format exactly.
4. **Lazy-load.** On `Skill` tool invocation with a registered name, read the body from disk and return as a user-visible message. Same semantics as Claude Code.
5. **Honor `<EXTREMELY-IMPORTANT>` blocks** verbatim in injected content.
6. **Plugin namespaces** (`vercel:nextjs`, `superpowers:brainstorming`, etc.) parse identically to Claude Code's namespacing; the `:` separator is recognized; the registry key is the full namespaced name.

### 7.3 Capability gating

When `capabilities` is set in frontmatter, the permission resolver consults it: a skill that declared only `[read]` cannot trigger a `Bash` tool call without an explicit user override. This is a v0.1 hardening that Claude Code does not have.

---

## 8. Vault integration

### 8.1 Detection

Walk up from CWD looking for either `campaigns/` directory or a `.borai-vault` marker file. First match wins. If found, set `VAULT_ROOT` for the session; otherwise vault features are inert.

### 8.2 Parser

`spore-vault::parser` reads the vault tree:
```
campaigns/<slug>/campaign.md
campaigns/<slug>/chapters/<NN-slug>/chapter.md
campaigns/<slug>/chapters/<NN-slug>/scenes/<NN-slug>.md
characters/<slug>.md
```

Frontmatter is parsed into typed `Campaign`, `Chapter`, `Scene`, `Character` structs (Rust). Schema mirrors `vault-template/CLAUDE.md` exactly.

### 8.3 Context injection

If CWD is inside or under a scene's working directory, a `<vault-context>` block is injected into the system prompt:

```
<vault-context>
Campaign: command-centre — "Building the AI-augmented work OS"
Chapter: 02b-borai-platform — "BorAI as a platform, not a product co"
Scene: 01-the-pivot (in-progress, opened 2026-04-27)
Thesis: ...
</vault-context>
```

### 8.4 Slash commands (v0.1)

| Command | Behaviour |
|---|---|
| `/scene new <slug>` | Copy `vault-template/templates/scene-template.md` to correct path; fill frontmatter from CWD-resolved chapter; open for edit |
| `/scene conclude` | Load current scene + thesis + chapter arc; draft Conclude block; present for edit |
| `/chapter list` | List chapters in current campaign with status |
| `/campaign list` | List campaigns with chapter counts |

v0.2 adds: `/character new`, `/scene ship`, `/scene rename`, `/chapter renumber`.

---

## 9. Models, providers, modes

### 9.1 Providers (v0.1)

| Provider | Crate module | Notes |
|---|---|---|
| Anthropic | `spore-providers/src/anthropic.rs` | Native HTTP via `reqwest` + structured types; supports streaming, prompt caching headers, tool use |
| Ollama | `spore-providers/src/ollama.rs` | Native HTTP; supports streaming, JSON mode for triage/manager prompts |

OpenAI-compat ships v0.2; Bedrock/Vertex deferred indefinitely (likely never — they're not core to the local-first pitch).

### 9.2 TUI mode

`borai-spore` (no args) opens the ratatui TUI. v0.1 minimum viable:
- Single chat view (scrollable history).
- Input box at bottom; multiline with Shift-Enter.
- `Ctrl-C` → confirm-then-exit.
- `/` enters slash-command mode.
- Status line shows: model, manager mode (if active), token count, cost so far this session.
- Tool calls render inline with collapsible details.

Polish (color theme, key chord configurability, tab-based session switching) is v0.2.

### 9.3 Headless mode

`borai-spore -p "prompt"` runs a single-turn non-interactive request. Outputs the final assistant message to stdout.

`borai-spore -p "prompt" --output-format stream-json` outputs a sequence of JSON frames matching Claude Code's `stream-json` shape exactly (script compatibility — existing Claude Code automation works against Spore unchanged).

### 9.4 Serve mode (see §11)

`borai-spore serve --bind 127.0.0.1:7474 --token-file <f>` runs as an HTTP server.

### 9.5 Stats mode

`borai-spore stats` aggregates telemetry and prints a summary (see §10).

---

## 10. Telemetry (`spore-telemetry`)

### 10.1 Storage

- Path: `~/.borai/telemetry/<session_id>.jsonl`
- Format: one JSON object per paid LLM call, append-only.
- No telemetry leaves the host. Ever. Local-first stance.

### 10.2 Schema

```json
{
  "ts": "2026-04-27T14:23:11.482Z",
  "session_id": "ses_01H...",
  "call_id": "call_01H...",
  "provider": "anthropic",
  "model": "claude-sonnet-4-6",
  "prompt_hash": "sha256:abcd...",
  "tokens_in": 1842,
  "tokens_out": 391,
  "cost_usd": 0.0167,
  "latency_ms": 2103,
  "cache_hit": false,
  "skill_invoked": "vercel:nextjs",
  "hook_invoked": null,
  "manager_decision": "escalate",
  "pre_shape_tokens_saved": 4231,
  "post_shape_compression_ratio": 0.42
}
```

Field notes:
- `manager_decision` ∈ `{"escalate", "handle_locally", "passthrough", "n/a"}`. `"n/a"` when manager mode is off.
- `pre_shape_tokens_saved` and `post_shape_compression_ratio` are `null` outside manager mode.
- `cost_usd` is computed from a pricing table embedded in the binary at build time. Refreshed per release. Unknown models record `null` and emit a tracing warning.
- `prompt_hash` is the sha256 of the normalized prompt (whitespace stripped, line endings normalized, model name lowercased, tool defs JSON-canonicalized) — enables cache lookup and dedup analytics without storing prompts on disk by default.

`--prompt-dump <dir>` flag opt-in dumps the full prompts and responses to disk for offline analysis (privacy-sensitive; off by default).

### 10.3 Surfaces

- `borai-spore stats` — cumulative cost, top-N skills by cost, top-N sessions by cost, cache hit %, manager-decision histogram (escalate vs handle-locally), pre-shape savings total, top-cost prompt hashes.
- `borai-spore stats --since <duration>` — windowed (e.g., `--since 7d`).
- `borai-spore stats --json` — machine-readable.
- `/usage` slash command in TUI — same data, current session only.

---

## 11. Serve mode (`spore-server` + `spore-client`)

### 11.1 Server

```
borai-spore serve \
    --bind 0.0.0.0:7474 \
    --token-file ~/.borai/serve.token
```

Token file format: one bearer token per line, with optional human-readable label after a space:

```
tok_abc123 laptop
tok_def456 ci-agent
tok_ghi789 webapp
```

Bind defaults to `127.0.0.1:7474`. Binding to non-loopback addresses requires `--token-file`; the binary exits with a clear error otherwise.

### 11.2 Endpoints

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/v1/sessions` | Create a session; response includes `session_id` |
| `POST` | `/v1/sessions/{id}/messages` | Submit a user message |
| `GET` | `/v1/sessions/{id}/events` | SSE stream of assistant events (token stream, tool calls, completion) |
| `GET` | `/v1/stats` | Telemetry aggregations for this server |
| `POST` | `/v1/chat/completions` | OpenAI-compatible passthrough — any OpenAI client works |

Auth: `Authorization: Bearer <token>` header. `tower-http` middleware checks tokens against the file at startup; reload via `SIGHUP`.

### 11.3 Client

The `spore-client` crate ships a typed Rust client wrapping the API. It also implements the `ModelClient` trait, so:

```rust
// In a downstream Spore's provider config:
providers:
  - kind: "spore_remote"
    endpoint: "https://machine-b:7474"
    token_env: "BORAI_REMOTE_TOKEN_MACHINE_B"
```

…makes another Spore behave as one of this Spore's model providers. This is the original ai-swarm-infra distributed-compute vision: Spore-on-laptop dispatches heavy work to Spore-on-server. Different from the original blueprint in shape (HTTP RPC, not raw Ollama API), same in spirit.

### 11.4 Rate limiting

v0.1 ships a per-token request-per-minute limit configurable in `~/.borai/settings.json`. Defaults: 60 rpm per token. Returns `429 Too Many Requests` when exceeded. No queuing; client retries.

---

## 12. Hooks, permissions, sessions, memory, config

### 12.1 Hooks

`spore-hooks` reads `~/.claude/settings.json` and project `.claude/settings.json` for hook definitions. Three event types in v0.1:

- `PreToolUse` — fires before a tool executes; non-zero exit blocks the call.
- `PostToolUse` — fires after a tool returns; receives result on stdin.
- `Stop` — fires when an assistant turn completes.

Hook command resolution and exit-code semantics match Claude Code's hook spec exactly. Drop-in compat.

### 12.2 Permissions

`spore-config` parses `permissions.allow`, `permissions.ask`, `permissions.deny` arrays from settings. `spore-agent::StockPermissionResolver`:

- `allow` matches → execute silently.
- `ask` matches OR no match → in TUI, prompt user [y/N/always]; in headless, fail with clear error unless `--dangerously-skip-permissions` set.
- `deny` matches → fail immediately.

Pattern matching mirrors Claude Code: `Tool(arg-glob)` syntax, e.g., `Bash(npm install:*)`.

### 12.3 Sessions

v0.1: JSON files at `~/.borai/sessions/<session_id>.json`. Each file holds the full conversation transcript, plus metadata: `created_at`, `updated_at`, `cwd`, `model`, `manager_mode`, `total_cost_usd`.

`borai-spore --resume <id>` reopens a session. `borai-spore --list-sessions` enumerates.

v0.2 ports to SQLite via `rusqlite` for query and pagination performance.

### 12.4 Memory

Same semantics as Claude Code's auto-memory:
- Project `MEMORY.md` (in CWD) — always-loaded, truncated at line 200 when injected.
- `~/.borai/projects/<cwd-hash>/memory/` — individual memory files, indexed by `MEMORY.md` pointers.
- Spore writes new memories to the project hash dir, updates `MEMORY.md` index.
- Memory types: `user`, `feedback`, `project`, `reference` (mirrors Claude Code's types).

### 12.5 Config hierarchy

Spore reads, in order, with later files overriding earlier:
1. `~/.claude/CLAUDE.md` (global)
2. `~/code/borai/CLAUDE.md` (workspace, after migration)
3. CWD `CLAUDE.md` (project)

Merge semantics differ by file type:
- **`CLAUDE.md` files** are concatenated in hierarchy order; the full text of all matching files is injected into the system prompt with simple `--- file: <path> ---` separators between files.
- **`settings.json` files** shallow-merge: top-level keys from later files override earlier; arrays and nested objects are replaced wholesale, not merged. The hierarchy is `~/.claude/settings.json` → workspace `borai/.claude/settings.json` → project `.claude/settings.json`.

---

## 13. Pivot artifacts (post-spec, see §14 for scene flow)

After this spec is committed, three classes of artifact are produced:

### 13.1 Superseded banners

Add to the top of each file:

**`~/code/ai-swarm-infra/docs/superpowers/specs/2026-04-24-orchestra-design.md`:**
> **Superseded 2026-04-27 by [BorAI Spore design](../../../../build-in-public/docs/superpowers/specs/2026-04-27-borai-spore-design.md).** Orchestra collapses into the `spore-orchestra` crate inside Spore. The HTTP shim role moves to `spore-server`. The bridge daemon disappears entirely (Spore is its own binary; no need to subprocess Claude Code).

**`~/code/build-in-public/docs/superpowers/specs/2026-04-22-borai-knowledge-graph-design.md`:**
> **2026-04-27 update:** Python implementation remains canonical for Spore v0.1 and v0.2. Spore v0.3 ports the retrieval engine to Rust as `crates/borai-graph` per the BorAI Spore design. The Python daemon stays as the v0.1/v0.2 backend (queried via HTTP shim added in v0.2).

**`~/code/ai-swarm-infra/swarm-architecture.md`:**
> **Superseded 2026-04-27.** The original three-node Python distributed-compute vision (Coder + Reviewer + Orchestrator) is superseded; cross-machine compute is realized in `agents/spore/crates/spore-server/` and `agents/spore/crates/spore-client/` per the [BorAI Spore design](../build-in-public/docs/superpowers/specs/2026-04-27-borai-spore-design.md). The spirit (Tasks-not-RAM streaming between machines) lives; the implementation differs.

### 13.2 New scene file

Create `~/code/build-in-public/campaigns/command-centre/chapters/02b-borai-platform/scenes/01-the-pivot.md` (or post-migration `~/code/borai/docs/campaigns/...`) capturing the BorAI shape pivot.

Scene frontmatter:
```yaml
---
campaign: "[[command-centre]]"
chapter: "02b-borai-platform"
scene: 1
title: "The Pivot — BorAI as a platform"
status: in-progress
date_opened: 2026-04-27
date_concluded:
characters: []
spec_file: "docs/superpowers/specs/2026-04-27-borai-spore-design.md"
blockers: []
supersedes: ["[[orchestra-design-2026-04-24]]", "[[swarm-architecture-2025]]"]
artifact_format: essay
artifact_file:
tags: [borai, spore, rust, platform-pivot, ollama, build-in-public]
---
```

The scene argues the thesis change: BorAI moves from "product company codebase" to "open platform for AI-augmented work" with Spore as its CLI face. Artifact = a build-in-public essay about the pivot.

### 13.3 Chapter setup

If `chapters/02b-borai-platform/chapter.md` does not exist, create it from `vault-template/templates/chapter-template.md`. Renumber existing chapter assignments if needed (the original 02a-systems-and-tools chapter currently lists future scenes that may shift).

---

## 14. Testing

### 14.1 Unit

Per crate. `pytest`-equivalent rigor — high coverage on pure functions (frontmatter parsing, vault parsing, telemetry aggregation, permission resolution, settings.json merge).

### 14.2 Integration

Live in `agents/spore/tests/`:

- **Mocked Anthropic provider.** Returns canned `stream-json` frames. Tests:
  1. `borai-spore -p "hello"` returns a non-empty completion.
  2. Skill loader registers fixture skills; `Skill` tool invocation returns body.
  3. Vault context block appears in system prompt when CWD is inside a fixture vault.
  4. Hooks fire in expected order; non-zero exit blocks tool call.
  5. Permission allowlist permits matching tools; deny pattern blocks; ask pattern in headless errors clearly.
- **Mocked Ollama provider.** Returns canned JSON-mode responses. Tests:
  6. Manager mode: user message → Ollama plans → `claude.deep_thought` tool emitted → mocked Anthropic responds → Ollama post-shapes → user receives integrated reply.
  7. Pre-shape and post-shape are both recorded in telemetry with non-null fields.
- **Serve mode contract.** Spin up `borai-spore serve` on ephemeral port; `spore-client` calls each endpoint; assert responses.
- **Cross-Spore RPC.** Serve A configured as provider in Serve B; B calls A; results integrate.

### 14.3 Fixtures

- `tests/fixtures/vault/` — minimal vault: 1 campaign, 1 chapter, 2 scenes, 1 character.
- `tests/fixtures/skills/` — 3 skills: a Claude-Code-shaped one, a native-extensions one, a plugin-namespaced one.
- `tests/fixtures/settings/` — settings.json with hooks, permissions, env overrides.

### 14.4 No live API in CI

Live-API tests run locally only via `cargo test --features live-api`.

---

## 15. Distribution + CI

### 15.1 Distribution

- **Primary:** GitHub Releases prebuilt binaries via `cargo-dist`. Targets:
  - `x86_64-unknown-linux-gnu`
  - `aarch64-unknown-linux-gnu`
  - `x86_64-apple-darwin`
  - `aarch64-apple-darwin`
- **Secondary:** `cargo install --git https://github.com/borai/borai borai-spore` (for users on uncommon arches).
- **Repo visibility:** private until v0.5; public OSS at v1.0 under Apache 2.0.
- **Windows:** v0.1 skips. Reconsider at v1.0 based on demand.

### 15.2 CI (GitHub Actions)

- `lint.yml` — `rustfmt --check`, `clippy --all-targets --all-features -D warnings`.
- `test.yml` — `cargo test --workspace` matrix on `ubuntu-latest` and `macos-latest`. Stable Rust only.
- `release.yml` — on tag push (`v*.*.*`), `cargo-dist` builds and publishes to GitHub Releases.
- No CodeQL or external scanners in v0.1 (private repo).

---

## 16. Definition of done — v0.1

The alpha closes when all ten are true.

1. `cargo install --path agents/spore/crates/borai-spore` from `~/code/borai/` produces a working binary.
2. `borai-spore` opens TUI; `borai-spore -p "..."` runs headless. `--output-format stream-json` matches Claude Code's frame shape.
3. Anthropic provider works end-to-end (real API, real streaming response, real tool use).
4. Skill loader registers skills from `~/.claude/skills/`, plugin tree, and project `.claude/skills/`. `Skill` tool invocation lazy-loads and returns body. Plugin namespaces parse correctly.
5. Vault parser correctly reads `vault-template/`. Scene context injected when session opened from inside a scene's CWD. `/scene new` and `/chapter list` work.
6. Hooks fire (`PreToolUse`, `PostToolUse`, `Stop`); permission allowlist enforced; sessions resume via `--resume <id>`.
7. `borai-spore --manager ollama:qwen3...` opens a session where Ollama is conversation manager. Ollama can invoke `claude.deep_thought` tool. Result integrates into reply.
8. Pre-shape and post-shape pipelines run on every Claude call in manager mode. Telemetry records `pre_shape_tokens_saved` and `post_shape_compression_ratio` for each call.
9. `borai-spore stats` outputs cumulative cost, top-cost skills, manager-decision histogram. `/usage` slash command shows session-scoped same data in TUI.
10. `borai-spore serve --bind 127.0.0.1:7474 --token-file <f>` accepts authenticated requests. `spore-client` from another machine on LAN reaches it AND can be configured as a provider in another Spore instance.

Six alpha users install and run a non-trivial session (read a file, edit it, run a hook) without Spore-side errors. At that point, v0.1 ships.

---

## 17. Open decisions deliberately deferred to the implementation plan

- Exact axum route handler signatures and error types (mechanical).
- `cargo-dist` configuration specifics — version pin, build profile, archive format.
- `tower-http` middleware stack ordering for serve mode (auth → CORS → trace → rate-limit, but exact order verified during implementation).
- Token file reload mechanism for `spore-server` — `SIGHUP` is the v0.1 plan; could change to inotify.
- TUI key bindings — Ctrl-C confirm dialog wording, slash-command popup width.
- Anthropic SDK shape — whether to use `anthropic-ai-sdk` crate (community), `clust` (community), or roll our own thin client. Probably roll our own for control + small surface; revisit if maintenance cost climbs.
- Ollama tool-calling format — whether to use Ollama's native tool-call JSON or a custom JSON-schema convention. Verified during implementation against the model picked for manager mode (`qwen3.6:35b-a3b-coding-q4_K_M` does support tool calls).
- Exact `prompt_hash` normalization rules — strip whitespace, normalize line endings, lowercase model names, stable JSON serialization for tool defs.
- Color theme defaults for TUI (using `colored` crate).
- Whether `--manager` accepts a config file path for the pre/post-shape system prompts (probably yes from v0.1 — externalize the prompts so users can tune without recompiling).

These are intentionally deferred because they are local execution decisions, not architectural ones.

---

## 18. Scene integration (build-in-public)

This spec opens a new chapter in the command-centre campaign: **`02b-borai-platform`**. Scene 01 (`01-the-pivot`) captures the architectural pivot itself. Subsequent scenes (drafted, not yet written):

- 02 — Phase 0 migration (move four sibling repos into `~/code/borai/`)
- 03 — Spore scaffolding (cargo workspace + 14 crates)
- 04 — The Anthropic provider (first real API call from the binary)
- 05 — The skill loader (drop-in compat proven against existing `~/.claude/skills/`)
- 06 — Manager mode goes live (first time Ollama drives a conversation that escalates to Claude)
- 07 — Telemetry surfaces (first stats output showing pre-shape savings)
- 08 — Serve mode + cross-Spore RPC (first time another machine calls this Spore)
- 09 — Vault integration (first scene Spore writes for itself)
- 10 — Alpha launch (six users install and use)

Each scene gets its own Set Stage / Progress / Conclude; each Conclude becomes a build-in-public artifact (essay, thread, or video). Chapter arc concludes when v0.1 ships to the six alpha users.
