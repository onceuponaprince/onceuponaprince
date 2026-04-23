---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 02
title: "reaching-past-claude"
status: not-started
date_opened: 2026-04-23
date_concluded: 
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: null
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

*Fill at session open.*

- 

### Moment-by-moment capture

*Commits, decisions, surprises.*

- [ ] 

### What's changing?

*Reversals, pivots, new information.*

- 

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
