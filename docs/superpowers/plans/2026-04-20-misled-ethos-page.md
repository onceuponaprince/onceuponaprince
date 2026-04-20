# Misled — Ethos Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the Misled ethos page (Stage 1 of a three-stage launch) at `misled.london` — Next.js 15 + Tailwind landing with r3f hero, Sanity-managed manifesto, Supabase+Resend double-opt-in email capture, Sentry, and Vercel Analytics.

**Architecture:** Next.js App Router app at `BorAI/apps/misled` in the existing Turborepo. Server Components by default; client islands for the r3f hero (dynamic import, `ssr: false`) and subscribe form. Node runtime for the `/api/subscribe` route. No shadcn/ui — hand-rolled Tailwind components. Visible-first build strategy (Approach 2): static page by Day 3, r3f hero by Day 7, fully wired by Day 10, ship Day 14.

**Tech Stack:** Next.js 15, React 19, TypeScript strict, Tailwind CSS, Framer Motion v12, `@react-three/fiber` + `drei` + `postprocessing`, Sanity, Supabase, Resend, Upstash Redis, Sentry, Vercel Web Analytics, pnpm.

**Spec:** `docs/superpowers/specs/2026-04-20-misled-ethos-page-design.md`

**Execution venue:** Most tasks execute in `~/code/BorAI/`, not in the build-in-public vault. Scene updates (`campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md`) happen in the vault.

---

## Phase 1 — Foundation (Day 1)

### Task 1: Scaffold `apps/misled` in BorAI monorepo

**Files:**
- Create: `~/code/BorAI/apps/misled/package.json`
- Create: `~/code/BorAI/apps/misled/tsconfig.json`
- Create: `~/code/BorAI/apps/misled/next.config.ts`
- Create: `~/code/BorAI/apps/misled/tailwind.config.ts`
- Create: `~/code/BorAI/apps/misled/postcss.config.mjs`
- Create: `~/code/BorAI/apps/misled/app/layout.tsx`
- Create: `~/code/BorAI/apps/misled/app/page.tsx`
- Create: `~/code/BorAI/apps/misled/app/globals.css`
- Create: `~/code/BorAI/apps/misled/.env.example`
- Create: `~/code/BorAI/apps/misled/.gitignore`

- [ ] **Step 1: Confirm you are in the BorAI repo, not the vault**

```bash
cd ~/code/BorAI && git status && ls apps/
```
Expected: `apps/talk-with-flavour` exists. You're on a clean working tree (or a feature branch).

- [ ] **Step 2: Create a feature branch**

```bash
git checkout -b feature/misled-ethos-page
```

- [ ] **Step 3: Create the `apps/misled/package.json`**

```json
{
  "name": "misled",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3001",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.6.0"
  }
}
```

- [ ] **Step 4: Create `tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 5: Create `next.config.ts`**

```ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  experimental: {
    typedRoutes: true,
  },
}

export default nextConfig
```

- [ ] **Step 6: Create `tailwind.config.ts` and `app/globals.css`**

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        // Placeholder tokens — finalised in Task 3 from brand HTML audit
        ink: '#0a0a0a',
        paper: '#f5f3ee',
        signal: '#b83a3a',
      },
      fontFamily: {
        display: ['var(--font-display)', 'serif'],
        body: ['var(--font-body)', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

export default config
```

```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --font-display: 'Georgia', serif;
  --font-body: 'Inter', system-ui, sans-serif;
}

html, body { @apply bg-paper text-ink; }
```

```js
// postcss.config.mjs
export default {
  plugins: { tailwindcss: {}, autoprefixer: {} },
}
```

- [ ] **Step 7: Create minimal `app/layout.tsx` and `app/page.tsx`**

```tsx
// app/layout.tsx
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Misled',
  description: 'A movement against being misled.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en-GB">
      <body>{children}</body>
    </html>
  )
}
```

```tsx
// app/page.tsx
export default function EthosPage() {
  return (
    <main className="min-h-screen flex items-center justify-center">
      <h1 className="text-4xl font-display">misled — coming soon</h1>
    </main>
  )
}
```

- [ ] **Step 8: Create `.env.example` and `.gitignore`**

```bash
# .env.example
NEXT_PUBLIC_SITE_URL=https://misled.london

NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

RESEND_API_KEY=

SANITY_PROJECT_ID=
SANITY_DATASET=production
SANITY_API_READ_TOKEN=

SENTRY_DSN=
SENTRY_AUTH_TOKEN=

UPSTASH_REDIS_REST_URL=
UPSTASH_REDIS_REST_TOKEN=
```

```gitignore
# .gitignore
node_modules
.next
.env.local
.env*.local
.vercel
*.tsbuildinfo
next-env.d.ts
```

- [ ] **Step 9: Install and typecheck**

```bash
cd ~/code/BorAI && pnpm install && pnpm --filter misled typecheck
```
Expected: no type errors. `pnpm install` completes.

- [ ] **Step 10: Verify dev server starts**

```bash
pnpm --filter misled dev
```
Expected: `http://localhost:3001` renders "misled — coming soon". Stop the dev server with Ctrl+C.

- [ ] **Step 11: Commit**

```bash
git add apps/misled/
git commit -m "feat(misled): scaffold apps/misled with Next.js 15 + Tailwind"
```

---

### Task 2: Vercel project + domain registration

**Files:**
- Modify: `apps/misled/.env.example` (no change needed, verify)
- Create: Vercel project via `vercel` CLI

- [ ] **Step 1: Link Vercel project**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx vercel link
```
Pick the BorAI team, create a new project named `misled-landing`, root directory = current.

- [ ] **Step 2: Deploy a preview**

```bash
pnpm dlx vercel
```
Expected: a preview URL like `misled-landing-<hash>-borai.vercel.app` that renders "misled — coming soon".

- [ ] **Step 3: Register the domain `misled.london`**

Register via Namecheap, Gandi, or Vercel Domains. Record the registrar for invoicing. Do NOT point DNS yet — domain go-live is Task 29.

- [ ] **Step 4: Check defensive domain availability**

Check `misled.com` and `misled.co.uk` pricing. Buy either under £50/year as defensive redirects. Flag prices to the client for reimbursement.

- [ ] **Step 5: Commit (no file changes expected — this is an infra task)**

Document what was done in a short note — create `apps/misled/INFRA.md`:

```markdown
# Infrastructure notes — misled

## Vercel
- Project: `misled-landing` (BorAI team)
- Root directory: `apps/misled`

## Domains
- Primary: `misled.london` — registered via <REGISTRAR>, expires <DATE>
- Defensive: `misled.co.uk` — <bought | skipped> (£<PRICE>/yr)
- Defensive: `misled.com` — <bought | skipped> (£<PRICE>/yr)

## DNS
- Currently pointed at: registrar default (NOT live on `misled.london` yet)
- Target: Vercel nameservers (Task 29)
```

```bash
git add apps/misled/INFRA.md
git commit -m "chore(misled): record infra decisions"
```

---

### Task 3: Typography, colour tokens, base layout

**Files:**
- Modify: `apps/misled/tailwind.config.ts`
- Modify: `apps/misled/app/layout.tsx`
- Modify: `apps/misled/app/globals.css`

**Prerequisite:** Open `build-in-public/references/misled/misled-design.html` and `misled-alternative.html` in a browser. Extract the exact hex colours, font stacks, and spacing rhythm. Populate below.

- [ ] **Step 1: Extract palette from the HTML design references**

Open both HTMLs, copy the computed `background-color`, primary text colour, and any accent colours. Example extraction format:

```
ink:    #0A0908
paper:  #F2EFE9
signal: #A62A2A
muted:  #6B6258
```

(Actual values come from the reference HTMLs — this is a manual extraction step.)

- [ ] **Step 2: Update `tailwind.config.ts` with extracted tokens**

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#0A0908',      // ← replace with extracted value
        paper: '#F2EFE9',    // ← replace
        signal: '#A62A2A',   // ← replace
        muted: '#6B6258',    // ← replace
      },
      fontFamily: {
        display: ['var(--font-display)', 'serif'],
        body: ['var(--font-body)', 'sans-serif'],
      },
      letterSpacing: {
        wider2: '0.18em',
      },
    },
  },
  plugins: [],
}

export default config
```

- [ ] **Step 3: Pick fonts**

Inspect reference HTMLs for font families. Use `next/font` to self-host. Example picking Playfair Display (display) + Inter (body):

```tsx
// app/layout.tsx
import type { Metadata } from 'next'
import { Playfair_Display, Inter } from 'next/font/google'
import './globals.css'

const display = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-display',
  display: 'swap',
})

const body = Inter({
  subsets: ['latin'],
  variable: '--font-body',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Misled',
  description: 'A movement against being misled.',
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? 'https://misled.london'),
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en-GB" className={`${display.variable} ${body.variable}`}>
      <body className="font-body antialiased">{children}</body>
    </html>
  )
}
```

(Replace font imports with actual font choices from the HTML references.)

- [ ] **Step 4: Verify in browser**

```bash
pnpm --filter misled dev
```
Open `http://localhost:3001`. Expected: text renders in the chosen display font; background matches `paper`; text colour matches `ink`.

- [ ] **Step 5: Commit**

```bash
git add apps/misled/tailwind.config.ts apps/misled/app/layout.tsx apps/misled/app/globals.css
git commit -m "feat(misled): typography + palette tokens from brand references"
```

---

## Phase 2 — Static ethos page (Day 2)

### Task 4: Static hero placeholder

**Files:**
- Create: `apps/misled/components/hero/index.tsx`
- Create: `apps/misled/public/sigil.png` (copy from `build-in-public/references/misled/misled_sigil.png`)

- [ ] **Step 1: Copy sigil asset**

```bash
cp ~/code/build-in-public/references/misled/misled_sigil.png \
   ~/code/BorAI/apps/misled/public/sigil.png
```

(Original is 5.8MB — consider compressing via `sharp` or `squoosh` to under 200KB before commit.)

- [ ] **Step 2: Create static Hero component**

```tsx
// components/hero/index.tsx
import Image from 'next/image'

export default function Hero() {
  return (
    <section className="relative min-h-[90vh] flex items-center justify-center overflow-hidden bg-ink text-paper">
      {/* Static placeholder — r3f scene lands in Task 10 */}
      <div
        className="absolute inset-0 opacity-60"
        style={{
          background:
            'radial-gradient(ellipse at 50% 80%, var(--tw-gradient-stops)) hsl(350 50% 15%)',
          backgroundImage:
            'linear-gradient(180deg, transparent 0%, #0a0908 80%), repeating-linear-gradient(90deg, rgba(255,255,255,0.04) 0px, rgba(255,255,255,0.04) 1px, transparent 1px, transparent 60px), repeating-linear-gradient(0deg, rgba(255,255,255,0.04) 0px, rgba(255,255,255,0.04) 1px, transparent 1px, transparent 60px)',
        }}
        aria-hidden
      />
      <div className="relative z-10 flex flex-col items-center gap-8 px-6 text-center">
        <Image
          src="/sigil.png"
          alt="Misled sigil"
          width={120}
          height={120}
          priority
        />
        <h1 className="font-display text-5xl md:text-7xl leading-tight max-w-3xl">
          Don't be misled.
        </h1>
        <p className="max-w-xl text-lg text-paper/80">
          A movement against the pressures pulling you off your path.
        </p>
      </div>
    </section>
  )
}
```

- [ ] **Step 3: Render in page**

```tsx
// app/page.tsx
import Hero from '@/components/hero'

export default function EthosPage() {
  return (
    <main>
      <Hero />
    </main>
  )
}
```

- [ ] **Step 4: Verify in browser**

```bash
pnpm --filter misled dev
```
Expected: 90vh section with grid overlay, sigil centred, headline + subhead readable on dark background.

- [ ] **Step 5: Commit**

```bash
git add apps/misled/components/hero/ apps/misled/app/page.tsx apps/misled/public/sigil.png
git commit -m "feat(misled): static hero placeholder with sigil"
```

---

### Task 5: Manifesto + tease + footer (hardcoded)

**Files:**
- Create: `apps/misled/components/manifesto.tsx`
- Create: `apps/misled/components/tease-block.tsx`
- Create: `apps/misled/components/footer.tsx`
- Modify: `apps/misled/app/page.tsx`

- [ ] **Step 1: Manifesto component with verbatim PDF copy**

```tsx
// components/manifesto.tsx
export default function Manifesto() {
  return (
    <section className="bg-paper py-24 md:py-36">
      <div className="max-w-2xl mx-auto px-6">
        <p className="font-body uppercase tracking-wider2 text-sm text-signal mb-6">
          The thesis
        </p>
        <h2 className="font-display text-4xl md:text-5xl mb-10 leading-tight">
          Misled is more than a brand. It is a refusal.
        </h2>
        <div className="prose-misled space-y-6 text-lg leading-relaxed">
          <p>
            In today's society, many young, disadvantaged people — especially from
            underprivileged communities — find it difficult to occupy space in a society
            that fails them. They are continuously bombarded with pressures, social
            media messages, and expectations that distract them from reaching or
            pursuing their true potential.
          </p>
          <p>
            These forces lead them astray. Instead of focusing on self-growth,
            authenticity, and empowerment, they are misled into following false ideals
            and temporary trends.
          </p>
          <blockquote className="border-l-4 border-signal pl-6 italic text-2xl font-display">
            Our apparel and skateboards won't just be products. They are symbols of
            resistance against conformity.
          </blockquote>
          <p>
            With every deck we craft and every hoodie we produce, we promote a positive,
            supportive, and authentic community — one where young people can proudly
            stand against the pressures that seek to mislead them.
          </p>
        </div>
        <p className="mt-12 font-display text-2xl">
          Get on the list. Be there when we drop.
        </p>
      </div>
    </section>
  )
}
```

(Copy above is the PDF's Introduction condensed. Task 8 replaces this with the adapted web-ready version.)

- [ ] **Step 2: Tease block**

```tsx
// components/tease-block.tsx
export default function TeaseBlock() {
  return (
    <section className="bg-ink text-paper py-24">
      <div className="max-w-3xl mx-auto px-6 text-center">
        <p className="font-body uppercase tracking-wider2 text-sm text-signal mb-6">
          Coming
        </p>
        <h2 className="font-display text-4xl md:text-5xl mb-6">
          Decks. Hoodies. Something worth putting on.
        </h2>
        <p className="text-lg text-paper/70 max-w-xl mx-auto">
          Limited first drop, London-made. Sign up below to see it first.
        </p>
      </div>
    </section>
  )
}
```

- [ ] **Step 3: Footer**

```tsx
// components/footer.tsx
import Link from 'next/link'

export default function Footer() {
  return (
    <footer className="bg-paper border-t border-ink/10 py-12">
      <div className="max-w-3xl mx-auto px-6 flex flex-col md:flex-row gap-6 md:justify-between text-sm text-muted">
        <p>© {new Date().getFullYear()} Misled. Made in London.</p>
        <nav className="flex gap-6">
          <Link href="/privacy" className="hover:text-ink">Privacy</Link>
          <a href="mailto:hello@misled.london" className="hover:text-ink">Contact</a>
        </nav>
      </div>
    </footer>
  )
}
```

- [ ] **Step 4: Assemble page.tsx**

```tsx
// app/page.tsx
import Hero from '@/components/hero'
import Manifesto from '@/components/manifesto'
import TeaseBlock from '@/components/tease-block'
import Footer from '@/components/footer'

export default function EthosPage() {
  return (
    <main>
      <Hero />
      <Manifesto />
      <TeaseBlock />
      {/* Subscribe form lands in Task 6 */}
      <Footer />
    </main>
  )
}
```

- [ ] **Step 5: Verify in browser**

```bash
pnpm --filter misled dev
```
Expected: scrolling from hero → manifesto → tease → footer renders in sequence. Desktop + mobile widths both readable.

- [ ] **Step 6: Commit**

```bash
git add apps/misled/components/ apps/misled/app/page.tsx
git commit -m "feat(misled): manifesto + tease + footer, hardcoded copy"
```

---

### Task 6: Subscribe form (UI shell only)

**Files:**
- Create: `apps/misled/components/subscribe-form.tsx`
- Modify: `apps/misled/app/page.tsx`

- [ ] **Step 1: Client Component form with local state**

```tsx
// components/subscribe-form.tsx
'use client'

import { useState, type FormEvent } from 'react'

type Status = 'idle' | 'submitting' | 'pending_confirm' | 'error'

export default function SubscribeForm() {
  const [email, setEmail] = useState('')
  const [website, setWebsite] = useState('') // honeypot
  const [status, setStatus] = useState<Status>('idle')
  const [error, setError] = useState<string | null>(null)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setStatus('submitting')
    setError(null)
    // Task 21 replaces this with real POST
    await new Promise((r) => setTimeout(r, 600))
    console.log('submit', { email, website })
    setStatus('pending_confirm')
  }

  return (
    <section className="bg-paper py-24" id="subscribe">
      <div className="max-w-xl mx-auto px-6">
        <form onSubmit={onSubmit} className="flex flex-col gap-4">
          <label htmlFor="email" className="font-display text-2xl">
            Get on the list.
          </label>
          <div className="flex flex-col sm:flex-row gap-3">
            <input
              id="email"
              name="email"
              type="email"
              required
              autoComplete="email"
              placeholder="you@whatever.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={status === 'submitting' || status === 'pending_confirm'}
              className="flex-1 border border-ink/20 bg-transparent px-4 py-3 font-body focus:outline-none focus:border-signal"
            />
            <button
              type="submit"
              disabled={status === 'submitting' || status === 'pending_confirm'}
              className="bg-ink text-paper px-6 py-3 font-body uppercase tracking-wider2 text-sm hover:bg-signal transition-colors disabled:opacity-50"
            >
              {status === 'submitting' ? 'Sending…' : 'Sign up'}
            </button>
          </div>
          {/* Honeypot — hidden from humans, bots tend to fill */}
          <input
            type="text"
            name="website"
            tabIndex={-1}
            autoComplete="off"
            value={website}
            onChange={(e) => setWebsite(e.target.value)}
            className="absolute left-[-9999px] opacity-0"
            aria-hidden
          />
          <p className="text-xs text-muted">
            We'll send one email to confirm. No spam, unsubscribe at any time.
          </p>
          <div role="status" aria-live="polite" className="min-h-[1.5rem] text-sm">
            {status === 'pending_confirm' && (
              <span className="text-signal">Check your inbox to confirm.</span>
            )}
            {status === 'error' && error && <span className="text-signal">{error}</span>}
          </div>
        </form>
      </div>
    </section>
  )
}
```

- [ ] **Step 2: Mount in page.tsx**

```tsx
// app/page.tsx
import Hero from '@/components/hero'
import Manifesto from '@/components/manifesto'
import TeaseBlock from '@/components/tease-block'
import SubscribeForm from '@/components/subscribe-form'
import Footer from '@/components/footer'

export default function EthosPage() {
  return (
    <main>
      <Hero />
      <Manifesto />
      <TeaseBlock />
      <SubscribeForm />
      <Footer />
    </main>
  )
}
```

- [ ] **Step 3: Verify in browser**

Dev server; type an email and click Sign up. Expected: "Sending…" then "Check your inbox to confirm." Console shows the submitted email + empty honeypot.

- [ ] **Step 4: Commit**

```bash
git add apps/misled/components/subscribe-form.tsx apps/misled/app/page.tsx
git commit -m "feat(misled): subscribe form UI with local state (no backend yet)"
```

---

### Task 7: Deploy preview for client review

- [ ] **Step 1: Push branch**

```bash
cd ~/code/BorAI && git push -u origin feature/misled-ethos-page
```

- [ ] **Step 2: Verify Vercel preview built**

Open Vercel dashboard for `misled-landing`. Wait for the preview deploy on the branch. Note the preview URL.

- [ ] **Step 3: Smoke test preview**

Open preview URL. Check: hero renders, manifesto scrolls in, tease visible, form accepts input and shows pending state, no console errors.

- [ ] **Step 4: Share preview URL with client**

Send preview URL + one-line note: "Day 3 static — reading this for voice and feel, not polish. Real hero + final copy land later."

---

## Phase 3 — Copy iteration (Days 3–5)

### Task 8: Adapt manifesto copy for the web

**Files:**
- Modify: `apps/misled/components/manifesto.tsx` (temporary — will move to Sanity in Task 15)

- [ ] **Step 1: Draft the web-adapted manifesto**

Working from `build-in-public/references/misled/Misled - The Brand.pdf`:

- Replace long paragraphs with 2–3 sentence beats
- Lead with a declarative opening ("A generation was misled.")
- Preserve the moral charge: empowerment, authenticity, refusal
- Add pullquote moments (earn the pause)
- Close with the email-list invitation

Target length: ~350 words on the page (PDF intro is ~450).

Draft in the vault first: `references/misled/manifesto-v1.md`. Sync with Prince's voice guide (British English, "earns its place", "load-bearing", avoid hedging).

- [ ] **Step 2: Update `components/manifesto.tsx` with the adapted copy**

Replace the verbatim PDF paragraphs in Task 5's component with the adapted version. Keep the structure: eyebrow, headline, body with pullquote, closing CTA.

- [ ] **Step 3: Deploy preview**

```bash
git add apps/misled/components/manifesto.tsx
git commit -m "feat(misled): adapted manifesto copy for web register"
git push
```

- [ ] **Step 4: Schedule + run Day 3 client sync**

Agenda (prep the night before):
- Walk the client through the preview URL on screen share
- Ask the three questions: *Does the voice feel like you? Is any line missing the mark? What's the single sentence you'd save from a burning building?*
- Capture in a vault scene log (Task 30 Conclude draws from this)

- [ ] **Step 5: Iterate on feedback**

Commit copy changes as separate commits with `docs(misled): copy iteration N` messages so the Conclude block can reference the iteration history.

---

## Phase 4 — r3f hero (Days 6–7)

### Task 9: Add r3f dependencies + scene skeleton

**Files:**
- Modify: `apps/misled/package.json`
- Create: `apps/misled/components/hero/scene.tsx`
- Modify: `apps/misled/components/hero/index.tsx`

- [ ] **Step 1: Install r3f dependencies**

```bash
cd ~/code/BorAI && pnpm --filter misled add three @react-three/fiber @react-three/drei @react-three/postprocessing maath
pnpm --filter misled add -D @types/three
```

- [ ] **Step 2: Create scene.tsx (empty Canvas shell)**

```tsx
// components/hero/scene.tsx
'use client'

import { Canvas } from '@react-three/fiber'
import { Suspense } from 'react'

export default function Scene() {
  return (
    <Canvas
      dpr={[1, 2]}
      camera={{ position: [0, 0.06, 1.1], fov: 35 }}
      gl={{ antialias: true, alpha: true }}
    >
      <Suspense fallback={null}>
        <color attach="background" args={['#0a0908']} />
        <ambientLight intensity={0.8} />
        {/* Terrain, sun, effects land in Task 10 */}
      </Suspense>
    </Canvas>
  )
}
```

- [ ] **Step 3: Rewrite hero/index.tsx with dynamic import**

```tsx
// components/hero/index.tsx
import dynamic from 'next/dynamic'
import Image from 'next/image'

const Scene = dynamic(() => import('./scene'), {
  ssr: false,
  loading: () => (
    <Image
      src="/hero-poster.jpg"
      alt=""
      fill
      priority
      className="object-cover"
      aria-hidden
    />
  ),
})

export default function Hero() {
  return (
    <section className="relative min-h-[90vh] overflow-hidden bg-ink text-paper">
      <div className="absolute inset-0" aria-hidden>
        <Scene />
      </div>
      <div className="relative z-10 min-h-[90vh] flex flex-col items-center justify-center gap-8 px-6 text-center">
        <Image src="/sigil.png" alt="Misled sigil" width={120} height={120} priority />
        <h1 className="font-display text-5xl md:text-7xl leading-tight max-w-3xl">
          Don't be misled.
        </h1>
        <p className="max-w-xl text-lg text-paper/80">
          A movement against the pressures pulling you off your path.
        </p>
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Create placeholder poster**

Until Task 13 produces the real poster, copy a temporary placeholder:

```bash
# placeholder — real poster generated in Task 13
cp ~/code/BorAI/apps/misled/public/sigil.png ~/code/BorAI/apps/misled/public/hero-poster.jpg
```

- [ ] **Step 5: Verify build + dev**

```bash
pnpm --filter misled build && pnpm --filter misled dev
```
Expected: build succeeds (no SSR crash on Canvas). Dev shows black hero background + overlay content.

- [ ] **Step 6: Commit**

```bash
git add apps/misled/package.json apps/misled/components/hero/ apps/misled/public/hero-poster.jpg
git commit -m "feat(misled): r3f dependencies + Canvas shell with dynamic import"
```

---

### Task 10: Port terrain + sun from linear-vaporwave-r3f

**Files:**
- Create: `apps/misled/components/hero/terrain.tsx`
- Create: `apps/misled/components/hero/sun.tsx`
- Modify: `apps/misled/components/hero/scene.tsx`

- [ ] **Step 1: Read the upstream source**

Open `https://github.com/MaximeHeckel/linear-vaporwave-react-three-fiber` in a browser. Key files to port:
- `src/components/Terrain.js` (or similar) — grid plane with heightmap shader
- `src/components/Sun.js` — radial gradient sphere with horizon line

Note the shader uniforms (`uColor`, `uColorB`, `uTime`) and geometry (plane segments).

- [ ] **Step 2: Port Terrain**

```tsx
// components/hero/terrain.tsx
'use client'

import * as THREE from 'three'
import { useFrame } from '@react-three/fiber'
import { useRef, useMemo } from 'react'

const vertexShader = /* glsl */ `
  uniform float uTime;
  varying vec2 vUv;
  varying float vElevation;

  void main() {
    vUv = uv;
    vec3 pos = position;
    float elevation = sin(pos.x * 4.0 + uTime * 0.5) * 0.05
                    + cos(pos.y * 3.0 + uTime * 0.3) * 0.04;
    pos.z += elevation;
    vElevation = elevation;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
  }
`

const fragmentShader = /* glsl */ `
  uniform vec3 uColorA;
  uniform vec3 uColorB;
  varying vec2 vUv;
  varying float vElevation;

  void main() {
    float gridX = step(0.98, abs(fract(vUv.x * 30.0) * 2.0 - 1.0));
    float gridY = step(0.98, abs(fract(vUv.y * 30.0) * 2.0 - 1.0));
    float grid = max(gridX, gridY);
    vec3 col = mix(uColorA, uColorB, vUv.y);
    gl_FragColor = vec4(col * (0.15 + grid * 0.9), grid * 0.9 + 0.1);
  }
`

export default function Terrain() {
  const mesh = useRef<THREE.Mesh>(null!)
  const uniforms = useMemo(
    () => ({
      uTime: { value: 0 },
      uColorA: { value: new THREE.Color('#2a0f14') },
      uColorB: { value: new THREE.Color('#a62a2a') },
    }),
    [],
  )

  useFrame((_, delta) => {
    uniforms.uTime.value += delta
  })

  return (
    <mesh ref={mesh} rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.1, 0]}>
      <planeGeometry args={[4, 8, 64, 128]} />
      <shaderMaterial
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniforms}
        transparent
        depthWrite={false}
      />
    </mesh>
  )
}
```

- [ ] **Step 3: Port Sun**

```tsx
// components/hero/sun.tsx
'use client'

import * as THREE from 'three'
import { useMemo } from 'react'

const vertexShader = /* glsl */ `
  varying vec2 vUv;
  void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`

const fragmentShader = /* glsl */ `
  uniform vec3 uColorA;
  uniform vec3 uColorB;
  varying vec2 vUv;
  void main() {
    float d = distance(vUv, vec2(0.5));
    float mask = smoothstep(0.5, 0.1, d);
    vec3 col = mix(uColorB, uColorA, vUv.y);
    // horizon bands
    float band = step(0.02, abs(fract(vUv.y * 6.0) - 0.5)) * smoothstep(0.55, 0.5, vUv.y);
    gl_FragColor = vec4(col, mask * (1.0 - band));
  }
`

export default function Sun() {
  const uniforms = useMemo(
    () => ({
      uColorA: { value: new THREE.Color('#f2efe9') },
      uColorB: { value: new THREE.Color('#a62a2a') },
    }),
    [],
  )

  return (
    <mesh position={[0, 0.25, -2]}>
      <planeGeometry args={[1.5, 1.5]} />
      <shaderMaterial
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniforms}
        transparent
        depthWrite={false}
      />
    </mesh>
  )
}
```

- [ ] **Step 4: Mount in scene**

```tsx
// components/hero/scene.tsx
'use client'

import { Canvas } from '@react-three/fiber'
import { Suspense } from 'react'
import Terrain from './terrain'
import Sun from './sun'

export default function Scene() {
  return (
    <Canvas
      dpr={[1, 2]}
      camera={{ position: [0, 0.06, 1.1], fov: 35 }}
      gl={{ antialias: true, alpha: true }}
    >
      <Suspense fallback={null}>
        <color attach="background" args={['#0a0908']} />
        <ambientLight intensity={0.8} />
        <Sun />
        <Terrain />
      </Suspense>
    </Canvas>
  )
}
```

- [ ] **Step 5: Verify in browser**

```bash
pnpm --filter misled dev
```
Expected: animated grid terrain receding to horizon, sun disc overhead. Colours are placeholder — tuning in Task 11. No console errors.

- [ ] **Step 6: Commit**

```bash
git add apps/misled/components/hero/
git commit -m "feat(misled): port vaporwave terrain + sun to r3f scene"
```

---

### Task 11: Adapt r3f palette to Misled brand

**Files:**
- Modify: `apps/misled/components/hero/terrain.tsx`
- Modify: `apps/misled/components/hero/sun.tsx`

- [ ] **Step 1: Tune shader colours against the brand palette**

Replace placeholder hex values in `uColorA` / `uColorB` with the tokens extracted in Task 3:

```tsx
// terrain.tsx — updated uniforms
uColorA: { value: new THREE.Color('#0a0908') },  // ink
uColorB: { value: new THREE.Color('#a62a2a') },  // signal
```

```tsx
// sun.tsx — updated uniforms
uColorA: { value: new THREE.Color('#f2efe9') },  // paper
uColorB: { value: new THREE.Color('#a62a2a') },  // signal
```

Tweak opacity values and the `smoothstep` bands until the scene reads as Misled (muted-with-bleed), not early-Maxime (teal-with-magenta).

- [ ] **Step 2: A/B the result against the static placeholder**

Swap the dynamic Scene mount for the Task 4 static hero briefly, compare the two. The r3f version should feel like a deeper, moving version of the same image — not a different page.

- [ ] **Step 3: Commit**

```bash
git add apps/misled/components/hero/terrain.tsx apps/misled/components/hero/sun.tsx
git commit -m "feat(misled): r3f palette adapted to brand tokens"
```

---

### Task 12: Performance monitoring + mobile gating

**Files:**
- Create: `apps/misled/components/hero/effects.tsx`
- Modify: `apps/misled/components/hero/scene.tsx`

- [ ] **Step 1: Bloom postprocessing (desktop only)**

```tsx
// components/hero/effects.tsx
'use client'

import { EffectComposer, Bloom } from '@react-three/postprocessing'

export default function Effects() {
  return (
    <EffectComposer>
      <Bloom intensity={0.6} luminanceThreshold={0.2} luminanceSmoothing={0.9} />
    </EffectComposer>
  )
}
```

- [ ] **Step 2: Scene with PerformanceMonitor + viewport gating**

```tsx
// components/hero/scene.tsx
'use client'

import { Canvas } from '@react-three/fiber'
import { PerformanceMonitor } from '@react-three/drei'
import { Suspense, useState, useEffect } from 'react'
import Terrain from './terrain'
import Sun from './sun'
import Effects from './effects'

export default function Scene() {
  const [quality, setQuality] = useState<'high' | 'low'>('high')
  const [isDesktop, setIsDesktop] = useState(false)

  useEffect(() => {
    const mq = window.matchMedia('(min-width: 768px)')
    setIsDesktop(mq.matches)
    const handler = (e: MediaQueryListEvent) => setIsDesktop(e.matches)
    mq.addEventListener('change', handler)
    return () => mq.removeEventListener('change', handler)
  }, [])

  return (
    <Canvas
      dpr={quality === 'high' ? [1, 2] : [1, 1]}
      camera={{ position: [0, 0.06, 1.1], fov: 35 }}
      gl={{ antialias: quality === 'high', alpha: true }}
    >
      <PerformanceMonitor
        onDecline={() => setQuality('low')}
        onIncline={() => setQuality('high')}
      />
      <Suspense fallback={null}>
        <color attach="background" args={['#0a0908']} />
        <ambientLight intensity={0.8} />
        <Sun />
        <Terrain />
        {isDesktop && quality === 'high' && <Effects />}
      </Suspense>
    </Canvas>
  )
}
```

- [ ] **Step 3: Verify on real mobile**

Open preview URL on a phone (or Chrome DevTools device emulation with CPU throttling 4× slowdown). Expected: scene animates smoothly; postprocessing disabled on mobile.

- [ ] **Step 4: Commit**

```bash
git add apps/misled/components/hero/
git commit -m "feat(misled): r3f performance monitor + mobile bloom gating"
```

---

### Task 13: Hero poster + reduced-motion fallback

**Files:**
- Create: `apps/misled/public/hero-poster.jpg` (replace placeholder from Task 9)
- Modify: `apps/misled/components/hero/index.tsx`

- [ ] **Step 1: Generate poster from real scene**

In dev, run the scene, capture the canvas as an image at `t=0`:

```js
// Paste in browser console on the hero page
const canvas = document.querySelector('canvas')
canvas.toBlob((blob) => {
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = 'hero-poster.jpg'
  a.click()
}, 'image/jpeg', 0.85)
```

Save to `apps/misled/public/hero-poster.jpg`. Optimise to <150KB via `squoosh` or `sharp`:

```bash
pnpm dlx sharp-cli -i apps/misled/public/hero-poster.jpg -o apps/misled/public/hero-poster.jpg --format jpeg --quality 80
```

- [ ] **Step 2: Reduced-motion gate in hero**

```tsx
// components/hero/index.tsx
'use client'

import dynamic from 'next/dynamic'
import Image from 'next/image'
import { useEffect, useState } from 'react'

const Scene = dynamic(() => import('./scene'), {
  ssr: false,
  loading: () => (
    <Image src="/hero-poster.jpg" alt="" fill priority className="object-cover" aria-hidden />
  ),
})

export default function Hero() {
  const [reducedMotion, setReducedMotion] = useState(false)

  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
    setReducedMotion(mq.matches)
    const handler = (e: MediaQueryListEvent) => setReducedMotion(e.matches)
    mq.addEventListener('change', handler)
    return () => mq.removeEventListener('change', handler)
  }, [])

  return (
    <section className="relative min-h-[90vh] overflow-hidden bg-ink text-paper">
      <div className="absolute inset-0" aria-hidden>
        {reducedMotion ? (
          <Image src="/hero-poster.jpg" alt="" fill priority className="object-cover" aria-hidden />
        ) : (
          <Scene />
        )}
      </div>
      <div className="relative z-10 min-h-[90vh] flex flex-col items-center justify-center gap-8 px-6 text-center">
        <Image src="/sigil.png" alt="Misled sigil" width={120} height={120} priority />
        <h1 className="font-display text-5xl md:text-7xl leading-tight max-w-3xl">
          Don't be misled.
        </h1>
        <p className="max-w-xl text-lg text-paper/80">
          A movement against the pressures pulling you off your path.
        </p>
      </div>
    </section>
  )
}
```

Note: `hero/index.tsx` is now a Client Component. Page.tsx imports it unchanged; Next.js handles the boundary.

- [ ] **Step 3: Test reduced motion**

In Chrome DevTools: *Rendering → Emulate CSS prefers-reduced-motion → reduce*. Refresh. Expected: no Canvas in DOM, poster image only.

- [ ] **Step 4: Commit**

```bash
git add apps/misled/public/hero-poster.jpg apps/misled/components/hero/index.tsx
git commit -m "feat(misled): hero poster + reduced-motion fallback"
```

---

## Phase 5 — Sanity CMS (Day 8)

### Task 14: Sanity project + schema

**Files:**
- Create: `apps/misled/sanity/sanity.config.ts`
- Create: `apps/misled/sanity/schemas/manifesto.ts`
- Modify: `apps/misled/package.json`
- Modify: `apps/misled/.env.example` (already has keys; verify)

- [ ] **Step 1: Create Sanity project**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx sanity@latest init --create-project "Misled" --dataset production
```
When prompted, do **not** use the starter template — pick "Clean project with no predefined schemas". Record the project ID it outputs.

- [ ] **Step 2: Install Sanity deps**

```bash
pnpm --filter misled add sanity @sanity/client next-sanity
pnpm --filter misled add -D @sanity/types
```

- [ ] **Step 3: Schema definition**

```ts
// sanity/schemas/manifesto.ts
import { defineType, defineField } from 'sanity'

export default defineType({
  name: 'manifesto',
  title: 'Manifesto',
  type: 'document',
  fields: [
    defineField({ name: 'eyebrow', type: 'string', title: 'Eyebrow (above headline)' }),
    defineField({
      name: 'headline',
      type: 'string',
      title: 'Headline',
      validation: (R) => R.required(),
    }),
    defineField({ name: 'intro', type: 'text', title: 'Intro paragraph', rows: 3 }),
    defineField({
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
    }),
    defineField({ name: 'closingCta', type: 'string', title: 'Closing CTA copy' }),
  ],
})
```

- [ ] **Step 4: Studio config**

```ts
// sanity/sanity.config.ts
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'
import manifesto from './schemas/manifesto'

export default defineConfig({
  name: 'misled',
  title: 'Misled CMS',
  projectId: process.env.SANITY_PROJECT_ID!,
  dataset: process.env.SANITY_DATASET ?? 'production',
  plugins: [structureTool()],
  schema: { types: [manifesto] },
})
```

- [ ] **Step 5: Commit**

```bash
git add apps/misled/sanity/ apps/misled/package.json
git commit -m "feat(misled): sanity project + manifesto schema"
```

---

### Task 15: Wire Sanity fetch in manifesto component

**Files:**
- Create: `apps/misled/lib/sanity.ts`
- Modify: `apps/misled/components/manifesto.tsx`
- Create: `apps/misled/app/api/revalidate/route.ts` (optional — for later webhook)

- [ ] **Step 1: Sanity client**

```ts
// lib/sanity.ts
import { createClient } from 'next-sanity'

export const sanityClient = createClient({
  projectId: process.env.SANITY_PROJECT_ID!,
  dataset: process.env.SANITY_DATASET ?? 'production',
  apiVersion: '2024-10-01',
  useCdn: true,
  perspective: 'published',
})

export type Manifesto = {
  eyebrow?: string
  headline: string
  intro?: string
  body: Array<
    | { _type: 'block'; children: Array<{ text: string }>; style?: string }
    | { _type: 'pullquote'; text: string; attribution?: string }
  >
  closingCta?: string
}

export async function getManifesto(): Promise<Manifesto | null> {
  const query = `*[_type == "manifesto"][0]{
    eyebrow, headline, intro, body, closingCta
  }`
  return sanityClient.fetch<Manifesto | null>(query, {}, {
    next: { revalidate: 60, tags: ['manifesto'] },
  })
}
```

- [ ] **Step 2: PortableText renderer**

```bash
pnpm --filter misled add @portabletext/react
```

- [ ] **Step 3: Update manifesto component**

```tsx
// components/manifesto.tsx
import { PortableText, type PortableTextComponents } from '@portabletext/react'
import { getManifesto } from '@/lib/sanity'

const components: PortableTextComponents = {
  block: {
    normal: ({ children }) => <p>{children}</p>,
  },
  types: {
    pullquote: ({ value }: { value: { text: string; attribution?: string } }) => (
      <blockquote className="border-l-4 border-signal pl-6 italic text-2xl font-display my-8">
        {value.text}
        {value.attribution && (
          <cite className="block mt-2 text-sm not-italic text-muted">— {value.attribution}</cite>
        )}
      </blockquote>
    ),
  },
}

const FALLBACK = {
  eyebrow: 'The thesis',
  headline: 'Misled is more than a brand. It is a refusal.',
  intro: 'A generation was misled by noise. This is what comes after.',
  body: [],
  closingCta: 'Get on the list. Be there when we drop.',
}

export default async function Manifesto() {
  const doc = (await getManifesto()) ?? FALLBACK

  return (
    <section className="bg-paper py-24 md:py-36">
      <div className="max-w-2xl mx-auto px-6">
        {doc.eyebrow && (
          <p className="font-body uppercase tracking-wider2 text-sm text-signal mb-6">
            {doc.eyebrow}
          </p>
        )}
        <h2 className="font-display text-4xl md:text-5xl mb-10 leading-tight">{doc.headline}</h2>
        {doc.intro && <p className="text-xl leading-relaxed mb-8">{doc.intro}</p>}
        <div className="space-y-6 text-lg leading-relaxed">
          <PortableText value={doc.body ?? []} components={components} />
        </div>
        {doc.closingCta && <p className="mt-12 font-display text-2xl">{doc.closingCta}</p>}
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Port adapted copy into Sanity studio**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx sanity dev
```
Open `http://localhost:3333`. Create the single `manifesto` document. Paste headline, intro, body (as Portable Text blocks), closingCta. Publish.

- [ ] **Step 5: Deploy studio**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx sanity deploy
```
Pick hostname `misled` — studio lives at `misled.sanity.studio`.

- [ ] **Step 6: Invite client to studio**

In Sanity dashboard (sanity.io/manage), add the client's email as an Editor. They receive an invite email.

- [ ] **Step 7: Configure env locally and on Vercel**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx vercel env add SANITY_PROJECT_ID
pnpm dlx vercel env add SANITY_DATASET
# use value 'production'
pnpm dlx vercel env pull .env.local
```

- [ ] **Step 8: Verify fetch**

```bash
pnpm --filter misled dev
```
Expected: manifesto renders from Sanity. Edit the headline in studio, wait up to 60s, refresh — new headline appears.

- [ ] **Step 9: Commit**

```bash
git add apps/misled/lib/sanity.ts apps/misled/components/manifesto.tsx apps/misled/package.json
git commit -m "feat(misled): fetch manifesto from sanity with portable text"
```

---

## Phase 6 — Email capture (Day 9)

### Task 16: Supabase subscribers table

**Files:**
- Create: `apps/misled/supabase/migrations/001_subscribers.sql`
- Create: `apps/misled/lib/supabase.ts`

- [ ] **Step 1: Create Supabase project**

Via Supabase dashboard: new project named `misled-landing`. Choose a region close to the UK (eu-west). Record project ref URL, anon key, service role key.

- [ ] **Step 2: Migration SQL**

```sql
-- apps/misled/supabase/migrations/001_subscribers.sql
create extension if not exists pgcrypto;

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

- [ ] **Step 3: Apply migration via Supabase SQL editor**

Paste the SQL into dashboard → SQL editor → Run. Confirm table appears in Table Editor.

- [ ] **Step 4: Supabase client helper**

```ts
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

export function serviceClient() {
  return createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
}
```

```bash
pnpm --filter misled add @supabase/supabase-js
```

- [ ] **Step 5: Vercel env**

```bash
pnpm dlx vercel env add NEXT_PUBLIC_SUPABASE_URL
pnpm dlx vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
pnpm dlx vercel env add SUPABASE_SERVICE_ROLE_KEY
pnpm dlx vercel env pull .env.local
```

- [ ] **Step 6: Commit**

```bash
git add apps/misled/supabase/ apps/misled/lib/supabase.ts apps/misled/package.json
git commit -m "feat(misled): supabase subscribers table + service-role client"
```

---

### Task 17: Upstash rate-limit client

**Files:**
- Create: `apps/misled/lib/rate-limit.ts`

- [ ] **Step 1: Provision Upstash via Vercel Marketplace**

Vercel dashboard → `misled-landing` → Storage → Connect Upstash Redis. Accept the provisioning — Vercel auto-sets `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN`.

```bash
pnpm --filter misled add @upstash/redis @upstash/ratelimit
pnpm dlx vercel env pull .env.local
```

- [ ] **Step 2: Rate-limit helper**

```ts
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const redis = Redis.fromEnv()

export const subscribeRateLimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(5, '1 m'),
  analytics: true,
  prefix: 'rl:subscribe',
})
```

- [ ] **Step 3: Commit**

```bash
git add apps/misled/lib/rate-limit.ts apps/misled/package.json
git commit -m "feat(misled): upstash ratelimit for subscribe endpoint"
```

---

### Task 18: `/api/subscribe` route

**Files:**
- Create: `apps/misled/lib/schema.ts`
- Create: `apps/misled/lib/resend.ts`
- Create: `apps/misled/app/api/subscribe/route.ts`
- Create: `apps/misled/app/api/subscribe/__tests__/route.test.ts`

- [ ] **Step 1: Install test + validation deps**

```bash
pnpm --filter misled add zod resend
pnpm --filter misled add -D vitest @vitest/ui
```

- [ ] **Step 2: Add Vitest config**

```ts
// apps/misled/vitest.config.ts
import { defineConfig } from 'vitest/config'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: { environment: 'node' },
})
```

```bash
pnpm --filter misled add -D vite-tsconfig-paths
```

Add to `apps/misled/package.json` scripts:

```json
"test": "vitest run",
"test:watch": "vitest"
```

- [ ] **Step 3: Zod schema**

```ts
// lib/schema.ts
import { z } from 'zod'

export const subscribeInput = z.object({
  email: z.string().trim().toLowerCase().email(),
  website: z.string().max(0).default(''), // honeypot — must be empty
})

export type SubscribeInput = z.infer<typeof subscribeInput>
```

- [ ] **Step 4: Resend client**

```ts
// lib/resend.ts
import { Resend } from 'resend'

export const resend = new Resend(process.env.RESEND_API_KEY!)

export async function sendConfirmEmail(email: string, token: string) {
  const url = `${process.env.NEXT_PUBLIC_SITE_URL}/confirm/${token}`
  return resend.emails.send({
    from: 'Misled <hello@misled.london>',
    to: email,
    subject: 'Confirm you are on the Misled list',
    text: `Confirm your spot on the list:\n\n${url}\n\nIf this wasn't you, ignore this email.`,
    html: `<p>Confirm your spot on the list:</p><p><a href="${url}">${url}</a></p><p>If this wasn't you, ignore this email.</p>`,
  })
}
```

- [ ] **Step 5: Write the failing test**

```ts
// app/api/subscribe/__tests__/route.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { POST } from '../route'

vi.mock('@/lib/supabase', () => ({
  serviceClient: () => ({
    from: () => ({
      upsert: vi.fn().mockReturnValue({
        select: vi.fn().mockReturnValue({
          single: vi.fn().mockResolvedValue({
            data: { email: 'x@y.com', confirm_token: 't', confirmed_at: null },
            error: null,
          }),
        }),
      }),
    }),
  }),
}))

vi.mock('@/lib/resend', () => ({ sendConfirmEmail: vi.fn().mockResolvedValue({ data: { id: 'e' } }) }))

vi.mock('@/lib/rate-limit', () => ({
  subscribeRateLimit: { limit: vi.fn().mockResolvedValue({ success: true }) },
}))

beforeEach(() => vi.clearAllMocks())

function makeReq(body: unknown) {
  return new Request('http://localhost/api/subscribe', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-forwarded-for': '1.1.1.1' },
    body: JSON.stringify(body),
  })
}

describe('POST /api/subscribe', () => {
  it('rejects invalid email shape', async () => {
    const res = await POST(makeReq({ email: 'not-an-email', website: '' }))
    expect(res.status).toBe(400)
  })

  it('drops bots silently on honeypot fill', async () => {
    const res = await POST(makeReq({ email: 'a@b.com', website: 'http://bot.example' }))
    expect(res.status).toBe(200)
    const body = await res.json()
    expect(body.status).toBe('pending_confirmation')
  })

  it('accepts valid input and returns pending status', async () => {
    const res = await POST(makeReq({ email: 'a@b.com', website: '' }))
    expect(res.status).toBe(200)
    const body = await res.json()
    expect(body.status).toBe('pending_confirmation')
  })
})
```

- [ ] **Step 6: Run test — expect fail**

```bash
pnpm --filter misled test
```
Expected: three tests fail — route doesn't exist yet.

- [ ] **Step 7: Implement the route**

```ts
// app/api/subscribe/route.ts
import { NextResponse } from 'next/server'
import { randomBytes } from 'crypto'
import * as Sentry from '@sentry/nextjs'
import { subscribeInput } from '@/lib/schema'
import { serviceClient } from '@/lib/supabase'
import { sendConfirmEmail } from '@/lib/resend'
import { subscribeRateLimit } from '@/lib/rate-limit'

export const runtime = 'nodejs'

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ?? 'unknown'

  const rl = await subscribeRateLimit.limit(ip)
  if (!rl.success) {
    return NextResponse.json({ error: 'rate_limited' }, { status: 429 })
  }

  let parsed
  try {
    const json = await req.json()
    parsed = subscribeInput.parse(json)
  } catch (err) {
    return NextResponse.json({ error: 'invalid_input' }, { status: 400 })
  }

  // Honeypot: bots fill the `website` field. Pretend success, drop silently.
  if (parsed.website !== '') {
    Sentry.captureMessage('honeypot hit', { level: 'info', tags: { bot: 'true' } })
    return NextResponse.json({ status: 'pending_confirmation' }, { status: 200 })
  }

  const token = randomBytes(24).toString('hex')
  const supabase = serviceClient()

  const { data, error } = await supabase
    .from('subscribers')
    .upsert(
      { email: parsed.email, confirm_token: token, source: 'ethos_page' },
      { onConflict: 'email' },
    )
    .select('email, confirmed_at, confirm_token')
    .single()

  if (error) {
    Sentry.captureException(error, { tags: { route: 'subscribe', stage: 'db' } })
    return NextResponse.json({ error: 'db_error' }, { status: 500 })
  }

  if (data.confirmed_at) {
    // already confirmed — don't resend the email
    return NextResponse.json({ status: 'already_confirmed' }, { status: 200 })
  }

  const resendResult = await sendConfirmEmail(parsed.email, data.confirm_token)
  if (resendResult.error) {
    Sentry.captureException(resendResult.error, { tags: { route: 'subscribe', stage: 'email' } })
    return NextResponse.json({ status: 'pending_confirmation', warn: 'email_delayed' }, { status: 202 })
  }

  return NextResponse.json({ status: 'pending_confirmation' }, { status: 200 })
}
```

- [ ] **Step 8: Run tests — expect pass**

```bash
pnpm --filter misled test
```
Expected: three tests pass. Add a Sentry mock if the tests complain about `@sentry/nextjs`:

```ts
vi.mock('@sentry/nextjs', () => ({ captureException: vi.fn(), captureMessage: vi.fn() }))
```

- [ ] **Step 9: Commit**

```bash
git add apps/misled/app/api/ apps/misled/lib/schema.ts apps/misled/lib/resend.ts apps/misled/vitest.config.ts apps/misled/package.json
git commit -m "feat(misled): /api/subscribe with zod + rate limit + double-opt-in send"
```

---

### Task 19: `/confirm/[token]` page

**Files:**
- Create: `apps/misled/app/(legal)/confirm/[token]/page.tsx`

- [ ] **Step 1: Confirmation page**

```tsx
// app/(legal)/confirm/[token]/page.tsx
import { notFound } from 'next/navigation'
import { serviceClient } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

type Props = { params: Promise<{ token: string }> }

export default async function ConfirmPage({ params }: Props) {
  const { token } = await params
  const supabase = serviceClient()

  const { data: row } = await supabase
    .from('subscribers')
    .select('email, confirmed_at')
    .eq('confirm_token', token)
    .maybeSingle()

  if (!row) {
    // render an expired-looking page rather than 404 — kinder UX
    return (
      <main className="min-h-screen flex items-center justify-center bg-paper px-6">
        <div className="max-w-md text-center">
          <h1 className="font-display text-4xl mb-4">This link has expired.</h1>
          <p className="text-muted mb-8">Head back to the signup and try again.</p>
          <a href="/#subscribe" className="underline">Back to the signup</a>
        </div>
      </main>
    )
  }

  if (!row.confirmed_at) {
    await supabase
      .from('subscribers')
      .update({ confirmed_at: new Date().toISOString() })
      .eq('confirm_token', token)
  }

  return (
    <main className="min-h-screen flex items-center justify-center bg-ink text-paper px-6">
      <div className="max-w-md text-center">
        <h1 className="font-display text-5xl mb-4">You're in.</h1>
        <p className="text-paper/80">
          We'll be in touch when the first drop is close. Not before.
        </p>
      </div>
    </main>
  )
}
```

- [ ] **Step 2: Manual test**

1. `pnpm --filter misled dev`
2. `curl -X POST http://localhost:3001/api/subscribe -H 'content-type: application/json' -d '{"email":"you@example.com","website":""}'`
3. Check Supabase table: row exists with `confirm_token`, `confirmed_at` is null.
4. Visit `http://localhost:3001/confirm/<that-token>` → "You're in." page.
5. Re-check table: `confirmed_at` is set.
6. Re-visit the same URL → still shows "You're in." (idempotent).

- [ ] **Step 3: Commit**

```bash
git add apps/misled/app/\(legal\)/confirm/
git commit -m "feat(misled): /confirm/[token] page with idempotent confirmation"
```

---

### Task 20: Resend domain + DNS records

- [ ] **Step 1: Add `misled.london` as a Resend sending domain**

Resend dashboard → Domains → Add Domain → `misled.london`. Note the SPF, DKIM, DMARC records it generates.

- [ ] **Step 2: Add DNS records at domain registrar**

At your registrar, add the TXT/CNAME records Resend specifies. Typical set:
- SPF: `v=spf1 include:amazonses.com ~all`
- DKIM: 3× CNAME records (provided by Resend)
- DMARC: `v=DMARC1; p=none; rua=mailto:dmarc@misled.london`

- [ ] **Step 3: Verify in Resend**

Refresh Resend's domain page. Wait for all four records to show green. Can take up to 48h but usually minutes.

- [ ] **Step 4: Add Resend API key to Vercel**

```bash
pnpm dlx vercel env add RESEND_API_KEY
```

- [ ] **Step 5: Cross-provider deliverability check**

Trigger confirm emails to addresses at: Gmail, Outlook/Hotmail, Proton, iCloud, a custom-domain (if any). Each should arrive to inbox (not spam) within 60 seconds.

If any land in spam: investigate SPF/DKIM alignment, warm the domain with a few initial sends.

---

### Task 21: Wire form to real API

**Files:**
- Modify: `apps/misled/components/subscribe-form.tsx`

- [ ] **Step 1: Replace stub submit with fetch**

```tsx
// components/subscribe-form.tsx — updated submit handler
async function onSubmit(e: FormEvent) {
  e.preventDefault()
  setStatus('submitting')
  setError(null)

  try {
    const res = await fetch('/api/subscribe', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email, website }),
    })

    if (res.status === 429) {
      setStatus('error')
      setError("Whoa, slow down — try again in a minute.")
      return
    }
    if (!res.ok) {
      setStatus('error')
      setError('Something broke on our end. Try again shortly.')
      return
    }
    const json = await res.json()
    if (json.status === 'already_confirmed') {
      setStatus('pending_confirm') // reuse the same "you're fine" branch
    } else {
      setStatus('pending_confirm')
    }
  } catch {
    setStatus('error')
    setError('Network hiccup. Try again.')
  }
}
```

(Rest of `subscribe-form.tsx` is unchanged from Task 6.)

- [ ] **Step 2: Add custom analytics event fire**

```tsx
// inside onSubmit, after successful response:
if (typeof window !== 'undefined' && 'va' in window) {
  // @ts-ignore — Vercel Analytics global
  window.va('track', 'subscribe_submitted')
}
```

Note: the `va` global comes from `@vercel/analytics` which is installed in Task 24. This code is dormant until then.

- [ ] **Step 3: Manual end-to-end**

1. Dev server
2. Submit a real email in the form
3. Receive confirm email
4. Click link
5. See "You're in." page
6. Supabase row `confirmed_at` set

- [ ] **Step 4: Commit**

```bash
git add apps/misled/components/subscribe-form.tsx
git commit -m "feat(misled): subscribe form wired to /api/subscribe"
```

---

### Task 22: E2E test for subscribe flow

**Files:**
- Create: `apps/misled/e2e/subscribe.spec.ts`
- Modify: `apps/misled/package.json`
- Create: `apps/misled/playwright.config.ts`

- [ ] **Step 1: Install Playwright**

```bash
pnpm --filter misled add -D @playwright/test
pnpm --filter misled exec playwright install chromium
```

- [ ] **Step 2: Playwright config**

```ts
// playwright.config.ts
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  use: { baseURL: 'http://localhost:3001' },
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3001',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
})
```

Add to `package.json`:

```json
"e2e": "playwright test"
```

- [ ] **Step 3: E2E spec**

```ts
// e2e/subscribe.spec.ts
import { test, expect } from '@playwright/test'

test('subscribe form shows pending state on valid submit', async ({ page }) => {
  await page.goto('/')
  await page.getByLabel(/Get on the list/i).fill('e2e-test@example.com')
  await page.getByRole('button', { name: /Sign up/i }).click()
  await expect(page.getByText(/Check your inbox to confirm/i)).toBeVisible()
})

test('subscribe form rejects empty email', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('button', { name: /Sign up/i }).click()
  // browser's native required-field tooltip prevents submission; we just assert no pending state
  await expect(page.getByText(/Check your inbox to confirm/i)).not.toBeVisible()
})
```

- [ ] **Step 4: Run E2E**

```bash
pnpm --filter misled e2e
```
Expected: both tests pass against a dev server. The "valid submit" test will actually hit your Supabase dev env — either pre-clean the email or use a dedicated test address.

- [ ] **Step 5: Commit**

```bash
git add apps/misled/e2e/ apps/misled/playwright.config.ts apps/misled/package.json
git commit -m "test(misled): e2e for subscribe form happy path"
```

---

## Phase 7 — Observability & legal (Day 10)

### Task 23: Sentry setup

**Files:**
- Create: `apps/misled/sentry.client.config.ts`
- Create: `apps/misled/sentry.server.config.ts`
- Create: `apps/misled/sentry.edge.config.ts`
- Modify: `apps/misled/next.config.ts`

- [ ] **Step 1: Install + init**

```bash
cd ~/code/BorAI/apps/misled && pnpm dlx @sentry/wizard@latest -i nextjs
```
Follow prompts, choose the BorAI Sentry org. Wizard creates the three config files and modifies `next.config.ts`.

- [ ] **Step 2: Trim Sentry config to error tracking only**

```ts
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0, // no perf monitoring for Stage 1
  replaysSessionSampleRate: 0,
  replaysOnErrorSampleRate: 0,
})
```

Apply the same to `sentry.server.config.ts` and `sentry.edge.config.ts`.

- [ ] **Step 3: Deliberate test error**

Add a temporary route:

```ts
// app/api/_sentry-test/route.ts
export function GET() { throw new Error('Sentry test — safe to delete after verifying') }
```

Deploy, curl the route, verify the error appears in Sentry. Then delete the route and commit the deletion.

- [ ] **Step 4: Commit**

```bash
git add apps/misled/sentry.*.config.ts apps/misled/next.config.ts apps/misled/package.json
git commit -m "feat(misled): sentry wired for client + server error tracking"
```

---

### Task 24: Vercel Analytics + custom events

**Files:**
- Modify: `apps/misled/app/layout.tsx`
- Create: `apps/misled/components/scroll-tracker.tsx`

- [ ] **Step 1: Install**

```bash
pnpm --filter misled add @vercel/analytics
```

- [ ] **Step 2: Mount Analytics component**

```tsx
// app/layout.tsx — add to body
import { Analytics } from '@vercel/analytics/react'

// inside RootLayout:
return (
  <html lang="en-GB" className={`${display.variable} ${body.variable}`}>
    <body className="font-body antialiased">
      {children}
      <Analytics />
    </body>
  </html>
)
```

- [ ] **Step 3: Scroll-depth tracker**

```tsx
// components/scroll-tracker.tsx
'use client'

import { useEffect } from 'react'
import { track } from '@vercel/analytics'

export default function ScrollTracker() {
  useEffect(() => {
    const fired = { 50: false, 100: false }
    function onScroll() {
      const pct = window.scrollY / (document.body.scrollHeight - window.innerHeight)
      if (pct >= 0.5 && !fired[50]) {
        track('manifesto_scroll_50')
        fired[50] = true
      }
      if (pct >= 0.95 && !fired[100]) {
        track('manifesto_scroll_100')
        fired[100] = true
      }
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])
  return null
}
```

- [ ] **Step 4: Mount in page.tsx + wire subscribe tracking**

```tsx
// app/page.tsx — add ScrollTracker
import ScrollTracker from '@/components/scroll-tracker'
// render <ScrollTracker /> inside <main>, before <Hero />
```

Replace the Task 21 `window.va('track')` stub in `subscribe-form.tsx` with the proper import:

```tsx
import { track } from '@vercel/analytics'
// inside onSubmit success path:
track('subscribe_submitted')
```

And in `app/(legal)/confirm/[token]/page.tsx`, fire `subscribe_confirmed` — since this is a Server Component, fire from a tiny client wrapper:

```tsx
// components/confirm-tracker.tsx
'use client'
import { useEffect } from 'react'
import { track } from '@vercel/analytics'
export default function ConfirmTracker() {
  useEffect(() => { track('subscribe_confirmed') }, [])
  return null
}
```

Import and render `<ConfirmTracker />` inside the confirm page's success branch.

- [ ] **Step 5: Verify in Vercel dashboard**

Deploy, visit the page, scroll, submit. Vercel Analytics dashboard shows four events populating over 5–15 minutes.

- [ ] **Step 6: Commit**

```bash
git add apps/misled/app/ apps/misled/components/ apps/misled/package.json
git commit -m "feat(misled): vercel analytics with 4 custom events"
```

---

### Task 25: Privacy policy + error/404 pages

**Files:**
- Create: `apps/misled/app/(legal)/privacy/page.tsx`
- Create: `apps/misled/app/error.tsx`
- Create: `apps/misled/app/not-found.tsx`

- [ ] **Step 1: Privacy policy**

```tsx
// app/(legal)/privacy/page.tsx
export const metadata = { title: 'Privacy — Misled' }

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-paper py-24 px-6">
      <article className="max-w-2xl mx-auto prose prose-lg">
        <h1 className="font-display text-4xl mb-8">Privacy</h1>
        <p>Last updated: {new Date().toISOString().slice(0, 10)}.</p>
        <h2 className="font-display text-2xl mt-8 mb-4">What we collect</h2>
        <p>
          If you sign up for the Misled list, we store your email address and the timestamp
          of your signup. That's it. No tracking cookies, no profile-building.
        </p>
        <h2 className="font-display text-2xl mt-8 mb-4">Why we collect it</h2>
        <p>
          To tell you when our first drop goes live, and to send you any follow-up emails
          you opt into. You can unsubscribe from any email we send.
        </p>
        <h2 className="font-display text-2xl mt-8 mb-4">Who we share it with</h2>
        <p>
          No one for marketing purposes. The infrastructure that sends emails (Resend) and
          stores the list (Supabase) sees your address as part of delivering the service.
        </p>
        <h2 className="font-display text-2xl mt-8 mb-4">Analytics</h2>
        <p>
          We use Vercel Web Analytics in cookie-free mode. It records anonymous page views
          and page performance. No cookies are set, no personal data is collected.
        </p>
        <h2 className="font-display text-2xl mt-8 mb-4">Your rights</h2>
        <p>
          You can ask us to delete your email from our list at any time by emailing{' '}
          <a href="mailto:privacy@misled.london" className="underline">privacy@misled.london</a>.
        </p>
      </article>
    </main>
  )
}
```

- [ ] **Step 2: Branded error page**

```tsx
// app/error.tsx
'use client'

import { useEffect } from 'react'
import * as Sentry from '@sentry/nextjs'

export default function ErrorPage({ error, reset }: { error: Error; reset: () => void }) {
  useEffect(() => { Sentry.captureException(error) }, [error])

  return (
    <main className="min-h-screen flex items-center justify-center bg-ink text-paper px-6">
      <div className="max-w-md text-center">
        <h1 className="font-display text-4xl mb-4">Something's misfiring.</h1>
        <p className="text-paper/80 mb-8">We've been pinged. Try again.</p>
        <button onClick={reset} className="underline">Reload</button>
      </div>
    </main>
  )
}
```

- [ ] **Step 3: Branded 404**

```tsx
// app/not-found.tsx
export default function NotFound() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-paper px-6">
      <div className="max-w-md text-center">
        <h1 className="font-display text-5xl mb-4">Off-path.</h1>
        <p className="text-muted mb-8">That page doesn't exist (yet).</p>
        <a href="/" className="underline">Back to the manifesto</a>
      </div>
    </main>
  )
}
```

- [ ] **Step 4: Verify**

Dev server. Visit `/privacy` — reads correctly. Visit `/does-not-exist` — 404 shows. Temporarily throw an error in a component to verify `error.tsx` catches it.

- [ ] **Step 5: Commit**

```bash
git add apps/misled/app/
git commit -m "feat(misled): privacy policy + branded error + 404 pages"
```

---

## Phase 8 — Polish (Days 11–12)

### Task 26: OG image + favicon + metadata

**Files:**
- Create: `apps/misled/app/opengraph-image.tsx`
- Create: `apps/misled/app/icon.tsx`
- Modify: `apps/misled/app/layout.tsx`

- [ ] **Step 1: OG image generator**

```tsx
// app/opengraph-image.tsx
import { ImageResponse } from 'next/og'

export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

export default function OgImage() {
  return new ImageResponse(
    (
      <div
        style={{
          background: '#0a0908',
          color: '#f2efe9',
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          fontFamily: 'Georgia, serif',
          padding: 60,
        }}
      >
        <div style={{ fontSize: 96, fontWeight: 700, letterSpacing: -2 }}>misled</div>
        <div style={{ fontSize: 28, marginTop: 24, opacity: 0.85 }}>
          A movement against being misled.
        </div>
      </div>
    ),
    { ...size },
  )
}
```

- [ ] **Step 2: Favicon from sigil**

```tsx
// app/icon.tsx
import { ImageResponse } from 'next/og'

export const size = { width: 32, height: 32 }
export const contentType = 'image/png'

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          background: '#a62a2a',
          width: '100%',
          height: '100%',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          color: '#f2efe9',
          fontSize: 22,
          fontWeight: 700,
          fontFamily: 'Georgia, serif',
        }}
      >
        M
      </div>
    ),
    { ...size },
  )
}
```

- [ ] **Step 3: Richer metadata**

```tsx
// app/layout.tsx — expand metadata
export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? 'https://misled.london'),
  title: 'Misled — A movement against being misled.',
  description: 'London skateboard + streetwear movement. Sign up for the first drop.',
  openGraph: {
    title: 'Misled',
    description: 'A movement against being misled.',
    type: 'website',
    locale: 'en_GB',
    siteName: 'Misled',
  },
  twitter: { card: 'summary_large_image' },
  robots: { index: true, follow: true },
}
```

- [ ] **Step 4: Verify**

Deploy preview. Check OG via `https://metatags.io/?url=<preview-url>`. Favicon visible in browser tab.

- [ ] **Step 5: Commit**

```bash
git add apps/misled/app/
git commit -m "feat(misled): OG image + favicon + rich metadata"
```

---

### Task 27: Responsive + Lighthouse pass

- [ ] **Step 1: Responsive audit**

Chrome DevTools → device toolbar. Test widths 375 (iPhone SE), 428 (iPhone Pro Max), 768 (tablet), 1024, 1440, 1920. Every breakpoint: hero readable, manifesto copy comfortable, form inputs reachable, no horizontal scroll.

Fix issues inline — typical: `max-w-2xl` bumping to `max-w-xl` on manifesto, reducing hero heading size below `md:`.

- [ ] **Step 2: Lighthouse pass**

```bash
pnpm dlx unlighthouse --site <preview-url>
```

Target scores: Performance ≥ 85, Accessibility = 100, Best Practices ≥ 95, SEO = 100.

Common fixes:
- LCP: ensure poster image is optimised, `<Image priority>` on hero content.
- CLS: reserve space for Canvas (min-h on hero).
- A11y: add missing `aria-label` on icon-only buttons, confirm colour contrast.

- [ ] **Step 3: Commit fixes**

```bash
git add -p apps/misled/
git commit -m "fix(misled): responsive tuning + lighthouse fixes"
```

---

### Task 28: Final copy micro-edits + pre-ship client review

- [ ] **Step 1: Surface all client-facing copy in a single diff**

Before the pre-ship review, send the client a preview URL with a note listing what changed since Day 3.

- [ ] **Step 2: Final sync (30 min max)**

Walk through each section. Capture any last copy tweaks. Resolve them same-day.

- [ ] **Step 3: Client signs off on go-live**

Explicit green light in writing (email or Slack). Record the timestamp — it's a scene beat.

---

## Phase 9 — Launch (Days 13–14)

### Task 29: Domain go-live

- [ ] **Step 1: Point `misled.london` nameservers to Vercel**

At registrar, replace existing NS records with Vercel's four nameservers (found in Vercel project → Settings → Domains → Add → shows NS). Save.

- [ ] **Step 2: Add domain to Vercel project**

Vercel dashboard → `misled-landing` → Settings → Domains → Add → `misled.london`. Also add `www.misled.london` with redirect to apex.

- [ ] **Step 3: Verify SSL + propagation**

Wait for Vercel to show green "Valid Configuration" (DNS propagation: minutes to 24h). Curl `https://misled.london` — returns 200, SSL valid.

- [ ] **Step 4: Update `NEXT_PUBLIC_SITE_URL` in Vercel env**

Set production value to `https://misled.london`. Redeploy production to pick it up. Verify OG image URL, confirm link in emails, all absolute URLs are now on the real domain.

- [ ] **Step 5: Final smoke test on live domain**

- Page loads, hero animates
- Submit a fresh email, receive confirm email from `hello@misled.london`, click, land on "You're in"
- Check Supabase row
- Check Sentry receives no unexpected errors
- Check Vercel Analytics is recording pageviews

---

### Task 30: Ship + Scene 04 Conclude

- [ ] **Step 1: Merge feature branch**

```bash
cd ~/code/BorAI
git checkout main
git merge --no-ff feature/misled-ethos-page
git push origin main
```

Vercel auto-deploys `main` to production.

- [ ] **Step 2: Tag the ship**

```bash
git tag -a misled-ethos-v1 -m "Misled ethos page — first live version"
git push origin misled-ethos-v1
```

- [ ] **Step 3: Draft Scene 04 Conclude in the vault**

In `~/code/build-in-public`:

```bash
cd ~/code/build-in-public
```

Invoke the vault's `/conclude` skill on the active scene `campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md`. Draw from:
- Day 3 client sync capture
- Copy iteration history (`docs(misled): copy iteration N` commits)
- Any hero perf debugging notes
- Any deliverability gotchas from Task 20

The Conclude block answers the five questions and an artifact proposal. Ship the artifact as Task 31 (not covered here — follows the vault's `/publish` workflow).

- [ ] **Step 4: Update the scene frontmatter**

```yaml
status: concluded
date_concluded: <YYYY-MM-DD>
artifact_format: essay   # or thread — decided during Conclude
artifact_file: "[[04-misled-ethos-shipped]]"   # placeholder until artifact is written
```

- [ ] **Step 5: Update chapter checklist**

```md
- [x] **[[04-misled-ethos-page]]** — Second proof point. *Concluded. Artifact: [[04-misled-ethos-shipped]].*
```

---

## Success check (from spec §11)

Before calling the scene done, verify each:

- [ ] `misled.london` resolves with valid SSL
- [ ] Hero renders r3f on desktop; poster fallback on mobile if perf fails
- [ ] Manifesto copy final, client-approved, live from Sanity
- [ ] Subscribe form E2E passes against production (real email round-trip)
- [ ] Privacy policy exists, linked from footer
- [ ] Sentry received at least one test error without raw email data
- [ ] Vercel Web Analytics shows `subscribe_submitted` event
- [ ] Client logged into Sanity studio and made a live edit
