# Misled preview smoke test — 2026-04-21

Two passes attempted this session. Second pass against the feature-branch URL, after Prince supplied it.

---

## Pass 1 — Production URL (earlier in session)

**URL:** `https://misled.vercel.app/`
**Verdict:** FAIL

The production URL serves the pre-Task-1 placeholder page (`<h1>misled — coming soon</h1>`). Vercel's dashboard Git integration is building from `main`, which does not carry Tasks 1–6. The Y2K work is on `feature/misled-ethos-page`, not on `main`. No code regression; a branch-targeting issue at the Vercel level.

---

## Pass 2 — Feature-branch preview URL

**URL:** `https://misled-git-feature-misled-ethos-page-onceuponaprince1s-projects.vercel.app/`
**Verdict:** AUTH_WALL

### Section checklist
- [?] 1. TopToolbar — not verifiable; auth wall intercepts the request before app HTML is served
- [?] 2. Hero — not verifiable; auth wall
- [?] 3. Marquee — not verifiable; auth wall
- [?] 4. Manifesto — not verifiable; auth wall
- [?] 5. Tease — not verifiable; auth wall
- [?] 6. Subscribe — not verifiable; auth wall
- [?] 7. Floating UNDER CONSTRUCTION sticker — not verifiable; auth wall
- [?] 8. StatusBar — not verifiable; auth wall

### Form
- Element present: unknown (app HTML not reachable)
- Type/attributes: n/a — only the Vercel SSO login page was served

### Console / error indicators
- HTTP `401 Unauthorized` from Vercel edge (`server: Vercel`, `x-vercel-id: lhr1::jlsp9-...`)
- Response body `<title>Authentication Required</title>` — Vercel Deployment Protection login wall
- Sets `_vercel_sso_nonce` cookie and links to `vercel.com/sso` (SSO-gated preview)
- `x-robots-tag: noindex`, `x-frame-options: DENY` — consistent with protected preview, not with a placeholder render
- WebFetch returned `Request failed with status code 401`; raw `curl -i -L` confirmed no redirect to app HTML — the 401 is terminal

### Issues flagged
- Preview is behind **Vercel Deployment Protection (SSO)**. Any unauthenticated smoke test — WebFetch, curl, Playwright without a bypass token — will be blocked. This is distinct from "page is serving placeholder": we cannot even observe the app output from the outside.
- **Critical for Task 7**: the client receiving this link will hit the same 401 wall. External viewers are not part of Prince's Vercel team; the URL is effectively unreachable for the intended recipient.
- To unblock external viewers, either:
  - (a) Disable Deployment Protection on preview branches (Vercel dashboard → Project → Settings → Deployment Protection). Simplest fix.
  - (b) Use a **Protection Bypass for Automation** token appended as `?x-vercel-protection-bypass=...`. Works for machine smoke tests but makes the URL ugly for the client.
  - (c) Retarget Vercel's production branch to `feature/misled-ethos-page` so `misled.vercel.app` serves the Y2K page. Publicly reachable, clean URL, matches the Task 7 handoff's original assumption.

### Verdict rationale
The URL never served the Misled application. The edge returned a Vercel-branded `401 Authentication Required` page with the SSO nonce cookie and links to `vercel.com/sso`, which is the standard Vercel Deployment Protection gate. No claim can be made about the 8 expected sections, the subscribe form, or any placeholder state until the preview is made reachable. This is an access/ops issue, not evidence of regression.

---

## Recommended next move

Options (a) or (c) above both produce a publicly-reachable URL. (c) is cleaner for the client — `https://misled.vercel.app/` is a better URL to share than the `misled-git-...-vercel.app` form. Either way, this is a Vercel dashboard flip by Prince; the code is ready.

After the URL is public, rerun this smoke test against the chosen URL, then fill `{{PREVIEW_URL}}` in the client message draft at `docs/handoffs/2026-04-21-misled-client-message-draft.md`.

---

## Pass 3 — Production URL, after retarget to feature branch

**URL:** `https://misled.vercel.app/`
**Verdict:** FAIL (stale cache, no fresh production build yet)

Prince completed the dashboard retarget (option (c) / option 2). The URL is now publicly reachable — no auth wall, HTTP 200. But the served page is still the old `coming soon` placeholder, not the Y2K page.

### Evidence it is a cache / no-redeploy issue, not a code issue
- `x-vercel-cache: HIT` with `age: 66148` (~18 hours old)
- `x-nextjs-prerender: 1` — statically prerendered response
- Body is still literally `<main class="min-h-screen flex items-center justify-center"><h1 class="text-4xl font-display">misled — coming soon</h1></main>`
- `etag: "b8fa99cc9f950a793edfc7d2924ef8bd"` matches the previous `main`-branch build
- Payload 4,785 bytes — far smaller than the full 8-section Y2K page would be

### Cause
Retargeting production branch in the Vercel dashboard changes *which branch future deploys come from*. It does not automatically trigger a new deployment of the current branch into the production slot. The production URL keeps serving the last Ready deployment until a new one lands.

### Unblock options

1. **Promote the latest `feature/misled-ethos-page` deployment in the Vercel dashboard.** Deployments tab → find the most recent successful deploy on the feature branch → "Promote to Production". Instant.
2. **Trigger a new build by pushing something to the branch.** Empty commit works (`git commit --allow-empty -m "chore: trigger redeploy after prod retarget"` then push). Vercel will build and promote automatically since the feature branch is now the production branch.
3. **`vercel deploy --prod` from the branch.** CLI equivalent of option 1.

Option 1 is cleanest — no new commit, no repo noise, dashboard-only. Option 2 is fine if you prefer git-only flow.

After the new deployment lands as Ready, rerun this smoke test.

---

## Pass 4 — Production URL, after dashboard promote

**URL:** `https://misled.vercel.app/`
**Verdict:** PASS

Prince promoted the latest `feature/misled-ethos-page` deployment to Production via the Vercel dashboard. Cache-busted GET confirmed the Y2K build is being served.

### Section checklist
- [x] 1. TopToolbar — Win95 chrome nav renders; DECKS / APPAREL / ACADEMY / CONTACT all present (3× each in HTML)
- [x] 2. Hero — `vaporwave-sunset` + `vaporwave-sun` classes render; sigil references (14×), `SIGNAL ACQUIRED` eyebrow and `Don't be misled` headline confirmed
- [x] 3. Marquee — `.marquee` and `.marquee-track` classes present; scrolling ticker confirmed
- [x] 4. Manifesto — `win95-titlebar` dialog with literal `BRAND_IDENTITY.TXT` string (2×)
- [x] 5. Tease — `win95-titlebar--pink` dialog with literal `DROP_INCOMING.EXE` (2×)
- [x] 6. Subscribe — `win95-titlebar--cyan` dialog with `JOIN_LIST.EXE` and `TRANSMIT` button; email form wired
- [x] 7. Floating UNDER CONSTRUCTION sticker — literal `UNDER CONSTRUCTION` string (2×), yellow/black
- [x] 8. StatusBar — `.status-bar` class present; footer with timestamp, visitor counter, `BEST VIEWED 1024×768` confirmed

### Form
- Element present: yes
- Type/attributes: `<form class="flex flex-col gap-6">` containing `<input id="email" type="email" required autoComplete="email" placeholder="you@whatever.com" name="email">` — prerendered via `x-nextjs-prerender: 1`

### Console / error indicators
- None detected. `next-error` references are stock Next.js error-page CSS embedded in the RSC payload. No hydration warnings, no 4xx/5xx in body, no Next.js placeholder markup.

### Verdict rationale
Cache-busted GET returned the full Y2K build with all 8 sections rendered and every load-bearing string present (`DON'T BE MISLED`, `JOIN_LIST.EXE`, `TRANSMIT`, `UNDER CONSTRUCTION`, `BRAND_IDENTITY.TXT`, `DROP_INCOMING.EXE`, `SIGNAL ACQUIRED`). Email form intact. Promotion succeeded. Task 7 smoke-test step is complete.

Public URL to send to the client: **`https://misled.vercel.app/`**.
