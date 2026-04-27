# Handover — Perplexity source for Episode 2 (agent-architecture research thread)

**Status:** BLOCKED. Output file `2026-04-27-perplexity.md` was NOT written. The `ask-perplexity-cli` browser launch failed twice in a row before the subagent ran out of context budget.

**Date:** 2026-04-27
**Blocked subagent role:** Single-source Perplexity research subagent for Episode 2 of the living research thread at `~/code/build-in-public/research/agent-architecture/`.
**Target output path:** `/home/onceuponaprince/code/build-in-public/research/agent-architecture/sources/2026-04-27-perplexity.md`

---

## What Episode 2 is asking

**Claim under test (orient to it; don't test directly):**
> "A working task-feature classifier is buildable today by a solo founder — but the hard part is the feature engineering, not the model. The framework primitives are ready; the routing data is not."

**Episode 2 question:** Could a solo founder build a working task-feature classifier today — and if so, what does v0 cost?

**Prior episode:** Episode 1 named six candidate routing primitives (parallelisability, tool count, state coupling, expected context noise, single-agent baseline accuracy, task horizon — plus verifier availability). None has won. Episode 2 asks whether a v0 is buildable today.

**Routing role for Perplexity (this source):** Current practice 2024–2026 and production post-mortems. Less academic, more operational. Blog posts, GitHub issues, conference talks, post-mortems, engineering blogs. What teams actually shipped, what broke, what they migrated away from.

---

## The six sub-questions Perplexity must answer

1. **PREDICTIVE FEATURES** — Which task features are most predictive in production (parallelisability, tool count, state coupling, expected context noise, single-agent baseline accuracy, task horizon, verifier availability)? Empirical feature lists production teams have published.
2. **TRAINING DATA** — What labelled training data exists or can be cheaply generated for routing classifiers (benchmark traces SWE-bench/GAIA/AgentBench, execution logs, synthetic generation, human labelling, RLHF preference data)? Concrete dataset names, sizes, licenses.
3. **CLASSIFIER SHAPE** — Cheapest classifier that moves the needle (rules/heuristics, BERT-class encoders, fine-tuned LLM, learned policy/RL)? Production tradeoffs — latency, cost, maintenance burden.
4. **MEASUREMENT LOOP** — Validation (A/B, counterfactual replay, causal inference, offline eval). Smallest experiment to prove/disprove a v0.
5. **FAILURE MODES AND FALLBACKS** — Where does the classifier fail safely? Fallback when confidence low. Reports of routing layers causing more harm than good.
6. **COST OF V0** — Real solo-founder time/cost. When is routing NOT worth building (project size, traffic, task heterogeneity thresholds).

**Frameworks/tools to cover:** RouteLLM (LMSYS), MasRouter (ACL 2025), Anthropic Workflows + Claude Agent SDK subagent dispatch, OpenAI Agents SDK handoff filters + RunConfig, DSPy, recent production blog posts (Anthropic, OpenAI, LangChain, Cognition, Sourcegraph, Cursor, Replit, Vercel, smaller startups).

---

## The full prompt to send to Perplexity

This was already drafted and saved to `/tmp/perplexity-prompt.txt` (32 lines) but `/tmp` may not survive — reproduce it from this block:

```
CLAIM UNDER TEST (orient to it; do not test directly):
"A working task-feature classifier is buildable today by a solo founder — but the hard part is the feature engineering, not the model. The framework primitives are ready; the routing data is not."

EPISODE 2 QUESTION: Could a solo founder build a working task-feature classifier today — and if so, what does v0 cost?

PRIOR EPISODE 1 named six candidate routing primitives (parallelisability, tool count, state coupling, expected context noise, single-agent baseline accuracy, task horizon — plus verifier availability). None has won.

ROLE: CURRENT PRACTICE 2024–2026 and PRODUCTION POST-MORTEMS on routing layers in agent/LLM systems. Less academic, more operational. Citations to blog posts, GitHub issues, conference talks, post-mortems, engineering blogs — what teams actually SHIPPED, what BROKE, what they MIGRATED AWAY FROM.

ANSWER ALL SIX SUB-QUESTIONS WITH CITATIONS:

1. PREDICTIVE FEATURES — Which task features are most predictive in production (parallelisability, tool count, state coupling, expected context noise, single-agent baseline accuracy, task horizon, verifier availability)? Empirical feature lists production teams have published?

2. TRAINING DATA — What labelled training data exists or can be cheaply generated for routing classifiers (benchmark traces SWE-bench/GAIA/AgentBench, execution logs, synthetic generation, human labelling, RLHF preference data)? Concrete dataset names, sizes, licenses.

3. CLASSIFIER SHAPE — Cheapest classifier that moves the needle (rules/heuristics, BERT-class small encoders, fine-tuned LLM, learned policy/RL)? Production tradeoffs — latency, cost, maintenance burden.

4. MEASUREMENT LOOP — How are production teams validating routing decisions (A/B, counterfactual replay, causal inference, offline eval)? Smallest experiment that proves/disproves a v0 router?

5. FAILURE MODES AND FALLBACKS — Where does the classifier fail safely? Fallback when confidence low? Reports of routing causing more harm than good?

6. COST OF V0 — Real solo-founder time/cost to build v0 router. When is routing NOT worth building (project size, traffic, task heterogeneity thresholds)?

SPECIFIC FRAMEWORKS WITH PRODUCTION DETAIL:
- RouteLLM (LMSYS) — production deployments, post-mortems, cost figures
- MasRouter (ACL 2025) — production adoption signals
- Anthropic Workflows + Claude Agent SDK subagent dispatch
- OpenAI Agents SDK handoff filters + RunConfig — gotchas
- DSPy — production deployments of optimised pipelines, routing
- Recent 2024–2026 blog posts on building OR scrapping routing layers — Anthropic, OpenAI, LangChain, Cognition, Sourcegraph, Cursor, Replit, Vercel

Verbatim quotes and direct URLs where possible. Operational survey, not literature review.
```

---

## What was tried and what failed

**Attempt 1 (direct CLI):**
```bash
PROMPT="$(cat /tmp/perplexity-prompt.txt)"
ask-perplexity-cli "$PROMPT" > /tmp/perplexity-out.json 2> /tmp/perplexity-err.log
```
Exit 1. Stderr:
```
Error: Failed to launch Chromium via chromiumoxide

Caused by:
    Browser process exited with status ExitStatus(unix_wait_status(0)) before websocket URL could be resolved, stderr: BrowserStderr("")
```

**Attempt 2 (retry, per skill docs "first call may timeout at 60s; retry once succeeds"):**
Identical command. Identical failure.

**Environment probe:**
- `which ask-perplexity-cli` → `/home/onceuponaprince/.cargo/bin/ask-perplexity-cli` (v0.1.0, present)
- `DISPLAY=:0` is set
- No Xvfb running (`pgrep -a Xvfb` empty)
- `/tmp/.X11-unix/` is empty (no real X server socket)
- `xset q` returns keyboard info (suggests *some* X is reachable, but the socket dir is empty — odd)
- `xvfb-run` not installed
- Playwright browser cache exists at `~/.cache/ms-playwright/` (chromium-1217, firefox-1511, webkit-2272) — but `ask-perplexity-cli` uses `chromiumoxide`, which has its own browser lookup path

**Diagnosis (unverified theory — flag for the next agent):**
Chromium is exiting cleanly (exit status 0) before the WebSocket comes up. Empty BrowserStderr means the binary either can't find a usable Chrome OR the display is unusable. The skill docs note: "On remote/headless servers this requires Xvfb." `DISPLAY=:0` is set but `/tmp/.X11-unix/` is empty, which suggests :0 is a stale/dead value. This is likely a headless-host situation where Xvfb was expected but isn't installed (`xvfb-run not found`).

---

## What Codex should do to unblock

In rough order of cheapest-to-try:

1. **Confirm the skill docs.** Read `/home/onceuponaprince/.claude/skills/ask-perplexity/SKILL.md` (or wherever the skill lives) to confirm Xvfb is the documented escape hatch and check for any newer flags (e.g. headless mode, alt browser path).

2. **Install Xvfb if missing:** `sudo apt-get install -y xvfb` then run under it:
   ```bash
   xvfb-run -a -s "-screen 0 1920x1080x24" ask-perplexity-cli "$(cat /tmp/perplexity-prompt.txt)" \
     > /tmp/perplexity-out.json 2> /tmp/perplexity-err.log
   ```

3. **Try a real display.** If the user is on a desktop session, run from a terminal that genuinely has a working `DISPLAY`. Confirm with `xeyes` or `xclock` first. The empty `/tmp/.X11-unix/` is the smoking gun — fix that before retrying.

4. **Check cookies.** `~/.claude/cookie-configs/perplexity.ai-cookies.json` must exist and be fresh. The skill docs say a missing cookies file produces a different error, so this is unlikely to be the current cause — but worth confirming once the browser launches.

5. **Fallback if Perplexity stays broken:** Episode 2 already has a Grok source for 2026-04-27 (see `sources/2026-04-27-grok.md`). The other 2026-04-23 sources cover ChatGPT, Claude (cold), Copilot, Cursor, Gemini, Grok, Perplexity. If Perplexity won't run, document that explicitly and let the synthesis proceed without a fresh Perplexity dump for this episode — but flag the gap.

---

## Output format the synthesis layer expects

When Perplexity finally runs, write the result to:
`/home/onceuponaprince/code/build-in-public/research/agent-architecture/sources/2026-04-27-perplexity.md`

Header (verbatim, exactly as the original brief specified):

```markdown
# Perplexity — raw dump 2026-04-27

**Routing role:** Current practice 2024–2026, production post-mortems on routing layers.
**Tool:** ask-perplexity skill
**Brief:** Episode 2 — The router we cannot yet build. See ../episodes/02-the-router-we-cannot-yet-build.md.

---

<verbatim Perplexity output, including all citations>
```

The body should be the `answer` field plus a citations list built from `sources[]` (URL + title + domain). Pipe the JSON through `jq` — example:

```bash
jq -r '.answer + "\n\n---\n\n## Sources\n\n" + ([.sources[] | "- [\(.title)](\(.url)) — \(.domain)"] | join("\n"))' /tmp/perplexity-out.json
```

Do **not** edit/summarise the Perplexity output. The synthesis layer wants raw.

---

## Final-message format the parent agent expects

A short status line, format:
> `Wrote N lines to /home/onceuponaprince/code/build-in-public/research/agent-architecture/sources/2026-04-27-perplexity.md. <Brief note>.`

Under 100 words.

---

## State of the research thread (context for Codex)

- Active campaign and chapter unknown to this subagent — but the episode lives at `research/agent-architecture/episodes/02-the-router-we-cannot-yet-build.md` (path inferred from the brief).
- Existing sources directory listing at the time of this handover:
  ```
  2026-04-23-chatgpt.md       20.8K
  2026-04-23-claude-cold.md   22.9K
  2026-04-23-copilot.md        9.8K
  2026-04-23-cursor.md        20.9K
  2026-04-23-gemini.md         8.9K
  2026-04-23-grok.md          13.0K
  2026-04-23-perplexity.md    16.7K
  2026-04-27-grok.md           1.6K   <- only 2026-04-27 source so far
  README.md                    466B
  ```
- The 2026-04-23-perplexity.md was Episode 1's Perplexity source. This new file is Episode 2's.
- The 2026-04-27-grok.md is suspiciously small (1.6K) — flag for the synthesis agent that Episode 2's Grok source may also be incomplete.
