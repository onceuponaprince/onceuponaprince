# Character Registry and Shared Skill Resources

**Date:** 2026-05-14
**Status:** Build-in-public engine note; canonical implementation spec lives in `~/code/borai/docs/superpowers/specs/2026-05-14-character-registry-design.md`.
**Related:**
- `2026-04-27-borai-spore-design.md`
- `../plans/2026-05-14-context-hygiene-pivot-roadmap.md` in the BorAI repo
- `../plans/2026-05-14-contextops-feature-list.md` in the BorAI repo

## What changed

Spore now has the beginning of a runtime **Character Registry** beside the existing node and skill registries.

The node registry answers: which machine or execution node can do the work?

The skill registry answers: which reusable procedural knowledge exists?

The character registry answers: which workspace role should do the work, which skills does it carry, and which already-loaded resources can it share rather than loading again?

This matters for the build-in-public engine because the engine is no longer just a single drafting voice. It is becoming a set of named operators: build-in-public narrator, resource curator, COO accountability operator, launch reviewer, research scout, curation engineer, code reviewer. Those roles should not be improvised from scratch every session. They should be described, resolved, permissioned, and spawned as runtime characters.

## Why it belongs in the engine

The build-in-public vault already treats characters as durable narrative and product objects. Files in `characters/` describe people or archetypes that recur across scenes. That is useful for narrative continuity, but insufficient for runtime work.

A runtime character needs a second layer:

- which skills it requires,
- which skills are optional,
- which tools it may use,
- how much context it may consume,
- what memory policy governs it,
- which vault or workspace scope it belongs to,
- and whether another character has already loaded the same skill resources.

The registry is the bridge between the narrative character and the executable operator. `resource-curator.md` can stay a design artefact; `resource-curator` as a runtime character can become the agent that reviews saved links, asks for missing evidence, drafts curation notes, and hands a filtered packet to the build-in-public narrator.

## Resource sharing rule

The critical implementation detail is not "more agents". It is **shared skill resources**.

If the launch reviewer and the COO accountability operator both need the same `launch-readiness` skill, Spore should not reload and reprompt that skill twice. It should resolve the skill once, hash its descriptor/body/resources, and hand compatible characters a stable resource handle.

That gives the engine three practical wins:

- Lower context usage because repeated skill bodies become handles and hashes.
- Faster character spawning because parsing and prompt assembly happen once per workspace hash.
- Cleaner governance because permission boundaries attach to characters and skills before a model starts acting.

## Programmatic creation

The registry also introduces a programmatic creation loop:

1. A task brief describes the role needed.
2. Spore searches installed skills deterministically.
3. It suggests matching skills with reasons.
4. If no strong match exists, it emits a `SkillGap`.
5. The gap can become a draft-only discovery packet or a draft `SKILL.md` through `skill-creator`.
6. A character template can then depend on the new skill only after the skill is written, discovered, and validated.

That sequence is important for build-in-public. It prevents the engine from hallucinating a role as if the capability already exists. A missing capability becomes material for the scene: a named gap, a draft skill, a decision about whether the role earns its place.

## Where to document this

Use three layers, each with a different job.

| Location | Job |
|---|---|
| `~/code/borai/docs/superpowers/specs/2026-05-14-character-registry-design.md` | Canonical engineering/product spec. This is the source of truth for implementation details. |
| `~/code/build-in-public/docs/superpowers/specs/2026-05-14-character-registry-design.md` | Build-in-public engine interpretation. This explains why the registry matters to scenes, characters, and narrative production. |
| `~/code/build-in-public/campaigns/command-centre/chapters/02a-systems-and-tools/scenes/08-two-layer-orchestration-pattern.md` | Narrative scene, when opened. This should explain the pattern in public-facing terms: static vault characters becoming executable workspace operators. |

Do not make the active scene file the canonical home. Scenes are receipts. Specs are contracts.

## Documentation recommendation

Keep the BorAI repo as the implementation source of truth and the build-in-public repo as the narrative/product source of truth.

Concretely:

- Update the BorAI spec whenever CLI flags, structs, discovery paths, or cache semantics change.
- Update this build-in-public note when the meaning of the system changes for the engine.
- Open the next narrative scene when the registry becomes visible as a workflow, not merely as code.

The recommended next scene is **2a-08, "Two-layer orchestration pattern"**. Its thesis should be: characters were already narrative continuity; the registry makes them operational continuity.
