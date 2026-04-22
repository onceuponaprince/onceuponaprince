# teenyweeny.studio landing page — design

*Date: 2026-04-22 · Scene: [[01-study-buddy-waitlist-landing]] · Chapter: [[02b-products-that-sell]]*

Orchestrator-prepared landing design for Scene 2b-01, second pass. Project handle pivoted from `study-buddy` to `teenyweeny.studio` on 2026-04-22; visual register pivoted from editorial-scholarly to zine on the same day. Copy preserved verbatim — the arguments hold regardless of register; only the wordmark and product-name mentions swap. Architecture preserved — the seven-section shape was the right shape; only the surface treatment changes. The actual build inside `~/code/BorAI/apps/study-buddy/` is deferred to a BorAI session with Prince present.

**Supersedes:** `docs/superpowers/specs/2026-04-21-study-buddy-landing-design.md`. The 2026-04-21 spec stays in place as the rejected direction — useful for the Conclude block's *what we learned* beat. Why it was rejected: it would have given the Resource Curator a *small-press publisher* feel, scholarly and trusted but slightly removed from their actual self-image. The Resource Curator is a practitioner first, a publisher second — they think of their vault as a workshop, not a journal. The zine register sits closer to that workshop posture.

## Founder-gated decisions (resolved)

### 1. Domain — `teenyweeny.studio` ✓

Resolved by founder. The `.studio` TLD reads as workshop / practice-space, which matches the Resource Curator's self-image better than `.page` (which reads publication-y). Cost is comparable (£15–25/year for `.studio`).

The 2026-04-21 spec's `studybuddy.page` recommendation is retired.

### 2. Wordmark — URL-as-wordmark ✓

Resolved by founder. There is no separate brand name. *`teenyweeny.studio`* is the wordmark. Header, footer, `<title>`, social cards, email-from address — all use the URL as the literal identity.

This is a discipline as much as an aesthetic. URL-as-wordmark sites can't drift into logo-redesign budget cycles. The brand is the domain registration; if the brand changes, the domain changes. Cheap to maintain, expensive to lie about.

In-copy substitution rule: where the 2026-04-21 spec said *Study Buddy*, this spec uses *teenyweeny.studio* — set in the body's monospace, never bolded mid-sentence (the wordmark earns its weight through context, not formatting).

### 3. Waitlist infrastructure — unchanged from 2026-04-21 spec

Inherits Misled's pattern. Required env vars and infrastructure shape are identical to the previous spec; only the from-address changes:

- `NEXT_PUBLIC_SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY`
- `RESEND_FROM_ADDRESS` — `hello@teenyweeny.studio`
- `CRON_SECRET`

Separate Supabase project per the previous spec's reasoning (own dashboard, own RLS, no bleed into agency client data).

### 4. Visual register — zine ✓

Resolved by founder. Replaces the editorial-scholarly direction.

**Typography:**

- **Display + body**: a single monospace family doing both jobs. Recommended: **JetBrains Mono** (excellent reading rhythm, generous proportions, available in regular and bold weights, free, already familiar to the Resource Curator audience who read terminal output every day). Fallback: IBM Plex Mono (slightly more institutional). Avoid Space Mono — it reads design-y rather than honest.
- **Discipline:** body copy is mono *regular*; headings are mono *bold*. No italic — italic mono is an aesthetic mistake. For the load-bearing one-liners that the previous spec rendered as italic editorial pull-quotes, use **bold + indent + a leading bullet rule** instead. The emphasis carries through structure rather than slope.
- **No serif, no grotesque, no display face.** One family, two weights. The whole site reads like a well-typeset README.

**Colour palette:**

- **Surface:** warm cream (`#F5F0E8`) — closer to photocopy paper than to clinical white. The slight warmth is the entire reason the page reads zine rather than terminal. Avoid pure white.
- **Ink:** near-black with brown undertone (`#1A1614`) — softer than `#000`, holds up against the cream surface without crushing.
- **Accent:** rust (`#B7410E`) — single bold accent, used sparingly. Permitted uses: links, the URL-as-wordmark, the primary CTA button background, dotted-rule colour, list bullets, the section-number markers (`§ 01`, `§ 02`...). Forbidden uses: paragraph fills, large-area panels, gradient stops. The accent earns its impact from scarcity.
- **No secondary tints.** No callout backgrounds. No alternating row stripes. Discipline: surface, ink, accent, full stop.

**Photocopier-grain treatment:**

- Subtle SVG noise overlay on the page background, opacity ~0.04. Just enough to suggest the page was reproduced rather than rendered. Built once as a CSS background-image on `<body>`; no per-element grain.
- No grain on the rust accent fills themselves — rust on grain reads muddy.

**Rules and ornaments:**

- Section dividers: dotted horizontal rules in rust, full content-width, with a section number and label centred-floated above (`· · · · · § 03 · POSTURE · · · · ·`). Sets the zine register without leaning on aggressive ornaments.
- Numbered lists use monospace section markers (`01.`, `02.`, `03.`) in rust. No CSS counter abstractions; just literal markers in the markup, since they're load-bearing visual elements.
- The footer carries an ASCII rule (`= = = = = = = = = = = = = = = = = = = = = = = = = =`) before the colophon line. Justified.

**Layout:**

- Mobile: single column, content-width 92vw, 18px body type.
- Desktop: single column still, max-width `64ch` (~640px), centred. Generous top/bottom margins per section (96px). Zines don't sprawl into 12-column grids — they're narrow, paginated, readable on the bus. The desktop layout honours that.
- Header: sticky, white-on-cream with a 1px rust bottom-border. Wordmark on the left, *Join waitlist* button on the right. No nav menu — this is a one-page site.

### 5. Architecture decisions inherited (unchanged)

These carry from the 2026-04-21 spec without modification:

- Runtime-import architecture (vault parsed client-side in the user's browser)
- No shadcn/ui — hand-rolled Tailwind
- CSS keyframes for above-the-fold entry animations (per the v12-for-React-19 memory)
- Dashboard-Git deploy integration (no CLI-first per the local-preview-before-deploy memory)
- Pre-push hook catches lint + typecheck before build burns

## Landing page architecture

Single-page, seven sections. Section count and component shape unchanged from the 2026-04-21 spec — the architecture was correct; only the chrome changes.

```
<Header />
<Hero />               // § 01
<WoundParagraph />     // § 02
<Posture />            // § 03 — three pillars
<HowItWorks />         // § 04 — three steps
<WaitlistForm />       // § 05
<ForAndNotFor />       // § 06
<Footer />             // § 07
```

Component shape, with zine-register notes:

- **Header** — minimal; `teenyweeny.studio` wordmark in mono bold rust on left, *Join waitlist* button on right (rust fill, cream text, no rounded corners — sharp 2px radius at most). Sticky on scroll with a 1px rust bottom-border.
- **Hero** — headline + sub + primary CTA. Headline in mono bold ~48px desktop / 32px mobile, ink colour. Sub in mono regular ~18px, ink. CTA same shape as the header button. No hero image at MVP; typography carries the weight, and the zine register makes that posture honest.
- **WoundParagraph** — body block in mono regular, ~18px. The closing one-liner is rendered as a separate block: bold + indented 1ch + leading rust bullet rule (`· `). Replaces the previous spec's italic editorial pull-quote.
- **Posture** — three sections stacked (no three-column desktop layout — zines don't column). Each section is a mono-bold heading + a paragraph. Section dividers between them are full-width dotted rust rules.
- **HowItWorks** — numbered list with mono section markers (`01.`, `02.`, `03.`) in rust. Each step is a mono-bold heading on the same line as the number, followed by a paragraph indented to align with the heading text (so the rust numbers stand free in the left margin).
- **WaitlistForm** — single email input + single role select + button. Inputs styled honest: cream background, 1px ink border, rust border on focus, no rounded corners. The Misled honeypot pattern carries over unchanged.
- **ForAndNotFor** — two stacked sections (not two-column desktop — same zine reasoning). Each section is a mono-bold heading and a tight bulleted list with rust `·` bullets.
- **Footer** — ASCII divider rule, then mono regular colophon line, then a second mono regular line with the mailto + yurika.space + BorAI mention. Ink colour, no rust except in the email link.

## Landing copy

Preserved from 2026-04-21 spec. Only product-name mentions swap from *Study Buddy* → *teenyweeny.studio*. Argument structure, voice, and order all hold.

### Header

Wordmark: *teenyweeny.studio*
Button: *Join the waitlist*

### Hero

**Headline:** *Send your vault. Not a software manual.*

**Sub:** *teenyweeny.studio turns a curated Obsidian vault into a zero-install study tool your audience can actually use. No accounts. No plugin chains. No Obsidian required.*

**Primary CTA:** *Join the waitlist →*

### Wound paragraph

You've spent hundreds of hours building a vault on something you know too well to teach casually. You send it to a peer. They ask how to open it. You send instructions. They install Obsidian. They install the spaced-repetition plugin. Your frontmatter doesn't parse. They give up.

· *The work is private. The distribution is broken.*

### Posture (three pillars)

**Zero-install for your audience.**
They drop your vault into a browser. That is the whole onboarding. No accounts, no plugin chain, no Obsidian required. A page your students can open the way they'd open a PDF.

**Privacy-first by construction.**
Your vault is parsed in the reader's browser. It never touches a server. You keep your intellectual property; your students keep their study data. Clearing browser history loses progress, not privacy.

**Distribute under your own brand.**
Custom players for curators with an audience — your domain, your visual identity, your students. The platform is invisible where it should be. A player is a player, not a SaaS login screen.

### How it works (three steps)

1. **Zip your vault.** Your existing Obsidian folder, as-is. Structure what you already have. No restructuring, no migration, no plugin chain to maintain in a new place.

2. **Preview the player.** Drop the zip into a browser to see what your audience will see. Flashcards, dashboards, spaced-repetition — all rendered from your markdown and frontmatter. What you wrote is what they read.

3. **Share the URL.** Your audience opens it in any browser. They study. Their progress stays on their device. You haven't had to teach them a new tool; they haven't had to trust a new platform.

### Waitlist form

**Headline:** *Be among the first curators.*

**Sub:** *A small group of curators goes first. We'll email you once, when teenyweeny.studio opens to you. Not before.*

**Fields:**
- `email` — single input
- `role` — single select: *I curate vaults* / *I'm a student* / *I'm curious*

**Button:** *Request access*

**Confirm state:** *Thank you. Check your inbox for a confirmation link.*

### For / Not for

**This is for:**
- Practitioners with specialised vaults — blockchain engineers, comedy writers, legal specialists, art historians, anyone whose audience is more interested in their expertise than in learning a new software suite.
- Curators who'd rather their work reach ten serious students than ten thousand casual ones.
- People who treat the privacy of their notes as a commitment, not a feature.

**This is not for:**
- General students looking for a flashcard app. That tool already exists.
- Curators whose distribution works fine on existing platforms. Ship there first.
- Teams wanting to manage student progress centrally. teenyweeny.studio keeps progress on the student's device, on purpose.

### Footer

`= = = = = = = = = = = = = = = = = = = = = = = = = =`

*teenyweeny.studio — an experiment in publishing what you know without platforming it.*
*hello@teenyweeny.studio · [yurika.space](https://yurika.space) · BorAI · 2026.*

## Voice notes for future scenes

Carry from the 2026-04-21 spec, with one addition:

- Write to the Resource Curator. Never to the student.
- Do not say "democratise". Do not say "revolutionise". Do not say "empower".
- British English throughout (per vault convention).
- Load-bearing one-liners get bold + leading rust bullet rule (` · `), not italics. Italics in mono read as a typesetting accident.
- The wider universe ([[yurika]], [[the-guild]], the agency) is footer-only.
- **New:** the wordmark is the URL. Never bold *teenyweeny.studio* mid-sentence. It is set in the body's monospace; its weight comes from the reader recognising it as the address bar of the page they're on. Bolding it would be like bolding the page title in the page's own copy.

## Out of scope for this document

- React component code.
- Backend route handlers (Misled's `app/api/subscribe/route.ts` and `app/confirm/[token]/page.tsx` are the templates).
- Vercel project configuration — Prince links the project and applies Root Directory `apps/study-buddy` (note: directory name unchanged for now; rename of `apps/study-buddy/` → `apps/teenyweeny-studio/` is a BorAI-session decision, deliberately deferred).
- A/B tests on copy. Ship this draft; test from feedback.

## Build sequence on founder-next-available

1. Domain `teenyweeny.studio` purchased + DNS configured.
2. Supabase project created for teenyweeny.studio; migration from Misled copied + adapted (table name, schema same).
3. Resend domain verified; `hello@teenyweeny.studio` sending.
4. `apps/study-buddy/` scaffold extended with landing route + components per architecture above. (Branch + directory rename deferred — change one thing at a time; the rename is a follow-up commit, not part of the landing build.)
5. Copy drafted into components; voice pass matches this spec.
6. `.env.example` + `.env.local` configured; deploy via dashboard-Git per the local-preview-before-deploy memory.
7. Smoke-test the URL you plan to send, not the URL you assume is serving (Scene 04's standing rule).
8. First confirm email received end-to-end by a real inbox.
9. Scene 2b-01 Conclude drafted from captured work; artifact format decided.
