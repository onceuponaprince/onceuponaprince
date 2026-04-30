---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 02
title: "Talk with Flavour landing page"
status: concluded
date_opened: 2026-04-17
date_concluded: 2026-04-18
characters:
  - "[[nathan]]"
  - "[[general-business-archetype]]"
  - "[[restaurant-owner-archetype]]"
spec_file: null
blockers: []
supersedes: null
artifacts:
  - format: essay
    file: "[[02-three-failed-deploys]]"
tags:
  - client-work
  - landing-page
  - chapter-1
  - yurika-web-template
---

# Scene 02 — Talk with Flavour landing page

*Chapter 1 — Origin · Campaign: [[command-centre]]*

First real test of the manual system on a live client deliverable.

---

## Set the Stage

### How did we get here?
[[nathan]] is a restaurant videographer with strong footage and no funnel. Work has been coming through word-of-mouth, which is volatile. He needs a URL he can point at that does his selling.

### Where are we going?
A landing page that moves a skeptical restaurant owner from *"interested"* to *"booked a call"*. Preview URL by end of session. Live by end of week.

### State of the world (project context)
- Fresh scaffold from `yurika-web-template`
- Theme: **editorial** (Nathan's preference). Style references at `~/code/build-in-public/references/talkwithflavour/` — `talkwithflavour-brand-spec.html`, `talk-with-flavour-styles.html`, `brand-palette.png`
- Assets pending from Nathan; using **stock footage** in the interim
- Deployment target: Vercel preview → production
- Booking: **Calendly embed** (book-a-meeting link)
- Newsletter signup: **Supabase** — deferred, not this iteration
- Blog section planned — **Next.js + Sanity** (headless CMS, Studio under `/studio`). Architecture decided; build deferred to a later scene

### State of the hero ([[general-business-archetype]] · [[restaurant-owner-archetype]])
Umbrella: [[general-business-archetype]] — any business owner who needs video and is unsure who to trust. Sharpest specific instance featured on this page: [[restaurant-owner-archetype]]. 90 seconds max on a page. Been burned before — amateur output last time, or a vendor who didn't understand the business. Wants video that matches their position. *Needs* reputation signals — past work in their vertical, operational sensitivity, clear pricing. Dominant objection: *will this vendor be competent and low-drama*, not price.

### State of the protagonist ([[nathan]])
Creative. Hates selling himself. Work is strong; self-presentation isn't.

### This moment in relation to goals
First infrastructure move for Talk with Flavour. Every downstream acquisition move routes here.

### Why now?
Scene 01 gave the thesis a shape. Chapter 1's arc requires the shape to survive contact with client work. This is the first scene where the method has to earn its place against a deliverable someone is paying for. If it can't, the thesis revises before any code is written.

---

## Progress the moment

### Goal for this session
Ship preview URL. Required sections:

1. Hero with reel (footage-led)
2. Logistics-pre-empted second section
3. Three case studies, visual-first
4. Opinionated pricing visible
5. Booking flow, one-click

### Moment-by-moment capture

- [ ] Theme picked and applied
- [ ] Hero section with reel embedded
- [ ] Logistics section drafted
- [ ] Case studies laid out
- [ ] Pricing section
- [ ] Booking flow wired
- [ ] Preview deployed
- [x] Scene opened, Set Stage revised and signed off
- [x] `general-business-archetype` character created; scene hero broadened to umbrella + specific instance
- Stack decisions made before first commit: **Calendly embed** for booking (dropped Supabase+Resend for this iteration), **Supabase** kept but deferred to newsletter signup only, **Sanity** chosen for blog CMS (deferred to its own scene), **stock footage** as interim for Nathan's pending assets. Editorial theme confirmed per Nathan's preference.
- Hero broadened from restaurant-owner-only to *any business owner who needs video and is unsure who to trust*. New umbrella archetype `[[general-business-archetype]]` created; `[[restaurant-owner-archetype]]` retained as the sharpest specific instance. Decision factors compound — page that serves the umbrella serves the restaurant case too.
- [x] Command Centre gets a product name: **BorAI**. Recorded in `campaign.md` frontmatter.
- [x] BorAI monorepo bootstrapped at `~/code/BorAI/` — Turborepo with `apps/*` and `packages/*` glob. Root configs lifted and adapted from `~/code/yurika.forge` (flagged as proprietary source; confirmed before copying).
- [x] `apps/talk-with-flavour/` scaffolded inside BorAI. Next.js 15 + React 19, TypeScript strict, Tailwind 3.4, framer-motion 11.
- Stack deviation from the `yurika-web-template` skill's defaults: no shadcn/ui, no Zustand, no React Query. Components built from scratch using `clsx + tailwind-merge` (as `cn()`), `class-variance-authority` for variants, framer-motion for motion. Rationale: a static marketing page doesn't need client state libs or a 3rd-party primitive kit — and hand-built components match the brand's neobrutalist-editorial register better than shadcn defaults.
- Brand tokens ported into Tailwind: forest palette (deep / DEFAULT / mid / muted / faint), cream scale, lime accent, custom `font-display` (Instrument Serif via `next/font/google`) and `font-body` (Cabinet Grotesk via Fontshare `<link>` — not on Google Fonts).
- Hero section built: Instrument Serif italic headline *"The art of bringing people to the table."*, eyebrow `Restaurant Video Production`, Cabinet Grotesk sub copy, primary CTA → Calendly (`Book a conversation`) + muted CTA → `See the work →`, stock-footage `<video>` slot with TODO comment for the mp4 asset, three-stat meta row below the fold.
- Bug encountered first paint: page rendered as solid forest green — all hero content present in SSR HTML but stuck at `opacity:0`. Motion's `initial` state was baked into SSR and client-side hydration didn't animate out (likely Next 15 dev Strict Mode double-mount + stagger-without-parent-property variant). Swapped `framer-motion@11` → `motion@12` first; didn't fix it.
- Real fix: ripped JS motion out of the hero's entry animation, replaced with a `.rise-in` CSS keyframe + staggered `animationDelay` per element. Animations now run pre-hydration — bulletproof against any JS failure. Motion v12 stays installed for below-the-fold interactions (scroll-reveal, hover states) where SSR visibility isn't critical.
- Lesson saved to memory: use CSS keyframes for above-the-fold entry animations on Next.js landing pages, not `<motion.div initial animate>`. Related: motion v12 + `motion/react` is the correct package for React 19 going forward.
- Button component extended: `intent: primary | ghost | muted`, `size: sm | default | lg`, `shadow: none | neo | neo-sm`, `loading: true | false` (renders inline spinner, sets `aria-busy`, disables click). Hero's secondary CTA dropped from ghost to muted for a cleaner hierarchy.
- [x] Logistics section built — asymmetric two-column, italic anchor *"We work around service, not through it."* + five numbered operational commitments. Pre-empts the archetype's dominant objection (shoot disruption). Voice: *covers · pass · service schedule · front-of-house* — industry-literate.
- [x] Case studies section built — 3-up grid, CSS gradient placeholders per vertical (forest / amber / plum), anonymous-but-specific descriptors (*Chef-led · Soho · Neighbourhood Italian · Hackney · Natural wine bar · Peckham*). Avoids fabricating restaurant names until Nathan's real portfolio lands; still reads credible.
- [x] Pricing section built — three editorial editions (**The Reel · The Series · The Standing Crew**), menu-style stacked rows with `From £—,—` placeholder figures. Opinionated closer: *"Most rooms graduate to The Series by the second quarter."*
- [x] Booking section built — inline Calendly embed themed via URL params (deep forest bg, cream text, lime primary). `<Script strategy="lazyOnload">` so the ~40kB widget.js only loads when the user scrolls to Section 5.
- [x] Footer built — huge italic serif wordmark closer, three-column nav/contact/method recap, `hello@talkwithflavour.com` mailto, `London — Since 2026` anchor.
- [x] Pill header added — fixed, centered, backdrop-blurred pill with wordmark + nav + theme toggle + Book CTA. Mobile collapses to toggle + wordmark + Book + hamburger at **min-[860px]** breakpoint (moved up from `md:` so the pill never wraps in the ambiguous 768-860px zone).
- [x] Scroll tracker component added — thin lime progress line along the bottom of the pill, spring-damped via motion's `useScroll` + `useSpring`.
- [x] Active-section highlight added — `useActiveSection` hook using IntersectionObserver with `rootMargin: "-40% 0px -55% 0px"` so the active nav link only changes when the matching section is near the vertical centre of the viewport.
- [x] Mobile nav component — hamburger morphs into an X via two absolutely-positioned spans translating to centre + rotating ±45°. Overlay portaled to `document.body` so it doesn't inherit the pill's theme-inverted CSS vars when opening.
- [x] Dark + light theme system — semantic tokens (`surface`, `ink`, `accent`, etc.) in `tailwind.config.ts`, CSS custom properties in `globals.css` swapped via `.light` class on `<html>`. Inline init script in `<head>` reads `prefers-color-scheme` + `localStorage.tf-theme` before first paint to prevent FOUC.
- [x] **Path B for light-mode accents committed:** lime stays only on CTA fills (primary Button, header Book pill, scroll tracker line); text/border accents shift to `green-muted` in light mode per the brand spec's own light-bg logo rule. On cream, pure lime read as neon; green-muted reads sophisticated.
- [x] Header pill inverted relative to page — added `.theme-inverted` class that overrides CSS vars to the opposite theme's values. Dark page → light pill; light page → dark pill. Creates the editorial "floating island of contrast" effect without touching component code.
- All eight existing components refactored from literal color names (`bg-forest-deep`, `text-cream-faint`, `text-lime`) to semantic tokens (`bg-surface`, `text-ink-muted`, `text-accent`). One mechanical pass; all theme behaviour now flows through CSS vars.
- Bug hunt captured to memory as `feedback_motion_v12_for_react_19.md` in the vault's memory store: *use CSS keyframes, not JS motion, for above-the-fold entry animations*. JS motion's SSR-baked initial state leaves content stuck invisible if client hydration misfires — as it did here under Next 15 dev Strict Mode. Motion kept installed for below-the-fold interactions (stagger on mobile nav, scroll tracker).
- [x] Production build verified — 57.1kB route, **159kB First Load JS**, 6.9s compile, 0 type errors, 0 lint errors. Up ~13kB from the hero-only build — the cost of adding motion (scroll tracker, mobile nav AnimatePresence) + theme toggle. Acceptable.
- [x] Initial git commit — BorAI monorepo with the full talk-with-flavour scaffold as a single feat commit, conventional-commits formatted. `ops/borai-inbox/` (plugin-generated) left untracked by design.
- [x] Vercel CLI authenticated interactively via `! vercel login`.
- Vercel deploy fought back three times before landing. Worth recording each:
  - First `vercel --yes` from repo root → **400: "project names must be lowercase"** — `BorAI` rejected. Fixed by `vercel link --project talk-with-flavour --yes` using an explicit lowercase name.
  - First build after link → **"No Next.js version detected"** — Vercel inspected the root `package.json` (no `next` there, only turbo/prettier/typescript). Root Directory defaulted to the monorepo root.
  - Vercel CLI has no flag for Root Directory and `vercel.json` doesn't accept it as a field. Fixed by PATCH against the Vercel REST API: `{"rootDirectory": "apps/talk-with-flavour"}`. Also cleared custom `buildCommand`/`installCommand`/`outputDirectory` so Vercel auto-detects Next.js from the now-correct root.
  - Second deploy succeeded — 40s end-to-end, turbo cache miss (expected on first build), Next 15.5.15 compiled in 9.3s. **Preview URL returned 401**: SSO-gated by default on this Pro team scope. Fixed by another REST API PATCH: `{"ssoProtection": null}`. Preview now public.
- [x] **Preview live: `talk-with-flavour-iccpqbe61-onceuponaprince1s-projects.vercel.app`**. Production domain reserved: `talk-with-flavour.vercel.app` (one `vercel --prod` away).
- [x] GitHub origin set: `git@github.com:onceuponaprince/borai.cc.git` (git config rewrites HTTPS → SSH). Not yet pushed.
- [x] `.gitignore` updated to exclude `.vercel` and `.env*.local` (Vercel CLI edit); second commit shipped.
- **Session goal met:** *preview URL by end of session* — done.

### What's changing?

- Hero broadened from restaurant-specific to umbrella. The restaurant case is now one instance of a wider pattern, which changes what "past work matching their vertical's positioning" means on the page — case studies should read as evidence of *operational fit across verticals*, not just restaurant competence.
- World shifted: booking is Calendly (not Supabase+Resend); Supabase is reserved for newsletter signup; blog moved to Next.js + Sanity in a separate scene. This session's deliverable is narrower than originally scoped.
- World shifted again, bigger: **BorAI now exists as a real Turborepo at `~/code/BorAI/` and is deployed on Vercel.** The vault is no longer pointing at a future product — the product's codebase exists and ships. Agency client work and the future Command Centre webapp will share this monorepo. The three-layer architecture (vault → agent → webapp) now has its second layer in concrete form, not just as a plan.
- World shifted: **a semantic theme-token system now exists** (surface / ink / accent + CSS vars). Any future sibling app in BorAI inherits it. Design decisions from this scene (Path B light-mode accents, theme-inverted header, CSS-first entry animations) are now encoded as reusable defaults, not one-off choices for Nathan's page.

---

## Conclude

### How is now different from the start?
At the start: a commitment to test whether the scene structure survives contact with paid client work. Now: a live public preview URL for Talk with Flavour, five full sections plus header and footer, a theme system that handles dark and light via CSS vars, a mobile-responsive editorial pill header with scroll tracker and active-section indicator, and an entire BorAI monorepo bootstrapped in the process. The product layer of the three-layer architecture has concrete shape.

### What are the consequences?
- Nathan receives a preview URL, not a screenshot. The next move is his feedback, which closes the first real test loop of the method.
- BorAI exists as a real codebase at `~/code/BorAI/` and on Vercel. Future agency client work lives alongside as `apps/*`; the Command Centre webapp (Chapter 2) will inherit the same stack, the same semantic tokens, and the same deployment pipeline.
- The archetype broadening ([[general-business-archetype]]) means Nathan's funnel doesn't need rebuilding when he takes on a café, a bar, or a small hospitality brand. One landing page, multiple verticals.
- A reusable component system (Button with `intent × size × shadow × loading`, SectionLabel, Header, Footer, theme vars) now sits in `apps/talk-with-flavour` — not yet abstracted into a shared package, but positioned to be when a second project demands it.

### What did we learn?
- **The scene structure holds under paid-client pressure.** No padding was needed. The session's real decisions *were* the content — the Conclude isn't paraphrasing the work, it's continuous with it.
- **Starter skills produce opinions, not defaults.** The `yurika-web-template` skill shipped shadcn + Zustand + React Query by default — none of which fit an editorial marketing page. Deviating explicitly (`cn + cva + motion`, no primitive kit) was the right call. Skills are scaffolding, not architecture.
- **SSR + JS motion + above-the-fold is a trap in Next 15 dev mode.** The hero rendered as a solid-green invisible-content page until we ripped motion out of the entry animation and replaced it with CSS keyframes. Saved to memory as a standing rule.
- **Vercel + Turborepo monorepo has a setup cost that isn't in the docs.** Root Directory must be PATCHed at the project level via the REST API (no CLI flag, no `vercel.json` field). Pro team previews are SSO-gated by default. Both fixable in one curl each — but only if you know.
- **Path B over Path A.** Pure lime against cream reads neon; the brand spec's own light-bg logo rule was right all along.
- **Friction is the content.** The deploy failed three times before landing. Each failure was a discrete moment worth capturing, not smoothed over. The thesis in miniature: the thing that would normally be buried is the thing the narrative is made of.

### Progress to thesis
Strong forward motion, with a caveat.

**Playing a game:** the session *did* feel like play — each obstacle was a discrete puzzle (the 401, the wrong Root Directory, the neon lime) with a discrete fix. Not grind.

**Producing the narrative:** the scene's capture block is publishable as-is; the seven Conclude questions are the artifact's five-beat structure. The loop is closed at the vault level.

**Caveat:** the loop isn't closed at the *external* level yet. The artifact (essay) is still pending at time of conclude. The session proved *play produces narrative in the vault*; publishing is still a manual step. That's Scene 02's handover to the future: the artifact step is where play-to-published actually completes, and it hasn't completed yet.

### Progress to goal
Chapter 1's goal is *one shipped client deliverable AND one publishable artifact, neither feeling extra*. This scene shipped the deliverable. The artifact follows as the next piece of work off this scene. Chapter 1 is closer to closing than it was this morning.

### Next scene
Two candidates:

- **03 — Nathan's feedback on the preview.** The real verdict on whether the method produced something usable for him. Short scene; might conclude in one session. Most honest next move — the scene is the feedback loop itself.
- **03 — Blog section with Sanity CMS.** Already scoped and architected. Bigger scene. Less testing of the method, more deepening of the codebase.

**Recommendation: Nathan's feedback first.** That's the test *result*. The blog is a capability; feedback is a judgment. Chapter 1's arc wants the judgment.

### Artifact format
**Essay.** Title: *Three failed deploys and a green page that wasn't*. Artifact: [[02-three-failed-deploys]].

---

## Notes
