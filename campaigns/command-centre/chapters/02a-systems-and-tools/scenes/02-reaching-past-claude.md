---
campaign: "[[command-centre]]"
chapter: "02a-systems-and-tools"
scene: 02
title: "reaching-past-claude"
status: concluded
date_opened: 2026-04-23
date_concluded: 2026-04-24
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
spec_file: "docs/superpowers/specs/2026-04-23-fast-travel-cli-design.md"
blockers: []
supersedes: null
artifacts:
  - format: thread
    file: "[[02-reaching-past-claude-thread]]"
  - format: essay
    file: "[[02-reaching-past-claude-essay]]"
  - format: newsletter
    file: "[[02-reaching-past-claude-newsletter]]"
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
- [x] **2026-04-24 — fast-travel-cli triage on entry.** Picked up the deferred fast-travel-cli commitment. Worktree setup needed a .gitignore commit first (`.worktrees/` not ignored on `master`) and the scaffold files (Cargo.toml, Cargo.lock, src/main.rs) were untracked — committed as `b6a8b60 chore: initial scaffold + ignore .claude session state`. Worktree at `.worktrees/feature/first-run/` on branch `feature/first-run`, master plus gitignore preludes on main. Cookie file at `~/.claude/cookie-configs/gemini.google.com-cookies.json` inspected: exists but holds 4 analytics cookies (`_gcl_au`, `_ga`, `_ga_BF8Q35BMLM`, and one more), all scoped to `.gemini.google.com`. No session cookies (`SID`, `SSID`, `__Secure-*`), no `.google.com` / `accounts.google.com` scope. Predicted-stall #3 from the design spec (auth redirect loop) surfaced at setup rather than at spec step 3. Founder picked *proceed and let the redirect loop confirm empirically*; cookie fix will land as a named in-scene beat when it trips.
- [x] **Scaffold state didn't match Set Stage claim.** Set Stage described `src/main.rs` as 45 bytes — a `fn main() { println!(...) }` placeholder. Reality on disk: 421 lines, 11 compile errors, multi-provider scaffolding (Provider enum: Chatgpt/Claude/Gemini/Generic), clap subcommands (Sync/Extract/Search), a local index system (`LoreIndex`, `update_master_index`, `search_index`, `save_lore_compendium`), and dead code from a merged-two-implementations pattern at lines 387–421. Context: **Claude usage had run out in the prior session; the existing code was built with Gemini.** If the code reads poorly — missing struct definitions, API-shape errors against chromiumoxide 0.9 (`set_cookie` singular instead of `set_cookies` plural, `CookieParam::new` field mutation that doesn't match the actual type), unreachable dead code after a returning match, inconsistent `.value` vs `.value()` calls against the same type — that's a reflection of Gemini's code quality on a Rust + chromiumoxide surface, not an architectural choice. Founder chose *fix, don't revert*: preserve what's worth keeping (Gemini-specific DOM selectors `user-query, model-response, .user-query-content, .model-response-text`, hydration-wait pattern) and strip what's out of first-run scope (Provider enum, subcommands, index system, dead code).
- [x] **First-run implementation shipped — single commit, empirical stall at step 6.** Founder revised commit cadence mid-reshape: keep `chrono`, `colored`, `rand` (treated as earned rather than stripped), don't defer any work to later commits, commit all now. The reshape + browser launch + cookie injection + wait + extract + markdown + README landed together as `5cb562a feat: fast-travel-cli first-run — Gemini conversation → markdown` on `feature/first-run`, then merged as `22d58f3` into `master` via non-fast-forward. Net diff against the Gemini-written baseline: `4 files changed, 349 insertions(+), 378 deletions(-)` — more deleted than added, because the reshape stripped more Gemini noise than first-run needed to add. Empirical verification against the provided URL (`https://gemini.google.com/app/9053dffe78ffe1d4`): tool got past the early auth-redirect check (url stayed on `gemini.google.com`, didn't bounce to `accounts.google.com`) but timed out in `wait_for_conversation` — no conversation DOM found within 30 seconds. Two candidate diagnoses: (a) cookies accepted enough for the navigation but not enough for an authenticated conversation view, so Gemini rendered a signed-out landing UI that doesn't match the conversation selectors; or (b) Gemini shipped a UI update since the prior-session code captured those selectors, and the selectors have drifted. Can't distinguish from headless logs alone. The `--visible` flag — authorised mid-scene with a note when the first three clarifying rounds ran — is the next debug affordance. Worktree at `.worktrees/feature/first-run/` removed after merge; branch `feature/first-run` deleted. First-run *code* is landed on `master`; first-run *round-trip* (scene's close condition) is not.
- [x] **`--visible` + on-timeout diagnostics landed (`1d000e7`) and the stall is neither hypothesis.** Added `--visible` (launch Chromium `with_head`) and a `dump_diagnostics` helper that fires on timeout — dumps URL, title, selector counts, sign-in signal, top 15 custom-element tag names, and first 800 chars of `body.innerText`. First visible-mode run against the same URL surfaced the real cause in one dump. Not a signed-out Gemini UI. Not selector drift. The URL had been redirected to `https://consent.google.com/m?continue=https://gemini.google.com/app/9053dffe78ffe1d4&gl=GB&m=0&pc=bard&cm=2&hl=en-US&src=1` — Google's GDPR consent wall, title *"Before you continue"*, body rendering the full *"We use cookies and data to"* consent dialog. The `gl=GB` parameter names the cause: UK jurisdiction, so GDPR consent is gated on every fresh session. The 4 analytics cookies (`_gcl_au`, `_ga`, `_ga_BF8Q35BMLM`, + one more) were enough to avoid an `accounts.google.com` bounce but not enough to satisfy Google that a consent decision had been made. The early-redirect check I wrote caught only `accounts.google.com` / `/signin` / `/login` — `consent.google.com` is a different host and a different failure mode, and it slipped through silently until the diagnostics dump made it legible. Upstream cause: `cookie-master-key`'s export was pulling cookies for `.gemini.google.com` only. Google's consent cookies (`CONSENT`, `SOCS`) and session cookies (`SID`, `SSID`, `HSID`, `APISID`, `SAPISID`, `__Secure-*`) live on `.google.com` — a broader scope the extension isn't reaching. The extension's README claims hostname-agnostic `<all_urls>` support; the actual export contradicts that claim. Fixing this generalises: every future Google-property scraper (YouTube, Drive, Docs) would benefit from the same broader scope, not just Gemini.
- [x] **Cookie-master-key scope fixed upstream (`e78eab5` in ghostroute).** Root-cause inspection of `popup.js` found the bug on one line. `chrome.cookies.getAll({ domain: url.hostname })` only matches cookies whose domain is the queried hostname or its subdomains — it skips parent-domain cookies by design. That's why exporting from a `gemini.google.com` tab returned `.gemini.google.com` analytics only. The correct query is `chrome.cookies.getAll({ url: tab.url })`, which asks Chrome *"which cookies would be sent with a request to this URL?"* and returns every applicable cookie including parent-domain ones. One-line code change with a load-bearing comment explaining why `url` is not interchangeable with `domain`. README updated to stop implying hostname-scope export; it now says URL-scope and calls out that parent-domain cookies (consent + session) are included. The fix generalises — future scrapers for any Google property, or any site that splits session cookies across a parent domain, get the right export from one click without per-site manifest edits. The fast-travel-cli half of the scene is now blocked only on a re-export + re-run, not on further code changes.
- [x] **Round-trip confirmed — the scene's fast-travel-cli close condition is met.** Founder reloaded the extension and re-exported from an authenticated Gemini tab. New cookie file: 23 cookies across two domain scopes (4 on `.gemini.google.com`, 19 on `.google.com` — including the full session set `SID`, `SSID`, `HSID`, `APISID`, `SAPISID`, `__Secure-1PSID`, `__Secure-3PSID`, `__Secure-1PAPISID`, `__Secure-3PAPISID`, plus `SOCS` for consent state). Headless run against `https://gemini.google.com/app/9053dffe78ffe1d4` skipped the consent interstitial entirely and landed on the conversation view — *"Extracted 30 messages — rendering to stdout."* The conversation it round-tripped was recursive: the prior Gemini session that wrote the broken code this session opened by fixing. fast-travel-cli's first read was its own origin story. Two noise issues surfaced on inspection: (1) selector `'user-query, model-response, .user-query-content, .model-response-text'` matched each model turn twice — once as the outer custom element, once as the inner class — so 30 "messages" was really 15 turns with every model response duplicated; (2) Gemini's UI disclosure text (`You said`, `Show thinking`, `Gemini said`) was inlined into `innerText`, prefixing every message. `86fdfe2 fix: narrow extraction selectors + strip Gemini UI labels` addressed both — selector narrowed to `'user-query, model-response'` only, JS-side label strip filters leading UI-text lines before the content crosses the Rust boundary. Verified: output is now strict User/Model alternation, 20 messages (10 turns × 2 roles), H2 headers inside model responses preserved (literal markdown the model wrote), no prefix noise. fast-travel-cli's first-run is *shipped clean*, not *shipped almost-clean*. Scene's remaining commitment: ghostroute retroactive docs.
- [x] **Ghostroute retroactive documentation shipped (`9fecce8` in ghostroute).** Single atomic commit lands three files. `README.md` replaces the 680-byte stub with a ~4 KB entry: ghostroute framed as a context-hygiene layer (two directional shapes — prompt-and-return and pure-read — sharing the same cookie-reuse substrate), components section (Node scrapers, Rust CLIs, Chrome extension, design records), providers section (Grok shipped via HTTP endpoint + Rust CLI; Perplexity scaffolded on `feature/perplexity-node-provider` branch; future providers slot in as `providers/<name>/`), setup, usage examples for both surfaces, architecture overview with links to deep dives, conventions (cookies outside repo, design records under `docs/superpowers/`, worktrees for feature branches, atomic commits). `docs/architecture.md` — full deep dive on: context-hygiene layer as problem statement; Node vs Rust language split (honest not doctrinal — Node for scraper libraries because Playwright + stealth are mature there, Rust for user-facing CLIs because compiled binaries fit terminal tools); session-reuse over API keys with the Scene 1.05 xAI-credits-exhaustion lesson cited as origin; monorepo of providers per the 2026-04-22 design; Node file archaeology (which root `.js` files are current, earlier iterations, or standalone experiments — retained because each encodes a design attempt). `docs/server.md` — `server.js` deep dive: purpose as a thin HTTP shim, starting + port fallback behaviour (retries up to 10 ports on `EADDRINUSE`), `POST /ask-grok` contract (request/response shapes, HTTP codes, failure modes), Claude Code integration pattern (direct HTTP today, MCP planned), explicit non-scope (not a production service; no process manager, no structured logging), environment variable reference. Net: `3 files changed, 325 insertions(+), 10 deletions(-)`. Both scene commitments now met.

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

### How is now different from the start?

Two tools entered the scene as intent and left it as working code. Fast-travel-cli was a 45-byte placeholder that had quietly accumulated 421 lines of broken Gemini-written code in the background; it now round-trips any Gemini conversation URL to clean User/Model-alternating markdown on stdout. Ghostroute was a 680-byte README stub sitting on top of a functioning Node scraper, an unfinished Rust CLI sibling, and a misbehaving Chrome extension; it now has a main README that frames it as a context-hygiene layer, two deep-dive docs that land the architectural rationale, and — most consequentially — a cookie-export extension that reads what it was always supposed to read. The scene's close condition (fast-travel-cli round-trips a conversation; ghostroute's README reflects its architecture) is met on both sides.

### What are the consequences?

Claude Code sessions can now carry Gemini research threads without pasting transcripts. Scene 2a-04 (scrapers into delegate-agent) is no longer blocked on tooling existing — fast-travel-cli and ask-grok-cli are both shippable CLI utilities with stable interfaces, which was the integration prerequisite. Every future Google-property scraper (Drive, Docs, YouTube, future Gemini endpoints) inherits a cookie export that actually includes `.google.com` session cookies, so none of them will re-discover the consent-wall stall this scene surfaced. Ghostroute's monorepo-of-providers shape is no longer a private architectural intuition; it is written down and linkable. The webapp climax at chapter 2a's end sits one honest infra layer closer.

### What did we learn?

The session's first stall lived four words into a 66-line Chrome extension: `domain: url.hostname` where it should have been `url: tab.url`. That single call was silently filtering out every `.google.com` cookie — which is where Google keeps consent, session, and authentication state — and blocking every downstream Google-property scraper as an inevitable consequence. The lesson is upstream-leverage: when a stall at the tip of one tool points at shared infrastructure, the fix there has compounding value across every consumer of that infrastructure. Second lesson: Gemini writing Rust on a chromiumoxide surface produced 421 lines of broken multi-provider subcommand scaffolding when the brief was a single-provider read. The code reflected the tool's capability, not the architecture the prompt described. Building with a side-LLM when Claude credits run out is an honest trade, but the output needs fixing back toward the original spec — don't inherit its architecture, only its reverse-engineering. Third lesson: GDPR is a geo-aware failure mode. A UK user hits a consent wall a US user does not; headless-only first-run builds need explicit consent-state cookies to skip it, and diagnostics-on-timeout are what make the distinction legible. Fourth, quieter lesson: diagnostics earn their place fast when they exist. One `--visible` + on-timeout dump turned "headless times out, two hypotheses" into "consent.google.com interstitial, gl=GB" in a single run.

### Progress to thesis

Build should feel like play; play should write the story. This scene's work *is* the story — the recursive moment where fast-travel-cli round-tripped the very Gemini conversation that wrote the broken code this session opened by fixing is a narrative peak the method produced without being asked to. No separate write-up step, no retrofit of meaning. The act of playing wrote the beat.

### Progress to goal

Chapter 2a's stated rule — *infra precedes product* — held and did its work. The scraper layer now exists as shippable tooling. Scene 2a-04 (delegate-agent integration) is viable. Scene 2a-06+ (webapp MVP) remains gated on Scene 2a-03 (near-proximal-and-the-stream) and Scene 2a-04, but the scraper half of the infra is no longer on the critical path.

### Next scene

[[04-scrapers-into-delegate-agent]]. With ghostroute's `POST /ask-grok` endpoint and fast-travel-cli's markdown-to-stdout both stable, the integration work Scene 1.05 flagged as dead becomes viable. Scene 2a-03 (borai-graph edge refactor) continues running in parallel and does not block.

### Artifact format

Thread. The scene's arc — an opening that expected two tool-builds and discovered a four-word bug infecting shared scraper infrastructure — has a clean beat structure: (1) sat down to build fast-travel-cli, (2) discovered 421 lines of Gemini-written code already there, (3) fixed it past the auth check to find a consent wall, (4) traced the wall upstream to a four-word Chrome-extension bug, (5) shipped the fix and watched every future Google scraper inherit the unblocking, (6) the tool's first read was its own origin story. The recursive beat earns the final post.

---

## Notes

*Free space.*

- 2026-04-26 — repo-level polish opened as PRs against `main`, awaiting review. **fast-travel-cli:** seven polish PRs (#1–#7); first-run post-polish pending fresh cookie export — auth-state expiry between sessions, not a code regression (round-trip code unchanged from the in-scene `86fdfe2` commit). **ghostroute:** three docs PRs (#1–#3); the closure brief's "Perplexity scaffolded, undocumented" premise was outdated by the time this session opened, so the work filled surviving gaps only — provider contract + add-a-provider walkthrough in the repo README, plus per-provider READMEs for Grok and Perplexity. Branch protection on `main` honoured in both repos; no merges. Two GitHub repos created in-flight (`onceuponaprince/fast-travel-cli` and `onceuponaprince/ghostroute`, both private) — flagged because the brief did not pre-authorise repo creation.
- 2026-04-27 — fast-travel-cli round-trip re-verified post-session-pause against `https://gemini.google.com/app/9053dffe78ffe1d4` on `main` HEAD (`86fdfe2`): exit 0, `Extracted 20 messages — rendering to stdout`, 1198 lines of strict User/Model markdown. Cookie re-export landed clean. Two environmental stalls hit en route — stale `/tmp/chromiumoxide-runner/SingletonLock` and orphaned headless Chrome processes from the prior failed run — both resolved by pre-flight cleanup; saved as a project-scoped operational note. The seven polish PRs remain unmerged so this run does not strictly verify they don't regress, but none touches the extraction or rendering path. Repos flipped public so branch protection is now enforceable at the GitHub level on the free tier — not yet configured.
