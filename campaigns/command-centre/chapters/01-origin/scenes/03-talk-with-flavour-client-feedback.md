---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 03
title: "Talk with Flavour — client feedback loop"
status: concluded
date_opened: 2026-04-20
date_concluded: 2026-04-20
characters:
  - "[[nathan]]"
  - "[[general-business-archetype]]"
  - "[[restaurant-owner-archetype]]"
artifact_format: essay
artifact_file: "[[03-when-the-clients-corrections-become-the-product]]"
tags:
  - client-work
  - landing-page
  - chapter-1
  - feedback-loop
  - positioning
---

# Scene 03 — Talk with Flavour · client feedback loop

*Chapter 1 — Origin · Campaign: [[command-centre]]*

The preview went out. The client came back. This scene is the loop closing — and the positioning correcting.

---

## Set the Stage

### How did we get here?
Scene 02 shipped a live preview for [[nathan]]'s landing page. He has now reviewed it and come back with structured feedback. His response reveals a category mismatch: the V1 page positioned him as a **premium restaurant videographer**; he is actually building a **media platform focused on founder storytelling that drives attention and footfall**. Same deliverables. Different product.

### Where are we going?
A V2 preview that repositions Talk with Flavour as a platform, not an agency. Six substantive edits:

1. Hero headline + subheading, outcome-driven, founder-storytelling-led
2. New section: **Behind the Counter** — Nathan's signature series, surfaced as core differentiator
3. New section: **What You Get** — three bands (content / method / deliverables)
4. Metrics: replace inflated percentages with grounded, specific numbers
5. Voice register: shift from "we / I" to brand-led third person ("Talk with Flavour captures…")
6. Pricing: convert fixed figures to "from" prefix

Deploy to Vercel preview by end of session.

### State of the world (project context)
- BorAI monorepo live. `apps/talk-with-flavour` deployed on Vercel as a public preview.
- Theme system (dark + light, semantic tokens via CSS vars) working.
- Stock footage still in place; Nathan's raw footage not yet received.
- No blocker dependencies — this is a pure copy + component pass.

### State of the hero ([[general-business-archetype]] · [[restaurant-owner-archetype]])
The hero doesn't change between V1 and V2. What changes is what the page claims to *be*. The skeptical business owner still lands here; they now meet a platform that publishes founder stories, not a videographer who films restaurants. The felt category does more work than any copy edit.

### State of the protagonist ([[nathan]])
The feedback is confident and specific. Not defensive, not vague. Nathan has a clearer read on his own positioning than the V1 brief captured — which is itself a win for the scene structure. The brief was best-guess; the feedback is authoritative. V2's job is to execute his correction precisely, not to second-guess it.

### This moment in relation to goals
First real feedback loop on the scene structure. Scene 02 tested whether the method could survive contact with paid client work *in the build*. Scene 03 tests whether it survives contact with client *response* — which is the only test that matters commercially. A method that ships but can't absorb feedback is an author's method, not a client-facing one.

### Why now?
Because the loop is open. Every downstream acquisition move Nathan makes routes through this page. Leaving the preview on the wrong positioning for longer than necessary costs him real traffic and real impressions with the wrong frame. Also: the narrative wants this scene. "Client sees V1, corrects positioning, V2 ships with the real brand" is the Chapter 1 beat that proves the method. The Conclude practically writes itself.

---

## Progress the moment

### Goal for this session
Ship V2 preview with all six feedback items executed. No new scope.

- [ ] Scene opened, Set Stage signed off
- [ ] Hero rewritten — headline, subheading, voice, metrics
- [ ] Behind the Counter component created and slotted
- [ ] What You Get component created and slotted
- [ ] Logistics left alone (minor polish if needed)
- [ ] Case studies — voice pass only
- [ ] Pricing — "from" figures, simplified body copy
- [ ] Booking + footer — voice pass
- [ ] `page.tsx` updated with new section order
- [ ] Build passes (`pnpm build`), deploy preview, URL sent to Nathan

### Moment-by-moment capture

- Feedback received from Nathan, 6 structured points + an approval note on logistics.
- Strategic read: this isn't copy polish — it's a category shift (videographer → media platform). Every other edit flows from the category correction.
- Scope decision: voice pass **before** section pass. The alternative (edit each section, then re-edit for voice later) meant rewriting every file twice. One register shift, executed once, touches every file.
- Hybrid copy approach chosen (founder's drafts verbatim where provided; TwF-voice rewrite where direction given): hero headline kept as Nathan drafted it; subheading refined to platform-register ("Talk with Flavour captures the story behind your room — and gets people through the door."); Behind the Counter and What You Get written from Nathan's direction, not from his prose.
- [x] **Hero rewritten.** Eyebrow repositioned from *Restaurant Video Production* to *Founder-Led Storytelling · Hospitality*. Headline is Nathan's draft verbatim. Subheading in brand voice. Metrics replaced with grounded, specific numbers: 20+ restaurants filmed, 18+ founder stories, 40k+ views on top episode — no inflated percentages. Secondary CTA repointed from *See the work* to *Watch Behind the Counter* so the hero routes to the new flagship section.
- [x] **Behind the Counter section created** as the second section on the page — not buried below logistics. Editorial two-column statement layout: large italic title ("Behind / the Counter") + Nathan's platform line ("A founder-led content series capturing the people, process, and story behind hospitality brands") + three pillars (Founder interviews, Kitchen & process, Social-first edits). CTA placeholder links to #work until Nathan's playlist URL is confirmed.
- [x] **What You Get section created** with Nathan's requested three-band structure (Content / Method / Delivery). Pulls the explanation *out* of pricing so pricing can slim down to "from" figures + differentiators only.
- [x] **Pricing restructured** — all three packages now on "from" pricing (£350 / £600 / £1,000/mo). Deliverables list replaced with a single "differentiator" line per package; descriptive copy tightened. Trailing paragraph repositioned away from "we sell up" phrasing.
- [x] **Voice pass — systemic.** All first-person *we/us/our* scrubbed from marketing + layout copy except in one deliberate location: booking headline *"Tell me about your room."* retained as the page's one licensed I-voice moment (invitational register, per Nathan's rule that I is acceptable where it adds personality). Third-person platform register ("Talk with Flavour captures…", "Talk with Flavour sits down with your GM…") now dominates.
- [x] **Logistics manifesto line refactored.** "We work around service, not through it." → "Work around service, not through it." — imperative, no pronoun. Section kept otherwise intact per Nathan's approval.
- [x] **Footer tagline updated.** *Cinematic video for rooms worth filming* → *Founder-led storytelling for rooms worth filming.* Matches hero category. Footer nav expanded to include Behind the Counter + What You Get.
- [x] **Header nav expanded.** Desktop nav: Series · Work · On service · Pricing (4 items, fits the pill). Mobile nav expanded to 6 links + Book CTA. `useActiveSection` section IDs updated to include the two new sections.
- [x] **Build verified.** `pnpm build` clean — 4s compile, 0 TypeScript errors, 0 lint errors. **First Load JS: 159 kB** — identical to V1 despite adding two new sections. Server components with no JS dependencies are effectively free at runtime.
- Deploy stumble, worth capturing: first `vercel --yes` ran from inside `apps/talk-with-flavour/` and failed with *"The provided path `~/code/BorAI/apps/talk-with-flavour/apps/talk-with-flavour` does not exist"*. The project's Root Directory setting (set in Scene 02 via REST API PATCH) is appended to cwd — so the CLI must run from the monorepo root, not the app dir. CLI also wrote a stray `.vercel/` and `.env.local` into the app folder, both cleaned up before re-running from the correct location.
- [x] **V2 deployed.** `vercel --yes` from `~/code/BorAI/` — 57s end-to-end, 40s build on Vercel, turbo cache miss (expected on a new preview). Preview live at `https://talk-with-flavour-b2d46fdk3-onceuponaprince1s-projects.vercel.app`, HTTP 200, SSO protection persistently off (no re-PATCH needed).
- [x] Conclude block drafted (below).
- Mid-scene side quest: built a PreToolUse hook (`~/.claude/hooks/vercel-preview-guard.sh`) that blocks `vercel` deploys until local preview is confirmed, prompted by the realisation that V2 shipped to a live preview URL without a local `pnpm dev` pass first. Small mistake, small cost — but the right response wasn't "remember next time", it was "make it structurally harder to skip next time". Reasoning offered: deliberate friction is cheaper to build than to live without. Lesson: building helpful things for the process itself compounds faster than grinding the process harder. Conclusion: making mistakes is part of the work; the point of building isn't to ship faster, it's to ship more usefully. The hook is small; the stance it encodes is not.

### What's changing?

- The page's **category** changes. Product, audience, and channel unchanged; positioning shifts from agency framing ("we film") to platform framing ("Talk with Flavour publishes").
- **Voice policy** changes permanently. "Talk with Flavour captures…" is now the dominant register. First-person is reserved for the one invitational moment (booking headline). This is the first Chapter 1 scene where voice is an architectural decision, not just a copy choice.
- **Page structure** grows from 5 marketing sections to 7. The additions (Behind the Counter, What You Get) carry editorial weight and enforce the platform framing.
- **Information architecture shifted.** Pricing no longer carries the explanatory weight — that has moved up the page to *What You Get*. Pricing now does one job (set expectations on range), not three.
- **A second invisible decision landed:** the page now has a "show-first" shape. The hero routes to the series; the footer includes the series as the first nav link. If someone takes only one action on the page, it's plausibly "watch an episode of Behind the Counter" rather than "book a call" — which is the funnel of a media platform, not an agency.
- **Protagonist stance shifted.** From building *for the product* to building *for the process that builds the product*. The Vercel-preview hook is the first artefact of that shift. Process-tooling is now a legit place to invest mid-scene, not a distraction from the scene's goal — a rule that will likely compound across later chapters.

---

## Conclude

### How is now different from the start?
At the start: a V1 preview on the wrong category. Nathan, being Nathan, didn't ask for cosmetic tweaks — he told us the product was wrong. Now: a V2 preview that argues his actual position. Same deliverables, different product. Seven marketing sections instead of five. A voice policy that didn't exist six hours ago. A page that leads with a show, not a pitch. The deliverable shipped; the category survived contact with the client.

### What are the consequences?
- **Nathan has a URL that argues the real business.** Every downstream move he makes — cold outreach, social posts, founder conversations — routes through a page that positions him correctly. The cost of the wrong positioning was invisible until the correction made it visible; now it's paid.
- **A voice policy now exists for Talk with Flavour as a brand.** *"Talk with Flavour captures…"* is the dominant register; first-person is reserved for the one invitational moment. That policy is reusable across future collateral (social copy, email sequences, pitch decks). The landing page is the first artefact that enforces it, not the only one.
- **The scene structure has survived contact with a client's *response*, not just a client's *brief*.** Scene 02 proved the method could ship. Scene 03 proves it can absorb correction. That's the whole point — a method that can only run one direction isn't a method, it's an author's workflow.
- **Pricing has been stripped of explanatory weight.** Customers no longer read paragraphs in each pricing card. They read "from £350" and a single differentiator. The explanation moved up the page to *What You Get*, where it earns its place as synthesis rather than sales copy. Information architecture did the persuasion the copy used to do.
- **Behind the Counter has a home.** Until V2 it was a series Nathan made in private; now it's the platform's flagship. Visible in the hero CTA, named in the nav, present in the footer. The show exists on the page as a thing, not as a reference.

### What did we learn?
- **Voice is architecture, not decoration.** Running the voice pass *before* the content pass saved roughly half the token cost of the work. If the voice rule comes last, every file gets rewritten twice — once for structure, once for register. Standing rule to carry forward: when a stylistic decision affects every file, land the style first, then do the local edits inside it.
- **Category mismatches disguise themselves as copy requests.** Nathan's six-point list read, at first glance, like polish. The strategic read revealed one correction underneath: videographer → media platform. Every bullet flowed from that. Read a feedback list twice — once for its items, once for its centre of gravity.
- **A feedback loop *is* a scene.** The temptation was to treat this as silent iteration — edit the files, redeploy, skip the ceremony. We didn't. The scene held. The capture block is publishable as-is. The iteration itself is narrative material, not an embarrassment to tidy up before the next chapter.
- **Vercel + monorepo has a second setup trap.** Scene 02 caught the Root Directory PATCH requirement. Scene 03 caught its corollary: you must run `vercel` from the monorepo root, not the project root, because the Root Directory setting is *appended* to cwd. An hour of opaque path-not-found errors without that knowledge. Saved to scene as a standing note.
- **The single contribution slot is a feature of the work.** One place was marked as "human taste will outperform the LLM" — the Behind the Counter tagline. That restraint is itself a lesson. A machine-drafted page will feel 80% correct; the remaining 20% is the author refusing to let the machine draft the parts that matter most.

### Progress to thesis
The thesis held in two dimensions today:

**Playing a game:** the session was a sequence of discrete puzzles — category correction, voice policy, deploy path — each with a discrete fix. Not grind. The "green page" of Scene 02 has a sibling in Scene 03: the path-not-found deploy error. Different surface, same texture. Both diagnosable, both small, both narrative.

**Producing the narrative:** the capture block is the artifact in draft form. The seven Conclude questions are the seven beats of a publishable essay. Scene 02 proved that shape on a build; Scene 03 proves it on an iteration. The method covers both directions — forward motion and correction — which is the test that actually matters.

**Caveat:** the loop doesn't fully close until Nathan responds to V2. This scene shipped the iteration; the conversation with Nathan about whether V2 lands closes the loop. That conversation is the next scene's input, not this one's.

### Progress to goal
Chapter 1's arc requires *one shipped deliverable AND one publishable artifact, neither feeling extra*. Scene 02 shipped the first deliverable; its artifact is live. Scene 03 shipped a second instance of the deliverable (the iteration) and produces a second artifact candidate. The chapter is materially closer to closing — possibly one client scene and a synthesis away from the climax.

### Next scene
Two candidates:

- **04 — Misled ethos page.** Already brainstormed on the main thread; Chapter 1's second client proof point. Stage 1 of the staged launch (ethos → tease → pre-order). The method applied to a new category (skate/streetwear movement brand), fresh of feedback scar tissue.
- **03b — Nathan's response to V2.** Short scene; only worth opening if Nathan comes back with substantive feedback. If he approves, the loop closes silently and we move to 04.

**Recommendation: queue 04 (misled) now, leave a stub for 03b that fires only if Nathan's response requires one.** The scene structure shouldn't force ceremony around a green-light email.

### Artifact format
**Essay.** Working title: *When the client's corrections become the product.* Five-beat shape maps cleanly from the Conclude:

1. The preview went out.
2. What came back wasn't polish — it was category.
3. The edits were the thing. The voice pass was the rule.
4. The page now leads with a show, not a pitch. The business it argues is the one Nathan is actually building.
5. The method survived its first correction. That's the only test that mattered.

Artifact file: [[03-when-the-clients-corrections-become-the-product]] *(draft pending)*.

---

## Notes
*Free space.*
