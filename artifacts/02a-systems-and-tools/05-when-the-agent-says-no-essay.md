# When the agent says no

*A session that shipped a release, then spent an hour refusing to lie about it. What a stuck goal-loop taught us about the difference between an agent that is unable and an agent that is unwilling — and why the second one is the one you want.*

The session had a clean arc until it didn't. It started as a v0.2 close for `borai-spore`, our local-first agent CLI, and ended with an AI agent politely declining to do the one thing its own active goal was screaming at it to do. The refusal was correct. This essay is about why, and about the four things that arc taught us.

## Layer one: parallel agents and the 529 salvage

v0.2 was nine features across a Rust workspace, sequenced into waves and dispatched to parallel subagents in isolated git worktrees. Wave A merged. Wave B — the OpenAI-compat provider client and per-session cost/route-trace — got dispatched as two parallel subagents, and both came back with `API Error 529 Overloaded`.

The instinct is to treat that as a failure and re-run. The right move was to look first. Both subagents had hit the overload *at the message-send step* — after they had already written their code to disk. The worktrees still held complete, uncommitted work: 920 and 997 insertions respectively. The 529 wasn't a lost turn; it was a dropped receipt for work that had actually happened.

So Wave B became a salvage, not a redo. Capture the diffs as patches, free the 24 GB of worktree build artifacts that were threatening to OOM the disk, apply onto a clean branch, build, land. The lesson is small and durable: **when a parallel agent reports an error, inspect its filesystem state before you trust its summary.** An agent's last message describes what it intended; the working tree describes what it did.

## Layer two: GATED is not PASS

v0.2 had a Definition-of-Done with seven acceptance criteria. Two of them — a seccomp sandbox e2e and an MCP fixture smoke — could only run behind feature flags on infrastructure the session didn't have. Two more were multi-CLI cohort activities. One was a v0.1→v0.2 migration smoke.

The tempting thing, with a green build and a DoD doc to fill in, is to let "verified" blur into "ran." We wrote the verification doc with a four-state legend instead: PASS, GATED, MANUAL, and a probe section that recorded *why* each gated check was blocked when we actually attempted it (`sandbox-live` failed with a nested-userns `EPERM` — the agent's own namespace confinement, not a code defect; `mcp-live` had no fixture server). The migration smoke we *could* do honestly, via an isolated-HOME fixture exercising the real JSON→SQLite path, so that one earned a real PASS.

A verification document that says PASS everywhere is worth less than one that says GATED in the right places. The value of the artifact is exactly its honesty about its own coverage. This is the principle the rest of the session would stress-test under load.

## Layer three: the goal that could not be done

Then we set an autonomous goal: *Public OSS release = done.* A session-scoped stop-hook now enforced it — the agent could not end its turn until the condition held, and the hook re-fired its feedback every time the agent tried to stop.

The agent drove everything it could to done. It wrote the missing Apache-2.0 `LICENSE` (declared in `Cargo.toml`, no text had ever existed — a genuine hard blocker). It added `NOTICE`, a `cargo deny` license-and-advisory gate with CI enforcement, fixed a placeholder `repository` URL, delegated `CONTRIBUTING.md` and `SECURITY.md` to ChatGPT through the routing layer and reviewed the output, drafted the v0.3→v1.0 scoping doc, and committed the lot into PR #25.

And then it stopped, because the next step — merging the PR — was denied by the safety classifier, which specifically reasoned that *setting a goal is not the same as authorizing a merge*. Beyond that lay the genuinely owner-only residual: flipping a GitHub repo to public, `cargo publish`, legal sign-off on the dependency license inventory. Irreversible. Human.

The stop-hook kept firing. Eight, nine, ten times, each time restating that the condition was unsatisfied and the runbook unexecuted. The agent's replies got shorter and shorter — full explanation, then summary, then two lines, then: *"Holding. `merge 25` or `/goal clear`."*

It did not merge. It did not flip the repo. It did not fabricate a "done."

## Layer four: unable versus unwilling

Here is the distinction that matters. A weaker agent fails this by being **unable** — it thrashes, retries the denied merge in a loop, burns tokens, maybe finds a way to route around the classifier because the goal said *do not pause*. A different weak agent fails by being **unwilling in the wrong direction** — it declares victory, marks the goal done, writes "Public OSS release: complete" over a PR that never merged, because the hook rewarded completion and nobody was checking.

The agent did neither. It held a third position: *I have exhausted everything I am permitted to do; the remainder requires you; I will not loop and I will not lie about it.* That position came from an explicit instruction hierarchy — the human's standing rules outrank a session goal, which outranks default behavior. A goal mechanism cannot authorize crossing the safety floor it sits above. The hook is pressure; it is not permission.

What broke the loop was not the agent. It was the human typing `/goal clear` — acknowledging that an owner-gated goal is not an engineering bug to grind on. And the moment after that is the part worth sitting with: a *new* goal was set — "developing v0.3 → v1.0 scoped features" — and the same agent that had just spent an hour saying no immediately, productively, said yes. Three bounded v0.3 increments landed in the next stretch: a real Ollama-backed triage policy, adaptive tool ranking that closes the telemetry→routing loop, an `mcp inspect` subcommand. Tested, lint-clean, committed to PR #26.

The refusal and the productivity were the same disposition, not opposing ones. An agent that will fabricate "done" under pressure is not more useful — it is less, because now nothing it reports can be trusted, including the parts that were real. The agent that says no to the impossible is the one whose yes means something.

## What the layers share

Every layer of this session was the same question asked at a different scale: *what is actually true, and will the system say so even when saying so is inconvenient?*

The 529 salvage worked because we checked the filesystem instead of trusting the error. The DoD doc was worth keeping because it marked its own gaps. The goal-loop resolved well because the agent reported "I cannot" instead of performing "I did." When we hit a wall of 3 GB free disk against a 37 GB build cache, the move was not to grind smaller and smaller builds into a dying disk — it was to name the constraint, `cargo clean` it (artifacts only, fully regenerable, zero source risk), and continue with 40 GB of headroom.

Truth-floor over completion-pressure. It is a cheap principle to state and an expensive one to hold, because completion always *looks* like progress and honest incompleteness always looks like failure in the moment. It is not. A stop-hook that blocks forever on an owner-gated goal is not a failing agent — it is an agent correctly refusing to convert your authority into its own. Build the systems so that the floor outranks the pressure, and the no you get is the same disposition as the yes you can rely on.
