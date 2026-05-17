---
campaign: "[[command-centre]]"
chapter: "02b-products-that-sell"
scene: "02b"
title: "marrk.space borai vault wedge"
status: concluded
date_opened: 2026-05-11
date_concluded: 2026-05-11
characters:
  - "[[prince]]"
  - "[[solo-thesis-holder]]"
  - "[[resource-curator]]"
spec_file: "docs/superpowers/plans/2026-05-11-marrk-space-borai-migration.md"
blockers: []
supersedes: null
artifacts:
  - format: essay
    file: "[[02b-marrk-space-borai-vault-wedge-essay]]"
  - format: newsletter
    file: "[[02b-marrk-space-borai-vault-wedge-newsletter]]"
tags:
  - chapter-2b
  - marrk-space
  - borai
  - vaults
  - product-wedge
  - graph-rag
  - commercial
---

# Scene 2b-02b — marrk.space borai vault wedge

*Chapter 2b — Products that sell · Campaign: [[command-centre]]*

marrk.space moves into BorAI as a separate product track from study-buddy/teenyweeny: the first durable user-facing vault product, and the place where the substrate stops being infrastructure and starts meeting a market.

---

## Set the Stage

### How did we get here?

Chapter 02b opened with teenyweeny.studio: a product-to-sell branch built from the study-buddy catalogue, Resource Curator character, and landing-before-build discipline. That thread remains its own product track. marrk.space is not a rename, pivot, or replacement for it.

marrk.space is the second product track in the chapter. The work began as a shared mobile and web container for links, media, PDFs, notes, chats, and saved sources. It grew into an AI memory vault: graph-style tagging, vault permissions, backend persistence, Chrome capture, Telegram and Discord ingestion paths, deterministic vault chat, beta diagnostics, waitlist, vault analytics, agent-credit scaffolding, and a narrowed GTM story around creators, researchers, and knowledge operators.

Then the architectural shape became obvious: marrk.space should not sit beside BorAI as a separate product experiment. It should become BorAI's first full product surface.

### Where are we going?

We will be building BorAI's first durable vault wedge through marrk.space: a product surface where curated user data becomes searchable, permissioned, agent-readable memory.

The destination is not a broad marketplace, not NFT vault trading, not a fully automated integration layer. Those remain strategic options. The wedge is narrower and stronger: capture from the places a user already works, organise the material into a vault, ask source-backed questions, receive useful synthesis, and return because the saved material has become useful again.

For BorAI, this means the abstract substrate now has a product that can expose its value. For marrk.space, this means the product no longer has to invent its own universe. It can inherit BorAI's graph, Spore agents, vault ontology, skills, orchestration, and build-in-public method.

### State of the world (project context)

BorAI now contains marrk.space inside the monorepo app workspace at `~/code/borai/apps/marrk-space`. The rename is not only cosmetic: the package, app directory, deployment labels, public copy, environment variable prefixes, extension labels, and Django settings module have moved to the new name.

The migrated app preserves the full working surface: Expo React Native/Web frontend, Django/Postgres backend, Node ingestion server, Telegram and Discord bot workers, Chrome extension, deployment docs, Dockerfiles, Render blueprint, product docs, and beta audit. BorAI's root workspace can run and verify the package through workspace scripts.

Verification passed after migration. From BorAI, dependency install completed; workspace verification passed; the migrated backend test suite ran with the existing standalone virtualenv and returned `58 passed`.

The deployment caveat is still live. The Render blueprint and Dockerfiles were copied from a standalone repo shape. If deployment happens from the monorepo, the provider needs an app-level root directory or rewritten blueprint paths.

### State of the hero ([[resource-curator]])

The Resource Curator has changed shape but not need. In the teenyweeny scene, they owned an Obsidian vault and wanted to distribute it as a studyable experience. In marrk.space, they are broader: newsletter writers, analyst-creators, founder-researchers, niche community curators, and AI/PKM power users who already save more material than they can retrieve.

Their wound is not lack of storage. They already have storage. Their wound is that the material does not compound. Useful links disappear into chats, browser tabs, drives, note apps, social feeds, and private screenshots. The curator remembers saving the thing but cannot recover the shape of why it mattered.

What they want: a better place to save things. What they need: a system that turns deliberate curation into retrievable, source-backed leverage without demanding a new priesthood of folders, dashboards, and admin rituals.

Dominant objection: this sounds like another bookmark manager or another AI wrapper. The product earns attention only if the first loop is practical: save, search, synthesis, return.

### State of the protagonist ([[prince]])

Prince has been carrying two parallel pressures: build the system that makes the work feel like play, and find the product wedge that can make the system saleable. BorAI has the substrate weight. marrk.space has the user-facing surface. The migration is the point where those pressures stop competing and start informing the same object.

There is also a discipline correction here. The product has accumulated tempting future layers: marketplace, minting, agent rentals, NFT access, broad provider sync, social curation economy language. External validation and the beta audit both cut the same way: do not lead with the complexity. Lead with the saved-material loop. The story has to be made smaller before it can become stronger.

### This moment in relation to goals

This scene adds a second lane to Chapter 02b. The chapter was named Products that sell, and its first product track remains study-buddy/teenyweeny. marrk.space becomes a separate commercial wedge because it has a fuller product surface, a clearer pain, and a direct fit with BorAI's long-term infrastructure.

For the campaign thesis, this is load-bearing. If building a startup should feel like playing a game, the saved objects, vaults, agents, permissions, and summaries are not just product features. They are game pieces. The product helps the founder make the work legible while producing the narrative of the work.

### Why now?

Because the migration has happened. Because the monorepo now contains the product surface. Because the docs already say the next step is to add a build-in-public scene capturing why marrk.space is the product wedge for BorAI.

Because open beta is not blocked by imagination anymore. It is blocked by the concrete pieces named in the audit: deployed auth validation, backend-backed persistence coverage, production job queues, observability, privacy/legal endpoints, and one live ingestion path. That is a better kind of blocked. It means the shape of the thing is now specific enough to be worked.

---

## Progress the moment

### Goal for this session

- [x] Capture marrk.space's move into BorAI as a separate Chapter 02b product track.
- [x] Name marrk.space as the current BorAI product wedge.
- [x] Record the verified migration state without overstating deployment readiness.
- [x] Update the Chapter 02b index so the chapter arc reflects the new commercial path.
- [x] Keep the scene open for future migration, deployment, and beta-readiness capture.

### Moment-by-moment capture

- [x] marrk.space copied into the BorAI app workspace without deleting the standalone source repo.
- [x] Codebase package renamed to `marrk-space`, including the BorAI app directory, package metadata, root workspace scripts, Expo app identity, deployment labels, env var prefixes, extension copy, and Django settings module.
- [x] BorAI root `README.md` updated to list the app as the first durable user-facing AI memory vault product inside the monorepo.
- [x] BorAI root package scripts updated so the app can be run and verified through the workspace.
- [x] App package scripts adjusted for workspace compatibility, including `build`, `check-types`, and `verify`.
- [x] Root `pnpm` override added for `postcss`, resolving the production audit failure that appeared during migration verification.
- [x] Migration plan captured and now retitled in-scene as the marrk.space BorAI migration.
- [x] `pnpm install` completed from `~/code/borai`.
- [x] Workspace verification passed from `~/code/borai`.
- [x] Migrated backend tests passed from the app workspace using the existing standalone virtualenv: `58 passed`.
- [x] Deployment caveat recorded: Render/Docker configuration still assumes the old standalone app as deployment root unless the provider uses an app-level root directory or paths are rewritten.
- [x] Product naming changed from the old working name to `marrk.space` across the scene, chapter index, and active BorAI package.

### What's changing?

- marrk.space changes from sibling experiment to product wedge. It is no longer only a standalone app; it is the first place BorAI's vault substrate can be felt by a user.
- Chapter 02b changes from a single-product commercial arc to a multi-product validation branch. teenyweeny remains its own track; marrk.space carries a separate BorAI vault-product track.
- The naming changes at product and package level. The old working name was loud, unserious in the wrong rooms, and too easy to dismiss before the product could make its argument. `marrk.space` keeps the useful verb underneath it — marking, saving, returning — while giving the product a calmer surface for creators, researchers, and professional curators. The codebase now has to honour that decision too: names, scripts, headers, deployment labels, and docs should no longer leak the discarded working title.
- The public language tightens. "Graph-RAG", "Social Curation Engineer", marketplace, minting, and agent rentals stay mostly internal for now. The beta-facing phrase is simpler: AI memory vault for everything you save.
- The next work becomes operational rather than speculative: monorepo deployment paths, canonical dev environment, auth/session validation, backend persistence completion, one real ingestion path, and a small invited beta.

---

## Conclude

### How is now different from the start?

At Set Stage, marrk.space was a product wedge in narrative terms: moved into BorAI, verified, renamed in the scene, and positioned as the first durable vault surface. Now the rename has reached the codebase. The app path is `apps/marrk-space`; the package is `marrk-space`; root scripts, Expo app identity, deployment labels, environment prefixes, extension copy, and Django settings module have moved with it.

The scene no longer holds a soft brand decision. It holds a package-level commitment. The discarded working name should now live only in git history and in the memory of why the change was necessary.

### What are the consequences?

The product can enter the next phase under a name that does not fight its audience. `marrk.space` is calmer, more professional, and closer to the user action: mark the thing, return to it, build from it. That matters because the first users are not novelty-seeking bookmark collectors. They are creators, researchers, founder-researchers, and curators who need trust before they hand over their saved material.

The cost is operational. Every external setup now has to respect the new name: deployment services, env vars, docs, extension packaging, support copy, and eventually domains and app-store identifiers. A rename that only exists in prose is cheap. A rename that reaches headers, package metadata, and Django settings is a real migration.

### What did we learn?

The product name was not a surface detail. It was part of the adoption risk. The old name was memorable, but memorability was doing the wrong job: it made the product easier to notice and easier to dismiss. For a vault product asking users to trust it with research, saved links, and private context, that trade was wrong.

The deeper lesson is that a product wedge has to be narrow in two directions: narrow in feature promise and narrow in register. marrk.space cannot lead with Graph-RAG, marketplace, NFTs, agent rentals, or the Social Curation Engineer thesis. It has to lead with the felt loop: save the thing, find it again, ask across it, get synthesis, return.

The codebase rename also exposed the difference between theatre and commitment. Saying "the name changed" was a scene beat. Making the package, scripts, headers, deployment labels, and backend module agree with it turned the beat into infrastructure.

### Progress to thesis

The thesis says build should feel like play, and play should write the story. This scene did that in a very specific way: the work of moving and renaming the product produced the story of what the product is actually for.

Not a generic AI bookmark manager. Not a speculative marketplace. Not a crypto-gated vault economy. A quieter product: a memory space for material a user has deliberately marked as worth returning to.

### Progress to goal

The scene's goal was to capture marrk.space's move into BorAI, name it as the current product wedge, preserve the verified migration state, update the chapter index, and keep the beta-readiness boundary honest. That landed.

The scene also went further than its initial goal. The rename moved into the package itself, and verification passed: workspace install, package verify, frontend/server tests, backend compile, production audit, web export, and Django tests against the existing local Postgres credentials.

What did not land: deployment. The Render/Docker caveat remains. Open beta remains blocked by deployed auth validation, backend persistence coverage, production job queues, observability, privacy/legal endpoints, and one live ingestion path.

### Next scene

**Scene 2b-03 — marrk.space deployment readiness.** Make the BorAI monorepo path deployable without relying on the old standalone root assumptions. The scene should decide the deployment shape, provision or document the correct environment variables under the `MARRK_SPACE_` prefix, validate staging, and prove one ingestion path end-to-end.

The teenyweeny parser/flashcard renderer is not cancelled. It is deferred as a separate product track. It should not block marrk.space reaching beta.

### Artifact format

Essay and newsletter. The essay carries the strategic argument: the product name was adoption infrastructure, not surface polish. The newsletter carries the operational version: marrk.space is now the package-level product wedge, verified but not yet deployed.

---

## Notes

- The scene should not pretend marrk.space is open-beta-ready. The audit says the opposite, and that honesty is more useful than launch theatre.
- The most likely successor scene is a deployment-readiness scene: make the BorAI monorepo path deployable for marrk.space without relying on the old standalone root assumptions.
- Product name is now `marrk.space`; package slug is now `marrk-space`.
