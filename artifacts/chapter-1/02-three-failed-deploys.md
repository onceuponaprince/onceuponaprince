# Three failed deploys and a green page that wasn't

Wednesday evening. Dev server at `localhost:3001`. Refresh.

The hero is a flat forest-green rectangle. No headline, no eyebrow, no sub-copy, no CTAs. Just green.

View source — everything's there. Every paragraph, every link, every stat. All of it stuck at `opacity: 0`, waiting for a client-side motion library that wasn't showing up to the job.

I spent forty-five minutes on the wrong theory — which framer-motion version, which React 19 compat layer, which variant-propagation edge case. Then the obvious landed: don't run a JavaScript animation library for content that has to be visible on first paint. Replaced five `<motion.div>` entries with a CSS `@keyframes` rule and `animation-fill-mode: both`. Content appears before React hydrates. Bulletproof.

That green page was one moment in Scene 02. The scene was about something bigger.

## What the scene was for

Chapter One of the AI Command Centre campaign has a single constraint: no webapp, no agent. Just markdown files, discipline, and real paid client work. The thesis under test is the product's own: *building a startup should feel like playing a game, and the act of playing it should produce the narrative that sells it.*

If I can run this by hand and produce both a shipped deliverable and a publishable artefact — without either one feeling like extra labour — the thesis has legs. If I can't, the thesis needs revision before any code gets written.

Scene 02 was the first test. The deliverable: a landing page for Nathan, a restaurant videographer with strong footage and no funnel. The artefact: this essay.

## What got built

A live preview URL. Five sections — hero, a logistics block that pre-empts the restaurant owner's dominant objection (*"will the shoot disrupt service?"*), three case studies, opinionated pricing in a menu-style stack, and an inline Calendly embed themed to the brand palette. A floating pill header with a scroll progress tracker, active-section highlighting, mobile nav, and a dark/light theme toggle. A footer. A new Turborepo called BorAI, which is the product's actual name.

Along the way, the restaurant-owner archetype broadened into a general *unsure-operator* umbrella, so the landing page works for cafés, bars, and small hospitality brands without rebuilding. The brand's lime accent shifts to muted green in light mode — pure lime against cream reads neon. A component kit built from scratch on `clsx + tailwind-merge + cva + motion`, no shadcn, because the editorial register needed something hand-tuned.

All of that in one session. None of it feels like the point.

## The three failed deploys

The point is this.

**Deploy one.** `vercel --yes` from the monorepo root. Rejected: *"Project names must be lowercase."* The directory is `BorAI`. Uppercase not allowed. Fixed by re-linking with an explicit `--project talk-with-flavour`.

**Deploy two.** Runs further this time. Then fails: *"No Next.js version detected."* Vercel was inspecting the root `package.json`, which has no `next` — only Turborepo, Prettier, TypeScript. The Next.js app lives in `apps/talk-with-flavour`. Vercel needs a Root Directory setting. The CLI has no flag for it. `vercel.json` doesn't accept the field. Fixed with a single REST API PATCH.

**Deploy three.** Build succeeds. Preview URL returns HTTP 401, SSO-gated. Default on Pro team scopes. Another PATCH — `{"ssoProtection": null}` — and the URL goes public.

Three fixes, three curls, one deployment.

## What the method actually produces

Two outputs came out of this scene. One is the preview URL. The other is this essay.

The essay isn't a retelling of work that happened elsewhere. The scene's Conclude block in the vault is the five-beat structure of a build-in-public post — how is now different, what are the consequences, what did we learn, progress to thesis, progress to goal. The Moment-by-moment capture is the raw material. Every sentence you're reading was already in the vault before I sat down to publish.

The doing and the telling are the same act. The work and the writing are continuous. That's the thesis, playing out live.

There's a caveat worth naming honestly. The loop isn't fully closed yet. This essay exists; publishing it is still a separate step. The scene structure produces narrative in the vault. The journey from vault to published artefact remains manual. That's Chapter 1's handover to Chapter 2: the webapp step is where play-to-published actually completes, and it hasn't completed yet.

## Why the failures stay in

The old instinct would have been to bury the three failed deploys. Smooth them out, make the deployment section read as *"then I shipped to Vercel."* That's the dominant aesthetic — the frictionless founder, the clean ship, the ops stuff that doesn't show up in the narrative.

The method inverts that. Friction is the content. The green page would normally be a commit message nobody reads. Here it's the turning point of an essay. The three failed deploys would be one line of a status update. Here they're their own section, because they are what actually happened.

Build-in-public without the friction is a lie. The method puts friction first — not as a performance of struggle, but because it was always the story. The thing that would normally be buried is the thing the narrative is made of.

## Next

Scene 03 is Nathan's feedback on the preview. That's the test result — whether the method produced something he can actually use. Short scene; one session. After that, Chapter 1 closes on the weekly synthesis, and the webapp gets built in Chapter 2.

Preview URL: [talk-with-flavour-iccpqbe61-onceuponaprince1s-projects.vercel.app](https://talk-with-flavour-iccpqbe61-onceuponaprince1s-projects.vercel.app).

Source: [github.com/onceuponaprince/borai.cc](https://github.com/onceuponaprince/borai.cc) (not yet pushed — this post ships first).

---

*Second post in the AI Command Centre build-in-public series. Chapter 1 — Origin, Scene 02. First post: [Build should feel like play. Play should write the story.](01-build-should-feel-like-play.md)*
