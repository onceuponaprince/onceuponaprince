# marrk.space is now the product wedge

This week’s useful shift was not a feature.

It was a naming decision that reached the codebase.

marrk.space is now the product wedge for BorAI: the first durable user-facing vault surface where saved material becomes searchable, structured, and useful again.

The loop is deliberately narrow:

- Save the thing.
- Find it again.
- Ask across it.
- Get synthesis.
- Return because the saved material now has value.

That narrowness matters.

The broader system still has larger ideas inside it: Graph-RAG, agents, vault permissions, marketplace scaffolding, minting, social curation, and eventually richer monetisation. But the first users do not need the whole cathedral. They need the first room to work.

The old working name was doing the wrong job. It was memorable, but not trustworthy enough for a product asking creators, researchers, and curators to bring private context into a vault.

marrk.space is calmer. It keeps the verb: mark the thing, make space for it, return later. It also gives the product room to be taken seriously in the places it needs to live: browser extension, research workflow, beta invite, deployment dashboard, and eventually public vault.

The important part: the rename is not just prose.

The package moved to `apps/marrk-space`. The package name is now `marrk-space`. Root scripts, Expo identity, deployment labels, environment variable prefixes, extension copy, and the Django settings module now follow the same decision.

That is the standard from here: if the narrative changes, the machinery has to agree.

What is done:

- marrk.space is inside BorAI as the live vault-product track.
- The codebase package rename is complete.
- Workspace verification passed.
- Frontend/server tests passed.
- Backend compile passed.
- Production audit passed.
- Web export passed.
- Django tests passed against the existing local Postgres credentials.

What is not done:

- It is not deployed.
- It is not open-beta ready.
- Auth/session behaviour still needs deployed validation.
- Backend persistence still needs to absorb the remaining local/demo flows.
- One ingestion path needs to work end-to-end in the wild.
- Privacy, export, deletion, and AI-processing consent need to become real product surfaces.

That is the next scene: deployment readiness.

The product now has a name that can carry trust. The package now agrees with it. The next test is whether a real user can mark something, return to it, and feel the system begin to compound.
