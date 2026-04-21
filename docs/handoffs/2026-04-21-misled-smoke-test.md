# Misled preview smoke test — 2026-04-21

**URL:** https://misled.vercel.app/
**Verdict:** FAIL

## Section checklist
- [✗] 1. TopToolbar — not present; no chrome strip, sigil, nav buttons, or visitor counter in DOM
- [✗] 2. Hero — not present; no gradient, sigil, grid floor, "SIGNAL ACQUIRED" eyebrow, or "DON'T BE MISLED." headline
- [✗] 3. Marquee — not present; no ticker element
- [✗] 4. Manifesto — not present; no "BRAND_IDENTITY.TXT" dialog, no pull-quote
- [✗] 5. Tease — not present; no "DROP_INCOMING.EXE" dialog
- [✗] 6. Subscribe — not present; no "JOIN_LIST.EXE" dialog, no email input, no TRANSMIT button
- [✗] 7. Floating sticker — not present; no "UNDER CONSTRUCTION" element
- [✗] 8. StatusBar — not present; no fixed bottom bar

## Form
- Element present: no
- Type/attributes: no `<form>`, no `<input type="email">`, no submit button in the rendered HTML

## Console / error indicators
- No Next.js error overlay markup, no "Application error", no 5xx, no client-side error boundary text
- Server returned HTTP 200 with a ~4.7 KB payload — the page renders cleanly, it just renders the wrong thing
- Head metadata matches the misled project (`<title>Misled</title>`, `<meta name="description" content="A movement against being misled.">`), so the right project is deployed — but the rendered body is a single placeholder: `<main class="min-h-screen flex items-center justify-center"><h1 class="text-4xl font-display">misled — coming soon</h1></main>`
- Build ID `hIIPs9F_QhpmKm4L2ddfK` present; lang is `en-GB`; Tailwind `font-display` token is wired (so the app shell compiled)

## Issues flagged
- Zero of the eight Task 6 components are on the live preview. The deployment is the pre-Task-1 placeholder app shell.
- Most likely cause: Vercel's dashboard Git integration is building from `main` (or another branch) rather than `feature/misled-ethos-page` — so the feature branch that carries Tasks 1–6 never produced the preview the handoff expected. Alternative causes to rule out: the feature branch's `app/page.tsx` still contains the placeholder, the last push didn't reach `origin`, or the build was overridden by a later commit.
- No domain/DNS issue — `https://misled.vercel.app/` resolves and serves. The delivery mechanism is fine; the content is wrong.
- Task 7 cannot proceed as planned. The "smoke test preview" step of the plan fails, and the suggested client message (which promises a Y2K-rave experience) would misrepresent what the client would actually see if sent against this URL.

## Verdict rationale
The preview URL is live and returning HTTP 200 with no errors, but the deployed bundle does not contain any of the eight sections shipped in Tasks 1–6 — it is serving the original `coming soon` placeholder. Before any client message goes out, confirm which branch/commit Vercel is building from and trigger a redeploy (or retarget the project) against `feature/misled-ethos-page` at `c69a238`. Until the preview actually renders the Y2K page, Task 7 is blocked.
