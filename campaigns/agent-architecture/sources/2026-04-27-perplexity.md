# Perplexity — raw dump 2026-04-27 (BLOCKED)

**Routing role:** Current practice 2024–2026, production post-mortems on routing layers.
**Tool:** `ask-perplexity` skill / `ask-perplexity-cli`
**Brief:** Episode 2 — The router we cannot yet build. See ../episodes/02-the-router-we-cannot-yet-build.md for full sub-questions and claim.

**STATUS: EXTRACTION FAILED — ENVIRONMENT BLOCK.** `ask-perplexity-cli` routes through `chromiumoxide`, which requires a display server. The current environment has `DISPLAY=:0` set but `/tmp/.X11-unix/` is empty and `xvfb-run` is not installed. Both subagent attempts hit `Failed to launch Chromium via chromiumoxide` before any HTTP request was issued. Installing `xvfb` requires `sudo` and was not attempted under the global no-sudo-without-explicit-instruction rule.

**Synthesis impact:** Perplexity's role on this Episode was *current practice 2024–2026, production post-mortems with citations*. Without it, the synthesis loses the load-bearing citation density Perplexity provided in Ep1 (43 cited sources). Cursor's trenches read partially compensates — it includes specific Reddit threads, GitHub issues, and arXiv IDs — but the production-blog and engineering-post layer that Perplexity uniquely surfaces is missing.

**Unblock path** (for a future addendum):

1. Install xvfb: `sudo apt-get install -y xvfb`
2. Re-fire with virtual display: `xvfb-run -a -s "-screen 0 1920x1080x24" ask-perplexity-cli "$(cat /tmp/perplexity-prompt-ep2.txt)" > /tmp/perplexity-out.json`
3. Convert JSON → markdown via `jq` per the handover doc
4. Re-write this file with the resulting content; update synthesis with addendum

The full handover is preserved at `2026-04-27-perplexity-HANDOVER.md` in this directory — includes the verbatim prompt, target output path, header format, the `jq` conversion one-liner, and failure logs.

---

*This file is a placeholder marking the Perplexity gap in Episode 2's cold round. The synthesis treats Perplexity as missing; addendum lands when the environment is unblocked.*
