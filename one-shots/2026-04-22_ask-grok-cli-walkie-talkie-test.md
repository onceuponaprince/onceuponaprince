# ask-grok-cli — MCP Walkie-Talkie End-to-End Test

*Date: 2026-04-22*
*Tool: `ask-grok-cli` (Rust CLI, CDP via `chromiumoxide`)*
*Repo: `~/code/scraper/ask-grok-cli`*
*Objective: Prove the walkie-talkie protocol loops cleanly between Grok and Claude Code.*

## Verdict

The loop holds. Grok emits strict JSON. Claude reads the file. Grok continues and ships the piece. Protocol proven on two bounces.

## Test metadata

| Metric | Value |
| --- | --- |
| Bounces until completion | 2 |
| Input tokens across session | 1518 mana (cl100k_base) |
| Output tokens across session | 1792 mana |
| Total session mana | 3310 |
| Wall time (rough) | ~13 min |
| Browser mode | Headful Chromium (`--headless false`) |
| Binary | `target/debug/ask-grok-cli` |

## Walkie-talkie trace

### Bounce 1 — initial call

- **User → Grok**: task prompt with hard-locked "TURN 1 JSON ONLY" constraint.
- **Grok → Claude** (14 output mana, 42 chars):

  ```json
  {"tool": "read_file", "path": "README.md"}
  ```

- **Claude action**: read `/home/onceuponaprince/code/scraper/README.md`.

### Bounce 2 — context injection

- **User → Grok**: README contents (newlines collapsed to spaces) plus "if you need more files, request; else deliver".
- **Grok → User** (1778 output mana, 8647 chars, 34 paragraphs): full 7-tweet thread + article in one response.
- **No further file requests emitted.** Grok chose to work off README alone rather than dig into `src/main.rs`, `Cargo.toml`, etc.

## Thread (as produced by Grok, unedited)

**1/7**
ask-grok-cli turns your terminal into a stealth mecha-suit for Grok. Native Rust. chromiumoxide drives Chrome DevTools Protocol. It types prompts like a drunk typist with human delays and typo fixes. Solid.

**2/7**
Core trick is the MCP Walkie-Talkie. Grok outputs strict JSON like `{"tool": "read_file", "path": "README.md"}`. Claude intercepts it, fetches the file, and reruns the task with fresh context. This loop wrote the thread you read right now.

**3/7**
Stateful memory campfires live in `.claude/.swarm-memory.json` at Git root. tiktoken-rs with cl100k_base tracks the mana bar for tokens. Cookies load from `~/.claude/cookie-configs` so the CLI runs from anywhere. No session reset nonsense.

**4/7**
Drunk-Typist Protocol randomizes delays and corrects typos on the fly. chromiumoxide handles the browser session. Global inventory system pulls auth without per-project setup. Claude Code orchestration slots in via a skill file that routes JSON requests back through the loop.

**5/7**
Installation stays dead simple. Clone, `cargo install --path .`, add `~/.cargo/bin` to PATH. Drop grok cookies into the config dir. One command launches it: `ask-grok-cli --prompt "your task here"`. It boots Chromium, injects cookies, updates memory, types, waits for stable text, prints clean.

**6/7**
Architecture stacks Rust with tokio async, clap for parsing, serde for JSON. No API keys passed in prompts. Browser automation bypasses basic detection through native CDP. Memory reuse cuts repeat context waste. Token estimates keep you honest on cost.

**7/7**
Frameworks coin themselves in the fire. This one coins the walkie-talkie loop as the real bridge. What looks like a simple CLI hides a full sub-agent handshake. The tool that runs you just proved the handshake works. Koan: the suit fits only when both sides admit they need the other to see the file.

## Article (as produced by Grok, unedited)

ask-grok-cli is a native Rust CLI tool that bridges your terminal with X.com Grok. It uses chromiumoxide to speak Chrome DevTools Protocol directly. The result is a browser session that types prompts, manages memory, and talks back through a strict walkie-talkie protocol with Claude.

The tool registers as a sub-agent inside Claude Code setups. When Grok needs file content it outputs exact JSON. Claude reads the file and continues. This loop is not hidden. One tweet in the thread above openly admits the entire piece came through that handshake. Claude fetched README.md first. Then the task continued. The system works because both sides follow the rule: no guessing, only explicit file requests.

Core mechanics break down into four named pieces.

**Drunk-Typist Protocol** handles input. It sends keystrokes asynchronously with randomized delays that mimic human rhythm. Every so often it triggers a typo-correct sequence so the prompt lands clean but never robotic. chromiumoxide drives the whole browser interaction so detection layers see a real session.

**MCP Walkie-Talkie** is the communication layer. Grok outputs nothing but the JSON shape when it needs context. Claude intercepts, reads, and feeds the content back in the next prompt. This turns a stateless model into a stateful collaborator inside any project directory. The README spells the exact format so no one has to improvise.

**Stateful Memory Campfires** persist context. At the Git root the tool creates or updates `.claude/.swarm-memory.json`. Recent interactions stay scoped to the project. Next run reuses what matters. No more dumping the same setup into every new prompt.

**Mana Bar** tracks tokens with tiktoken-rs and the cl100k_base encoding. Input and output estimates appear so you know the burn rate before you commit. Global Inventory System loads authentication cookies from `~/.claude/cookie-configs`. One directory serves every terminal session. The CLI launches from any working directory and still carries valid auth.

Installation follows standard Rust flow. Clone the repo, cd into it, run `cargo install --path .`. Make sure `~/.cargo/bin` sits in your shell PATH. Configuration needs the cookie directory created once. Export cookies from a logged-in browser session on grok.com. Save at least one file that matches the `*-cookies.json` pattern into the directory. The tool scans and injects them automatically.

Usage stays minimal. One flag carries the prompt.

```bash
ask-grok-cli --prompt "Write a short haiku about Rust."
```

Under the hood it launches a Chromium session through chromiumoxide, injects the cookies, checks or creates the memory campfire, types the prompt character by character under Drunk-Typist rules, waits until the response text stabilizes, then prints the clean output.

Claude Code integration adds one skill file. Create `.claude/skills/ask_grok.md` with a short description that tells Claude to run the CLI and handle any JSON tool requests that come back. The skill file reminds that Grok has no direct file access so the walkie-talkie must stay active. Claude becomes the dispatcher. Grok becomes the specialized thinker that can request exact context without hallucinating paths.

The architecture stack lists cleanly. Language is Rust. Browser automation is chromiumoxide over native CDP. CLI parsing uses clap. Serialization uses serde and serde_json. Token counting uses tiktoken-rs. Async runtime is tokio. Everything compiles to a single binary with zero external service calls beyond the browser session itself.

No marketing layers sit on top. The tool does not claim to replace anything. It simply adds a reliable bridge. When Grok needs the contents of `Cargo.toml` or `src/main.rs` it asks once through JSON. Claude delivers. The loop continues until the task resolves. Register breaks happen naturally. Solid. The handshake holds.

Project memory reuse shows up most clearly on repeated tasks inside the same repo. First run builds the campfire. Later runs pull recent exchanges so Grok starts with grounded context instead of zero. Token estimates prevent surprise overruns when prompts grow long. Cookie management removes the friction of re-authenticating per shell.

Drunk-Typist details matter for anyone watching the browser window. Delays vary. Occasional backspace and retype sequences appear. The prompt still arrives complete. CDP commands keep the session alive and responsive. chromiumoxide exposes the exact control needed without layering extra abstractions that break on Chrome updates.

The walkie-talkie admits its own nature. This thread and the article exist because Grok output a JSON read request, Claude supplied the README, and the generation continued. No file contents were guessed. The constraint was followed exactly on the first turn. That transparency is the point. Tools that hide their limits create brittle chains. Tools that declare the limit and route around it create robust ones.

Claude Code users add the skill once. From then on any task can route to Grok with full context fetch. The skill file stays short because the protocol stays strict. JSON in, file content out, no extra parsing games.

Rust choices keep the binary small and startup fast. tokio handles the async CDP streams. serde ensures the memory JSON never drifts. clap keeps flags obvious and extensible. The stack avoids runtime dependencies that complicate distribution.

Edge cases register clearly. No internet means no cookie refresh inside the tool. You export fresh cookies when they expire. Memory campfire lives only inside the Git root so separate projects stay isolated. Token counts use the same encoding Grok itself applies so estimates stay close.

The mecha-suit metaphor fits because the CLI is not the intelligence. It is the interface layer that lets Grok wear the terminal and reach into your files through Claude. The suit moves only when both pilots coordinate. One requests. The other fetches. The loop closes.

Framework coinage stops here. The walkie-talkie already names the pattern. Future extensions can add more JSON tools without changing the core handshake. Claude stays the manager. Grok stays the sub-agent that asks cleanly for what it needs.

This setup scales to real work. Large refactors, research spikes, test generation, all gain from the memory campfire and precise file pulls. No need to paste entire directories into prompts. The tool pulls exactly the file Grok requests.

> The suit never walks alone. It only moves when the walkie-talkie crackles and the file arrives. Silence means nothing to fetch. Sound means the bridge is live. Listen for the JSON. That is the entire protocol.

## Voice compliance notes (drift flags)

What Grok got right and where it drifted from the Prince voice profile. Useful for a corrective re-run if this ships to Twitter/Medium.

| Rule | Status | Notes |
| --- | --- | --- |
| Zero em-dashes | ✅ | None detected in thread or article. |
| "I" register | ⚠️ drift | Grok wrote in descriptive/third-person ("ask-grok-cli turns your terminal"). Prince voice needs "I built a stealth mecha-suit...". Full rewrite of openings needed. |
| Thesis-first tweet 1 | ⚠️ drift | Tweet 1 opens with a description, not a conclusion. A Prince-true opener would be "The CLI I just ran to generate this thread asked me, through Claude, for one file. That is the whole handshake." |
| Original framework coinage | ⚠️ drift | Grok only echoed existing names (walkie-talkie, Drunk-Typist). No new coinage. Prince would have named "Context-Yielding Recursion" or similar. |
| Register breaks | ✅ | "Solid." lands in tweet 1. "No session reset nonsense" in tweet 3 is close. |
| Named specifics | ✅ | chromiumoxide, tiktoken-rs, cl100k_base, CDP, clap, serde, tokio, `.swarm-memory.json`, `~/.claude/cookie-configs` all named. |
| Koan close | ✅ / ⚠️ | Thread and article both have koans, and they differ (as requested). The thread koan is labelled "Koan:" on the nose, which is cute but Prince would drop the label. |
| Meta-recursion admitted | ✅ | Tweet 2: "This loop wrote the thread you read right now." Article paragraph confirms the same. Mission accomplished. |
| 280-char tweet limit | ⚠️ | Tweets 5 and 7 exceed 280 chars when measured strictly. Would need trimming before posting. |
| No marketing vocab | ✅ | No leverage/unlock/synergy/paradigm. |
| No hedging | ✅ | Declarative throughout. |
| No emoji | ✅ | None. |
| No CTA-first | ✅ | No "check this out" opener. |
| Sentence-length variance | ⚠️ mild drift | Grok clusters around 8-15 word sentences. Prince's rhythm swings wider (3-word punches next to 30-word extensions). |

**Summary:** content and structure are on-target. Voice is 70% there. Before shipping to Twitter this needs a human pass to swap third-person descriptions into "I" openings and trim tweets 5 and 7 under 280 chars.

## Rough edges surfaced during the test (tool-level bugs)

The test incidentally found three real bugs in `ask-grok-cli`. All three got patched in this session (uncommitted):

1. **Stale debug binary silently throws an old error string** (`Missing grok.com-cookies.json! Did you export them?`) that no longer exists in the current source. Had to `cargo build` first. Non-fix, just a "rebuild before reporting cookie errors" gotcha.
2. **`human_type_with_typos` and the context paste both route through CDP's single-char keymap**, which has no entry for `\n`. Typing any string containing a literal newline throws `Key not found: `. Patched at `src/automation/typing.rs` and `src/main.rs:234-241` to substitute `\n`/`\r`/`\t` with a space before typing. The semantic cost is small: Grok reads flattened prose instead of multi-line prose. The alternative (press Enter for newline) would submit the message prematurely, so substitution is correct.
3. **`RESPONSE_TIMEOUT_MS = 45_000` is too tight** when the response is long-form. Grok's thread + article stream took ~75 seconds from first visible text to stable, well over 45s. Bumped to `240_000` at `src/config/mod.rs:2`. Worth promoting to a CLI flag (`--response-timeout-ms`) rather than a hardcoded constant.

The test also incidentally demonstrated why the Drunk-Typist is expensive on long prompts: ~90ms average delay per char plus 5% typo retries means a 2000-char prompt takes 3+ minutes just to type. For programmatic use where "human-like pacing" doesn't matter, a `--fast` flag that skips the Drunk-Typist would cut the feedback loop by an order of magnitude.

## What changed on disk this session (uncommitted)

- `src/config/mod.rs` — `RESPONSE_TIMEOUT_MS`: 45_000 → 240_000
- `src/automation/typing.rs` — newline/tab/CR normalisation in `human_type_with_typos`
- `src/main.rs` — newline/tab/CR normalisation in context paste block
- `.claude/.swarm-memory.json` — populated with the two session turns (2 entries, 3310 mana)

None of these were committed. Keep, fold into a `fix(typing): normalise whitespace for CDP keymap` commit, or revert — that's the next decision.
