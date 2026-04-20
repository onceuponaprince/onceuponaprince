# When the client's corrections become the product

Saturday morning. Preview URL sent to Nathan the night before. His reply lands a few hours later — not the thumbs-up I half-expected, not a list of typos either. Six structured points. A category correction underneath.

The first line of his feedback says it cleanly:

> *"At the moment it leans a bit more towards a 'video production company', but what I'm building is closer to a media platform focused on founder storytelling that drives attention and footfall."*

Same deliverables. Different product.

## What the V1 page was selling

The version I'd shipped was, in effect, a premium restaurant videographer's site. Hero: *"The art of bringing people to the table."* Sub-copy: *"Cinematic video for restaurants and hospitality operators who take themselves seriously."* Eyebrow: *Restaurant Video Production.* Three case studies, pricing in a menu, a logistics block that pre-empted the shoot-disruption objection. Everything on brand, everything coherent — and all of it arguing the wrong business.

The failure wasn't in the writing. The writing was fine. The failure was in the brief. I'd written the page for a videographer who does a good job; Nathan was running a media platform that happened to shoot.

## Six notes, one correction

His list looked, at first glance, like copy polish. Read again, it was one correction repeated in six places.

- The hero needed to lead with the outcome — *founder-led storytelling* — not the medium.
- The platform's signature series, *Behind the Counter*, was nowhere on the page. On a media platform's site, the show comes second, not sixth.
- The *What You Get* section needed to read like an editor's brief, not a deliverables list.
- Metrics needed to be specific, falsifiable, un-inflated — the language of a masthead, not a SaaS dashboard.
- Voice had to shift from "we / I" to brand-led third person. *Talk with Flavour captures…* Platforms talk in the third person. Freelancers and agencies don't.
- Pricing had to stop trying to explain the relationship and just set expectations — *from* figures, confirmed at the walkthrough.

One throughline: the page should stop announcing a service and start behaving like a publication.

## The edit order

Six files, one voice register shift, two new sections. The instinct was to work section by section. That's the trap. A stylistic rule that touches every file — third-person brand voice instead of first-person team voice — has to land *before* the local edits, or every file gets rewritten twice.

So the first pass was the voice pass. *We work around service, not through it* became *Work around service, not through it.* *We sit down with your GM and head chef* became *Talk with Flavour sits down with your GM and head chef.* No content changed; the register did. Once the register was settled, the content edits fit inside it cleanly.

One deliberate exception: the booking section's headline — *"Tell me about your room"* — stayed in the first person. A strict read would sweep it out, but that line is the invitational moment of the page. Reframing it to third person (*"Tell Talk with Flavour about your room"*) reads like a form field, not a conversation. Voice rules earn their place by making a page better; they're not a spelling bee.

## What the page became

Two new sections landed. *Behind the Counter*, introduced as the second section on the page — right after the hero, not sixth — given the editorial weight of a flagship, not a service line. And *What You Get*, a three-band synthesis (content, method, delivery) placed before pricing, so pricing could slim back to its real job.

The hero's secondary CTA was re-routed from *See the work* to *Watch Behind the Counter*. The footer's nav now leads with the series. If a visitor takes one action on the page, it's plausibly *watch an episode* rather than *book a call*. That's the funnel of a media platform, not an agency.

The copy shifted in places but the information architecture shifted more. Hero → Series → Logistics → Work → What You Get → Pricing → Book reads *platform → evidence → conversation*. The old order read *pitch → sell → close*. Same page, same sections, different business.

## The method surviving a correction

Scene 02 proved the method could ship something — a real preview, through a real stack, under a real client's name. That was the first test.

This was the second, and the one that matters commercially. A method that only runs one direction — brief to build — isn't a method, it's an author's workflow. The real question is whether it can absorb correction when the correction is substantive. Can the scene structure hold when what came back wasn't polish but a category shift?

It held. The feedback arrived on Saturday morning. The V2 preview went out Saturday afternoon. The scene's Conclude block is this essay, more or less unedited. The iteration was the scene. The scene was the content.

## A side quest worth naming

One moment of the session didn't belong to the main plot but earned its place anyway. The V1 redeploy had gone straight to a live preview URL without a local `pnpm dev` pass first. Small mistake, small cost — the V2 happened to look right in production anyway. But the impulse wasn't *remember next time.* It was *make it structurally harder to skip next time.*

A hook now blocks `vercel` deploy commands until the local preview has been confirmed. Ten minutes to build. The stance it encodes is the larger point: making mistakes is part of the work, but the point of building isn't to ship faster — it's to ship more usefully. Process-tooling is a legitimate place to invest mid-scene, not a distraction from the scene's goal. The hook is small; the stance it encodes is not.

## Next

Scene 04 is the next client: *Misled*, a London skate and streetwear brand with a staged launch — ethos, tease, pre-order. A new category, same method. Nathan's response to V2 will fold into Scene 03's Conclude silently if he approves, or open its own small scene if he comes back with more.

V2 preview: [talk-with-flavour-b2d46fdk3-onceuponaprince1s-projects.vercel.app](https://talk-with-flavour-b2d46fdk3-onceuponaprince1s-projects.vercel.app).

Source: [github.com/onceuponaprince/borai.cc](https://github.com/onceuponaprince/borai.cc) (monorepo; the Talk with Flavour app lives at `apps/talk-with-flavour`).

---

*Third post in the AI Command Centre build-in-public series. Chapter 1 — Origin, Scene 03. Previous: [Three failed deploys and a green page that wasn't](02-three-failed-deploys.md).*
