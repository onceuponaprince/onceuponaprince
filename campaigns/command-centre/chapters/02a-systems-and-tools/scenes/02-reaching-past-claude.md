---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 02
title: "reaching-past-claude"
status: in-progress
date_opened: 2026-04-23
date_concluded: 
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: "docs/superpowers/specs/2026-04-23-fast-travel-cli-design.md"
blockers: []
supersedes: null
artifact_format: 
artifact_file: 
tags:
  - chapter-2a
  - scrapers
  - fast-travel-cli
  - ghostroute
  - gemini
  - grok
  - context-hygiene
---

# Scene 2a-02 — reaching-past-claude

*Chapter 2a — Systems and tools · Campaign: [[command-centre]]*

Two scrapers, one premise: side-LLM outputs are useful only if they can enter a Claude session without blowing its context budget. Build `fast-travel-cli` for Gemini, document `ghostroute` for Grok, treat both as members of the same infrastructure layer.

---

## Set the Stage

### How did we get here?

Scene 05 of Chapter 1 catalogued the delegate-agent routing work and flagged the Grok path as dead — the xAI credits that backed it were exhausted, and nothing in the delegate-agent chain could actually reach Grok anymore. Chapter 2a's original plan named a Scene 02 — *Grok scraper into delegate-agent* — to fix that. Since then the picture has shifted: `~/code/ghostroute/` was built outside the vault's capture rhythm (a Node/Express scraper that reuses a browser session via cookies stored in `grok.com-cookies.json`, fronting a small API that turns Grok into a programmatic surface). Grok is no longer the bottleneck. The bottleneck is Gemini.

The founder runs Gemini concurrently with Claude all day — it earns its place as a cross-check, a second opinion, a research companion. But Gemini conversations are silos. The only way to carry a Gemini insight into Claude today is to paste the whole transcript, which destroys the context budget Claude needs to stay useful. `~/code/fast-travel-cli/` is the deliberate response: a Rust CLI (chromiumoxide + clap) currently sitting at a 45-byte `main.rs`, ready to be built.

### Where are we going?

Two tools shipped as siblings of the same infrastructure layer:

1. **`fast-travel-cli` (Gemini, live build).** A Rust binary that authenticates to Gemini via reused browser session, navigates to a conversation by URL or ID, extracts a selected range or message, and emits markdown suitable for Claude. The design mirrors ghostroute's cookie-reuse pattern because Scene 05's lesson held: API-key paths die when credits die; session-reuse paths survive as long as the user can log in.

2. **`ghostroute` (Grok, retroactive documentation).** The scene records what ghostroute actually is, why it was built in Node rather than Rust, what the cookie-master-key subdirectory does, how the server is meant to be invoked, and the reasons behind the architectural choices that already exist in code. This is the scene giving ghostroute its scene — the beat it should have had when it was built.

The scene closes when `fast-travel-cli` can round-trip a specific Gemini conversation range to stdout and ghostroute's README reflects the documented architecture.

### State of the world (project context)

- **`~/code/fast-travel-cli/`** — Rust edition 2024. Dependencies declared and locked: `chromiumoxide 0.9.1`, `clap 4.6.1` (derive feature), `tokio 1.52.1`, `chrono 0.4.44`, `serde 1.0.228`, `serde_json 1.0.149`, `futures 0.3.32`. `src/main.rs` is 45 bytes — a scaffolded `fn main() { println!(...) }` placeholder. No other source files. No README. Git-initialised.

- **`~/code/ghostroute/`** — Node. Files: `composable-scraper.js`, `grok-reverse-api.js`, `grok-reverse-api-grok-main.js`, `search-scraper.js`, `server.js`, `grok.com-cookies.json`, `x.com-cookies.json`, `package.json`, `package-lock.json`, `README.md` (680 bytes — minimal), subdirectories `ask-grok-cli/`, `cookie-master-key/`, `docs/`, `.claude/`. The tool was built and used; documentation lags the code.

- **Chapter 02a slot reshuffle.** The chapter's original Scene 02 (*Grok scraper into delegate-agent*) becomes Scene 03 — the integration work, distinct from the scrapers-as-tools work happening here. Scene 03 (two-layer orchestration pattern) becomes 04. Scene 04+ (webapp MVP) becomes 05+. Chapter.md bullets updated in the same commit as this scene.

- **Delegate-agent remains untouched this scene.** Wiring either tool into delegate-agent routing is explicitly Scene 2a-03 work, not this scene's work. The scrapers ship as standalone CLI utilities first.

### State of the hero ([[solo-thesis-holder]])

Runs concurrent LLM sessions — Claude for building, a second model for cross-check, a third for web-grounded research. Universal pain: each model's history is a walled garden. The audience doesn't care which specific LLMs these scrapers target — they care whether the *pattern* (session-reuse cookie-based scraping that surfaces as a programmatic CLI) generalises to whichever side-model they run. The artifact earns its read by landing the pattern, not by selling fast-travel-cli or ghostroute as products.

### State of the protagonist ([[prince]])

Chose Rust for `fast-travel-cli` deliberately: a compiled binary for a background tool feels right in a way an npm-installed JS CLI does not. ghostroute's Node/JS origin is a historical fact, not a preference — it came from grok-reverse-api work that was already JS-shaped. The two-language split is honest: pick the language that fits the tool's centre of gravity, don't force uniformity.

Knows ghostroute well enough to document it accurately. Does not yet know chromiumoxide's API well enough to predict where `fast-travel-cli` will stall. Expect the first stall to be around cookie import / session persistence in headless Chrome — ghostroute's cookie-master-key pattern should inform the Rust implementation rather than be reinvented.

### This moment in relation to goals

Chapter 02a's stated rule: *infra precedes product*. The webapp climax (now Scene 2a-05+) cannot honestly open until the scraper layer exists as shippable tooling. Delegate-agent integration (Scene 2a-03) depends on these binaries existing first. This scene is the chapter honouring its own constraint.

Thesis-wise: a solo founder building their own context-hygiene layer — rather than waiting for a commercial cross-LLM integration that would serve institutional users first — is the chapter's arc in miniature.

### Why now?

- fast-travel-cli is in the "about to be built" state (scaffolded, deps chosen) — the cheapest moment to open the scene is before the first non-trivial commit.
- ghostroute is still fresh enough in the founder's memory to be documented accurately. Wait another month and the why-we-chose-this becomes guesswork.
- Gemini context is piling up *right now*, every day the tool doesn't exist.
- Scene 2a-01 (ai-swarm hello-world) hasn't concluded yet, but the two scenes are independent infrastructure — 02a's arc explicitly supports parallel scenes where dependencies allow. This scene doesn't touch ai-swarm.

---

## Progress the moment

### Goal for this session

- Perplexity scraper design and scaffold landed in ghostroute: design spec, Node provider implementation plan, vitest scaffold, `providers/perplexity/` directory, five HTML fixtures at `__fixtures__/`, typed error classes.
- Architectural fork named: fast modes (Auto / Pro / Reasoning) follow the askGrok browser-roundtrip pattern; Deep Research gets a job-shaped API via the `--deep` flag → jobID.
- Git worktree in place at `.worktrees/feature/perplexity-node-provider/` for subagent-driven execution of Plan 1.
- Commit boundary: eight commits on ghostroute `main`, 18:08–18:41, from design spec (`db6d39d`) through typed error classes (`35b399e`).
- fast-travel-cli first-run and ghostroute retroactive docs **deferred to a follow-on scene session.** Chapter 2a's *infra precedes product* rule still holds; the scene stays open until fast-travel-cli round-trips a Gemini URL and ghostroute's README reflects its architecture.

### Moment-by-moment capture

- [x] **2026-04-23 16:17 — Ghostroute absorbs Perplexity as a provider.** Session opened on ghostroute (`~/code/ghostroute/`) with *"let's start building a scraper for perplexity."* What the scene had framed as a two-tool layer (fast-travel-cli + ghostroute-as-Grok-scraper) reshapes at the ghostroute level: the repo is a monorepo that houses scrapers for every side-LLM. Grok is now its first provider; Perplexity its second. The layer is still two repos; ghostroute scales by provider, not by spawning new repos.
- [x] Architectural fork named early: Perplexity's modes split by response time. Auto / Pro / Reasoning return in ~10–60s (synchronous-friendly); **Deep Research** runs 3–8 minutes and streams progress. One HTTP shape cannot serve both. Fast modes follow ghostroute's existing askGrok pattern (open browser → wait → return string); deep research needs a job-shaped API.
- [x] Architecture choice: **A now, B later** — synchronous path first, async Deep Research as follow-on. End-state is a Rust CLI sibling to `ask-grok-cli`; Node provider ships first inside ghostroute's monorepo.
- [x] Timeouts: 3-min fast, 30-min deep research, 5-min no-progress trip. `--deep` flag spawns a job and returns a jobID.
- [x] Execution pattern: subagent-driven, deferred until Plan 1 ships. Project-local git worktree at `.worktrees/feature/perplexity-node-provider/`.
- [x] Five HTML fixtures captured with seed prompt *"who founded meta (formerly facebook)?"* at `providers/perplexity/__fixtures__/` — Auto×Web baseline, Pro×Web, plus three covering Pro-mode variants and Deep Research / Academic. Fixtures drive offline `parse.js` unit tests and freeze a known-good DOM so a broken test can distinguish *my code regressed* from *Perplexity shipped a UI change.*
- [x] Commits on ghostroute `main` (post-session, 18:08–18:41): `db6d39d` scraper design spec · `4c7b5a5` timeout bumps + spec deep jobID in Rust CLI · `7539062` Node provider implementation plan · `a07cc22` gitignore `.worktrees/` for feature-branch isolation · `abf10df` plan commands switched from pnpm to npm to match existing toolchain · `4520347` vitest + `providers/perplexity/` scaffold · `24d7633` gitkeep `__fixtures__` until Task 2 captures populate it · `35b399e` typed error classes.
- [x] **Goal block revised in-vault.** Original Goal (Option 2: fast-travel-cli first-run) was drafted before the 952dde93 session log was reviewed. On reviewing the log the block no longer matched reality — it named a tool the session had not touched. Rewritten in place to record what the Perplexity scraper session actually shipped; fast-travel-cli deferred as an explicit remaining commitment rather than a silent omission. The revision is itself a scene moment — Goal blocks that outlive the work they were written for are worth marking, not quietly overwriting.

### What's changing?

- The scene's title still reads *reaching-past-claude* and the two-repo shape holds — fast-travel-cli (Gemini, standalone Rust binary) and ghostroute (monorepo of providers). What changed is ghostroute's inside: Grok is no longer the repo's subject, it is its first provider. Perplexity is the second. Future side-LLMs slot in as `providers/<name>/` rather than spawning new repos. The premise — session-reuse cookie scraping as a context-hygiene layer — carries the shape without strain.
- Ghostroute is proving its shape as a **monorepo of providers**, not a single-tool repo. The 2026-04-22 *ghostroute monorepo setup spec* (`118a1ec`) is the organising pattern; Perplexity is its second provider landing on it. Future side-LLMs slot in as siblings rather than spawning new repos.
- Honest note on session timing. *Goal for this session* was drafted in the vault after the ghostroute session had already run — the session actually shipped Perplexity scaffold, not the fast-travel-cli first-run that Option 2 named. The vault is catching up to the work, not directing it. This is itself a chapter-2a pattern: infra-layer scenes that capture work already in flight in sibling repos.

---

## Pivot — 2026-04-23

**Trigger.** The ghostroute session that ran 16:17–18:41 (`952dde93-73f8-48c3-a204-5f8c218cd820`) shipped a Perplexity scraper — a third tool the scene's two-tool framing did not anticipate. Instead of fast-travel-cli (Gemini) starting its Rust build per the signed-off Option 2, the earlier work picked up a different side-LLM with different response-time characteristics (3–8 min Deep Research versus 10–60s fast modes). The vault arrived after the work, not before it.

**Old → New.**

- *Old:* Two tools, one premise — fast-travel-cli (Gemini, standalone Rust binary) and ghostroute (the Grok scraper).
- *New:* Two repos, N providers — fast-travel-cli remains standalone; ghostroute has crystallised as a monorepo that houses providers for every side-LLM. Grok is ghostroute's first provider; Perplexity is its second; the `providers/<name>/` directory, vitest scaffold, and fixture-driven parse tests are now the repo's organising shape rather than Grok-specific artefacts.

**Carries forward.**

- The premise holds exactly. *Side-LLM outputs are useful only if they can enter a Claude session without blowing its context budget* covers Perplexity as cleanly as it covered Gemini and Grok. The pivot is shape, not premise — a new scene is not required.
- The session-reuse-over-API-keys lesson holds. Every provider reuses browser cookies; none depends on paid API access that can be revoked.
- The language split holds. Node for provider libraries (scraping surfaces, fixture-driven parse tests); Rust for user-facing CLIs. Perplexity lands on both sides of that split over time — Node provider first, Rust CLI sibling to `ask-grok-cli` later, both inside ghostroute.
- The chapter 2a rule *infra precedes product* holds. The webapp climax still waits on this layer landing, and ghostroute's monorepo shape means future side-LLMs extend the layer without extending the scene list.

**Supersedes.**

- The *two scrapers, one premise* framing in Set Stage *Where are we going?*. The shape is now *two repos, N providers* — premise unchanged.
- The implicit reading of ghostroute as *the Grok scraper*. Ghostroute is the monorepo that absorbs side-LLMs; Grok is one provider among future siblings.
- The session goal as originally drafted (fast-travel-cli first-run). fast-travel-cli deferred to a follow-on scene session; Perplexity scaffold shipped inside ghostroute.
- Chapter 2a's scene bullet for Scene 02. Updated in the same vault pass as this pivot to read as fast-travel-cli + ghostroute-monorepo rather than two Grok-scoped tools.

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
