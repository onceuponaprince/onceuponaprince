# Grok — raw dump 2026-04-27 (xvfb retry)

**Routing role:** Contrarian read, recency bias on 2026 X discourse on routing primitives and rollbacks.
**Tool:** `ask-grok-cli` via xvfb-run (display unblocked 2026-04-27)
**Brief:** Episode 2 - The router we cannot yet build. See ../episodes/02-the-router-we-cannot-yet-build.md.
**Pre-flight:** wiped .claude/.swarm-memory.json; em-dashes pre-sanitised; xvfb-run wrapping for display server.

**STATUS: EXTRACTION STILL FAILED (xvfb retry).** Same root error after xvfb-run wrapper. Chromium exits cleanly before websocket; empty BrowserStderr. xvfb is no longer the bottleneck; the chromiumoxide-Chromium handshake itself is broken.

**Two likely fixes** (either should resolve the empty-stderr clean-exit failure mode):

1. **Allow multiple Chrome instances** — pass `--user-data-dir=/tmp/chrome-<pid>` per invocation in chromiumoxide BrowserConfig. The current default single-profile-dir gets locked between calls, causing the second-and-subsequent launches to silently fail when an earlier process holds the lock.
2. **Explicit headless-new mode** — `.with_head(false)` plus `--headless=new`, `--no-sandbox`, `--disable-gpu`, `--disable-dev-shm-usage`. Required in containerised / no-display environments.

Patch lives in `~/code/ghostroute/ask-grok-cli/src/main.rs` (and the sibling `ask-perplexity-cli/src/main.rs`). Out of scope for Episode 2.

---

## Addendum diagnosis — 2026-04-27 evening (re-fire after Perplexity unblock)

**STATUS: EXTRACTION STILL FAILED, but for a different reason than originally diagnosed.**

Two re-fires under `xvfb-run -a -s "-screen 0 1920x1080x24"`:

1. `ask-grok-cli --prompt "$(cat /tmp/ep2-grok-prompt.txt)"` (default headless=true)
2. `ask-grok-cli --headless false --prompt ...` (forced headless=false under xvfb)

Both reached this point and stopped:

```
[Equipping Mecha Suit] Launching Chromium (via chromiumoxide)...
[Infiltrating] Injecting cookies...
[Infiltrating] Cookies injected successfully.
[Nav State] url=https://grok.com/ title="Grok"
[Timing] After navigation: 6902ms (run 1) / 3840ms (run 2)
[Scouting Perimeter] Grok homepage loaded. Scanning for input field...
[Engaging] Engaging Drunk-Typist protocol...
[Timing] Input located: 8826ms (run 1) / 4855ms (run 2)
```

Then **silence for 30+ minutes**. Process never exits on its own; never emits another log line; never writes to stderr.

The earlier sessions' diagnosis (chromiumoxide clean-exit, no websocket) is **not** the failure mode in this environment. Chromiumoxide launches cleanly. Cookie injection works. Navigation works. Input field is located. The hang is **after** input-located — at the Drunk-Typist paste step or the response-watch loop.

Companion symptom: when `.claude/.swarm-memory.json` is non-empty, Grok produces an explicit `Failed to paste previous context into input field: Key not found: ≥` and exits cleanly. Wiping `swarm-memory.json` removes that error but does not unblock the hang. The hang and the Unicode error are different bugs in the same paste path.

**Likely root cause:** Grok's web UI changed between the Episode 1 (working) and Episode 2 (failing) sessions. Either the input-field DOM hierarchy changed (so the synthetic paste targets a stale node), or the response-container selector no longer matches (so the CLI waits forever for output that has rendered but not in the expected place). The Ep1 dump explicitly notes a structural-selector fix applied to `RESPONSE_SELECTOR` in `src/config/mod.rs`. The same kind of fix is now likely required for the input-field selector in the Drunk-Typist module.

**Fix is upstream in `~/code/ghostroute/ask-grok-cli/`:** specifically `src/automation/` (Drunk-Typist module) and `src/config/mod.rs` (selectors). Not in the vault. Not in the campaign. **Escalated to user.**

The verdict's load-bearing work survives the Grok absence — Cursor's Reddit/GitHub coverage from the original round partially fills the contrarian-X gap (LangGraphJS #779, OpenAI Agents SDK #2216 / #617 / #771, RouteLLM LiteLLM regression #25629). The contrarian-X discourse remains the only un-closed source in Episode 2's manifest.

---


      _____           _      ___  ___  _ 
     |  __ \         | |     |  \/  | | |
     | |  \/_ __ ___ | | __  | .  . | | |
     | | __| '__/ _ \| |/ /  | |\/| | | |
     | |_\ \ | | (_) |   <   | |  | | |_|
      \____/_|  \___/|_|\_\  \_|  |_/ (_)
    
[System] Initiating stealth sequence...
[Status] Booting Chromium engine...
[System] Calibrating GPS coordinates...
[System] Loading save state from: /home/onceuponaprince/code/build-in-public/.claude/.swarm-memory.json
[System] No existing save file found. Starting with a fresh slate.
[Mana Bar] Input Cost: 920 Mana (Tokens)
[DIAGNOSTIC] args.headless = true
[Equipping Mecha Suit] Launching Chromium (via chromiumoxide)...
[Infiltrating] Injecting cookies...
Error: Failed to launch Chromium via chromiumoxide

Caused by:
    Browser process exited with status ExitStatus(unix_wait_status(0)) before websocket URL could be resolved, stderr: BrowserStderr("")
