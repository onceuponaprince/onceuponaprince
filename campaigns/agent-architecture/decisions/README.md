# Decisions — architecture choices from the research

Working ADRs distilled from the living research in the parent folder. Each decision is a commitment made for a real system — BorAI Knowledge Graph, vault tooling, a future scene's implementation — not an abstract recommendation.

## Naming

`NNN-short-slug.md`, three-digit, starting at `001`.

## Shape

Each ADR carries:

- **Context** — what the system is, what the task demands
- **Decision** — the position chosen on the spectrum
- **Alternatives considered** — the other positions, briefly
- **Consequences** — what this buys, what this costs, what it blocks
- **Source** — which episode and which raw dumps in `../sources/` drove the call
- **Revisit trigger** — what would cause this decision to be reopened

The last field is load-bearing. Decisions without a revisit trigger are stuck.
