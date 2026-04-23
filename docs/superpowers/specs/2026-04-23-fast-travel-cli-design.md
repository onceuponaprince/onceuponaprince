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
