# Session retrospective — 2026-04-23 borai-graph ship

*Written at session close. Specific about what drifted, rotted, or wasted time, and what concretely changes next time.*

---

## The session in numbers

| Metric | Value |
|---|---|
| Vault commits pushed | 1 (`57234c6`) |
| BorAI main commits landed | 50 (48 rebased from PR #3 + 4 from PR #4) |
| PRs merged | 2 (#3, #4) |
| Tests at session start / end | 103 / 107 |
| Artefacts shipped to `artifacts/borai-graph-ship/` | 3 (paper, thread, this retrospective) |
| Lines added, paper | ~2,500 words, 11 external citations |
| Graph state now | 3,916 nodes / 1,614,528 edges / healthy |
| Containers running | 2 (borai-ollama, borai-graph) |
| Paid-API dependencies introduced | 0 |

The graph grew 156 nodes since the initial 17-minute ingest — that is the three artefacts (paper, thread, and the first pass of this retrospective) being indexed by the watcher while I was still writing them. The self-reference I wrote about in §8 of the paper is no longer theoretical.

## What went well

Three things, briefly.

The **spot-check self-review at the start of the session** caught five real-but-minor issues and turned one of them into the WARNING-logging commit that shipped with PR #3. Doing the review *before* proposing any change meant the change was scoped to what was actually broken, not what felt like it might be worth cleaning up.

The **decision to dockerise in a separate PR** from the original indexer merge was correct. PR #3 shipped a working local daemon; PR #4 turned it into a portable package. If they had been one PR, both pieces would have shipped later and neither in isolation would have been reviewable.

The **fact-check pass on the research paper** found three claims that would have aged badly — most notably the cost-framing, where I was leaning on a hosted-vs-self-hosted cost argument that was simply false at this corpus's scale. Conceding that point in the revised draft made the sovereignty argument stronger, not weaker.

## Drift / rot moments

Specific failures, with what was actually lost and what needs to change.

**Skill-list dumps, five times.** The available-skills catalogue (~180 lines) was re-injected as a system reminder at five separate points during the session. I already had it in context; the re-injections consumed tokens I could not reclaim. This is logged in `docs/upstream-issues.md` but the entry has not been revisited since the last session flagged the same thing. **Needed:** a PROGRESS.md-level note so the next session's opener thinks about whether to disable the injection for this project.

**Background task with an empty output file.** The first `docker compose up -d --build` was kicked off in a background Bash task (`bbuf2ebqh`). It completed at exit 0 but the output file was 0B. Lost visibility into the build sequence; had to re-run in the foreground to see what actually happened. **Needed:** prefer foreground for commands whose output is the only evidence of success.

**Docker image cache masked source edits twice.** I edited `pipeline.py` and `chunker.py`, restarted the stack with `docker compose up -d`, and the old behaviour persisted. BuildKit correctly invalidated the COPY layer only when the content hash changed — but `docker compose up -d` without `--build` didn't rebuild at all. **Needed:** a one-line rule in the docker-compose README that says "after any `ops/borai-graph/` source edit, `docker compose up -d --build`".

**Monitor timed out 2 minutes before the ingest finished.** First monitor set a 15-minute timeout; ingest took 17:11. Had to re-arm a 30-minute monitor. **Needed:** Monitor timeouts for Ollama-backed ingest workloads default to 30+ minutes; the cost of over-shooting the timeout is zero, the cost of under-shooting is manual re-arming.

**Stale hash_registry blocked the second bulk ingest.** After a broken first run (the chunker was rejecting everything and the .venv noise was flooding), the hash_registry was partially written. The next restart saw "7 entries — skipping initial bulk ingest" and populated a graph with 0 nodes. **Needed:** `run.py` should refuse to treat a hash_registry as "non-empty" when the corresponding `graph.json` has zero nodes — that is a corrupt-partial state, not a resumable one.

**Chunker's hardcoded path rules survived my review.** I spot-checked `pipeline.py`, `engine.py`, and `run.py` at the top of the session. I did not spot-check `chunker.py`. The hardcoded `/mnt/skills/` rules only surfaced as a bug when the docker stack actually ran against `/watch/*/` mounts. **Needed:** the spot-check rubric should explicitly include "does this file encode deployment-specific assumptions?" as a question.

**Not enough subagent delegation.** Six web searches ran in the main context, each returning ~10-15KB of raw search results. A `general-purpose` subagent with a scoped "research this claim" prompt would have returned a two-paragraph summary and kept the main context clean. **Needed:** default to Agent for any research task that involves 3+ external lookups.

## Proposed system improvements

Three buckets, ordered by cost-to-value.

### Cheap and high-value (next session)

1. **Migrate the embedder to `/api/embed`.** Batched embedding cuts cold-start ingest time meaningfully. Half-day of work.
2. **Delete the hardcoded `/mnt/skills/`-style path rules.** The extension fallback covers them. Leaving the dead rules in creates quiet divergence as new source types get added.
3. **Add periodic progress INFO logs during bulk ingest.** "Processed N/M files" every minute. No architectural change; ten-line addition to `run.py::initial_bulk_ingest`.
4. **Fix the BorAI pre-push hook.** Typecheck step errors when no `apps/*` package has a `typecheck` script (it does not, today). Guard the step with `pnpm --filter "./apps/*" --if-present typecheck` or similar.

### Medium (a scene of work each)

5. **Cap temporal edge distance.** Current rule creates every-pair `follows` / `precedes` edges within a file. Cap at distance 1 (or 2). This alone shifts edge density from 425/node to a manageable ratio. **This is the single most impactful refactor this system has left in it** — and it's a good next-session opening beat.
6. **Bake the embedding model into a custom Ollama image.** `FROM ollama/ollama:0.4.4` + `RUN ollama serve & sleep 5 && ollama pull nomic-embed-text`. Saves the five-minute first-boot pull for anyone cloning the repo.
7. **Add a `borai-graph-query` CLI entry point.** Currently requires a Python one-liner. A proper `borai-graph-query --agent funding_tracker 'Korea F-6 founder visa'` CLI would make the starter-skill's example shorter and more ergonomic.

### Expensive but strategically interesting

8. **Claude Code subprocess bridge for edge enrichment.** Covered in the paper's §7; still the right next-big-thing.
9. **Web UI for retrieval.** Also §7.

## The design choice worth pausing on

The cap-temporal-edge-distance refactor (#5 above) is a real trade-off, not a mechanical change. There are three defensible shapes:

- **Drop `follows` / `precedes` entirely.** Rely on `relates_to` for semantic proximity. Smallest graph, cleanest signal, risks losing sequential context that a good reader would use.
- **Cap at distance 1 within a file.** Only immediate siblings are related. Cuts density by ~99%, preserves the "this chunk comes right after that one" signal.
- **Keep every-pair but raise the cost of traversing them.** Drop their `edge_confidence` from 1.0 to 0.1 so they survive only when nothing else does. More complex to tune; preserves flexibility.

My read is that distance-1 is correct; the every-pair rule was a first-implementation shortcut, not a design. But this is a decision that shapes how the retrieval engine behaves for months, and the correct answer depends on what you notice when you actually start querying the graph during real drafting sessions. It belongs to you, not to me. Flagged in PROGRESS.md as the first thing to decide when next session opens.

## What this retrospective does not contain

- Praise. Not the genre.
- A claim that this was the best session possible. It was not. The three drift moments above cost perhaps 40 minutes in aggregate.
- Any suggestion that the follow-up list is complete. It is not. It is the part that is visible at the close; the rest surfaces during real use.

## What this retrospective *does* contain, as a side effect

A new node in the graph, indexed within seconds of saving.
