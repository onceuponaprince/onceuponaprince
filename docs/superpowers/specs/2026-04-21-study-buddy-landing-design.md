# Study Buddy landing page — design

*Date: 2026-04-21 · Scene: [[01-study-buddy-waitlist-landing]] · Chapter: [[02b-products-that-sell]]*

Orchestrator-prepared landing design for Scene 2b-01. Copy, component architecture, and founder-gated decisions. The actual build in `~/code/BorAI/apps/study-buddy/` is deferred to a BorAI session with Prince present for domain + env decisions.

## Founder-gated decisions

### 1. Domain

Catalogue's hosting cost model assumes a £12/year domain. Three options worth weighing:

- **`studybuddy.page`** (recommended) — `.page` is £10–15/year, ties to the product's core metaphor (a page you open in a browser), reads as scholarly rather than startup-y. Matches the Resource Curator register directly.
- **`studybuddy.xyz`** — cheapest (~£1/year), reads nerdy-correct, loses a little warmth.
- **`study.yurika.space`** (subdomain fallback) — £0, inherits yurika.space authority, but positions Study Buddy as a sub-project of yurika rather than its own product. Resource Curator audience is not the yurika audience; risk of confusion.

Recommendation: **`studybuddy.page`** as primary, `studybuddy.xyz` as fallback if unavailable. Subdomain only if the commercial intent softens.

### 2. Product name

Scene 05's catalogue uses `study-buddy` (kebab-case, code-facing). For public branding, three shapes:

- **Study Buddy** (two words, title case) — warmest; risks generic-flash with existing apps.
- **StudyBuddy** — camel-cased, more tech-product.
- **Buddy** — unclaimable on its own but works as an affectionate short form inside copy.

Recommendation: keep **Study Buddy** as the public brand for now; treat it as a working name that can be sharpened if signals come back unfavourable. Code references stay `study-buddy/`.

### 3. Waitlist infrastructure

Inherits Misled's pattern:

- Supabase `subscribers` table (separate project or shared? — recommend **separate Supabase project** so study-buddy can have its own dashboard and RLS policies without bleeding into agency client data)
- Resend double-opt-in flow
- Vercel Cron for self-cleaning unconfirmed rows after 7 days

Required env vars (founder-gated):
- `NEXT_PUBLIC_SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY`
- `RESEND_FROM_ADDRESS` — recommend `hello@studybuddy.page`
- `CRON_SECRET`

### 4. Visual register

Not Y2K. Editorial, scholarly, tool-first. Proposed typography:

- **Display**: Instrument Serif (already wired in BorAI via TWF) — trusted, warm, literary.
- **Body**: Cabinet Grotesk (already wired in BorAI via TWF) — editorial sans, pairs with Instrument Serif.
- **Mono**: Space Mono or similar — for code blocks / frontmatter samples.

Proposed palette:

- **Surface**: off-white (`#FAF7F0` or similar)
- **Ink**: near-black with warmth (`#14110F`)
- **Accent**: deep green (`#1F4028` or similar — inherits the *vault* metaphor, reads scholarly, shares zero register with Misled's Y2K gold)
- **Subtle secondary**: warm paper highlight (`#E8DDC7`) for callouts

No chrome bevels, no hard-offset shadows, no Win95 dialogs. Typography-first hierarchy. Plenty of white space. Closer to a small-press publisher's website than a SaaS landing.

### 5. Architecture decisions inherited

These are carried from Scene 05's catalogue + earlier scenes' memory and don't need Prince's attention to confirm:

- Runtime-import architecture (vault parsed client-side in the user's browser)
- No shadcn/ui — hand-rolled Tailwind
- CSS keyframes for above-the-fold entry animations
- Dashboard-Git deploy integration (no CLI-first)
- Pre-push hook catches lint + typecheck before build burns

## Landing page architecture

Single-page, seven sections. Section count mirrors TWF V2 (seven sections) and Misled (seven major blocks) — the house shape.

```
<Header />
<Hero />               // 1
<WoundParagraph />     // 2
<Posture />            // 3 — three pillars
<HowItWorks />         // 4 — three steps
<WaitlistForm />       // 5
<ForAndNotFor />       // 6
<Footer />             // 7
```

Component shape:

- **Header** — minimal; Study Buddy wordmark + *Join waitlist* button.
- **Hero** — headline + sub + primary CTA. No hero image at MVP; typography carries the weight.
- **WoundParagraph** — editorial block, italic one-liner at close.
- **Posture** — three-column on desktop, stacked on mobile. Each column is a short heading + one paragraph. No icons.
- **HowItWorks** — numbered list; optional screenshot placeholders in boxes that are captioned rather than decorated.
- **WaitlistForm** — single input + single select + button; copies Misled's honeypot pattern.
- **ForAndNotFor** — two-column list of specifics. Earns its place by naming the Resource Curator out loud.
- **Footer** — mailto, link to yurika.space, one sentence on the mission.

## Landing copy

### Header

Wordmark: *Study Buddy*
Button: *Join the waitlist*

### Hero

**Headline:** *Send your vault. Not a software manual.*

**Sub:** *Study Buddy turns a curated Obsidian vault into a zero-install study tool your audience can actually use. No accounts. No plugin chains. No Obsidian required.*

**Primary CTA:** *Join the waitlist →*

### Wound paragraph

You've spent hundreds of hours building a vault on something you know too well to teach casually. You send it to a peer. They ask how to open it. You send instructions. They install Obsidian. They install the spaced-repetition plugin. Your frontmatter doesn't parse. They give up.

*The work is private. The distribution is broken.*

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

**Sub:** *A small group of curators goes first. We'll email you once, when Study Buddy opens to you. Not before.*

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
- Teams wanting to manage student progress centrally. Study Buddy keeps progress on the student's device, on purpose.

### Footer

*Study Buddy — an experiment in publishing what you know without platforming it.*
*hello@studybuddy.page · [yurika.space](https://yurika.space) · BorAI · 2026.*

## Voice notes for future scenes

- Write to the Resource Curator. Never to the student. The curator's purchase decision is the one that matters; the student is the curator's audience.
- Do not say "democratise". Do not say "revolutionise". Do not say "empower". Say what the tool does; let the reader derive the political posture themselves.
- British English throughout (per vault convention).
- Italics for the load-bearing one-liners (*"The work is private. The distribution is broken."*). Not every paragraph needs one.
- The wider universe ([[yurika]], [[the-guild]], the agency) is not the landing page's subject. Footer mention only.

## Out of scope for this document

- React component code. Handover to a BorAI session.
- Backend route handlers. Misled's `app/api/subscribe/route.ts` and `app/confirm/[token]/page.tsx` are the templates.
- Vercel project configuration — Prince links the project and applies Root Directory `apps/study-buddy` via the dashboard-Git pattern.
- Actual copy A/B tests. Ship this draft; test from feedback.

## Build sequence on founder-next-available

1. Domain purchased + DNS configured.
2. Supabase project created for study-buddy; migration from Misled copied + adapted (table name, schema same).
3. Resend domain verified; `hello@studybuddy.page` sending.
4. `apps/study-buddy/` scaffold extended with landing route + components per architecture above.
5. Copy drafted into components; voice pass matches this spec.
6. `.env.example` + `.env.local` configured; deploy via dashboard-Git.
7. Smoke-test the URL you plan to send, not the URL you assume is serving (Scene 04's standing rule).
8. First confirm email received end-to-end by a real inbox.
9. Scene 2b-01 Conclude drafted from captured work; artifact format decided.
