# fast-travel-cli — design (first-run scope)

**Date:** 2026-04-23
**Status:** approved, pre-implementation
**Scope:** First round-trip — read cookies, launch headless Chrome via `chromiumoxide`, navigate to one Gemini conversation URL, extract the conversation to markdown, emit to stdout. Deferred: message-range selection, output format flags, visible browser mode, installed-binary packaging, threading, MCP integration, typed errors, tests.
**Drives:** scene [[02-reaching-past-claude]] — fast-travel-cli's half of the scene's remaining commitments.

---

## Context

`fast-travel-cli` is the Gemini sibling to `ask-grok-cli`. Both belong to the context-hygiene layer scene 2a-02 installs: a side-LLM's conversation becomes useful to Claude only if it can enter a Claude session without blowing its context budget.

`ask-grok-cli` (inside `ghostroute/ask-grok-cli/`) is the direct reference — a Rust CLI that boots Chromium via `chromiumoxide`, injects cookies from a global config directory, types a prompt, reads the response, prints to stdout. `fast-travel-cli` inverts the read direction: instead of *typing a prompt and reading the response*, it *reads an existing conversation the user had with Gemini in another tab*. The use case is carrying a Gemini research thread into Claude without pasting transcripts.

Gemini differs from Grok in ways that shape the design:

1. **Conversations are URL-addressable.** A Gemini conversation has the shape `https://gemini.google.com/app/<conversation-id>`. Grok has no equivalent — `ask-grok-cli` creates conversations fresh each run.
2. **No prompt typing.** `fast-travel-cli` doesn't need the drunk-typist protocol `ask-grok-cli` uses. It is a pure reader.
3. **Modes are irrelevant to first-run.** Gemini has modes (2.5 Flash, 2.5 Pro, Deep Research) but a conversation renders identically regardless of which mode produced it. Mode selection is a write-side concern; this is a read-side tool.

---

## Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Single-file `src/main.rs` for first-run.** Split into modules (`browser/`, `automation/`, `cli/`, `config/`) only when the file crosses ~400 lines. | `ask-grok-cli`'s module layout emerged over time; premature splitting is cost without benefit. |
| 2 | **Cookie path `~/.claude/cookie-configs/gemini.google.com-cookies.json`.** | Follows `ask-grok-cli`'s global convention. New side-LLMs drop into the layer without path-contract renegotiation. |
| 3 | **clap args: `--conversation-url <url>` required. No range flag for first-run.** Extract whole conversation. | Range extraction requires DOM message-boundary logic. Ship whole-conversation first; add range once selectors are stable. |
| 4 | **Output: markdown to stdout. No format flags.** `>` redirect for piping. | stdout is Unix-idiomatic; markdown is the format Claude handles cleanly. JSON and raw-HTML escape hatches come later. |
| 5 | **Headless Chromium, no `--visible` flag for first-run.** `BrowserConfig::builder().build()`. | Keep boot minimal. `--visible` is a debugging affordance to add if DOM extraction fails. |
| 6 | **DOM extraction via `page.evaluate` returning structured JSON.** Parse Gemini's conversation DOM into `{role, content}[]` in browser context, serialise to JSON, deserialise in Rust. | DOM traversal through CDP node lookups in Rust is painful; a single `page.evaluate` keeps the Rust side thin. |
| 7 | **Stateless — no memory, no `.swarm-memory.json`, no threading for first-run.** | `ask-grok-cli`'s memory is write-side. This is pure read. Stateless keeps scope contained. |
| 8 | **No typed errors, no `anyhow` beyond `Box<dyn Error>` for first-run.** | First-run is exploratory; error taxonomy emerges from real failure modes. Tighten after selectors stabilise. |

---

## Architecture (first-run)

```
fast-travel-cli/
├── Cargo.toml          (existing — deps already locked)
├── src/
│   └── main.rs         (grows 45 B → ~300–400 lines)
└── README.md           (written at first-run close)
```

### `main.rs` shape

```rust
use clap::Parser;
use chromiumoxide::{Browser, BrowserConfig};
use futures::StreamExt;
use serde::Deserialize;

#[derive(Parser)]
#[command(name = "fast-travel-cli", about = "Carry Gemini conversations into Claude")]
struct Args {
    /// Gemini conversation URL (e.g. https://gemini.google.com/app/<id>)
    #[arg(long)]
    conversation_url: String,
}

#[derive(Deserialize)]
struct Message {
    role: String,     // "user" | "model"
    content: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();

    let cookies = load_cookies()?;                              // step 2
    let (browser, mut handler) = Browser::launch(               // step 3
        BrowserConfig::builder().build()?
    ).await?;
    tokio::task::spawn(async move {
        while let Some(_) = handler.next().await {}
    });

    let page = browser.new_page("about:blank").await?;
    inject_cookies(&page, &cookies).await?;
    page.goto(&args.conversation_url).await?
        .wait_for_navigation().await?;

    wait_for_conversation(&page).await?;                        // step 4
    let messages: Vec<Message> = extract_conversation(&page).await?;  // step 5
    print_markdown(&messages);                                  // step 6

    browser.close().await?;
    Ok(())
}
```

### Cookie shape (inherited)

JSON array of cookie objects with `name`, `value`, `domain`, `path`, `secure`, `httpOnly`, `sameSite`, `expires`. Exported by `ghostroute/cookie-master-key/` — a Chrome extension whose `manifest.json` already grants `<all_urls>` and whose popup logic is hostname-agnostic. `gemini.google.com` is supported out of the box; the extension's README understated its scope and is corrected in the same vault pass as this spec.

### DOM extraction (Gemini-specific, to confirm during build)

Gemini renders conversation messages as alternating user / model nodes. Exact selectors need inspection against a real conversation. First-run approach:

1. `page.evaluate` queries the conversation container (selector to discover).
2. For each message node: extract `role` from data attribute or class; `content` from `innerText` (or richer traversal if code blocks need to survive).
3. Return `{messages: [{role, content}, ...]}` as JSON; deserialise in Rust.

If Gemini uses virtualised rendering, may need to scroll to force full render. Address only if first-run observation shows truncation.

### Markdown output

```markdown
## User

<first user message>

## Model

<first model response>

## User

...
```

No frontmatter, no citations, no mode annotations for first-run. Clean role-prefixed markdown. Claude parses this cleanly.

---

## First-run build sequence

Ordered, commit-per-step. Each step leaves `main.rs` compilable.

1. **clap scaffold.** `Args` struct, `#[tokio::main]`, prints parsed URL. Commit: `feat: scaffold clap args`.
2. **Cookie loader.** Reads `~/.claude/cookie-configs/gemini.google.com-cookies.json`, deserialises to `Vec<Cookie>`. Fails loudly if the file is missing. Commit: `feat: load cookies from global config dir`.
3. **Chromium launch + cookie injection.** Launches headless Chrome, injects cookies, navigates to `args.conversation_url`, closes cleanly. No extraction yet. Manual verification: `page.evaluate("document.cookie")` confirms cookies carried through. Commit: `feat: launch headless chromium with injected cookies`.
4. **Conversation wait.** Polling or explicit selector wait until the conversation DOM is present. Commit: `feat: wait for conversation render`.
5. **Conversation extraction.** `page.evaluate` extracts messages, returns JSON, Rust deserialises to `Vec<Message>`. Commit: `feat: extract conversation via page.evaluate`.
6. **Markdown rendering.** Iterate messages, print to stdout with role headers. Commit: `feat: render conversation as markdown`.
7. **README.** Minimal — name, purpose, installation, cookie setup (points at `ask-grok-cli`'s cookie section), example invocation. Commit: `docs: README for first-run`.

Scene 2a-02's fast-travel-cli close condition: step 6 produces markdown from a known Gemini conversation URL. Step 7 is the follow-through.

---

## Out of scope (first-run)

- Range selection (`--range <from>..<to>`)
- Output format flags (`--format json`, `--format html`)
- Visible browser mode (`--visible`)
- Memory / caching / `.swarm-memory.json`
- MCP integration
- Installed-binary packaging (`cargo install --path .`)
- Typed error taxonomy (`anyhow` / custom `Error` enum)
- Tests — first-run is exploratory

---

## Predicted stalls

1. **Cookie injection shape mismatch.** `chromiumoxide`'s cookie API may not accept the `cookie-master-key` JSON export verbatim — field name or type drift. Check before anything else. `ask-grok-cli`'s cookie loader is the reference implementation.
2. **Gemini DOM selector drift.** Gemini UI updates frequently. Selector stability is not guaranteed; expect iteration. Keep selectors in one place (the `page.evaluate` string) so updates are a single edit.
3. **Auth redirect loop.** Stale or incomplete cookies will redirect to Google auth. Surface as an error rather than hang — `wait_for_conversation` times out with a legible message.
4. **Virtualised rendering.** If Gemini lazily renders older messages, extraction will truncate silently. Detect by comparing message count against a scroll-to-top baseline. Address only if observed.

---

## References

- `~/code/ghostroute/ask-grok-cli/` — direct Rust reference. Cookie loading, `chromiumoxide` launch, `page.evaluate` usage.
- `~/code/ghostroute/cookie-master-key/` — Chrome extension producing the cookie JSON shape. Hostname-agnostic; works for Gemini with no extension changes.
- `~/code/ghostroute/docs/superpowers/specs/2026-04-23-perplexity-scraper-design.md` — sibling provider's design spec; structure mirrored here.
- Scene [[02-reaching-past-claude]] — the vault scene this spec drives.

---

## Phase 2 — Conversation search & filter (added 2026-04-27)

**Status:** approved-in-design, pre-implementation. Ships after Phase 1 (Gemini extraction) lands.

**Scope:** Search and filter past conversations across **Perplexity**, **Claude.ai**, and **Grok** (Gemini joins via Phase 1's existing extractor). Each provider has its own ingestion path; all feed into one unified SQLite + FTS5 index. The CLI gains `index`, `search`, and `show` subcommands.

**Drives:** the *jump-back* primitive — go from "I remember asking about X somewhere" to the original conversation in seconds, regardless of which side-LLM held it.

### Decisions (continuing the table)

| # | Decision | Rationale |
|---|----------|-----------|
| 9 | **Per-provider ingestion, unified SQLite index at `~/.claude/fast-travel/index.db`.** | Three providers, three access patterns. Pretending they're the same is a leaky abstraction. One index makes search uniform; per-provider code keeps ingestion honest. |
| 10 | **SQLite + FTS5 for full-text search.** | Single binary dependency, sub-second search at solo-founder volumes, no infrastructure. FTS5's BM25 ranking is good enough out of the box. |
| 11 | **Ingestion is manual via subcommand.** `fast-travel index --provider <perplexity\|claude\|grok\|all>`. | Background daemons add ops surface for marginal benefit. The user runs it when they want fresh state, or once a day via cron. |
| 12 | **Cookies and credentials reuse `~/.claude/cookie-configs/`.** Same global config dir as `ask-grok-cli`, `ask-perplexity-cli`, and Phase 1. | One auth surface across the whole context-hygiene layer. |
| 13 | **Schema is provider-shaped but unified.** One `threads` table with `provider`, `thread_id`, `title`, `started_at`, `last_message_at`, `message_count`, `summary_json`, `url`. One `messages` table with `thread_id`, `role`, `content`, `position`, `at`. FTS5 virtual table over `messages.content` and `threads.title + summary_json`. | Asymmetric per-provider data normalises to common columns where possible; per-provider quirks land in the `summary_json` blob. |
| 14 | **No semantic search for v1.** Pure FTS5 (BM25) only. | Embedding pipelines add cost (model, indexing time, storage). Defer until BM25 visibly fails. Most "I asked about X somewhere" queries are keyword-matchable. |
| 15 | **Stateless query — index is the only state.** No query history, no cache, no recent-searches list. | The CLI is read-mostly; persistence is the index, queries are ephemeral. |

### Per-provider ingestion

**Perplexity.** Two paths, gated by flags:

1. *Default:* parse vault `research/*/sources/*-perplexity.md` files for `Thread ID:` headers (Ep1's perplexity dump proves this pattern). Fetch each thread by URL via `chromiumoxide`. Cheap to re-run; captures research-driven threads.
2. *`--full` flag:* log into perplexity.ai, scroll the threads sidebar, capture all thread URLs + titles, fetch each. Captures conversational and one-shot threads outside the vault.

**Grok.** Walk `~/code/*/.claude/.swarm-memory.json` (the campfire is git-root-scoped — one file per project). Each entry has prompt + response + timestamp. Schema mapping: `provider="grok"`, `thread_id=<git-root-hash>::<entry-index>`, `title=<first 60 chars of prompt>`, `url=null` (Grok threads are not URL-addressable). `show` for a Grok thread renders the cached prompt + response inline rather than navigating anywhere.

**Claude.ai.** Cookie-driven scrape of the conversation list page (canonical URL TBD during build — likely `claude.ai/conversations` or similar). No public API exists. Pattern: navigate, wait for the list to render, extract `{title, conversation_id, last_message_at}` per thread. Click-through fetches the full conversation. Most fragile of the three; expect periodic selector drift.

### CLI surface

```
fast-travel index --provider <perplexity|claude|grok|gemini|all> [--full]
  Re-ingest threads from the named provider into ~/.claude/fast-travel/index.db.
  Idempotent: existing thread IDs update in place; new ones append.

fast-travel search <query> [filter flags...]
  Full-text search over the unified index. Default: top 20 by ranking formula.
  Output: provider · title · last_message_at · snippet · URL (or "[grok local]").

fast-travel show <thread-id> [--full]
  Print the cached snippet of a thread by ID. --full triggers Phase 1-style
  extraction (Gemini / Perplexity / Claude); Grok renders from cache directly.
```

### Filter primitives (v1)

- `--provider <name>` — restrict to one provider
- `--since <timespec>` — `7d`, `2w`, `1m`, `2026-04-01`
- `--until <timespec>` — same syntax
- `--min-messages <n>` — only threads with N+ messages (filters out one-shot lookups)
- `--has-url` — restrict to threads with a real URL (excludes Grok)
- `--limit <n>` — override default 20

Deferred to v3: tag filtering (no tag schema yet), citation filtering, role-specific filters, vault-quote backref ("conversations I quoted from in vault scene X").

### Ranking formula

**Default:** `final_score = bm25_score * exp(-age_in_days / 90)` — BM25 multiplied by exponential recency decay with a 90-day characteristic constant. A 180-day-old result needs roughly 2.7× the BM25 score of a 90-day-old result to outrank it; a 90-day-old result needs roughly 2.7× a fresh result. Decay is gentle enough that *"I half-remember a thing from months ago"* queries still surface their answer; recent threads still rise without burying the rest.

The user can override via `--rank <bm25|recency|exp|hybrid>` flag at search time:

- `bm25` — pure BM25, recency ignored
- `recency` — newest-first, BM25 only as a tiebreaker
- `exp` — the default (90-day decay)
- `hybrid` — top-50 by BM25 then re-rank by recency (two-phase, similar to the BM25 + RRF pattern queued for borai-graph)


### Build sequence (Phase 2)

Ordered, commit-per-step. Each step leaves the CLI compilable and the previous functionality intact.

1. **Add subcommand routing.** `fast-travel index|search|show ...`. Stub each. Commit: `feat: add index/search/show subcommands`.
2. **SQLite schema + migrations.** Create `~/.claude/fast-travel/index.db` on first run. Schema version column. Commit: `feat: sqlite schema for unified threads + messages`.
3. **Perplexity ingestion (path 1 — vault scrape).** Parse vault `sources/*-perplexity.md` files for thread IDs, fetch each, store. Commit: `feat: perplexity ingestion via vault thread-IDs`.
4. **Grok ingestion (campfire parse).** Walk `~/code/*/.claude/.swarm-memory.json` files, normalise into the index. Commit: `feat: grok ingestion from swarm-memory campfires`.
5. **Claude.ai ingestion (list-page scrape).** CDP scrape of the conversation list. Commit: `feat: claude.ai ingestion via list-page scrape`.
6. **Search command with FTS5.** Full-text query, default ranking formula. Commit: `feat: full-text search with ranking`.
7. **Filter flags.** `--provider`, `--since`, `--until`, `--min-messages`, `--has-url`, `--limit`, `--rank`. Commit: `feat: filter and ranking flags for search`.
8. **Show subcommand.** `fast-travel show <thread-id>` returns cached snippet; `--full` invokes Phase 1 extraction. Commit: `feat: show subcommand with --full extraction`.
9. **README update.** Document the four-provider scope. Commit: `docs: README updated for phase 2`.
10. **Perplexity ingestion (path 2 — full).** Conversation list page scrape behind `--full` flag. Commit: `feat: perplexity full ingestion via list-page scrape`.

### Out of scope (Phase 2)

- Semantic search / embeddings
- Cross-provider thread linking ("this Perplexity thread led to that Claude thread")
- Tag / label schema
- Vault-quote backref search
- Cron / daemon mode
- MCP integration
- ChatGPT ingestion (separate spec when the `ask-chatgpt` skill is more settled)

### Predicted stalls (Phase 2)

1. **Claude.ai DOM drift.** The conversation list selector will break periodically. Same mitigation as Phase 1: keep the selector in one place; treat drift as expected, not exceptional.
2. **Cookie expiry across three providers simultaneously.** Each provider's cookies expire on its own schedule. A failed ingestion should report which provider's cookies failed, not bail silently.
3. **`.swarm-memory.json` format drift.** If `ask-grok-cli` changes its schema, the Grok ingestion breaks. Pin the parser to a schema version; ignore unknown fields; bump on breaking changes.
4. **Perplexity thread URL pattern change.** Currently `perplexity.ai/search/<id>`. If the URL pattern changes, vault-scraped thread IDs become unfetchable. Detect by HTTP 404 on a known-good ID; fall back to path 2 (`--full`).
5. **Index corruption.** SQLite is robust but power loss during WAL writes can corrupt FTS5. Provide `fast-travel reindex` to rebuild from canonical sources. Schema version bump triggers reindex automatically.
6. **`.swarm-memory.json` discovery cost.** Walking `~/code/*/.claude/.swarm-memory.json` is fast for a dozen projects but scales with the user's project count. Cache the file paths in the index; only re-scan on `index --full` or schema bump.

### References (Phase 2)

- `~/.claude/fast-travel/index.db` — the unified index location.
- `~/code/ghostroute/ask-perplexity-cli/` — reference for Perplexity HTTP / scrape paths.
- `~/code/<project>/.claude/.swarm-memory.json` (per git-root) — Grok ingestion source.
- `claude.ai/conversations` (canonical URL TBD during build) — Claude.ai ingestion target.
- `~/code/build-in-public/research/agent-architecture/sources/2026-04-23-perplexity.md` — example of the vault thread-ID extraction source for Perplexity path 1.
