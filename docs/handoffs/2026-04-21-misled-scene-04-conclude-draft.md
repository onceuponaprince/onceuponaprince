---
title: Misled — Scene 04 Conclude block draft
date: 2026-04-21
status: draft, awaiting Prince's edit + scene seal
---

# Scene 04 Conclude block draft

*Drafted by Gemini, light orchestrator edits (fixed the 'next scene' reference — Scene 05 has already concluded; the next scene in Chapter 1 is the Chapter 1 close / weekly synthesis). Do not merge into `04-misled-ethos-page.md` until Prince approves.*

---

### How is now different from the start?

We started with a PDF brief and a hollow shell. The site was a `coming soon` placeholder with no pulse. Now: it is a functional engine. Supabase is live. The Resend double-opt-in flow handles confirmations through a custom API route and an inline Y2K-styled email template. The scanlines, the typography, the Win95 chrome are all in sync with a backend that will actually accept and remember a user.

### What are the consequences?

The client has a preview URL that feels like a final product, not a mock. The infrastructure is self-cleaning: a Vercel Cron job purges unconfirmed subscriber rows every seven days. A pre-push hook guards against the trivial lint errors that previously burned build cycles. One tactical loose end: production at `misled.vercel.app` still points at `main`, so the public URL is a ghost town until the Vercel production branch is retargeted. That decision is not a merge; it is a dashboard flip, and it stays with the founder.

### What did we learn?

Defaults are dangerous. The Vercel production branch did not align with momentum: it had to be named and chosen. A pretty interface is no shield for sloppy devops: documentation and hooks are the only things that stop play from turning into mess. The load-bearing lesson is simpler still: smoke-test the URL you plan to send, not the URL you assume to be serving. A twenty-second curl earlier in the session would have caught the deploy mismatch before the backend work began.

### Progress to thesis

Build should feel like play. Play should write the story. The play was the typographic and aesthetic stack: Anton, Press Start 2P, VT323, the vaporwave horizon lifted from Maxime Heckel, scanlines layered on CRT. The story is the resulting system: an opinionated surface that now persists real users, sends real emails, and cleans up after itself. The aesthetic shaped the architecture. The backend exists only to support the world the frontend invented.

### Progress to goal

Chapter 1's goal is from insight to manual proof on real client work. Scene 04 was always the one that had to carry the proof: the client work, shipped, end-to-end. That is what this session delivered. Not theory, not internal infra: a live site for a paying client, with a working subscriber flow and a distinctive voice. The preview URL is the evidence. The outstanding items (mobile check, send the message, decide on production branch) are Prince's to close, but the work itself is done.

### Next scene

**[[06-chapter-1-close-weekly-synthesis]]**. Chapter 1's final scene: weekly synthesis, stepping back from individual client work to notice what the method produced in the round. Scene 05 (two side-projects) already concluded earlier this session. The branch for Misled can merge into production on Prince's decision; it does not require its own scene.

### Artifact format

**Thread + essay.** The thread compresses the five-beat arc of the session and lands on the deploy-mismatch lesson — a clean, shareable lesson that travels alone. The essay takes the longer arc: why 'build should feel like play' showed up literally in this scene, why the Y2K choice was load-bearing rather than decorative, and why the most honest lesson (smoke-test the URL you intend to send) is not advice anyone wants to learn the hard way.
