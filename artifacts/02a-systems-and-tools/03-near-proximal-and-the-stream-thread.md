1/ 91.6% of my knowledge graph's edges were noise.

1,478,598 of 1,614,528 — every-pair mtime-driven temporal edges, within-directory cross-products, 425 per node. The ranker was drowning.

2/ The retrospective I'd shipped the day before offered three shapes for a fix.

Drop the temporal edges entirely.
Cap them at distance 1.
Keep every-pair and downweight.

Its recommendation was cap-at-1. Sober. The least ambitious of the three.

3/ I chose a fourth shape.

`near` — stored, within-file, d=1, bidirectional. Cheap.
`proximal` — computed at query time, d>1, relevance-ranked. Not stored.

Split the signal in two.

4/ Relevance = α·(1/d) + (1−α)·cosine(seed_vec, target_vec).

The embeddings are already paid for at ingest. Refusing to use them at retrieval is cheapness for its own sake.

α=0.5 default. Fallback to pure decay is one env-flip away.

5/ Same PR, two more shapes earned their slot.

Two-layer tags. Author YAML stays sovereign; the indexer mints a reserved-prefix layer alongside — `type:scene`, `status:concluded`, `chapter:02a`. The prefix is the contract that stops the layers colliding.

6/ And a progressive data stream.

`query()` now returns shallow results — tags and handles, no bodies. Callers pass `mode="full"` or call `engine.expand(handle)` on demand.

"Surface me the names first. I'll ask for the body when I want it."

7/ Breaking API change. Earned its place.

The old default was *here is everything*. The new default is a candidate list with tags. The shape of the retrieval API is now the shape the webapp needs. First render stops being a token-budget fight over chunk bodies.

8/ Reingest: 151 files in 18m 40s. Fresh graph — 3,968 nodes, 144,482 edges.

**89% edge-count reduction.**

End-to-end query on *"temporal edge decision"* split cleanly: `{seed: 5, near: 10, proximal: 14, relates_to: 24}`. Every mechanism firing.

9/ The retrospective's cap-at-1 call was defensible. It left signal on the table — embeddings already bought, sitting in the graph, doing nothing at retrieval time.

The call that earned its place was splitting the signal. Cheap contract at d=1. Richer signal at d>1.

Become more specific, not less.

[essay →]
