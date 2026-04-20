# Misled — Ethos page (Stage 1 of staged launch)

*Design spec for Scene 04 of Chapter 01 — Origin, Campaign: AI Command Centre (BorAI).*

**Date:** 2026-04-20
**Scene:** `[[04-misled-ethos-page]]` (to be created)
**Chapter:** `[[01-origin]]`
**Campaign:** `[[command-centre]]`
**Client:** Misled — London-based skateboard + streetwear brand
**Target deploy:** `BorAI/apps/misled` on `misled.london`

---

## 1. Summary

Build and ship the ethos page — Stage 1 of a three-stage launch (ethos → tease → pre-order). The ethos page's job is to establish Misled's movement-register voice, capture a launch audience via email, and lay the production-grade foundation the two later stages will inherit.

Scene 04 ships the ethos page only. Tease and pre-order are separate later scenes.

## 2. Requirements (from brainstorming)

| ID | Decision | Source |
|---|---|---|
| R1 | Staged rollout across three separate pages, not one-page-three-states | Q1 |
| R2 | Scene 04 scope = ethos page only | Q2 |
| R3 | Production-grade: custom domain, SEO, email capture, analytics, Sentry, client-editable copy | Q3 |
| R4 | Soft deadline, few weeks runway | Q4 |
| R5 | Full r3f hero, fork of `linear-vaporwave-react-three-fiber`, palette adapted | Q5 |
| R6 | Copy: PDF manifesto adapted by Prince for web, client approves | Q6 |
| R7 | Email capture backend: Resend + Supabase `subscribers` table | Q7 |
| R8 | Domain: register as part of Scene 04, pattern B (agency-managed DNS) | Q8 |
| R9 | CMS: Sanity for manifesto body, hardcoded for hero/CTAs/tease | Q9 |
| R10 | Client review: PR previews (async) + one scheduled sync at copy approval | Q10 |
| R11 | Legal: privacy policy + double opt-in, cookie-free analytics, no cookie banner | Q11 |
| R12 | Domain: `misled.london` | Q12 |
| R13 | Page sections: hero + manifesto + "what we're making" tease + email signup + footer | Q13 |
| R14 | Analytics: Vercel Web Analytics (cookie-free tier) | Q14 |
| R15 | No shadcn/ui — hand-rolled Tailwind components | Feedback during design |
| R16 | Build strategy: visible-first (Approach 2) — static page by Day 3, real r3f hero by Day 7, fully wired by Day 10, ship Day 14 | Approach choice |

## 3. Architecture

### Stack

- **Framework:** Next.js 15 (App Router), React 19
- **Language:** TypeScript strict
- **Styling:** Tailwind CSS only. No shadcn/ui, no component libraries. Hand-rolled components.
- **Motion:** Framer Motion v12 (interactions) + CSS keyframes (first-paint entries) — per existing memory on React 19 / motion v12 SSR behaviour
- **3D:** `three` + `@react-three/fiber` + `@react-three/drei` + `@react-three/postprocessing`
- **CMS:** Sanity (hosted studio at `misled.sanity.studio`)
- **Database:** Supabase (Postgres), service-role access from API route only
- **Email:** Resend
- **Analytics:** Vercel Web Analytics (cookie-free tier)
- **Errors:** Sentry (`@sentry/nextjs`)
- **Rate limit:** Upstash Redis via Vercel Marketplace
- **Package manager:** pnpm (monorepo convention)

### File layout

```
BorAI/apps/misled/
├── app/
│   ├── layout.tsx                      # root shell, fonts, analytics, Sentry init
│   ├── page.tsx                        # ethos page (Server Component)
│   ├── error.tsx                       # branded error boundary
│   ├── not-found.tsx                   # branded 404
│   ├── opengraph-image.tsx             # OG image generator
│   ├── icon.tsx                        # favicon from sigil
│   ├── api/
│   │   └── subscribe/
│   │       └── route.ts                # POST → Supabase + Resend (Node runtime)
│   └── (legal)/
│       ├── privacy/page.tsx
│       └── confirm/[token]/page.tsx    # double-opt-in landing
├── components/
│   ├── hero/
│   │   ├── index.tsx                   # wrapper, dynamic import with ssr:false
│   │   ├── scene.tsx                   # <Canvas> and scene graph
│   │   ├── terrain.tsx                 # vaporwave grid terrain
│   │   ├── sun.tsx                     # sun/horizon element
│   │   └── effects.tsx                 # postprocessing (bloom, gated by viewport)
│   ├── manifesto.tsx                   # Server Component, fetches Sanity
│   ├── tease-block.tsx                 # "what we're making"
│   ├── subscribe-form.tsx              # Client Component
│   └── footer.tsx
├── lib/
│   ├── sanity.ts                       # read-only client
│   ├── supabase.ts                     # service-role client, server-only
│   ├── resend.ts                       # Resend client
│   ├── rate-limit.ts                   # Upstash wrapper
│   └── schema.ts                       # zod validators
├── sanity/
│   ├── schemas/manifesto.ts
│   └── sanity.config.ts
├── public/
│   ├── hero-poster.jpg                 # pre-rendered first-frame of r3f scene
│   ├── sigil.png
│   └── logo.png
├── next.config.ts
├── tailwind.config.ts
├── package.json
└── tsconfig.json
```

### Component boundaries

- **Server Components** (default): `page.tsx`, `manifesto.tsx`, `tease-block.tsx`, `footer.tsx`, all legal pages.
- **Client Components** (opt-in): `hero/*` (r3f needs DOM/WebGL), `subscribe-form.tsx` (interactive state).
- **Route handlers** (Node runtime, not Edge): `/api/subscribe` — Resend SDK requires Node APIs.

## 4. Data flow

### Email capture (happy path)

```
User submits email
  ↓
subscribe-form.tsx → POST /api/subscribe
  ↓
app/api/subscribe/route.ts:
  1. zod.parse (email shape + honeypot check)
  2. rate-limit (5/min/IP via Upstash)
  3. Supabase upsert into subscribers (email UNIQUE)
      - If new: insert with confirm_token, confirmed_at=null
      - If existing unconfirmed: rotate confirm_token
      - If existing confirmed: return 200 with "already in" flag
  4. Resend.emails.send — confirm email with link to /confirm/{token}
  5. return 200 { status: 'pending_confirmation' }
  ↓
Form UI → pending state ("Check your inbox")
  ↓
User clicks confirm link in email
  ↓
/confirm/[token] (Server Component, service-role Supabase):
  1. Look up row by confirm_token
  2. Set confirmed_at = now()
  3. Render "You're in" page
```

### Supabase schema

```sql
create table public.subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  confirm_token text not null unique,
  confirmed_at timestamptz,
  source text default 'ethos_page',
  created_at timestamptz not null default now()
);

create index subscribers_confirmed_at_idx on public.subscribers (confirmed_at);

alter table public.subscribers enable row level security;
-- No public policies. Access only via service-role key from API route.
```

### Why double opt-in

PECR (UK) allows single opt-in only where a prior commercial relationship exists. This is a cold capture from a launch page — double opt-in is legally clean and improves Resend deliverability by filtering typos and abuse.

## 5. r3f hero

### Source

Fork of `MaximeHeckel/linear-vaporwave-react-three-fiber` (MIT). Extract scene components only — do not import their build tooling. Copy into `components/hero/`, adapt to Next.js App Router.

### Integration specifics

- `hero/index.tsx` exports `<Hero />` via `next/dynamic` with `ssr: false`. r3f touches `window` on mount; SSR would crash `next build`.
- GLSL shaders inline as template literals — avoids Next.js/Turbopack shader-loader config.
- Poster image (`public/hero-poster.jpg`) shown during r3f mount and as reduced-motion fallback. Pre-rendered export of scene at `t=0`, JPEG-optimised for LCP.

### Palette adaptation

Upstream uses teal/magenta vaporwave. Misled's palette — to be confirmed from `references/misled/misled-design.html` and `misled-alternative.html` on Day 6 — skews muted and earthier. Adapt shader `uColor` and `uColorB` uniforms; keep geometry and motion identical.

### Performance strategy

- `<Canvas dpr={[1, 2]}>` — clamp device pixel ratio
- `<Bloom />` postprocessing gated: disabled below 768px viewport
- drei's `<PerformanceMonitor>` downshifts quality when FPS < 30
- Static poster shown during initial mount (≤100ms); Canvas hydrates over it
- Full bypass for `prefers-reduced-motion: reduce` — render poster only, never mount Canvas

## 6. Sanity schema

```ts
// apps/misled/sanity/schemas/manifesto.ts
export default {
  name: 'manifesto',
  type: 'document',
  title: 'Manifesto',
  __experimental_actions: ['update', 'publish'], // singleton, no creation
  fields: [
    { name: 'eyebrow', type: 'string', title: 'Eyebrow (above headline)' },
    { name: 'headline', type: 'string', title: 'Headline',
      validation: (R) => R.required() },
    { name: 'intro', type: 'text', title: 'Intro paragraph', rows: 3 },
    {
      name: 'body',
      type: 'array',
      title: 'Body',
      of: [
        { type: 'block' },
        {
          type: 'object',
          name: 'pullquote',
          title: 'Pullquote',
          fields: [
            { name: 'text', type: 'text', rows: 2 },
            { name: 'attribution', type: 'string' },
          ],
        },
      ],
    },
    { name: 'closingCta', type: 'string', title: 'Closing CTA copy (above email form)' },
  ],
}
```

### Studio & revalidation

- Studio deployed to `misled.sanity.studio` (Sanity hosts free).
- Client invited by email, edits and publishes.
- Fetch with `next: { revalidate: 60 }` on the manifesto query — edits live within 60 seconds.
- Webhook-driven instant revalidation (`revalidateTag('manifesto')`) deferred unless client complains about the 60s lag.

## 7. Deployment & domain

### Vercel project

- Name: `misled-landing`
- Team: BorAI (same team as `talk-with-flavour`)
- Root directory: `apps/misled`
- Build command: `pnpm turbo run build --filter=misled`
- Install command: `pnpm install --frozen-lockfile`
- Framework preset: Next.js

### Domain setup

1. Register `misled.london` (Namecheap or Vercel Domains; ~£30–50/yr, agency-paid, client-reimbursed)
2. Nameservers point to Vercel — agency-managed DNS (Q8 pattern B)
3. SSL auto-provisioned via Let's Encrypt
4. `www.misled.london` → 301 to apex
5. Check availability of `misled.com` / `misled.co.uk`. If available at under £50/year each, buy for defensive redirect to the apex. Flag to client for reimbursement. If either is premium-priced, skip and flag.

### Environment variables

| Variable | Scope | Sensitivity |
|---|---|---|
| `NEXT_PUBLIC_SITE_URL` | client + server | public |
| `NEXT_PUBLIC_SUPABASE_URL` | client | public |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | client | public (RLS-gated) |
| `SUPABASE_SERVICE_ROLE_KEY` | server | **secret** |
| `RESEND_API_KEY` | server | **secret** |
| `SANITY_PROJECT_ID` | server | public |
| `SANITY_DATASET` | server | public |
| `SANITY_API_READ_TOKEN` | server (preview mode) | **secret** |
| `SENTRY_DSN` | client + server | public |
| `SENTRY_AUTH_TOKEN` | build-time | **secret** |
| `UPSTASH_REDIS_REST_URL` | server | public |
| `UPSTASH_REDIS_REST_TOKEN` | server | **secret** |

All managed in Vercel dashboard. Local dev uses `vercel env pull .env.local`. `.env.example` commits with keys only, no values.

### Preview & production flow

- Every PR → preview URL at `misled-git-<branch>-borai.vercel.app`
- `main` branch → production at `misled.london`
- Production is **manually promoted** (Vercel setting). No auto-deploy on merge.

## 8. Observability

### Sentry

- Error tracking only. Not performance, not session replay, not profiling.
- `@sentry/nextjs` — client + server SDKs.
- Source maps uploaded at build time.
- Error boundary at `app/error.tsx` reports render errors.
- `/api/subscribe` reports non-2xx with hashed-email-domain context (never raw emails).

### Vercel Web Analytics

Cookie-free tier. Default pageviews + Core Web Vitals. Four custom events:

- `subscribe_submitted` — user hit submit
- `subscribe_confirmed` — confirmation link clicked
- `manifesto_scroll_50` — scrolled past midpoint
- `manifesto_scroll_100` — reached bottom

Goal: answer *"did people read the manifesto and sign up?"* — conversion + read-depth. That's the whole dashboard.

## 9. Error handling & edge cases

| Surface | Case | Handling |
|---|---|---|
| `/api/subscribe` | Invalid email | 400, inline form error, no Sentry |
| `/api/subscribe` | Honeypot filled (bot) | 200 fake success, silently drop, Sentry tag `bot=true` |
| `/api/subscribe` | Rate limit exceeded | 429, form shows "Slow down" |
| `/api/subscribe` | Supabase down | 500, form shows "Try again shortly", Sentry |
| `/api/subscribe` | Resend fails | 202, row saved with token, Sentry — async retry out of scope for Stage 1 |
| `/api/subscribe` | Duplicate email, confirmed | 200, form shows "You're already in" — no resend |
| `/api/subscribe` | Duplicate email, unconfirmed | Rotate token, resend confirm email |
| `/confirm/[token]` | Token not found | Branded "This link has expired" + fresh form |
| `/confirm/[token]` | Token already used | Render "You're in" anyway — idempotent |
| Hero | WebGL disabled / unavailable | Error boundary → poster JPG |
| Hero | FPS low (`<PerformanceMonitor>`) | Downshift quality; persistent low FPS → poster fallback |
| Sanity | Manifesto document missing | Fallback to hardcoded copy, Sentry reports loud |
| Any page | Uncaught render error | `app/error.tsx` — branded error page + reload |

### Form UX states (visible)

`idle → submitting → pending_confirm → error`
Confirmed state surfaces on `/confirm/[token]`, not inside the form.

### Security posture

- Honeypot field (`name="website"`, CSS-hidden).
- Upstash Redis rate limit: 5 submits/minute/IP.
- Supabase RLS enforced: service-role key server-only; no public read/write.
- No CSRF middleware — Next.js same-origin + zod validation covers the surface.
- Sentry never receives raw email addresses — only hashed domain for cohort analysis.

## 10. Phasing (build order)

Approach 2 — visible-first. Fourteen-day plan.

| Days | Work | Visible to client | Risk |
|---|---|---|---|
| 1 | Scaffold `apps/misled`, Tailwind, register `misled.london`, Vercel link, first deploy (template) | Preview URL live | Low |
| 2 | Static hero (CSS gradient + grid + sigil), hardcoded manifesto (PDF verbatim), tease stub, form stub (console.log) | Static ethos page | Low |
| 3 | **Client sync — copy & aesthetic reaction** | — | Low |
| 4–5 | Prince adapts copy from feedback, client approves final | Updated static page | Low |
| 6–7 | Fork + adapt linear-vaporwave r3f, integrate into `components/hero/`, mobile perf pass, reduced-motion fallback | Real hero live | **Medium** |
| 8 | Sanity project + studio + schema, port manifesto into Sanity, wire `lib/sanity.ts` | No visible change | Low |
| 9 | `subscribe-form` + `/api/subscribe` + Supabase table + Resend template + `/confirm/[token]` + Upstash rate limit; end-to-end test | Form works on preview | Medium |
| 10 | Sentry, Vercel Web Analytics, privacy policy page | — | Low |
| 11–12 | Polish: transitions, responsive pass, Lighthouse, OG image, favicon, copy micro-edits | Production-ready preview | Low |
| 13 | Domain go-live, final client review | Live on `misled.london` | Low |
| 14 | Ship. Scene 04 Conclude drafted | Live site | — |

## 11. Success criteria (exit)

Scene 04 can conclude when **all** of:

1. `misled.london` resolves to the production site with valid SSL.
2. Hero renders the r3f scene on desktop Chrome/Safari/Firefox; poster fallback on mobile if perf fails.
3. Manifesto copy is final, client-approved, live from Sanity.
4. Subscribe form completes end-to-end: submit → email arrives → confirm link works → `subscribers` row has `confirmed_at` set.
5. Privacy policy page exists and is linked from footer.
6. Sentry receives a test error from a staging-only route without raw emails.
7. Vercel Web Analytics shows at least one `subscribe_submitted` event.
8. Client has logged into Sanity studio at least once and made a live edit (proves handoff).

## 12. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| r3f hero perf on mobile | High | Medium | Poster fallback, `<PerformanceMonitor>` downshift, reduced-motion skip |
| Sanity copy approval delay | Medium | High | Pre-draft two copy variants Day 2, show both Day 3 |
| Domain snag | Low | Low | `.co.uk` fallback registered same day |
| Resend deliverability to Gmail/Outlook | Medium | High | SPF/DKIM/DMARC Day 1, cross-provider test Day 9 |
| Supabase free-tier limits | Very Low | — | Free tier covers scope by orders of magnitude |
| Client unreachable during review | Medium | High | Day 3 sync hard-scheduled; Prince continues on infra during silence |
| Prince context-switches off this scene | Medium | Medium | Vault enforces one in-progress scene at a time |
| linear-vaporwave shader license | Low | — | MIT, attribution in footer |

### Unknown-unknowns

- True r3f port time (estimate: 2 days; realistic spread: 1–4)
- Client reaction to Day 3 static version — the moment that reshapes the brief
- Whether PDF register carries on the web, or voice shifts more than anticipated

## 13. Out of scope for Scene 04

These are for later scenes / stages and explicitly not this spec:

- Tease / drop page (Stage 2, separate scene)
- Pre-order flow + Stripe integration (Stage 3, separate scene)
- Admin dashboard for the client to view subscriber count / exports
- Newsletter send flow (transactional-only for Stage 1)
- Community wall / IG embeds
- Shop, product catalogue, anything that reveals actual SKUs
- Internationalisation
- User accounts

## 14. Links

- Brand source: `references/misled/Misled - The Brand.pdf`
- Design references: `references/misled/misled-design.html`, `references/misled/misled-alternative.html`
- Logo / sigil: `references/misled/misled_logo.png`, `references/misled/misled_sigil.png`
- r3f source: https://github.com/MaximeHeckel/linear-vaporwave-react-three-fiber
- Precedent scene: `[[02-talk-with-flavour-landing-page]]`
- Precedent artifact: `[[02-three-failed-deploys]]`
