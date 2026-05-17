# SaaS Opportunity Research — Ranked Top-3 + Build Plans

**Date:** 2026-05-16 · **Owner:** Prinx John Akpeki (yurika.space)
**Method:** dual-agent deep scan of 23 `~/code` projects (2 independent scanners + reconciler each) → 19-candidate ledger → two-pass external validation via borai-cc fanout → balanced scorecard (time-to-revenue 25 / build-effort 20 / strategic-fit 20 / TAM 20 / moat 15).
**Run artifacts:** `.run-2026-05-16/` (46 dossiers, ledger, fanout requests/responses, cull log).

---

## Confidence caveat (read first)

**Updated 2026-05-16 (post infra-fix rerun).** External validation is now
**genuine 4-engine cross-validated**, content-verified on-topic (not
`status=usable`-trusted). Original run was DeepSeek-only; the three infra
blockers were root-caused and fixed (see Follow-ups), then a role-specialised
Pass-2 was re-run over all 6 survivors via a compact-chunked method:

| Engine | State | Pass-2 role contribution |
|---|---|---|
| **DeepSeek** | ✅ patchright | Technical feasibility (S/M/L + risk + solo build time) |
| **Gemini** | ✅ playwright | Competitive landscape — named incumbents + solo gap |
| **Grok** | ✅ selenium_uc | Live 2026 demand signal + bear case |
| **Perplexity** | ✅ selenium_uc | TAM/SAM order-of-magnitude + pricing comps + citations |

Confidence now: **codebase-asset claims = high** (two independent code reads
each). **Competitor / demand / feasibility = medium-high** (4 engines, each
answer content-checked against the real candidate definitions). **TAM = directional** —
Perplexity itself flagged its figures as *"order-of-magnitude sketches to
stress-test the ideas, not pitch-deck numbers."* Use TAM to compare relative
scale, not to size a raise.

---

## The Top 3

Scorecard (1-10 per axis, weighted 25/20/20/20/15):

| Rank | Candidate | Origin · tag | T2Rev | Build | Fit | TAM | Moat | **Score** |
|---|---|---|--:|--:|--:|--:|--:|--:|
| **#1** | **C17 — "Lens Engine" personalised-analogy tutor** | study-buddy · greenfield | 8 | 8 | 9 | 7 | 6 | **7.70** |
| **#2** | **C15 — Spec-to-Code brief generator** | yurika-forge-app · proprietary | 8 | 8 | 8 | 6 | 4 | **7.00** |
| **#3** | **C14 — Gumroad-lite + Keygen-lite** | yurika.forge/apps/storefront · proprietary | 9 | 8 | 5 | 7 | 5 | **7.00** |
| — runner-up | C2 — LLM cost-router / tokens-saved proxy | borai+ai-swarm · greenfield | 8 | 6 | 6 | 7 | 4 | 6.40 |

#2 and #3 tie at 7.00 — ordered by strategic-fit (the yurika thesis). **The explicit trade-off for your go/no-go:**

- **C15** — best thesis fit (turns human intent into agent-actionable specs), S effort, but moat is just prompts (cloneable) and DeepSeek flags "briefs go stale as code diverges." Proprietary → confirm-gate.
- **C14** — *fastest cash* (DeepSeek PAY 8/10; "Gumroad fees just hit 10%+$0.30, migration pain is real"; ~80% built **with 7 passing test suites**), but weakest yurika-thesis fit (commerce infra). Proprietary → confirm-gate.
- **C2** (runner-up) — only top-tier **greenfield** option (no confirm-gate), DeepSeek PAY 9/10 ("inference spend is board-level"), Orchestra is a 2,813-line *tested* implementation plan ≈ transcription — **but** DeepSeek rates the core latency-aware router **HARD** build-risk and the moat is thin vs Portkey/LiteLLM/OpenRouter. Consider swapping C2→#3 if you want to avoid the proprietary gate entirely.

---

## #1 — C17 "Lens Engine" personalised-analogy tutor

**What:** Re-teaches any technical topic through the learner's *own two fluencies* (e.g. music + finance) via a rigorous dual-lens framework, plus auto-generated spaced-repetition decks with "misconception-bait" questions. Buyers: self-taught senior devs, bootcamp grads, interview-preppers (~$15-30/mo).

**Why #1:** Best strategic fit with the human-centric-AI thesis (AI adapts to the learner's mind; augments understanding, doesn't replace it). The hard part — the pedagogy — is *already fully written*. DeepSeek Pass-1B: STRONG + a TOP-5 pick. Greenfield → **no proprietary confirm-gate** (only de-identification).

**External read (DeepSeek, medium-conf):** STRONG; competitors Khan Academy / Duolingo (different segment — generic, not structural-lens); risk = "fluency detection fails without a long-term user model."

**Harvestable assets (study-buddy):**
- `_meta/Lens Framework.md` + `_meta/Conventions.md` — the core pedagogical system-prompt / grading rubric (the IP; framework generalises at ~L95-110).
- `_templates/New Module.md`, `_templates/Study Session.md` — output schemas.
- 20+ deep-dive modules + `Flashcards/` — few-shot exemplars.
- `copilot/copilot-custom-prompts/*` — 15 ready LLM transform prompts.
- `_meta/Dashboard.md` — progress-UX pattern.

**Build plan (S, ~2-3 wks to paid alpha):**
- **Team:** `feature-dev:code-architect` (wrap framework→system-prompt + few-shot pipeline) → 1 implementer (Next.js app: topic intake → lens-pair selection → generated module + SM-2 deck export) → `feature-dev:code-reviewer`.
- **Sequence:** de-identify framework (strip Prince/Yurika refs) → prompt pipeline + eval harness (does it beat generic ELI5?) → minimal web app + auth + Stripe → flashcard export (Anki `.apkg`) → 10-user paid alpha.
- **MVP scope:** one fluency-pair onboarding, one topic→module flow, deck export, $19/mo. No social, no mobile.
- **Risks:** method "untested at scale" (author's own caveat) — alpha must measure retention lift; crowded LLM-tutor space, moat is framework rigour not tech.

---

## #2 — C15 Spec-to-Code brief generator

**What:** Guided product-intake form chains LLM stages (Product Spec → Creative Direction → Landing Copy → `CLAUDE.md` engineering reference) into a ready-to-paste agent-brief bundle, provider-swappable Gemini/Claude. Buyers: indie founders & agencies using AI coding agents.

**Why #2:** Working end-to-end today; S effort; strong thesis fit (structures human intent for agents — "AI as extension of human choice"). DeepSeek TOP-5. Tie-break winner over C14 on strategic fit.

**External read (DeepSeek, medium-conf):** MODERATE; competitors v0 / Mintlify / (adjacent: Flowise, Dify); risk = "briefs become outdated instantly as code diverges from spec" → product must support brief *re-generation/diffing*, not one-shot.

**Harvestable assets (yurika-forge-app — PROPRIETARY, confirm-before-build):**
- `app/api/forge/route.ts` — stage→system-prompt dispatch + dual-provider abstraction (Anthropic SDK + `@google/generative-ai`), directly liftable.
- `app/page.tsx` L30-81 — `generateYamlContext()` + `runPipeline()` sequential forward-context chaining (the core IP pattern); L17-24 — 25-field intake schema.
- The 4 staged system-prompt strings — the actual recipe (the moat; genericise off Yurika framing).

**Build plan (S, ~2-3 wks):**
- **Team:** `feature-dev:code-explorer` (confirm whether deeper Forge prompts live in a sibling repo) → `code-architect` → 1 implementer (auth, credit metering, output persistence, streaming, editable stage prompts, rate-limit) → `code-reviewer`.
- **Sequence:** **clear proprietary confirm-gate** → genericise prompts off Yurika → add auth + rate-limit (open route today = cost-abuse) → credit billing → brief versioning/diff (answers the "stale brief" objection) → alpha.
- **MVP scope:** form → 4-stage bundle → download + saved history + credits. Defer team seats.
- **Risks:** prompts are the moat and are cloneable; hardcoded model IDs rot; crowded adjacent (Flowise/Dify/PromptLayer).

---

## #3 — C14 Gumroad-lite + Keygen-lite

**What:** Self-hostable owned checkout (Stripe Checkout — *Stripe* carries PCI, not the seller — + webhook fulfilment + collision-safe license keys + Resend receipts + RLS-locked purchase ledger, zero platform fee). The license issue/verify slice spins out as its own `/issue` + `/verify` API ("Keygen-lite"). Buyers: template/kit sellers fleeing Gumroad's fee hikes; solo plugin/SaaS authors needing license keys.

**Why #3:** *Fastest path to cash.* ~80% built **and tested** (7 vitest suites). DeepSeek Pass-2B: PAY **8/10**, ~$1.8M ACV est, wedge "self-hosted Stripe + license API, no platform middle layer", build-risk only MEDIUM, and timing is acute ("Gumroad fees just hit 10% + $0.30"). DeepSeek's Pass-1B WEAK verdict was on a *factually wrong* premise (it assumed the seller handles PCI — Stripe Checkout makes the seller PCI-out-of-scope); the deeper Pass-2B look corrected it.

**Harvestable assets (yurika.forge/apps/storefront — PROPRIETARY, confirm-before-build):**
- `lib/license.ts` — collision-safe Crockford-style key gen, zero deps (the Keygen-lite core).
- `lib/stripe.ts` + `app/api/checkout/route.ts` + `app/api/webhook/stripe/route.ts` — signature-verified Checkout→fulfilment.
- `lib/supabase.ts` + `supabase/migrations/0001_purchases.sql` — RLS, unique-constraint idempotency.
- `lib/email.ts` + `emails/PurchaseConfirmation.tsx` — Resend + react-email.
- `tests/**` — 7 vitest suites (raises reuse confidence).

**Build plan (S for the API slice; M for multi-tenant storefront):**
- **Team:** `code-architect` (multi-tenant boundary) → 1 implementer (Keygen-lite `/issue`+`/verify` API first — days; then storefront: seller accounts, dynamic catalog vs hardcoded `products.ts`, Stripe Connect) → `code-reviewer` (security: webhook sig, key entropy under concurrency).
- **Sequence:** **clear proprietary confirm-gate** → ship **Keygen-lite API** as wedge #1 (fastest, smallest) → then multi-tenant storefront as wedge #2 → migration importer from Gumroad.
- **MVP scope:** license `/issue`+`/verify` + dashboard + Stripe metering. Storefront multi-tenancy is phase 2.
- **Risks:** product catalog hardcoded in `products.ts` (biggest gap); no buyer auth/dashboard; Stripe Connect net-new; collision-safe keygen under concurrency (DeepSeek MEDIUM risk — load-test it).

---

## Proprietary confirm-before-build checklist (per `~/code/CLAUDE.md`)

No code may be lifted from these until you explicitly confirm:

- [ ] **C15** — source: `~/code/yurika-forge-app` (`yurika*` proprietary). Lifting: `app/api/forge/route.ts`, `app/page.tsx` pipeline, the 4 stage system-prompts.
- [ ] **C14** — source: `~/code/yurika.forge/apps/storefront` (`yurika*` proprietary; also sells Yurika-branded goods + uses guild-pattern subgraph). Lifting: `lib/license.ts`, `lib/stripe.ts`, checkout/webhook routes, `supabase/migrations/0001_purchases.sql`, email layer, tests.
- [ ] **C17** — source: `~/code/study-buddy` (greenfield, *no* confirm-gate) but content is Prince-personalised → **de-identify** `_meta/*` + modules before any resale.

---

## Security finding — RETRACTED after forensic verification (2026-05-16)

The pre-compaction scanner reported a *"live Supabase service-role key committed
in `~/code/yurika.space/.env.local`, purge from git history."* **This was an
overstatement and is retracted.** Six independent checks confirm there is **no
git leak**:

- `~/code/yurika.space/.env.local` is **untracked**, has **zero git history**,
  and `.gitignore` covers `.env*` (lines 2–6).
- **No env file was ever tracked** in history, on any branch.
- **No JWT-shaped secret in any blob** across all of history
  (`git rev-list --all` pickaxe + grep, values never printed).
- The only commits naming `SUPABASE_SERVICE_ROLE_KEY` are benign
  `process.env.SUPABASE_SERVICE_ROLE_KEY` *reads* (commits 374633f, fb60c07,
  bd053b4) — no values.
- Cross-repo sweep of every `~/code` repo HEAD: no real committed secrets — all
  hits were `.env.example` placeholders, dummy fallbacks, the public Hardhat
  test mnemonic, doc placeholders, or dev-only compose defaults.

**No history purge performed** (nothing to purge; a destructive rewrite of a
clean repo is pure risk). **No forced rotation** — the scanner conflated "secret
present in a working-tree file" with "committed to git". The only residue is
benign: the live key sits in the *untracked, gitignored* working file
`.env.local` (normal local-dev practice). The single genuine improvement is
**architectural**: a waitlist-only landing page should use the anon key + an RLS
`insert` policy rather than the RLS-bypassing service-role key. Rotate only as
optional precaution if the key was exposed out-of-band (deploy log, screenshot,
shared in chat) — not indicated by anything in this run.

## Infra follow-ups (root-caused + fixed/verified this run)

1. **borai-bot fanout preflight** — ✅ added this run: `GET /providers/{p}/probe` + a gate in `team_fanout.run_team_fanout` (env `FANOUT_SKIP_PREFLIGHT=1` bypass). Working.
2. **Gemini** — ✅ **RESOLVED 2026-05-16**. Interactive login completed; probe now reports `online:true, logged_in:true, lib:playwright` (composer visible at `gemini.google.com/app`). Gemini is fanout-ready.
3. **grok / perplexity concurrency 502** — ✅ **ROOT-CAUSED + FIXED + VERIFIED 2026-05-16**. Cause: concurrent `uc.Chrome()` launches race on undetected-chromedriver's *shared on-disk patched binary* + port allocation → one driver killed (`errno 111`), the other degraded. Fix: process-wide `asyncio.Lock` over the whole selenium_uc session lifetime in `browser_pool.BrowserPool.session()` (playwright/patchright unaffected, stay concurrent). Verified: pre-fix grok∥perplexity = grok 502/killed; post-fix both 200 (V1), 4-engine smoke `completed` 4/4. Residual: a *single shared* selenium_uc lane serialises selenium providers (acceptable; they're 2 of 4).
4. **borai-bot long-prompt truncation** — ✅ **ROOT-CAUSED + FIXED + VERIFIED 2026-05-16**. Cause measured: `keyboard.type()` at delay=0 drops ~14% of characters *scattered through* long input into ProseMirror (1652 sent → 1418 landed) → model answers a garbled prompt confidently OFF-TOPIC yet passes `validate_model_response` → **silent `usable` hallucination** (this is why the original Pass-2 gemini/deepseek "succeeded" with wrong products). Fix: atomic insertion — Playwright `keyboard.insert_text()` and, for undetected-chromedriver, CDP `Input.insertText` (`browser-bot/selenium_adapter.py::SeleniumKeyboardAdapter.insert_text`); plus a **read-back assertion** in `providers/base.py::BaseProvider._enter_prompt` that raises on mismatch so truncation is now a *loud failed lane*, never a silent hallucination. Verified at ~1.4 KB: gemini want=1407/got=1405 `ok=True`, grok 1407/1407 `ok=True`, sentinel present, answers on-topic. Long prompts are now safe; chunking is no longer required (it was the interim workaround used for this run's Pass-2).

## Pass-2 — 4-engine cross-validation (2026-05-16 rerun)

Role-specialised, content-verified on-topic. Artifacts: `.run-2026-05-16/fanout/pass2-fill/`.

| Cand | Perplexity TAM (directional) | Grok demand / bear | Gemini incumbents · solo gap | DeepSeek MVP |
|---|---|---|---|---|
| **C2** cost-router | $1–3B; comp LangSmith ($100s→low-$1000s/mo); budget ✓ | STRONG tailwind; bear: fast commoditization (LiteLLM/cloud GW) | Martian, Portkey, RouteLLM · *local edge↔cloud routing* | **S · 2–3 wk** · risk: <50 ms overhead |
| **C3** anti-farm | low-100s M (T&S/fraud slice); comp reCAPTCHA Ent | MODERATE + real pain (51% AI PRs, farming) | Gitcoin Passport, Galxe, LayerZero · *code-velocity micro-patterns* | M · 6–8 wk · risk: false positives |
| **C12** ctx-graph | infra slice (dev-tools) | tailwind (agent amnesia = top 2026 dev pain) | Cursor, Mem0 · *runtime temporal memory vs static index* | **L · 10–14 wk** · risk: traversal/mem at 100k+ symbols |
| **C14** Gumroad-lite | $1–2B; comp Gumroad $10/mo+10% | STRONG but **SATURATED** (Payhip, Lemon Squeezy, Thrivecart) | Gumroad, Keygen, Whop · *zero-config crypto-key embed for CLI devs* | M · 6–9 wk · risk: offline license enforcement |
| **C15** spec→code | $0.1–1B+; comp Copilot $10–19/dev | MASSIVE tailwind; bear: **commoditized** (Cursor/Claude Code/Spec Kit) | Lovable, Bolt, v0, Cursor · *PRD→prompt blueprinting (pre-dev)* | **S · 2–4 wk** · risk: output consistency |
| **C17** Lens | several B (edtech/AI-study); comp Khanmigo $20 | STRONG ($30B AI-edu by 2030, 30%+ CAGR) | Khanmigo, Synthesis, TutorAI · *analogy-to-prior-knowledge* | L · 10–14 wk · risk: personalisation quality |

**What it confirms / challenges the Top-3:**
- **C2 strengthened** (was single-engine runner-up): best + best-cited TAM, fastest build (S), and Gemini *independently* named the ledger's exact wedge (local-first routing). Its only weak axis — moat/commoditization — is real; the local-first + savings-receipt differentiation is now externally cross-validated, not just an internal thesis.
- **C15 moat weakened**: two independent engines (Grok, Gemini) flag heavy commoditization (Cursor/Claude Code/Copilot/Spec Kit). Time-to-revenue/effort remain excellent (S); the durable angle is Gemini's "pre-dev PRD→prompt blueprinting", not generic spec→code.
- **C17 #1 holds** on TAM + strategic-fit (yurika human-centric thesis) + moat, but DeepSeek confirms **L build-effort (10–14 wk)** — the honest drag on its time-to-revenue.
- **C14 stable**: acute fee-pain + ~80% built, but Grok/Gemini confirm a saturated field — the defensible slice is the narrow "zero-config crypto-license for indie CLI/desktop devs", not a broad Gumroad clone.

The headline scorecard table above is retained; this cross-validation refines the *reasoning* (notably: C2's wedge is now evidence-backed; C15's moat risk is now double-confirmed) without fabricating new precise scores.

## Method note (what to trust)

The **codebase intelligence** (Phase 0-1) is the durable, high-confidence output: 23 projects, 46 independent dossiers, reconciled, 19 deduped candidates with asset paths. The **external fanout** is now **genuine 4-engine, content-verified** (each engine's answer checked against the real candidate definitions, not trusted on `status=usable` — which this run proved is *not* a correctness signal). TAM figures remain order-of-magnitude by the engines' own admission. Net honest weighting: ranking leans on codebase evidence (what's built, effort, fit) with the 4-engine read as a now-genuine external cross-check (was a single-engine overlay; the three infra blockers that forced that were fixed and verified — see Follow-ups 3-4).
