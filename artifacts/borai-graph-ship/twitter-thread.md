# Twitter/X thread — borai-graph ship (fact-checked revision)

*Target platform: X. British English. No emoji. Paste per numbered post; thread them in order. Screenshot of the stats block attaches to post 5 or post 6.*

---

**1/**

Shipped a self-hosted knowledge graph over my command-centre vault today.

Entire stack in docker-compose. Rules-only edges. Ollama-embedded.

Anyone can clone the repo, point three paths at their own content, and have 3,760 chunks indexed in seventeen minutes.

**2/**

Why it was necessary:

By day ninety, a vault of scenes, specs, plans and shipped artefacts outgrows your head.

You start writing new things that the old things already answered, because recall is grep plus memory. The empire in your head diverges from the files on disk.

**3/**

Why local and not a hosted vector DB:

Not cost. At 3,760 vectors, managed services are trivially cheap. The crossover where self-hosting actually saves money is around 5M vectors or 1M queries a month.

The real argument is sovereignty. Client handoffs, visa status, voice profile — none of it belongs on a third-party SaaS. The electricity cost is the tariff I'm willing to pay.

**4/**

How it works:

watchdog sees a file change → chunker splits on H2/H3 headings → Ollama embeds → a rule engine detects structural and similarity edges → atomic three-file swap writes the new graph.

Every agent skill now queries the graph before drafting. Inversion of control.

**5/**

Shape of the graph, right now, on this machine:

```
NODES        3,760
             note: 3,756 | code: 4
EDGES        1,604,734
             follows: 735,443
             precedes: 735,443
             relates_to: 133,848
INDEX        last flushed 2026-04-23T17:16:59Z
HEALTH       ollama reachable
```

**6/**

Ingest duration: 17 minutes 11 seconds. Cold start against the real vault plus BorAI ops plus my user-level skills (142 files).

Consumer CPU. Single box. No paid API calls at any point during the build or the run.

**7/**

What changes for each agent skill:

- build-in-public-engine — pulls prior scenes + voice profile before drafting
- funding-tracker — surfaces prior eligibility notes and supersedes archive dedup
- hackathon-radar — refuses to resurface things already evaluated
- delegate-agent — includes prior spec paths in the delegation prompt

None of this required rewriting the skills. Each gained one ~15-line section.

**8/**

Security posture, because this runs on your actual machine:

Read-only bind mounts for host content. Non-root runtime user. Read-only root filesystem. cap_drop: ALL. no-new-privileges. Zero ports published to the host.

Ten lines of compose config. OWASP's minimum-privilege recipe.

**9/**

Honest pitfalls:

Temporal edges are 92% of the graph — probably too dense. nomic-embed-text is adequate (MTEB 62); bge-m3 scores closer to 72 and would be strictly better for longer chunks. Our embedder still hits the deprecated /api/embeddings endpoint; migrating to /api/embed enables batching.

**10/**

Where it goes next:

A Claude Code subprocess bridge for edge enrichment at subscription prices rather than per-token API prices.

A small web UI on the same docker network so queries are browsable rather than invisible.

Eventually, cross-vault federation — two founders consent-sharing slices of each other's corpus.

**11/**

The thing I keep circling back to:

Shipping a tool for your own work is different from shipping client work.

The tool becomes part of the corpus the tool was built to serve. This thread, once posted, will be indexed by the next watch event. The author becomes a node in the author's own graph.

**12/**

The cost to ship it was two merged PRs, 107 tests, a single working day.

The cost *not* to ship it was a continuously degrading vault that only I could navigate.

Solo-founder work compounds only when the infrastructure compounds with it.

**13/**

Everything lives here:

github.com/onceuponaprince/borai.cc

Clone, copy `.env.docker.example` to `.env`, edit three paths, `docker compose up -d`.

Starter vault and starter skills are included so a fresh clone has something to index on day one.

**14/**

Now to actually post the bloody thing.

---

## Posting notes

- Post **1/** is the hook. Lead with the shipped-thing, not the prelude.
- Post **3/** is the pivot — every founder who reads it will be mentally comparing against a Pinecone invoice. Conceding the cost point up front earns the sovereignty point. Do not soften to "both matter."
- Post **5/** carries the stats block — screenshot the actual `borai-graph-stats` output from `docker compose exec borai-graph borai-graph-stats` and attach it as an image instead of (or alongside) the code block. Images outperform code blocks on X.
- Post **9/** concedes three real limitations. This is the post that separates build-in-public from performance. Keep it specific (exact MTEB numbers, named endpoint) rather than hedged.
- Post **11/** is the reflective beat; it is the one that earns replies from other solo founders. Do not soften it.
- Post **13/** is the call to action. Keep the URL plain text; X's crawler prefers that.
- Post **14/** is the closer. The self-aware line about posting is load-bearing. Do not cut it.

## If the platform bites back

- If **6/** feels too dry alone, splice the hardware spec into the previous post and retire it.
- If **9/** reads as too self-critical for the thread's energy, move the pitfalls to a reply under the main thread rather than in the numbered chain.
- If X's character counter complains on any single post, the usual cuts are: "on this machine" (5), "during the build or the run" (6), "because this runs on your actual machine" (8).

## Korean variant

Out of scope for this artefact. Korean-audience framing would shift substantially (the self-hosting framing reads differently in a market where hosted SaaS is the default assumption). If a Korean thread is wanted, spawn it as a new artefact under the same directory.
