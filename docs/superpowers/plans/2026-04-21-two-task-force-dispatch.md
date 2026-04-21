# Two-Task-Force Dispatch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dispatch two parallel subagent task forces from the Claude Code orchestrator to close Misled Scene 04 to ship-minus-send state and bring ai-swarm-infra from scaffold to first-runnable + bootstrap-ready state, delegating generative sub-tasks to Gemini / Copilot / Cursor per the delegate-agent routing table.

**Architecture:** Approach C hybrid staged dispatch. Phase 1 parallel state-mapping via Claude Code `Explore` subagents. Phase 2 parallel generative delegation to external LLMs (Gemini for long-form prose and specs, Copilot for single-file code and shell, Cursor for multi-file feature implementation). Phase 3 review via `diff-reviewer` for Tier 2 outputs + consolidated Tier 3 presentation to Prince. Two isolated git worktrees prevent filesystem collision between task forces.

**Tech Stack:** BorAI monorepo (pnpm workspaces, Turborepo, Vercel). Misled app: Next.js 15 App Router + Tailwind + shadcn-less hand-rolled Y2K components. Backend additions: Supabase (postgres + auth), Resend (transactional email), Vercel Cron. ai-swarm-infra: Python 3.11 + uv + requests + python-dotenv + rich (CLI output). External CLIs: gemini, copilot, cursor-agent. Review: delegate-agent routing table at `~/.claude/commands/delegate-agent/references/`.

---

## Referenced spec

`docs/superpowers/specs/2026-04-21-two-task-force-dispatch-design.md` (committed earlier this session, short hash pending). All acceptance criteria, hard limits, and risk register in that spec are authoritative.

## Repo map (before dispatch)

- **BorAI** `~/code/BorAI` — currently on `feature/misled-ethos-page` at `c69a238`, clean working tree. Main at `35cc0a8`.
- **build-in-public** `~/code/build-in-public` — active vault, main branch, clean.
- **delegate-agent references** `~/.claude/commands/delegate-agent/references/` — routing-table.md, tool-registry.md, review-gates.md.

## CLI verification

Installed and available on PATH:

- `gemini` → `/home/linuxbrew/.linuxbrew/bin/gemini`
- `copilot` → `/home/onceuponaprince/.local/bin/copilot`
- `cursor-agent` → `/home/onceuponaprince/.local/bin/cursor-agent`
- `gh` → `/snap/bin/gh` (snap-packaged; prefix `GIT_CONFIG_NOSYSTEM=1` before any gh command per PROGRESS.md)

---

# Phase 0: Worktree setup (orchestrator, serial)

Both worktrees must exist before Phase 1 can run in parallel. The orchestrator creates them before dispatching anything.

### Task 0.1: Create Misled worktree

**Files:**
- Create worktree at: `~/code/BorAI-misled-wt/`
- Tracks branch: `feature/misled-ethos-page` (already exists, pushed)

- [ ] **Step 1: Create the worktree**

```bash
cd ~/code/BorAI
git worktree add ~/code/BorAI-misled-wt feature/misled-ethos-page
```

- [ ] **Step 2: Verify worktree exists and tracks correct branch**

```bash
git worktree list
```

Expected output includes a line like:
```
~/code/BorAI-misled-wt c69a238 [feature/misled-ethos-page]
```

- [ ] **Step 3: Verify clean state**

```bash
cd ~/code/BorAI-misled-wt && git status --short
```

Expected: empty output (no changes).

### Task 0.2: Create ai-swarm-infra worktree

**Files:**
- Create worktree at: `~/code/BorAI-swarm-wt/`
- New branch: `feature/ai-swarm-infra-impl` off `main`

- [ ] **Step 1: Create the worktree with new branch**

```bash
cd ~/code/BorAI
git worktree add -b feature/ai-swarm-infra-impl ~/code/BorAI-swarm-wt main
```

- [ ] **Step 2: Verify**

```bash
git worktree list
```

Expected output includes:
```
~/code/BorAI-swarm-wt 35cc0a8 [feature/ai-swarm-infra-impl]
```

- [ ] **Step 3: Confirm pyproject exists at expected location**

```bash
ls ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/
```

Expected: `main.py`, `network_client.py`, `orchestrator.py`, `personas.py`, `pyproject.toml`, `README.md`.

---

# Phase 1: Parallel state-mapping (two Explore subagents, run concurrently)

Dispatched together in one orchestrator turn with two concurrent Agent calls.

### Task 1.1: Misled state explorer

**Agent:** `Explore` (read-only, thoroughness: medium)

**Files read (no writes):**
- `~/code/build-in-public/docs/handoffs/2026-04-21-misled-task-7-handoff.md`
- `~/code/build-in-public/docs/superpowers/plans/2026-04-20-misled-ethos-page.md`
- `~/code/BorAI-misled-wt/apps/misled/` (full tree)
- `~/code/build-in-public/campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md`

- [ ] **Step 1: Dispatch the explorer**

```
Agent({
  description: "Misled state mapping",
  subagent_type: "Explore",
  prompt: "Map the current state of the Misled Next.js app for Task 7 dispatch. Read:
  - ~/code/build-in-public/docs/handoffs/2026-04-21-misled-task-7-handoff.md
  - ~/code/build-in-public/docs/superpowers/plans/2026-04-20-misled-ethos-page.md (focus: Phase 5 backend tasks 21–24)
  - ~/code/BorAI-misled-wt/apps/misled/ (list all components, check app/ router structure, inspect subscribe-form.tsx for current form handler)
  - ~/code/build-in-public/campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md (scope 04 context)

  Return a structured report under 400 words with:
  1. Current subscribe form submit handler location + current behaviour (should be console.log per handoff)
  2. Any Supabase/Resend scaffolding already present (.env.example, package deps, API routes)
  3. Exact path where Supabase migration should live (check for existing apps/misled/supabase/ or propose path)
  4. Exact path for Resend API route (confirm apps/misled/app/api/subscribe/route.ts pattern)
  5. Whether vercel.json exists; if so, its current shape
  6. Any deltas between the Task 7 handoff description and current filesystem state
  7. GO/NO-GO for Phase 2 backend scaffold, with any blockers listed"
})
```

- [ ] **Step 2: Capture explorer output**

Record the returned report in the session as a reference for Phase 2 delegations. Orchestrator uses this report to parameterise Cursor/Copilot delegation prompts with exact paths.

### Task 1.2: ai-swarm-infra state explorer

**Agent:** `Explore` (read-only, thoroughness: medium)

**Files read (no writes):**
- `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/` (full tree)
- `~/code/build-in-public/campaigns/command-centre/chapters/01-origin/scenes/05-source-ai-swarm-infra-catalogue.md`

- [ ] **Step 1: Dispatch the explorer**

```
Agent({
  description: "ai-swarm-infra state mapping",
  subagent_type: "Explore",
  prompt: "Map ai-swarm-infra scaffold state for Phase 2 implementation dispatch. Read:
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/README.md (architecture blueprint)
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/main.py (current skeleton)
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/orchestrator.py (current skeleton)
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/network_client.py (current skeleton)
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/personas.py (persona strings, already populated)
  - ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/pyproject.toml (current deps)

  Return under 400 words with:
  1. Exact current line count + content summary of each skeleton file
  2. pyproject.toml current dependencies and Python version pin
  3. Ollama API contract expected per README (endpoint path, payload shape, stream flag)
  4. Persona prompts (CODER_PERSONA, REVIEWER_PERSONA) summarised
  5. Proposed file structure for bootstrap tutorials (recommend ops/ai-swarm-infra/bootstrap/windows-coder.md, macos-reviewer.md, linux-orchestrator.md)
  6. Any gap between the README blueprint and the skeletons that needs explicit design choice (e.g. retry strategy, timeout values, output directory handling)
  7. GO/NO-GO for Phase 2 Python dispatch"
})
```

- [ ] **Step 2: Capture explorer output**

Same pattern: record report, use to parameterise Phase 2 delegations.

---

# Phase 2A: Misled Task Force delegations

All tasks operate inside `~/code/BorAI-misled-wt/`. Run in the order below (some can parallel — noted per task). Commit frequently, atomic commits, conventional messages.

### Task 2A.1: Smoke-test the live Vercel preview

**Agent:** general-purpose (read-only Agent dispatch with WebFetch)

**Files:** no code changes, produces report at `~/code/build-in-public/docs/handoffs/2026-04-21-misled-smoke-test.md`.

- [ ] **Step 1: Dispatch the smoke-test agent**

```
Agent({
  description: "Misled preview smoke test",
  subagent_type: "general-purpose",
  prompt: "Smoke-test https://misled.vercel.app/ against the Task 7 handoff expectations in ~/code/build-in-public/docs/handoffs/2026-04-21-misled-task-7-handoff.md (section 'State of the live page'). Use WebFetch to pull the rendered HTML. Report:
  1. All eight expected sections present? (TopToolbar, Hero, Marquee, Manifesto, Tease, Subscribe, floating sticker, StatusBar)
  2. Any obviously-broken markup (missing images, broken refs)
  3. Form element present with expected attributes (name, type, placeholder)
  4. Any <script> errors visible in the initial HTML (e.g. error boundaries rendered)
  5. Verdict: PASS / FAIL / FLAG. If FAIL or FLAG, list specific issues.

  Write the report as markdown. Return the report body — the orchestrator will write it to disk."
})
```

- [ ] **Step 2: Write the smoke-test report**

```bash
# In orchestrator
# Write the returned report body to:
# ~/code/build-in-public/docs/handoffs/2026-04-21-misled-smoke-test.md
```

- [ ] **Step 3: Commit the report to the vault**

```bash
cd ~/code/build-in-public
git add docs/handoffs/2026-04-21-misled-smoke-test.md
git commit -m "docs(misled): smoke-test report for preview deploy"
```

### Task 2A.2: Supabase subscribers table migration

**Files:**
- Create: `~/code/BorAI-misled-wt/apps/misled/supabase/migrations/0001_create_subscribers.sql`
- Modify: `~/code/BorAI-misled-wt/apps/misled/.env.example` (add SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY)

**Delegation:** Copilot (Tier 1 — auto-apply after validation)

- [ ] **Step 1: Dispatch Copilot for the migration SQL**

```bash
copilot -p "Generate a PostgreSQL migration for a Supabase 'subscribers' table for a Y2K-coded landing page waitlist.

Columns required:
- id: uuid primary key default gen_random_uuid()
- email: citext unique not null
- confirmed: boolean default false
- confirmation_token: uuid default gen_random_uuid()
- created_at: timestamptz default now()
- confirmed_at: timestamptz nullable

Also:
- Enable citext extension if not enabled
- Create btree index on email
- Create btree index on (confirmed, created_at) for the cron deletion job

Return only valid SQL, no markdown fences, no commentary."
```

- [ ] **Step 2: Save output to migration file**

```bash
# Capture stdout from Copilot into apps/misled/supabase/migrations/0001_create_subscribers.sql
# Orchestrator validates: SQL syntax parses, contains CREATE TABLE subscribers, contains CREATE EXTENSION citext
```

- [ ] **Step 3: Update `.env.example`**

```bash
# Append to ~/code/BorAI-misled-wt/apps/misled/.env.example:
cat >> ~/code/BorAI-misled-wt/apps/misled/.env.example <<'EOF'

# Supabase (Phase 5 backend — Scene 04 Task 7 scope)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
EOF
```

- [ ] **Step 4: Commit**

```bash
cd ~/code/BorAI-misled-wt
git add apps/misled/supabase/migrations/0001_create_subscribers.sql apps/misled/.env.example
git commit -m "feat(misled): add supabase subscribers migration + env scaffolding"
```

### Task 2A.3: Resend double-opt-in (multi-file — Cursor Tier 2)

**Files:**
- Create: `~/code/BorAI-misled-wt/apps/misled/app/api/subscribe/route.ts`
- Create: `~/code/BorAI-misled-wt/apps/misled/app/api/confirm/[token]/route.ts`
- Create: `~/code/BorAI-misled-wt/apps/misled/lib/supabase.ts`
- Create: `~/code/BorAI-misled-wt/apps/misled/lib/resend.ts`
- Create: `~/code/BorAI-misled-wt/apps/misled/emails/confirmation-email.tsx` (React Email template)
- Modify: `~/code/BorAI-misled-wt/apps/misled/components/subscribe-form.tsx` (wire form to API route)
- Modify: `~/code/BorAI-misled-wt/apps/misled/package.json` (add `@supabase/supabase-js`, `resend`, `react-email`, `@react-email/components`)
- Modify: `~/code/BorAI-misled-wt/apps/misled/.env.example` (add RESEND_API_KEY, RESEND_FROM_ADDRESS, NEXT_PUBLIC_APP_URL)

**Delegation:** Cursor (Tier 2 — diff-reviewer then apply)

- [ ] **Step 1: Check worktree clean**

```bash
cd ~/code/BorAI-misled-wt && git status --short
```

Expected: empty. If dirty, halt and alert Prince.

- [ ] **Step 2: Dispatch Cursor with exact scope**

```bash
cd ~/code/BorAI-misled-wt
cursor-agent -p "Implement the Resend double-opt-in flow for the Misled waitlist subscribe form.

SCOPE — modify only these exact files, do not touch anything outside this list:
- CREATE apps/misled/app/api/subscribe/route.ts
- CREATE apps/misled/app/api/confirm/[token]/route.ts
- CREATE apps/misled/lib/supabase.ts
- CREATE apps/misled/lib/resend.ts
- CREATE apps/misled/emails/confirmation-email.tsx
- MODIFY apps/misled/components/subscribe-form.tsx (only the form submit handler; preserve all Y2K visual styling)
- MODIFY apps/misled/package.json (only add deps: @supabase/supabase-js, resend, react-email, @react-email/components; do not change unrelated entries)
- MODIFY apps/misled/.env.example (append three entries: RESEND_API_KEY=, RESEND_FROM_ADDRESS=, NEXT_PUBLIC_APP_URL=)

REQUIREMENTS:
- apps/misled/app/api/subscribe/route.ts: POST handler. Reads { email, website } from request body. 'website' is honeypot — if truthy, return 200 with silent drop. Validates email with zod. Inserts into subscribers table via service-role Supabase client. Sends confirmation email via Resend with token in the link (NEXT_PUBLIC_APP_URL + '/api/confirm/' + token). Returns { ok: true } on success, { error: '...' } on failure.
- apps/misled/app/api/confirm/[token]/route.ts: GET handler. Sets confirmed=true, confirmed_at=now() where confirmation_token matches param. Returns HTML page (inline template in route file, no new component) confirming success, styled to match Y2K aesthetic (Win95 dialog shape, gold borders). On invalid token returns 404 HTML.
- apps/misled/lib/supabase.ts: exports a getServiceRoleClient() function using SUPABASE_SERVICE_ROLE_KEY. Do not expose service role key client-side.
- apps/misled/lib/resend.ts: exports sendConfirmationEmail(email, token) calling the Resend client.
- apps/misled/emails/confirmation-email.tsx: React Email template. Subject: 'Confirm your Misled transmission'. Body references Y2K voice: 'SIGNAL AWAITING CONFIRMATION.' Single confirm link.
- apps/misled/components/subscribe-form.tsx: replace the console.log submit handler with fetch to /api/subscribe. On 200 keep the existing ConfirmPanel. On non-200 show error state in existing form shell. Preserve all existing visual elements.

CONSTRAINTS:
- TypeScript strict mode, no 'any' types
- No comments except where logic is non-obvious
- No em-dashes in source code
- Function length under 30 lines, file length under 200 lines
- Add zod to package.json deps if using it
- No hardcoded credentials; everything via process.env with zod env validation via apps/misled/env.ts — if env.ts does not exist, create it as part of this scope

Return a diff summary at the end. Do not commit."
```

- [ ] **Step 3: Route Cursor output through diff-reviewer**

```
Agent({
  description: "Diff review: Resend flow",
  subagent_type: "general-purpose",
  prompt: "Act as diff-reviewer per ~/.claude/commands/delegate-agent/references/review-gates.md. Review the uncommitted changes in ~/code/BorAI-misled-wt/ with: git -C ~/code/BorAI-misled-wt/ diff --stat && git -C ~/code/BorAI-misled-wt/ diff.

Check:
- Are all modifications within the stated scope? (list of files in Task 2A.3)
- Any breaking interface change in subscribe-form.tsx?
- New deps added: @supabase/supabase-js, resend, react-email, @react-email/components, zod only?
- Any hardcoded credentials, API keys, or SUPABASE service role values?
- Any out-of-scope file modified?
- TypeScript strict; no 'any'
- Honeypot 'website' field handling present?

Return the exact REVIEW NOTE format from review-gates.md section 'diff-reviewer subagent specification' — Verdict: PASS or FLAG, max 200 words, no em-dashes."
})
```

- [ ] **Step 4: If PASS — commit**

```bash
cd ~/code/BorAI-misled-wt
pnpm install   # install new deps before committing lockfile
git add apps/misled/app/api/subscribe/route.ts apps/misled/app/api/confirm/[token]/route.ts apps/misled/lib/supabase.ts apps/misled/lib/resend.ts apps/misled/emails/confirmation-email.tsx apps/misled/components/subscribe-form.tsx apps/misled/package.json apps/misled/.env.example apps/misled/env.ts pnpm-lock.yaml
git commit -m "feat(misled): resend double-opt-in flow with honeypot + supabase persistence"
```

- [ ] **Step 5: If FLAG — escalate to Prince**

Present the review note + flagged concerns. Do not apply. Wait for Prince's instruction: revise / discard / accept-anyway.

### Task 2A.4: Cron deletion of unconfirmed rows (Vercel Cron)

**Files:**
- Create: `~/code/BorAI-misled-wt/apps/misled/app/api/cron/cleanup/route.ts`
- Modify: `~/code/BorAI-misled-wt/apps/misled/vercel.json` (add crons schedule)
- Modify: `~/code/BorAI-misled-wt/apps/misled/.env.example` (add CRON_SECRET)

**Delegation:** Copilot (Tier 1 — auto-apply after validation)

- [ ] **Step 1: Dispatch Copilot for cron handler**

```bash
copilot -p "Write a Next.js 15 App Router GET route handler at apps/misled/app/api/cron/cleanup/route.ts for Vercel Cron.

Requirements:
- Validates Authorization header equals 'Bearer ' + process.env.CRON_SECRET. Returns 401 if mismatch.
- Uses getServiceRoleClient() from '@/lib/supabase' (already exists in the repo)
- Deletes rows from 'subscribers' table where confirmed = false AND created_at < now() - interval '7 days'
- Returns JSON { deleted: <count> } on success
- TypeScript strict, no 'any', under 30 lines
- No em-dashes, no comments unless the logic is non-obvious

Return only the route file contents, no markdown fences."
```

- [ ] **Step 2: Save to route file**

```bash
# Orchestrator writes Copilot output to apps/misled/app/api/cron/cleanup/route.ts
# Validate: contains GET export, references process.env.CRON_SECRET, calls .delete()
```

- [ ] **Step 3: Update vercel.json**

```bash
# If apps/misled/vercel.json does not exist, create it with:
cat > ~/code/BorAI-misled-wt/apps/misled/vercel.json <<'EOF'
{
  "crons": [
    {
      "path": "/api/cron/cleanup",
      "schedule": "0 3 * * *"
    }
  ]
}
EOF
# If it exists, merge the crons key carefully (orchestrator reads first, merges)
```

Schedule rationale: 03:00 UTC daily — off-peak, once-per-day is enough for a 7-day TTL.

- [ ] **Step 4: Append CRON_SECRET to .env.example**

```bash
cat >> ~/code/BorAI-misled-wt/apps/misled/.env.example <<'EOF'
CRON_SECRET=
EOF
```

- [ ] **Step 5: Commit**

```bash
cd ~/code/BorAI-misled-wt
git add apps/misled/app/api/cron/cleanup/route.ts apps/misled/vercel.json apps/misled/.env.example
git commit -m "feat(misled): vercel cron to purge unconfirmed subs older than 7 days"
```

### Task 2A.5: Client message draft (Gemini Tier 3)

**Files:**
- Create: `~/code/build-in-public/docs/handoffs/2026-04-21-misled-client-message-draft.md`

**Delegation:** Gemini (Tier 3 — present to Prince)

- [ ] **Step 1: Dispatch Gemini with voice context**

```bash
gemini -p "$(cat <<'EOF'
Draft a message from Prince to the Misled founder to share the ethos-page preview.

Recipient: London-based skater + brand operator, not a typical SaaS founder. Register: direct, peer-to-peer, no 'as discussed', no 'kindly find attached'.

Preview URL: https://misled.vercel.app/

What the client will see: Y2K rave/tech aesthetic landing page. Vaporwave hero, Win95 OS chrome, CRT scanlines. Anton + Press Start 2P + VT323 + Space Grotesk + Space Mono + Syne typography. Three Win95 'windows' containing manifesto, tease, and subscribe sections. Form is visually wired but not yet connected to the backend (backend is shipping in the same cycle). Hero will be replaced with a Maxime Heckel WebGL fork in the next cycle.

Voice requirements: British English (realise, colour, organise). No marketing speak. Sentences short and declarative. Colons that earn their keep. No em-dashes. No words: 'game-changer', 'disruptor', 'synergy', 'leverage', 'unlock' (as marketing), 'dive in', 'break this down'.

Structure the message:
1. Opening line: preview is live, URL.
2. One line on the aesthetic intent.
3. Ranked three-question feedback prompt: (a) Y2K dial too much / too little, (b) manifesto copy voice check, (c) typography fit for audience.
4. One-line status on what is pending (WebGL hero fork, backend).

Under 120 words. No markdown. Plain text ready to paste.
EOF
)"
```

- [ ] **Step 2: Strip Gemini preamble + save to vault**

```bash
# Orchestrator captures stdout, strips any lines before the actual message body,
# writes to: ~/code/build-in-public/docs/handoffs/2026-04-21-misled-client-message-draft.md
# Wraps the message in a short header noting it is a draft awaiting Prince's pass.
```

- [ ] **Step 3: Commit draft**

```bash
cd ~/code/build-in-public
git add docs/handoffs/2026-04-21-misled-client-message-draft.md
git commit -m "docs(misled): client message draft for task 7 handoff"
```

- [ ] **Step 4: Queue for Prince Tier 3 review**

Do not send. Present in final batch at end of Phase 3.

### Task 2A.6: Scene 04 Conclude block draft (Gemini Tier 3)

**Files:**
- Modify: `~/code/build-in-public/campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md` (populate empty Conclude block)

**Delegation:** Gemini (Tier 3 — present to Prince for edit)

- [ ] **Step 1: Gather source material**

The orchestrator reads:
- `campaigns/command-centre/chapters/01-origin/scenes/04-misled-ethos-page.md` (existing Set Stage + Moment-by-moment)
- `docs/handoffs/2026-04-21-misled-task-7-handoff.md`
- `docs/superpowers/plans/2026-04-20-misled-ethos-page.md` (decisions log)

- [ ] **Step 2: Dispatch Gemini with vault voice + source bundle**

```bash
gemini -p "$(cat <<'EOF'
Draft the Conclude block for Misled Scene 04 in Prince's voice per ~/code/build-in-public/CLAUDE.md section 'Voice guide'.

The five core questions of a Conclude block, answered in order (from ~/code/build-in-public/CLAUDE.md section 'The scene structure'):
1. How is now different from the start?
2. What are the consequences?
3. What did we learn?
4. Progress to thesis
5. Progress to goal
6. Next scene
7. Artifact format

Input materials: scene's Set Stage + Moment-by-moment capture, the Task 7 handoff doc, the Scene 04 implementation plan.

Source summary to base the Conclude on:
- Scene started with a PDF brief from the Misled founder and a blank Next.js app
- Through Tasks 1–6: scaffolded the app, applied the Y2K design system, landed a Maxime Heckel vaporwave reference aesthetic, shipped 8 composed sections with full typographic system and CRT scanlines
- Introduced a load-bearing pre-push hook after burning a build cycle on lint
- Deployed via Vercel dashboard Git integration, not CLI
- Phase 5 backend (this session): Supabase + Resend double-opt-in + Vercel Cron implemented
- The scene concludes when Prince sends the preview to the client — this Conclude drafts the reflection assuming that send has just happened
- Thesis: 'Build should feel like play. Play should write the story.'
- The chapter goal: from insight to manual proof on real client work

Voice constraints: British English. Sophisticated register. No marketing speak. Short declaratives. Colons that earn their keep. No em-dashes. Avoid: game-changer, disruptor, synergy, leverage, unlock, dive in, break this down, at the end of the day. Embrace: load-bearing, earns its place, compounds, the shape of the thing.

Artifact format: suggest one of 'thread', 'newsletter', 'video', 'essay', or a combination — your call based on the material.

Output: markdown body only, starting with '### How is now different from the start?' (no frontmatter, no top-level heading). Max 600 words.
EOF
)"
```

- [ ] **Step 3: Strip preamble + save draft to a side file**

```bash
# Orchestrator writes to:
# ~/code/build-in-public/docs/handoffs/2026-04-21-misled-scene-04-conclude-draft.md
# NOT yet merged into the scene file — Prince edits first.
```

- [ ] **Step 4: Commit draft**

```bash
cd ~/code/build-in-public
git add docs/handoffs/2026-04-21-misled-scene-04-conclude-draft.md
git commit -m "docs(misled): scene 04 conclude block draft for prince's pass"
```

- [ ] **Step 5: Queue for Prince Tier 3 review**

Do not merge into the scene file. Present at end of Phase 3.

---

# Phase 2B: ai-swarm-infra Task Force delegations

All tasks operate inside `~/code/BorAI-swarm-wt/`. Runs in parallel with Phase 2A (different worktree, no filesystem collision). Orchestrator schedules delegations in waves so context pressure stays low.

### Task 2B.1: pyproject.toml dependencies (Copilot Tier 1)

**Files:**
- Modify: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/pyproject.toml`

- [ ] **Step 1: Read current pyproject**

```bash
cat ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/pyproject.toml
```

- [ ] **Step 2: Dispatch Copilot for dep update**

```bash
copilot -p "Rewrite the [project] dependencies array in a pyproject.toml to add these runtime deps for an Ollama HTTP orchestrator CLI:
- requests>=2.32
- python-dotenv>=1.0
- rich>=13.7

And these dev deps under [dependency-groups] dev:
- pytest>=8.0
- pytest-mock>=3.12
- responses>=0.25

Python requires-python should be '>=3.11'.

Preserve the existing [project] name, version, description, and any authors. Return only the updated pyproject.toml content, no markdown fences, no commentary."
```

- [ ] **Step 3: Save output + validate TOML parses**

```bash
# Orchestrator writes Copilot output to ops/ai-swarm-infra/pyproject.toml
python3 -c "import tomllib; tomllib.loads(open('$HOME/code/BorAI-swarm-wt/ops/ai-swarm-infra/pyproject.toml').read())" && echo "TOML valid"
```

Expected: `TOML valid`. If parse fails, re-delegate with correction note.

- [ ] **Step 4: Run uv sync**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv sync
```

Expected: lockfile created/updated, no resolution errors.

- [ ] **Step 5: Commit**

```bash
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/pyproject.toml ops/ai-swarm-infra/uv.lock
git commit -m "feat(swarm): runtime + dev deps for ollama orchestrator"
```

### Task 2B.2: Config loader + .env.example (Copilot Tier 1)

**Files:**
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/config.py`
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/.env.example`

- [ ] **Step 1: Dispatch Copilot**

```bash
copilot -p "Write a Python 3.11 module config.py for an Ollama orchestrator CLI.

Requirements:
- Uses python-dotenv to load .env at import time (load_dotenv())
- Exports a frozen dataclass SwarmConfig with fields:
  - coder_url: str  (from env CODER_NODE_URL, e.g. 'http://192.168.1.20:11434')
  - reviewer_url: str  (from env REVIEWER_NODE_URL)
  - coder_model: str  (from env CODER_MODEL, default 'qwen2.5-coder:7b')
  - reviewer_model: str  (from env REVIEWER_MODEL, default 'llama3.2:3b')
  - request_timeout_seconds: int  (from env REQUEST_TIMEOUT, default 120)
  - output_dir: str  (from env OUTPUT_DIR, default './output')
- Exports load_config() -> SwarmConfig. Raises ValueError with a clear message if any required env var is missing. Required: CODER_NODE_URL, REVIEWER_NODE_URL.
- Type hints throughout, no 'any'
- No em-dashes, no comments except for the missing-env ValueError message
- Under 50 lines

Return only the config.py contents, no markdown fences."
```

- [ ] **Step 2: Save + create .env.example**

```bash
# Write Copilot output to ops/ai-swarm-infra/config.py
# Create ops/ai-swarm-infra/.env.example with:
cat > ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/.env.example <<'EOF'
# Required
CODER_NODE_URL=http://192.168.X.X:11434
REVIEWER_NODE_URL=http://192.168.Y.Y:11434

# Optional
CODER_MODEL=qwen2.5-coder:7b
REVIEWER_MODEL=llama3.2:3b
REQUEST_TIMEOUT=120
OUTPUT_DIR=./output
EOF
```

- [ ] **Step 3: Validate import**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run python -c "from config import SwarmConfig; print(SwarmConfig.__dataclass_fields__.keys())"
```

Expected: dict_keys containing all six fields.

- [ ] **Step 4: Commit**

```bash
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/config.py ops/ai-swarm-infra/.env.example
git commit -m "feat(swarm): config loader + env template for worker node URLs"
```

### Task 2B.3: network_client.py implementation (Cursor Tier 2)

**Files:**
- Modify: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/network_client.py`
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/tests/test_network_client.py`

- [ ] **Step 1: Check worktree clean**

```bash
cd ~/code/BorAI-swarm-wt && git status --short
```

Expected: empty. If dirty, halt.

- [ ] **Step 2: Write the failing tests first (TDD — orchestrator writes these directly; small enough to not need delegation)**

```python
# Write to: ops/ai-swarm-infra/tests/test_network_client.py
"""Tests for NetworkClient using responses lib to mock HTTP."""
import pytest
import responses
from network_client import NetworkClient, WorkerError


@responses.activate
def test_generate_returns_response_text():
    responses.add(
        responses.POST,
        "http://worker:11434/api/generate",
        json={"response": "def hello(): pass"},
        status=200,
    )
    client = NetworkClient(timeout_seconds=10)
    result = client.generate(
        node_url="http://worker:11434",
        model="qwen2.5-coder:7b",
        system="You are a coder",
        prompt="Write hello",
    )
    assert result == "def hello(): pass"


@responses.activate
def test_generate_raises_on_non_200():
    responses.add(
        responses.POST,
        "http://worker:11434/api/generate",
        json={"error": "model not found"},
        status=404,
    )
    client = NetworkClient(timeout_seconds=10)
    with pytest.raises(WorkerError, match="model not found"):
        client.generate(
            node_url="http://worker:11434",
            model="bogus",
            system="s",
            prompt="p",
        )


@responses.activate
def test_generate_raises_on_connection_error():
    responses.add(
        responses.POST,
        "http://worker:11434/api/generate",
        body=ConnectionError("refused"),
    )
    client = NetworkClient(timeout_seconds=10)
    with pytest.raises(WorkerError, match="connection"):
        client.generate(
            node_url="http://worker:11434",
            model="m",
            system="s",
            prompt="p",
        )
```

- [ ] **Step 3: Run the tests to confirm they fail**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/test_network_client.py -v
```

Expected: ImportError or all three tests fail (WorkerError not defined, etc).

- [ ] **Step 4: Dispatch Cursor for implementation**

```bash
cd ~/code/BorAI-swarm-wt
cursor-agent -p "Implement ops/ai-swarm-infra/network_client.py to satisfy the tests in ops/ai-swarm-infra/tests/test_network_client.py.

SCOPE: only modify ops/ai-swarm-infra/network_client.py. Do not modify tests, do not touch any other file.

REQUIREMENTS:
- Export class NetworkClient with __init__(self, timeout_seconds: int)
- Method: generate(self, node_url: str, model: str, system: str, prompt: str) -> str
- POSTs to f'{node_url}/api/generate' with JSON body: {'model': model, 'system': system, 'prompt': prompt, 'stream': False}
- Returns parsed response['response'] on 200
- Raises WorkerError('...') on non-200 with the Ollama 'error' field in the message if present
- Raises WorkerError('connection ...') on requests ConnectionError or Timeout
- Export custom exception class WorkerError(Exception)
- Uses requests library. No retries in this class — retries are an orchestrator concern.
- Type hints throughout, no 'any'
- Under 60 lines
- No em-dashes

Run 'uv run pytest tests/test_network_client.py -v' inside ops/ai-swarm-infra and confirm all tests pass before returning."
```

- [ ] **Step 5: Run tests to confirm green**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/test_network_client.py -v
```

Expected: 3 passed.

- [ ] **Step 6: Route diff through diff-reviewer**

```
Agent({
  description: "Diff review: network_client",
  subagent_type: "general-purpose",
  prompt: "diff-reviewer per ~/.claude/commands/delegate-agent/references/review-gates.md. Review: git -C ~/code/BorAI-swarm-wt/ diff ops/ai-swarm-infra/network_client.py. Check scope (only network_client.py modified), no hardcoded URLs, no em-dashes, type hints present, WorkerError exported, under 60 lines. Return REVIEW NOTE in the specified format."
})
```

- [ ] **Step 7: Commit on PASS**

```bash
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/network_client.py ops/ai-swarm-infra/tests/test_network_client.py
git commit -m "feat(swarm): network client with ollama generate endpoint + tests"
```

### Task 2B.4: orchestrator.py implementation (Cursor Tier 2)

**Files:**
- Modify: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/orchestrator.py`
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/tests/test_orchestrator.py`

- [ ] **Step 1: Write the failing test**

```python
# ops/ai-swarm-infra/tests/test_orchestrator.py
from unittest.mock import MagicMock
from orchestrator import run_pipeline
from network_client import NetworkClient


def test_pipeline_dispatches_coder_then_reviewer():
    mock_client = MagicMock(spec=NetworkClient)
    mock_client.generate.side_effect = ["raw code v1", "reviewed code v1"]

    result = run_pipeline(
        client=mock_client,
        user_goal="write hello world",
        coder_url="http://coder:11434",
        coder_model="qwen2.5-coder:7b",
        reviewer_url="http://reviewer:11434",
        reviewer_model="llama3.2:3b",
    )

    assert result == "reviewed code v1"
    assert mock_client.generate.call_count == 2
    first_call = mock_client.generate.call_args_list[0]
    second_call = mock_client.generate.call_args_list[1]
    assert first_call.kwargs["node_url"] == "http://coder:11434"
    assert first_call.kwargs["prompt"] == "write hello world"
    assert second_call.kwargs["node_url"] == "http://reviewer:11434"
    assert second_call.kwargs["prompt"] == "raw code v1"
```

- [ ] **Step 2: Run test — expect fail**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/test_orchestrator.py -v
```

Expected: ImportError on run_pipeline.

- [ ] **Step 3: Dispatch Cursor for implementation**

```bash
cd ~/code/BorAI-swarm-wt
cursor-agent -p "Implement ops/ai-swarm-infra/orchestrator.py to satisfy ops/ai-swarm-infra/tests/test_orchestrator.py.

SCOPE: only modify ops/ai-swarm-infra/orchestrator.py. Do not touch tests, personas.py, network_client.py, or anything else.

REQUIREMENTS:
- Export function run_pipeline(*, client, user_goal, coder_url, coder_model, reviewer_url, reviewer_model) -> str (keyword-only args after client)
- Two-stage pipeline:
  1. Call client.generate(node_url=coder_url, model=coder_model, system=CODER_PERSONA from personas.py, prompt=user_goal) — captures raw_code
  2. Call client.generate(node_url=reviewer_url, model=reviewer_model, system=REVIEWER_PERSONA from personas.py, prompt=raw_code) — captures reviewed_code
  3. Return reviewed_code
- Use rich.console.Console to print progress: '[cyan]→ dispatching to Coder...[/cyan]', '[green]← Coder returned (N chars)[/green]', then same for Reviewer
- Type hints throughout, no 'any'
- Under 40 lines
- No em-dashes

Run 'uv run pytest tests/test_orchestrator.py -v' before returning."
```

- [ ] **Step 4: Run tests**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/test_orchestrator.py -v
```

Expected: 1 passed.

- [ ] **Step 5: diff-reviewer pass**

```
Agent({
  description: "Diff review: orchestrator",
  subagent_type: "general-purpose",
  prompt: "diff-reviewer per review-gates.md. git -C ~/code/BorAI-swarm-wt/ diff ops/ai-swarm-infra/orchestrator.py. Check scope, no em-dashes, rich.Console used, under 40 lines. Return REVIEW NOTE."
})
```

- [ ] **Step 6: Commit on PASS**

```bash
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/orchestrator.py ops/ai-swarm-infra/tests/test_orchestrator.py
git commit -m "feat(swarm): two-stage orchestrator (coder -> reviewer) + tests"
```

### Task 2B.5: main.py CLI entry (Cursor Tier 2)

**Files:**
- Modify: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/main.py`
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/tests/test_main.py`

- [ ] **Step 1: Write the failing test (integration-ish via CliRunner or subprocess)**

```python
# ops/ai-swarm-infra/tests/test_main.py
import sys
from unittest.mock import patch
from main import run


def test_run_writes_output_file(tmp_path, monkeypatch):
    monkeypatch.setenv("CODER_NODE_URL", "http://coder:11434")
    monkeypatch.setenv("REVIEWER_NODE_URL", "http://reviewer:11434")
    monkeypatch.setenv("OUTPUT_DIR", str(tmp_path))

    with patch("main.NetworkClient") as mock_client_cls:
        mock_client = mock_client_cls.return_value
        mock_client.generate.side_effect = ["raw", "reviewed"]
        run(["write a login route"])

    written = list(tmp_path.glob("*.txt"))
    assert len(written) == 1
    assert written[0].read_text() == "reviewed"
```

- [ ] **Step 2: Run — expect fail**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/test_main.py -v
```

Expected: ImportError on run.

- [ ] **Step 3: Dispatch Cursor**

```bash
cd ~/code/BorAI-swarm-wt
cursor-agent -p "Implement ops/ai-swarm-infra/main.py to satisfy ops/ai-swarm-infra/tests/test_main.py.

SCOPE: only modify ops/ai-swarm-infra/main.py. Do not touch other files.

REQUIREMENTS:
- Export function run(argv: list[str] | None = None) -> None
  - Uses argparse with a single positional arg 'goal' (the user prompt)
  - Calls config.load_config() to get SwarmConfig
  - Creates NetworkClient(timeout_seconds=cfg.request_timeout_seconds)
  - Calls orchestrator.run_pipeline(client=..., user_goal=args.goal, coder_url=cfg.coder_url, coder_model=cfg.coder_model, reviewer_url=cfg.reviewer_url, reviewer_model=cfg.reviewer_model)
  - Ensures cfg.output_dir exists (Path.mkdir(parents=True, exist_ok=True))
  - Writes the reviewed_code to a timestamped file like {output_dir}/swarm-{timestamp}.txt where timestamp is YYYYMMDD-HHMMSS
  - Prints the output path via rich.Console: '[bold green]Written to:[/bold green] {path}'
- Export function main() that calls run(sys.argv[1:]) — the module entry point for 'python main.py ...'
- if __name__ == '__main__': main()
- Type hints throughout, under 60 lines
- No em-dashes

Run 'uv run pytest tests/test_main.py -v' before returning."
```

- [ ] **Step 4: Run test**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/ -v
```

Expected: all tests pass (network_client + orchestrator + main).

- [ ] **Step 5: diff-reviewer pass**

- [ ] **Step 6: Commit on PASS**

```bash
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/main.py ops/ai-swarm-infra/tests/test_main.py
git commit -m "feat(swarm): main.py CLI with output file write + integration test"
```

### Task 2B.6: README.md update (Gemini Tier 3)

**Files:**
- Modify: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/README.md`

**Delegation:** Gemini (Tier 3 — Prince approves before merge)

- [ ] **Step 1: Dispatch Gemini with current README as context**

```bash
CURRENT_README=$(cat ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/README.md)
gemini -p "$(cat <<EOF
Extend the README for ai-swarm-infra to reflect the now-runnable state. Preserve all existing content (architecture blueprint, hardware allocation, network flow, API interface, personas, target structure). Add two new sections at the end:

## 7. Quick Start (Orchestrator host)

Cover: prerequisites (Python 3.11, uv, a LAN with two worker nodes running Ollama), install steps (git clone ..., cd ops/ai-swarm-infra, cp .env.example .env, fill in worker IPs, uv sync), a one-line example run (uv run python main.py "write a python fastapi login route"), where output goes, how to verify it worked.

## 8. Bootstrapping worker nodes

Link to the three bootstrap tutorials under ./bootstrap/:
- windows-coder.md for the Ryzen 5 7535HS Coder node
- macos-reviewer.md for the 2019 Intel MacBook Pro Reviewer node
- linux-orchestrator.md for the Linux orchestrator host

One line describing each.

Constraints:
- Voice: technical, direct, plain. British English (realise, colour).
- No em-dashes.
- No fluff, no "this amazing" language.
- Return the full README content (existing + new sections), ready to write to disk.

Existing README content:
${CURRENT_README}
EOF
)"
```

- [ ] **Step 2: Save output**

```bash
# Orchestrator writes Gemini output to ops/ai-swarm-infra/README.md
```

- [ ] **Step 3: Queue for Prince Tier 3 review — do not commit yet**

### Task 2B.7: Windows Coder bootstrap tutorial (Gemini Tier 3)

**Files:**
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/windows-coder.md`

- [ ] **Step 1: Dispatch Gemini**

```bash
gemini -p "$(cat <<'EOF'
Write a step-by-step bootstrap tutorial for setting up an Ollama worker node on Windows. This node runs the Coder persona in the ai-swarm-infra orchestrator.

Hardware context: Ryzen 5 7535HS, 16GB RAM, small integrated GPU (431MB VRAM), 108GB free of 475GB. Windows 10 or 11.

Tutorial must cover:
1. Install Ollama for Windows (download link, installer verification)
2. Pull the qwen2.5-coder:7b model (size warning: ~4.7GB)
3. Configure Ollama to bind on 0.0.0.0 instead of 127.0.0.1 via the OLLAMA_HOST environment variable. Show how to set it persistently via System Properties > Environment Variables > User variables. Value: 0.0.0.0:11434.
4. Restart the Ollama service after the env change (taskkill + relaunch OR Services console restart).
5. Open inbound TCP port 11434 in Windows Defender Firewall. Show both the GUI path (Advanced Settings > Inbound Rules > New Rule > Port > TCP 11434 > Allow > Domain/Private only, NOT Public) and a single netsh command equivalent.
6. Find the machine's LAN IPv4 address using ipconfig. Point to the 'IPv4 Address' field under the active adapter (Ethernet or Wi-Fi).
7. Smoke-test the setup: from the orchestrator host (the Linux machine), curl http://<windows-ip>:11434/api/tags and expect JSON with qwen2.5-coder listed.
8. Add the discovered IP to the orchestrator's .env file as CODER_NODE_URL=http://<ip>:11434.

Constraints:
- Markdown with numbered sections matching the list above
- Plain, technical register
- British English
- No em-dashes
- Include copy-pasteable commands in fenced code blocks where possible
- Under 800 words
- Start with a one-line 'You should have finished this when...' success criterion at the top

Return only the markdown body.
EOF
)"
```

- [ ] **Step 2: Save output**

```bash
mkdir -p ~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap
# Orchestrator writes Gemini output to bootstrap/windows-coder.md
```

- [ ] **Step 3: Queue for Prince Tier 3 review**

### Task 2B.8: macOS Reviewer bootstrap tutorial (Gemini Tier 3)

**Files:**
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/macos-reviewer.md`

- [ ] **Step 1: Dispatch Gemini**

```bash
gemini -p "$(cat <<'EOF'
Write a step-by-step bootstrap tutorial for setting up an Ollama worker node on macOS. This node runs the Reviewer persona.

Hardware context: 2019 Intel MacBook Pro 16-inch, i9 2.3GHz, 16GB RAM, Radeon Pro 5500M 4GB (CPU inference primary path for llama3.2:3b), 300GB free of 1TB HDD. macOS Sonoma or later.

Tutorial must cover:
1. Install Ollama on macOS via brew install ollama OR direct download from ollama.com (include both options, note that brew is preferred for updatability)
2. Pull the llama3.2:3b model (size: ~2GB)
3. Set OLLAMA_HOST=0.0.0.0:11434 persistently. Show the launchctl approach for a launchd-managed service: create/edit ~/Library/LaunchAgents/com.ollama.plist with the EnvironmentVariables key containing OLLAMA_HOST. Alternatively, set in ~/.zshrc if running ollama serve manually.
4. Restart the Ollama service: launchctl unload/load sequence OR kill and restart the serve process.
5. Open inbound TCP port 11434 in macOS firewall. Intel Macs use the pf firewall plus the UI at System Settings > Network > Firewall. Show both: adding an application allow rule in System Settings, and optionally a pf anchor rule for explicit port 11434 inbound on en0 or en1 interface only (LAN, not Wi-Fi if on hotel networks).
6. Find the machine's LAN IPv4 using ifconfig en0 | grep 'inet '.
7. Thermal management note: the i9 under sustained inference will throttle. Recommend running on a cooled surface (laptop stand, desk with clearance), installing 'stats' (brew install stats) or 'TG Pro' to monitor CPU temps. Acceptable sustained temp under load: under 90°C. If throttling observed, reduce model size to llama3.2:1b.
8. Smoke-test from the orchestrator: curl http://<mac-ip>:11434/api/tags, expect llama3.2 listed.
9. Add to orchestrator .env: REVIEWER_NODE_URL=http://<mac-ip>:11434.

Constraints: same as Windows tutorial — markdown, numbered sections, British English, no em-dashes, under 800 words, one-line success criterion at the top.

Return only the markdown body.
EOF
)"
```

- [ ] **Step 2: Save output**

```bash
# Orchestrator writes Gemini output to bootstrap/macos-reviewer.md
```

- [ ] **Step 3: Queue for Prince Tier 3 review**

### Task 2B.9: Linux orchestrator host bootstrap tutorial (Gemini Tier 3)

**Files:**
- Create: `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/linux-orchestrator.md`

- [ ] **Step 1: Dispatch Gemini**

```bash
gemini -p "$(cat <<'EOF'
Write a step-by-step bootstrap tutorial for setting up the orchestrator host (the main machine that dispatches to the worker nodes) on Linux.

Hardware context: AMD Ryzen 5 (2.8GHz/3.4GHz), 36GB RAM, 43GB free of 250GB. Ubuntu-like distro (apt). The orchestrator does NOT run Ollama itself — it only runs the Python CLI that talks to the remote workers.

Tutorial must cover:
1. Install uv (the Python package manager) via the official curl installer from astral.sh/uv. Verify with uv --version.
2. Clone the BorAI repo (if not already cloned), navigate to ops/ai-swarm-infra.
3. Create .env from .env.example: cp .env.example .env. Fill in CODER_NODE_URL and REVIEWER_NODE_URL with the IPs discovered in the Windows and macOS tutorials.
4. Install dependencies: uv sync. This creates .venv and installs all runtime + dev deps pinned in uv.lock.
5. Smoke-test connectivity to both workers before a first run: two separate curl commands to http://<coder-ip>:11434/api/tags and http://<reviewer-ip>:11434/api/tags. Both must return JSON with the expected model listed. Include troubleshooting: if refused, worker bind address wrong; if timeout, firewall blocking.
6. First pipeline run: uv run python main.py 'write a python function that reverses a string'. Expected output: a file at ./output/swarm-YYYYMMDD-HHMMSS.txt containing reviewed code.
7. Tail the output: cat ./output/swarm-*.txt | tail -20.
8. Where to look when things fail: network_client errors mean the worker is unreachable; orchestrator errors mean a model is missing on a worker.

Constraints: same as other tutorials. Under 600 words.

Return only the markdown body.
EOF
)"
```

- [ ] **Step 2: Save output + commit all tutorials together**

```bash
# Orchestrator writes Gemini output to bootstrap/linux-orchestrator.md
# Then, once all three tutorials saved:
cd ~/code/BorAI-swarm-wt
git add ops/ai-swarm-infra/README.md ops/ai-swarm-infra/bootstrap/
git commit -m "docs(swarm): README quick-start + 3 bootstrap tutorials (win, mac, linux)"
```

---

# Phase 3: Review + consolidate (orchestrator)

### Task 3.1: Run full test suite in swarm worktree

- [ ] **Step 1: Execute**

```bash
cd ~/code/BorAI-swarm-wt/ops/ai-swarm-infra
uv run pytest tests/ -v
```

Expected: all tests pass. If any fail, halt and alert Prince.

### Task 3.2: Run lint + typecheck in misled worktree

- [ ] **Step 1: Execute per global CLAUDE.md rule**

```bash
cd ~/code/BorAI-misled-wt
pnpm --filter misled lint && pnpm --filter misled typecheck
```

Expected: both pass. If either fails, halt and alert Prince.

### Task 3.3: Push both branches

- [ ] **Step 1: Push misled branch**

```bash
cd ~/code/BorAI-misled-wt
git push -u origin feature/misled-ethos-page
```

- [ ] **Step 2: Push swarm branch**

```bash
cd ~/code/BorAI-swarm-wt
git push -u origin feature/ai-swarm-infra-impl
```

Expected: both succeed. Pre-push hook should pass since lint + typecheck already verified.

### Task 3.4: Consolidate Tier 3 outputs for Prince

Queue for single Prince review session:

- [ ] **Step 1: Assemble Tier 3 review packet**

Packet contents:
1. `docs/handoffs/2026-04-21-misled-smoke-test.md` — smoke test report
2. `docs/handoffs/2026-04-21-misled-client-message-draft.md` — client message
3. `docs/handoffs/2026-04-21-misled-scene-04-conclude-draft.md` — Scene 04 Conclude
4. `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/README.md` (diff vs previous)
5. `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/windows-coder.md`
6. `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/macos-reviewer.md`
7. `~/code/BorAI-swarm-wt/ops/ai-swarm-infra/bootstrap/linux-orchestrator.md`

- [ ] **Step 2: Present to Prince in one consolidated message**

Orchestrator outputs a structured presentation with file paths + one-line context per item + explicit instruction: "Review each. For any: 'use as-is', 'revise X', or 'discard'. On 'use as-is' for the Gemini Tier 3 items in the swarm repo, orchestrator commits the files into the branch. On revise, re-delegate. On discard, log and move on."

- [ ] **Step 3: On Prince approval of swarm README + tutorials — commit**

Already covered in Task 2B.9 commit. If Prince rejects any tutorial, rollback that specific file + re-delegate with correction notes.

### Task 3.5: Write session close handoff

**Files:**
- Create: `~/code/build-in-public/docs/handoffs/2026-04-21-two-task-force-dispatch-close.md`

- [ ] **Step 1: Draft the handoff**

Contents:
- TL;DR: both task forces shipped what was in scope
- Misled: list of commits on `feature/misled-ethos-page`, preview URL, what Prince still owes (mobile check, send message, domain decision deferred)
- ai-swarm-infra: list of commits on `feature/ai-swarm-infra-impl`, Tier 3 outputs status (approved/revised), what Prince still owes (run the three bootstraps on the worker machines tonight)
- Delegation learning log: per `Post-conclusion note` captured on Scene 05, surface 3–5 observations about parallelism / delegation boundaries / friction points as material for a future scene
- PR readiness: feature/ai-swarm-infra-impl ready to open PR; feature/misled-ethos-page must NOT merge (hard rule)
- Scene 04 status: concluded drafted but not sealed (Prince seals on send)

- [ ] **Step 2: Commit the handoff**

```bash
cd ~/code/build-in-public
git add docs/handoffs/2026-04-21-two-task-force-dispatch-close.md
git commit -m "docs(handoff): two-task-force dispatch close — 2026-04-21"
```

---

# Execution notes

## Parallelism shape (for subagent-driven executor)

- Phase 0 tasks 0.1 and 0.2 run sequentially (orchestrator serial).
- Phase 1 tasks 1.1 and 1.2 run in parallel — one Agent call message with two concurrent dispatches.
- Phase 2A and Phase 2B run in parallel — different worktrees, no filesystem collision.
- Within Phase 2A: Tasks 2A.2 and 2A.4 can run sequentially against the same worktree (both touch .env.example, serial avoids merge conflicts). 2A.3 must complete before 2A.4 because 2A.4 imports `@/lib/supabase` created in 2A.3. 2A.1 (smoke-test) and 2A.5/2A.6 (Gemini drafts) can run in parallel with the Copilot/Cursor delegations.
- Within Phase 2B: 2B.1 (pyproject) must complete before 2B.2–2B.5 (those need uv-installed deps). 2B.3 → 2B.4 → 2B.5 are sequential (each imports from the prior). 2B.6–2B.9 (Gemini docs) can run in parallel with 2B.3–2B.5 (different files).
- Phase 3 runs after both 2A and 2B fully green.

## Failure handling

- Any CLI delegation failure: retry once per tool-registry.md retry rules. On second failure, escalate to Prince with the error output, do not silently fall back.
- Any test failure: halt that task force, alert Prince, let him decide to re-delegate or to take the task himself.
- Any diff-reviewer FLAG verdict: escalate to Tier 3 (Prince) before applying. Do not auto-apply a flagged Cursor output.

## Context pressure discipline

- If orchestrator context crosses 40% during execution, force any remaining Gemini/Cursor tasks out even if routing said "auto-apply after validate". Validation becomes a post-hoc check.
- At 60% the orchestrator pauses and alerts Prince before any direct generation.

## What this plan does NOT do

Per spec section 5 (out-of-scope):
- No mobile viewport check — Prince only, on a real phone
- No sending of the client message — Prince only
- No registering misled.london — Prince only, on explicit go
- No merging of feature/misled-ethos-page to main — forbidden
- No SSH into worker machines — Prince runs the bootstraps himself tonight
- No end-to-end swarm run against live Ollama — only possible after workers bootstrap
- No fix for Scene 05 Vercel regression (apps/study-buddy) — separate queued item

---

# Self-review (post-draft, pre-handoff)

Ran the 3-check against the spec:

1. **Spec coverage.** All Misled acceptance criteria (smoke test, Supabase+Resend wired, cron, client message, Scene 04 Conclude, branch pushed) → Tasks 2A.1–2A.6 + 3.3. All ai-swarm-infra acceptance criteria (pyproject, network_client, orchestrator, main, .env.example, README, 3 tutorials) → Tasks 2B.1–2B.9 + 3.3. Session handoff → Task 3.5. No gaps.

2. **Placeholder scan.** No TBDs. Every delegation prompt is complete. Every validation command is explicit. Every commit message is written out.

3. **Type consistency.** `NetworkClient.generate(node_url, model, system, prompt)` signature matches in Task 2B.3 test, 2B.3 impl, 2B.4 test, 2B.4 impl, 2B.5 impl. `run_pipeline(*, client, user_goal, coder_url, coder_model, reviewer_url, reviewer_model)` matches in 2B.4 test, 2B.4 impl, 2B.5 impl. `SwarmConfig` field names match in 2B.2 impl and 2B.5 impl. `WorkerError` exception consistent. `subscribers` table column names (`email`, `confirmed`, `confirmation_token`, `created_at`) consistent across 2A.2 migration, 2A.3 API route, 2A.4 cron handler.

Plan approved for execution.
