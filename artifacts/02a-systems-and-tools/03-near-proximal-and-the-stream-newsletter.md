# The fourth shape

*The retrospective offered three options for fixing the knowledge graph. I chose a fourth. Eighty-nine percent of the edges fell out; the shape of the webapp fell in.*

## Where this starts

The day before closed with a retrospective: three shapes to fix the every-pair temporal edges that were 91.6% of my knowledge graph. Drop them. Cap at distance 1. Keep every-pair and downweight. The recommendation on the page was cap-at-1 — sober, the least ambitious of the three.

I opened this session expecting to execute the recommendation. Spec the cap, write the test, rebuild the graph, publish the follow-up. A one-afternoon scene.

By the time I was writing the spec, the shape had drifted.

## The fourth shape

Cap the *stored* edge at distance 1 — the retrospective's call for the stored shape — and compute distance > 1 at query time with a proper relevance signal. Two mechanisms for two jobs.

`near` is the stored edge. Within-file, d=1, bidirectional. Cheap. The closest prior chunk and the closest next chunk, always there when the query needs *what's right next to this*. After the rebuild: 7,640 near edges across 3,968 nodes, roughly 1.9 per node. Down from the old 425.

`proximal` is the computed relation. Distance > 1 within a file, surfaced only at query time, not stored. The signal is relevance-ranked, not distance-ranked:

```
relevance = α·(1/d) + (1−α)·cosine(seed_vec, target_vec)
```

The embeddings are already paid for at ingest. A retrieval engine that refuses to use them at query time is cheap for the sake of being cheap. α = 0.5 as the named default; fallback to pure decay is one environment variable flip.

The retrospective was thinking *cut the noise*. This was thinking *split the signal*. Become more specific, not less.

## The shapes that rode along

Once the edge-schema change was going to break the graph — a fresh reingest was unavoidable either way — two more shapes earned their slot in the same PR.

A two-layer tag system. Author YAML tags keep their sovereignty; the indexer mints a structured layer alongside — `type:scene`, `status:concluded`, `chapter:02a-systems-and-tools`, `campaign:command-centre`. The two layers coexist via a reserved-prefix contract: anything the author writes that collides with a reserved prefix gets stripped at ingest. The minted vocabulary stays clean; the author's intent stays whole.

A progressive data stream. `query()` now defaults to shallow mode — tags and handles, no bodies. Callers pass `mode="full"` for the old behaviour or call `engine.expand(handle)` on demand. The old default said *here is everything*. The new default says *surface me the names first; I'll ask for the body when I want it*. The webapp's first render becomes a candidate list, not a token-budget fight.

It is a breaking change for every caller — the four skill one-liners in my Claude Code setup all hit `query()` today. They will be updated in the next scene. The breaking change earned its place because the old default was a webapp tax I was going to pay forever.

## What rebuild looked like

Docker cache landmine first. The `up -d --build` form kept a stale image — yesterday's repeat offender, I should have known. `build --no-cache` + `up -d` picked up the new code. Verified by grepping the source inside the running container before the ingest started.

One hundred and fifty-one files, roughly thirteen per minute, 18m 40s. Progress log every sixty seconds as designed. Ingest closed with:

- 3,968 nodes (from 3,916)
- 144,482 edges (from 1,614,528) — **89% reduction**
- 7,640 `near`
- 136,842 `relates_to` (content similarity, untouched by this scene)
- 0 `follows` / `precedes` (the whole point)

End-to-end query on *"temporal edge decision"* returned 53 results split cleanly by mechanism: `{seed: 5, near: 10, proximal: 14, relates_to: 24}`. Every layer firing. Clean provenance in the `reason` field. Proximal scores in the 0.35–0.37 range — a reasonable first number for α=0.5 on within-file siblings. A funding query on *"Korea F-6 founder visa"* surfaced the founder-profile reference at 0.79 similarity — tag-scoped routing behaving as designed.

Tests at close: 135 passing, up from 107. Four cheap riders bundled in the same PR — embedder migrated to `/api/embed`, vestigial `/mnt/skills/` path rules deleted, periodic progress logs on ingest, `--if-present` guard on the BorAI pre-push hook's typecheck step.

## What this unblocks

The webapp climax — Scene 02a-06 in the chapter — cannot honestly open while the graph underneath it misleads callers. It just stopped. The retrieval API's shape is now the shape the webapp needs: a candidate list with tags and handles first, bodies only on expansion. First render is what a user wants to scan, not what a token budget cannot afford.

Next scene either updates the four skill one-liners to the new API or rolls that update into the delegate-agent integration (Scene 2a-04). The delegate-agent work is bigger; the skill update is small enough to ride along. Leaning 2a-04 next.

## What I got wrong

The Docker cache cost me seventeen minutes. It is a repeat offender from the previous session. A one-line header comment in `docker-compose.yml` noting the `--no-cache` requirement would have caught it before the first false-positive ingest started. Added to the next-scene carry.

The cap-at-1 recommendation was not wrong. It was conservative — a defensible call that left signal on the table. The retrospective had named it as the recommendation; I deviated deliberately. The call against the sage's grain is the one that had to earn its place.

## The ship

- **borai-graph** — four-part edge model (`near` stored / `proximal` computed), two-layer tags, progressive data stream. 89% edge reduction on reingest.
- **BorAI ops** — pre-push hook guard for typecheck on scaffold apps.

Next scene opens with either skill one-liners or delegate-agent scrapers. The graph stops being the answer and starts being the substrate.
