# How the substrate hardened

The home cluster's first end-to-end run closed with the pipeline alive and twelve named failure surfaces still in it. Two days later, eight of those twelve are gone. The other four are scheduled. What follows is the structure of that work, and the three observations from it worth carrying out of the home-cluster setting.

## The setting

Two workers (a Ryzen running Windows, a 2019 Intel MacBook Pro running macOS), one orchestrator (a Linux box), Ollama on each. A Coder model on the Ryzen, a Reviewer model on the MBP, the orchestrator pinning the dispatch order. The whole thing fits on the home LAN.

The first round-trip succeeded. The session that produced it surfaced its own failure modes: a model that pulled but refused to load (RAM gating, hard upfront), a cloud passthrough that listed but rejected the call (subscription gating, invisible until first generate), a small reviewer that confidently rewrote working code into something that didn't compile, a Windows firewall that dropped ICMP while accepting TCP, a `keep_alive` window that meant every standalone invocation paid a ten-second cold load. The session shipped its essay on those gates. This essay is what happened next.

## The structure

Twelve gap items came out of that session. Grouped into three tiers, ordered by criticality:

- **Tier 1** — sharp edges that bit. Four items: pre-flight probe, `keep_alive` on the payload, Reviewer persona tightening, retry on transient runner crashes.
- **Tier 2** — production readiness. Four items: test coverage, dockerised orchestrator, structured logging, streaming output.
- **Tier 3** — architecture stretch. Four items: multi-round refinement, model routing, LAN auth, HTTP API.

The closing condition for the scene was *Tier 1 must close, Tier 2 should close, Tier 3 carries to a sibling scene if needed.* That structure is the one piece of the work that earned its place ahead of any code. Twelve items in one session is a scope-inflation trap. Twelve items tiered with a closing condition that doesn't require all twelve is a tractable plan.

Tier 1 and Tier 2 closed. Tier 3 carries.

## Three observations

### 1. Gap analysis isn't gap inventory

The gap list claimed three modules needed test coverage. Walking the test directory found that one of those three already had three tests — accurate at the time the original session wrote the list down, stale by the time this session opened. The capture in the scene corrected the record rather than chasing a ghost gap and writing duplicate tests.

The lesson is small but load-bearing. *A gap list is a snapshot, not a register.* Re-walking the code before scoping a follow-up session catches the gap that was already filled and would otherwise burn an hour of redundant work. The cost is one `ls` and one read; the saving is one ghost-chase per misremembered item.

### 2. Transient versus deterministic is the policy's atom

The retry policy started as a paragraph in the gap list — *retry on transient failures.* What landed in code is a four-item tuple:

    TRANSIENT_ERROR_SUBSTRINGS = (
        "unexpected eof",
        "llama runner process has terminated",
        "connection reset",
        "connection error",
    )

Everything in that tuple gets retried up to twice with exponential backoff. Everything outside it raises on the first hit. Critically: *RAM gates and subscription gates are not in the tuple.* They are deterministic failures, and retrying them compounds the problem — three identical "model requires more system memory" responses spaced eight seconds apart are worse than one.

The atom of the policy is the substring list. Adding a new transient failure mode is one constant edit. Adding a new deterministic failure is recognising that the existing fast-fail behaviour is correct and doing nothing. The mechanism around the atom — the retry loop, the backoff, the `_is_retryable` check — is the same regardless of what is in the list.

The shape of this generalises. Any policy that gates between *retry* and *raise* — circuit breakers, network clients, queue consumers — earns clarity when the policy's atom is a named, edited-by-hand list rather than an inferred-from-context heuristic. The cost is having to write the list. The benefit is that the list is the policy.

### 3. Streaming was a correctness change, not just UX

The pipeline started with `stream: False` on every Ollama request. The orchestrator waited for the whole response and then handed it on. The reason to switch to streaming looked, on the surface, like UX — tokens appearing as they arrive feel alive instead of hung.

The deeper effect was correctness. With buffered responses, mid-generation failures only surfaced when the full response arrived wrong. A model that crashed forty percent of the way through a long generation looked, from the orchestrator's perspective, the same as a model that never started. The retry policy had nothing to retry against until the buffered response came back broken.

Streaming changed that. Each NDJSON chunk is a point of observation: an `error` field mid-stream raises immediately and feeds the existing retry policy without waiting for the rest. The same retry mechanism that already existed became more correct because failures now surface where they happen rather than where they finish buffering.

The UX win — watching the tokens arrive — was real. It was not the change's biggest effect. The biggest effect was that the retry policy *learned what to retry against earlier*.

## What compounds beyond the home cluster

The three observations are all *small, load-bearing* in the same way. They look like notes about a specific debugging session and they are also notes about how to design any pipeline that has external workers, transient and deterministic failure modes, and a retry policy. The home cluster is the setting; the observations are not.

Twelve items into eight in two sessions, with a tier structure that explicitly allowed stopping before all twelve, is the shape of the work. The substrate is calmly trustable now in a way it was not on Monday. The Tier 3 extensions — multi-round refinement, model routing, authentication, an HTTP API — carry to the next scene, where they will stand on this layer rather than competing with it for attention.

Build should feel like play. The hardening work was the kind of work that usually feels like filing taxes, and the tier structure kept the cognitive shape playful. Each Tier item shipped as its own small win. The compound was a substrate that earns its place.
