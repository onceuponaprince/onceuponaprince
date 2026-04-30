# Ghostroute prior-art research — 2026-04-27

**Topic:** what existing Rust crates and patterns cover what we are building in
`ghostroute-browser` and the ghostroute CLI family (ask-perplexity-cli,
ask-grok-cli, fast-travel-cli)?

**Sources** (one Brief, three independent reads):
- **Gemini** (gemini-cli, HTTP) — `/tmp/research-gemini.md` (52 lines).
- **Perplexity** (ask-perplexity-cli, web-cited) — `/tmp/research-perplexity.json` (23K answer text + sources).
- **Grok** (ask-grok-cli, commentary) — `/tmp/research-grok.txt` (4K).

Confidence markers below: **★** = unanimous (3/3); **·** = 2/3 confirm.

---

## 1. Repos to evaluate (most-relevant first)

### ★ rquest — `github.com/0x676e67/rquest`
**Rust-native curl-impersonate / TLS fingerprint impersonation.** Pins
JA3, JA4, HTTP/2 fingerprints to specific Chrome/Safari/Edge versions
using BoringSSL. **The single most impactful library all three sources
recommend.** Direct path to the "real Chrome TLS fingerprint" gap behind
our Cloudflare problems — for endpoints that don't strictly require a
browser, `rquest` lets us bypass CF *without* chromiumoxide entirely,
which collapses S6 (browserd daemon) and parts of S8 (cookie handshake)
into a thinner library wrapper.

**Tradeoffs (per Grok):** fast, low cost, low complexity. Fails on JS
challenges + Turnstile (still need CDP fallback for those). Lifespan
~months as Cloudflare evolves. **Hybrid is the play**: `rquest` for
gate, CDP only for clearance harvesting.

### · chromiumoxide_stealth — `github.com/cloei/chromiumoxide_stealth`
Direct Rust analogue of `selenium-stealth` / `puppeteer-extra-stealth`,
targeting chromiumoxide specifically. Bundles the
`navigator.webdriver`/`languages`/`chrome` overrides, plus more we don't
have today (WebGL renderer spoofing, plugin object shapes,
permissions/notifications stubs). **Drop-in candidate to replace our
hand-rolled `STEALTH_INIT_SCRIPT`** in `ghostroute-browser/src/stealth.rs`.

### · chaser-oxide — `lib.rs/crates/chaser-oxide`
Newer (2026) family of hardened browser-automation crates around
chromiumoxide. Claims protocol-level detection reduction (strips `cdc_`
markers from CDP payloads, which puppeteer-stealth-evasions in JS can't
reach). Worth reading even if not adopted — informs what the
detection-side knows.

### · wreq + wreq-util — secondary network-impersonation track
Browser emulation templates targeting Chrome 136 etc. for anti-bot
evasion. Less mature than `rquest` per the Perplexity citations but
useful as a fallback. Reference: `roundproxies.com/blog/wreq-util/`.

### · reqwest-impersonate — `github.com/matthewransley/reqwest-impersonate`
Older, more experimental than `rquest` but the prior art that taught
the Rust ecosystem how Chrome-version-specific impersonation looks
inside a `reqwest`-shaped API. Skip in favour of `rquest`.

### · rookie — `github.com/thewh1teagle/rookie`
Cross-platform browser cookie extraction. Crucial: handles Windows
"App-Bound Encryption" (2024-2025 update) plus macOS Keychain and Linux
Secret Service. Solves the cookie-master-key gap where `cf_clearance`
isn't always exported.

### Cookie-decryption tools (single-source from Perplexity, verify)
- `github.com/Krptyk/chromeDekrpt` — direct Chrome SQLite cookie + master-key decryption.
- `github.com/lainalie/Chrome-Chromium-cookie-parser-and-decryptor` — newer Chromium cookie store handling.

Both are Python prior art; useful as reference implementations to port
patterns into Rust if `rookie` doesn't cover our cases.

### llm-chat-scraper-skill — `github.com/scrapeless-ai/llm-chat-scraper-skill`
**Closest prior art for multi-provider chat scraping** (ChatGPT, Gemini,
Perplexity, Grok). Python, not Rust. **Architectural reference** for
provider-adapter patterns and DOM abstraction, not a direct dependency
target.

### Single-source claims that didn't verify (skip)
- `dig2crawl` (Gemini only) — could not corroborate.
- `rama` at `pluvia-software/rama` (Gemini only) — likely hallucinated URL.
- Other Gemini suggestions returned no Perplexity/Grok corroboration.

Likely-hallucinated entries are flagged so they don't end up in code.

---

## 2. Techniques to investigate further

### TLS-layer Cloudflare bypass (no browser needed)
**Approach:** use `rquest` (or curl-impersonate via FFI) to issue HTTPS
requests that match real Chrome's JA3/JA4/HTTP2 frame ordering at the
network layer. For endpoints without aggressive JS-challenge
requirements, `cf_clearance` stops mattering because the request *looks*
like real Chrome at the protocol level.

**Lifespan:** months. Cloudflare evolves fingerprints; `rquest` is
maintained and tracks Chrome updates.

**Scope:** doesn't solve Turnstile interactive challenges. Still need CDP
fallback for that. Both Grok and Perplexity flag this directly — hybrid
architecture is the play.

### Profile warmup beyond `user_data_dir`
**Approach:** pre-seed cookies from a real Chrome profile (decrypt the
SQLite Cookies file with `rookie` + the master key from
keyring/Keychain), then `set_cookies` into the chromiumoxide session.
Combined with **JA3/JA4 pinning per profile** (configure `rquest` or a
chromiumoxide TLS subset to match the Chrome version that issued the
cookies).

**Lifespan:** longer than today's chromiumoxide-only profiles —
`cf_clearance` reuse improves dramatically because the request
fingerprint matches the issuance fingerprint.

### Multi-provider scrape orchestration
Existing tools (per Grok) use a combination of:
- **YAML-configured selector maps** (per-provider, version-tagged).
- **Recorded test fixtures** (snapshot DOM shapes per provider; replay
  tests so we catch drift in CI before runtime).
- **Profile registries** (separate `user_data_dir` per provider — which
  ghostroute-browser already does).
- **CDP event listeners for DOM drift detection** at runtime.

This is the structural answer to the "selector drift" pain (Gemini DOM
moved from `user-query`/`model-response` to `#chat-history` +
`<message-content>` mid-session). The S7 feature in feature-list.md
should adopt the YAML-selector-map + fixture-replay approach.

### Auto-selector discovery (state of the art is thin in Rust)
- Rust ecosystem: minimal direct prior art. Our heuristic
  (longest-run-of-similarly-shaped-siblings + role-marker scoring) is on
  par with what exists.
- LLM-assisted DOM inference (per Gemini's `dig2crawl` — unverified) is
  the path of least effort for high coverage, at the cost of one local
  Ollama call per discovery.

### `SingletonLock` symlink correctness
**Direct from Grok:** "Check symlink target PID + process existence
instead of `Path::exists()`." This is exactly the bug we hit in
`chrome_appears_running` — `.exists()` follows symlinks and returns
false when the dead-PID target is unresolvable. Fix is
`fs::symlink_metadata().is_ok()` or read the symlink and parse
`<host>-<pid>`, then check if the PID is alive.

---

## 3. Governance and risk

**Direct from Grok:**
- All five providers (OpenAI, Anthropic, Google, Perplexity, xAI)
  prohibit automated access / scraping of web UIs in their TOS. Focus is
  on authorised APIs. Bot/automation language is explicit.
- Perplexity has faced public scrutiny for aggressive crawling
  (Cloudflare called them out in 2024).
- Precedents: account ban waves, IP blocks, fingerprint evolution.
  Survivors use residential proxies, heavy human-like jitter, per-profile
  isolation, and hybrid non-browser fallbacks.
- **Authenticated sessions increase ban risk** if detected as non-human.
  Our human-behaviour helpers (jittered sleeps, drunk-typist, profile
  isolation) mitigate but don't eliminate.

This is worth recording explicitly in feature-list.md — these tools are
TOS-grey at minimum. Personal use with rate limits ≤ what a human user
would generate is the lowest-risk operating envelope.

---

## 4. Top 5 things to adopt or stop building

1. **Adopt `rquest`** for the network-layer Cloudflare bypass. Hybrid
   architecture: `rquest` for HTTP requests where possible, chromiumoxide
   only when JS execution is required. Collapses parts of S6 + S8.
2. **Adopt `rookie`** for cross-platform Chrome cookie extraction.
   Replaces hand-coded `cookie-master-key` extension dependency for the
   `cf_clearance` and other HttpOnly+Secure cases.
3. **Adopt `chromiumoxide_stealth`** in place of our hand-rolled
   `STEALTH_INIT_SCRIPT` — same shape, but more battle-tested overrides
   (WebGL, audio context, permissions stubs).
4. **Stop hand-writing per-provider selectors as code constants.** Move
   to a YAML/TOML profile registry with version tags + recorded DOM
   fixtures (the multi-provider orchestration pattern). This is the
   structural fix for selector drift; S7 in feature-list.md should
   inherit this approach.
5. **Fix the `SingletonLock` detection bug** —
   `fs::symlink_metadata().is_ok()` is the one-liner. Grok flagged this
   directly; we already saw it fail this session.

---

## Source files

- `/tmp/research-gemini.md` — Gemini (52 lines, some hallucinated repo URLs).
- `/tmp/research-perplexity.json` — Perplexity (23K, web-cited, `.answer` field).
- `/tmp/research-grok.txt` — Grok (4K, structured A-K answers).
- `/tmp/ghostroute-research-brief.md` — the canonical Brief sent to all three (4.6K, ASCII).
