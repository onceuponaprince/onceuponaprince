# marrk.space: naming the product wedge

The useful work was not choosing a nicer name.

That would be too small a lesson. A nicer name is a surface correction. This was a product correction.

marrk.space began as an app for saved material: links, PDFs, notes, media, chats, fragments, sources. The usual graveyard. Everyone has one now. Browser tabs. Read-later queues. Private Discord messages. Screenshots. Voice notes. Half-organised folders in Drive. Obsidian vaults with one corner polished and six corners feral.

The premise was simple enough: if people are already curating high-signal material for themselves, AI should be able to help them turn that material into something retrievable, structured, and useful again.

The mistake would have been to keep treating that as a generic bookmark product.

The more the build progressed, the clearer the shape became. This was not storage. Storage is passive. This was not only search. Search is episodic. This was a vault: a place where marked material becomes a working surface for memory, synthesis, and agentic retrieval.

That matters because BorAI needed a product wedge.

BorAI has the substrate: graph, agents, skills, local-first memory, orchestration, a scene-based ontology for work becoming narrative. It is powerful in the way infrastructure is powerful: real, flexible, and difficult to explain without a concrete object in front of it.

marrk.space gives it that object.

A user does not need to care about Graph-RAG to understand the first loop. Save the thing. Find it again. Ask across it. Get synthesis. Return because the saved material has become useful.

That is the wedge.

Not the marketplace. Not minted vaults. Not agent rentals. Not the social curation economy, even if that thesis still matters. Those are later layers. Some may become real. Some may remain useful scaffolding. None of them should be allowed to stand between the user and the first felt utility.

The product needs to earn trust before it earns complexity.

That is why the name had to change.

The old working title was memorable. That was the problem. It was memorable in a way that made the product easier to notice and easier to dismiss. For a product asking creators, researchers, founder-researchers, and curators to hand over private context, saved sources, and half-formed research trails, the wrong kind of memorability is a tax.

marrk.space is quieter. It is still opinionated. It keeps the useful verb underneath the product: mark the thing, make a space for it, return when it matters. It suggests an action and a container without over-explaining either. It can sit in a browser extension, a product deck, an email subject line, a research workflow, and a deployment dashboard without making the user do extra social work to defend it.

That sounds like branding. It is really adoption infrastructure.

The scene only became load-bearing when the codebase followed the name.

It is easy to write "we renamed the product" in a document. It is harder, and more honest, to make the package agree. The app moved into BorAI as `apps/marrk-space`. The package became `marrk-space`. The root scripts changed. The Expo app identity changed. The deployment labels changed. The environment prefixes changed. The extension copy changed. The Django settings module changed.

The scene stopped being theatre when the system could no longer leak the discarded title through headers, scripts, settings, and docs.

That is the real lesson: narrative decisions have to reach the machinery or they are not decisions yet.

The package now says what the product says. The product now says what the wedge says. The wedge now says what the user should feel first.

Save something worth keeping.

Ask across what you have marked.

Turn private curation into usable memory.

There is still a lot not done.

marrk.space is not open-beta ready. Deployment still needs real staging and production validation. Auth has to behave correctly across web and future React Native clients. Backend persistence has to finish replacing demo-local flows. One ingestion path has to work end-to-end outside the developer machine. Observability has to catch failures before users have to explain them. Privacy, export, deletion, and AI-processing consent have to become product surfaces, not intentions.

But those are better blockers than ambiguity.

Before this scene, the product had too many possible futures competing for the same sentence. After it, the next sentence is simpler:

marrk.space is BorAI's first durable vault product.

It is an AI memory vault for everything worth marking.

Now it has to deploy.
