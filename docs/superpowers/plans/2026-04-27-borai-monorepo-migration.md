# BorAI Monorepo Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate `~/code/BorAI/` (with its 2 sibling worktrees), `~/code/ai-swarm-infra/`, and `~/code/build-in-public/docs/superpowers/` into a single private monorepo at `~/code/borai/`, with all three BorAI branches merged into `main` and per-file git history preserved through `git-filter-repo`. Outcome: a clean monorepo ready to host the BorAI Spore v0.1 build (separate plan).

**Architecture:** The BorAI repo is renamed in-place to `borai` and becomes the monorepo root (preserving its full history). Sibling worktrees (BorAI-graph, BorAI-swarm-wt) and their feature branches are merged into `main` first to reconcile parallel work. External repos (ai-swarm-infra, build-in-public/docs/superpowers) are imported via `git-filter-repo` so per-file history at the new paths is preserved. Existing dirs are then restructured (move/rename) to match the target layout from the BorAI Spore design spec §3.1. Snapshot tarball is taken before any destructive op.

**Tech Stack:** git, git-filter-repo (installed via `uv tool` first), pnpm (verifies workspace post-migration), uv (verifies graph Python project post-migration).

**Spec reference:** `~/code/build-in-public/docs/superpowers/specs/2026-04-27-borai-spore-design.md` §3.

---

## Phase A: Pre-flight (Tasks 1-4)

### Task 1: Install git-filter-repo

**Files:** none (system tool install)

- [ ] **Step 1: Check if git-filter-repo is already installed**

```bash
git filter-repo --version 2>&1 | head -1
```

Expected: a version string like `2.38.0` (skip rest of task) OR `git: 'filter-repo' is not a git command.` (proceed to Step 2).

- [ ] **Step 2: Install via uv tool**

```bash
uv tool install git-filter-repo
```

Expected: `Installed 1 executable: git-filter-repo` near the end of output.

- [ ] **Step 3: Verify install**

```bash
git filter-repo --version
```

Expected: a version number prints. If "command not found", restart the shell so `~/.local/bin` (uv tool install path) is on PATH.

- [ ] **Step 4 (fallback only): if uv unavailable, use pipx**

```bash
pipx install git-filter-repo
```

Expected: same as Step 2.

### Task 2: Take a safety-net snapshot

**Files created:** `~/code/borai-pre-migration-snapshot.tar.gz`

Reason: this plan rewrites git history of the BorAI repo. If anything goes wrong, the snapshot lets us restore.

- [ ] **Step 1: Create snapshot tarball**

```bash
cd ~/code
tar --exclude='*/node_modules' --exclude='*/.next' --exclude='*/dist' --exclude='*/target' \
    -czf borai-pre-migration-snapshot.tar.gz \
    BorAI BorAI-graph BorAI-swarm-wt ai-swarm-infra
```

Expected: command exits 0; tarball created. Size likely 50-300MB depending on excluded artifacts.

- [ ] **Step 2: Verify snapshot is intact and readable**

```bash
ls -lh ~/code/borai-pre-migration-snapshot.tar.gz
tar -tzf ~/code/borai-pre-migration-snapshot.tar.gz | head -20
```

Expected: file size in MB displayed; tarball lists files starting with `BorAI/`, `BorAI-graph/`, etc.

### Task 3: Stash uncommitted changes in worktrees that have them

**Files modified:** stash entries in two worktrees

Pre-flight check (from earlier discovery): BorAI has 1 uncommitted line, BorAI-swarm-wt has 1 uncommitted line, BorAI-graph is clean, build-in-public has 9 uncommitted lines (we leave those alone — we never touch its working tree).

- [ ] **Step 1: Stash in BorAI (main)**

```bash
cd ~/code/BorAI
git stash push -u -m "pre-migration stash 2026-04-27"
```

Expected: `Saved working directory and index state On main: pre-migration stash 2026-04-27` — OR `No local changes to save` if state changed since pre-flight (acceptable; just continue).

- [ ] **Step 2: Stash in BorAI-swarm-wt (feature/ai-swarm-infra-impl)**

```bash
cd ~/code/BorAI-swarm-wt
git stash push -u -m "pre-migration stash 2026-04-27"
```

Expected: `Saved working directory and index state On feature/ai-swarm-infra-impl: pre-migration stash 2026-04-27` — OR `No local changes to save`.

- [ ] **Step 3: Confirm BorAI-graph is clean (no stash needed)**

```bash
cd ~/code/BorAI-graph
git status --porcelain
```

Expected: empty output. If non-empty, stash same way as Step 1.

### Task 4: Verify clean state across all source repos

- [ ] **Step 1: Loop check**

```bash
for d in BorAI BorAI-graph BorAI-swarm-wt ai-swarm-infra; do
  count=$(git -C ~/code/$d status --porcelain | wc -l)
  echo "$d: $count uncommitted lines"
done
```

Expected: all four show `0 uncommitted lines`.

If any are non-zero: investigate and stash before proceeding to Phase B.

---

## Phase B: Branch reconciliation (Tasks 5-9)

The BorAI repo has three branches across three worktrees. Merge sequentially into `main`.

### Task 5: Switch to BorAI worktree on `main` and confirm

**Files:** working directory only

- [ ] **Step 1: cd and confirm branch**

```bash
cd ~/code/BorAI
git status
```

Expected: `On branch main`, `nothing to commit, working tree clean`. If not on main, `git checkout main` first.

### Task 6: Merge `feat/near-proximal-stream` into `main`

**Files:** repo state changes (merge commit + potentially conflict resolutions)

- [ ] **Step 1: Run merge with --no-ff for an explicit merge commit**

```bash
git merge --no-ff feat/near-proximal-stream -m "merge: feat/near-proximal-stream into main (Phase 0 reconciliation)"
```

Expected outcome A — clean merge: auto-creates merge commit; proceed to Step 3.
Expected outcome B — conflicts: git lists conflicting files; PAUSE and do Step 2.

- [ ] **Step 2: Resolve conflicts manually (if any)**

For each conflicted file:
1. Open the file; locate `<<<<<<<` / `=======` / `>>>>>>>` markers.
2. Decide canonical content. Default heuristic: prefer `main`'s version unless `feat/near-proximal-stream` clearly added new functionality (e.g., a new file or new function — keep it). When uncertain, keep both halves under a comment marker `# MERGE-NEEDS-REVIEW: ...`.
3. Remove conflict markers.
4. `git add <file>`.
5. After all conflicts resolved: `git commit` (the merge message from Step 1 is preserved).

- [ ] **Step 3: Verify merge commit exists**

```bash
git log --oneline -3
```

Expected: top commit reads `merge: feat/near-proximal-stream into main (Phase 0 reconciliation)`.

### Task 7: Merge `feature/ai-swarm-infra-impl` into `main`

Same shape as Task 6. The `feature/ai-swarm-infra-impl` branch likely contains in-progress swarm-infra work that we want preserved (the orchestra design originated there).

- [ ] **Step 1: Run merge**

```bash
git merge --no-ff feature/ai-swarm-infra-impl -m "merge: feature/ai-swarm-infra-impl into main (Phase 0 reconciliation)"
```

Expected outcomes: same A/B as Task 6.

- [ ] **Step 2: Resolve conflicts manually if any (same procedure as Task 6 Step 2)**

- [ ] **Step 3: Verify both merges in log**

```bash
git log --oneline -5
```

Expected: top two non-merged commits show the two reconciliation merges in reverse-chronological order.

### Task 8: Verify post-merge state still builds

- [ ] **Step 1: Inspect that expected dirs are present**

```bash
ls ~/code/BorAI/
```

Expected: at minimum `apps/`, `ops/`, `starter-vault/`, `starter-skills/`, `docker-compose.yml`, `package.json`, `pnpm-lock.yaml`.

- [ ] **Step 2: Run pnpm install (workspace integrity check)**

```bash
cd ~/code/BorAI
pnpm install
```

Expected: install succeeds. Lockfile may update with merge-related dep adjustments.

- [ ] **Step 3: If pnpm-lock.yaml has merge conflicts**

```bash
rm pnpm-lock.yaml
pnpm install
git add pnpm-lock.yaml
git commit -m "chore: regenerate pnpm-lock.yaml after Phase 0 branch merge"
```

- [ ] **Step 4: Verify one webapp builds (study-buddy is the lightest)**

```bash
pnpm --filter study-buddy build 2>&1 | tail -20
```

Expected: build succeeds (exit 0). If fail: investigate; merge may have left study-buddy broken. Don't proceed until builds pass.

### Task 9: Sync the other two worktrees to main

The BorAI-graph and BorAI-swarm-wt worktrees still have their feature branches checked out. Move them to `main` so they don't accidentally get used.

- [ ] **Step 1: Check out main in BorAI-graph**

```bash
cd ~/code/BorAI-graph
git checkout main
```

Expected: `Switched to branch 'main'`.

- [ ] **Step 2: Check out main in BorAI-swarm-wt**

```bash
cd ~/code/BorAI-swarm-wt
git checkout main
```

Expected: `Switched to branch 'main'`.

- [ ] **Step 3: Confirm all three worktrees on main**

```bash
git -C ~/code/BorAI worktree list
```

Expected: all three lines show `[main]`.

---

## Phase C: External repo imports (Tasks 10-13)

Import `ai-swarm-infra` and `build-in-public/docs/superpowers/` into the BorAI repo using `git-filter-repo` to relocate paths and preserve per-file history.

### Task 10: Filter ai-swarm-infra to its target paths

**Files:** working in `~/code/ai-swarm-infra-mig/` (temporary)

`git-filter-repo` rewrites history destructively — must work on a clone, never the source.

- [ ] **Step 1: Clone ai-swarm-infra to a temp location**

```bash
git clone ~/code/ai-swarm-infra ~/code/ai-swarm-infra-mig
```

Expected: clone succeeds; new dir `~/code/ai-swarm-infra-mig/` created.

- [ ] **Step 2: Run filter to relocate paths to target structure**

```bash
cd ~/code/ai-swarm-infra-mig
git filter-repo \
    --path-rename orchestra/:docs/superpowers/superseded/orchestra-design-2026-04-24/ \
    --path-rename swarm-architecture.md:docs/superpowers/superseded/swarm-architecture-2025.md \
    --path-rename docs/superpowers/specs/2026-04-24-orchestra-design.md:docs/superpowers/superseded/orchestra-design-2026-04-24/spec.md \
    --force
```

Expected: filter runs; prints stats like `Parsed N commits` and timing. The `--force` flag is required because the working dir is a clone (filter-repo refuses to operate on a non-fresh repo without it).

- [ ] **Step 3: Verify the filter result**

```bash
ls docs/superpowers/superseded/
```

Expected: `orchestra-design-2026-04-24/` directory and `swarm-architecture-2025.md` file both present.

- [ ] **Step 4: Spot-check that history was preserved**

```bash
git log --oneline docs/superpowers/superseded/orchestra-design-2026-04-24/spec.md | head -5
```

Expected: at least one commit listed (the original commit of the orchestra spec).

### Task 11: Pull filtered ai-swarm-infra into BorAI

- [ ] **Step 1: Add the filtered temp repo as a remote in BorAI**

```bash
cd ~/code/BorAI
git remote add ai-swarm-infra-mig ~/code/ai-swarm-infra-mig
git fetch ai-swarm-infra-mig
```

Expected: fetch succeeds; new remote tracking branch `ai-swarm-infra-mig/main` (or `ai-swarm-infra-mig/master`) appears.

- [ ] **Step 2: Identify the default branch of the filtered repo**

```bash
git branch -r | grep ai-swarm-infra-mig
```

Expected: a single remote branch listed. Note its name (`main` or `master`); use in next step.

- [ ] **Step 3: Merge with --allow-unrelated-histories**

```bash
git merge --allow-unrelated-histories \
    -m "merge: import ai-swarm-infra (orchestra design + swarm-architecture, both superseded)" \
    ai-swarm-infra-mig/main
```

(Substitute `ai-swarm-infra-mig/master` if that's what Step 2 showed.)

Expected: merge commit created; new files appear under `docs/superpowers/superseded/`. If conflicts (unlikely since these are new paths), resolve same as Task 6 Step 2.

- [ ] **Step 4: Cleanup — remove temp remote and temp clone**

```bash
git remote remove ai-swarm-infra-mig
rm -rf ~/code/ai-swarm-infra-mig
```

Expected: remote gone (verify with `git remote`); temp dir gone.

- [ ] **Step 5: Verify imported paths are present in working tree**

```bash
ls docs/superpowers/superseded/
[ -d docs/superpowers/superseded/orchestra-design-2026-04-24 ] && echo "orchestra dir: OK"
[ -f docs/superpowers/superseded/swarm-architecture-2025.md ] && echo "swarm-arch file: OK"
```

Expected: both "OK" lines printed.

### Task 12: Filter build-in-public/docs/superpowers/ to its target paths

Pulls only `docs/superpowers/` from build-in-public, since the rest of build-in-public is the user's vault and stays in place.

- [ ] **Step 1: Clone build-in-public to temp**

```bash
git clone ~/code/build-in-public ~/code/build-in-public-mig
```

Expected: clone succeeds.

- [ ] **Step 2: Filter to keep only docs/superpowers/**

```bash
cd ~/code/build-in-public-mig
git filter-repo --path docs/superpowers/ --force
```

Expected: filter succeeds; only `docs/superpowers/` content remains in working tree and history.

- [ ] **Step 3: Verify filter result**

```bash
find . -type d -not -path './.git*' | head -10
```

Expected: only `./docs`, `./docs/superpowers`, and child dirs visible.

- [ ] **Step 4: Confirm spec we just committed is present**

```bash
ls docs/superpowers/specs/ | grep "borai-spore"
```

Expected: `2026-04-27-borai-spore-design.md` is present.

### Task 13: Pull filtered build-in-public docs into BorAI

- [ ] **Step 1: Add temp remote and fetch**

```bash
cd ~/code/BorAI
git remote add bip-mig ~/code/build-in-public-mig
git fetch bip-mig
```

- [ ] **Step 2: Identify default branch (main or master)**

```bash
git branch -r | grep bip-mig
```

Note the name for next step.

- [ ] **Step 3: Merge with --allow-unrelated-histories**

```bash
git merge --allow-unrelated-histories \
    -m "merge: import build-in-public/docs/superpowers (specs, plans, scenes)" \
    bip-mig/main
```

(Substitute `bip-mig/master` if applicable.)

Expected: merge succeeds; `docs/superpowers/{specs,plans,...}/` directories appear (or merge cleanly into existing ones from Task 11).

- [ ] **Step 4: Cleanup**

```bash
git remote remove bip-mig
rm -rf ~/code/build-in-public-mig
```

- [ ] **Step 5: Verify the spore design spec is present**

```bash
[ -f docs/superpowers/specs/2026-04-27-borai-spore-design.md ] && echo "spec: OK" || echo "spec: MISSING"
```

Expected: `spec: OK`.

---

## Phase D: Restructure (Tasks 14-19)

Move existing dirs to match target layout from spec §3.1.

### Task 14: Move `ops/borai-graph/` to `graph/`

**Files:** `ops/borai-graph/` → `graph/`

- [ ] **Step 1: Move directory via git mv**

```bash
cd ~/code/BorAI
git mv ops/borai-graph graph
```

Expected: command exits 0; `graph/` now exists with same content as `ops/borai-graph/` had.

- [ ] **Step 2: Verify content**

```bash
ls graph/
```

Expected: contents previously at `ops/borai-graph/` (e.g., `pyproject.toml`, `src/`, `tests/`, `README.md`).

- [ ] **Step 3: Check if `ops/` is now empty**

```bash
ls ops/ 2>&1
```

If empty: `rmdir ops` and stage with `git add -A`. If has other content (e.g., `ai-swarm-infra/` from old layout), leave alone.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: move ops/borai-graph to graph/ (Phase 0 monorepo restructure)"
```

### Task 15: Rename `starter-vault/` to `vault-template/`

- [ ] **Step 1: git mv**

```bash
git mv starter-vault vault-template
```

- [ ] **Step 2: Verify**

```bash
ls vault-template/
```

Expected: campaigns/, characters/, templates/, CLAUDE.md, README.md.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: rename starter-vault to vault-template (Phase 0)"
```

### Task 16: Rename `starter-skills/` to `skills-template/`

- [ ] **Step 1: git mv**

```bash
git mv starter-skills skills-template
```

- [ ] **Step 2: Verify**

```bash
ls skills-template/
```

Expected: example-research/, README.md.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: rename starter-skills to skills-template (Phase 0)"
```

### Task 17: Create `agents/spore/` placeholder

The actual Spore implementation is a separate plan (Plan 2). This task creates only the directory + a placeholder README so the layout matches spec §3.1.

- [ ] **Step 1: Create dir and placeholder**

```bash
mkdir -p agents/spore
cat > agents/spore/README.md <<'EOF'
# borai-spore

Rust agent CLI — the user-facing surface of the BorAI platform.

See spec: `../../docs/superpowers/specs/2026-04-27-borai-spore-design.md`

This is a Phase 0 placeholder. Implementation begins with Plan 2 (Spore v0.1 build).
EOF
```

- [ ] **Step 2: Stage and commit**

```bash
git add agents/spore/
git commit -m "chore: scaffold agents/spore/ placeholder (Phase 0)"
```

### Task 18: Create `inbox/` directory

- [ ] **Step 1: Create dir + README**

```bash
mkdir -p inbox/events
cat > inbox/README.md <<'EOF'
# inbox/

Event-staging directory. Skills and Spore write events as timestamped markdown files into `events/`. The inbox-consumer daemon (Spore v0.3) reads them.

Event filename format: `<ISO-8601-timestamp>_<event-type>_<slug>.md`

Spec: `../docs/superpowers/specs/2026-04-27-borai-spore-design.md` §1
EOF

# Add a .gitkeep so the empty events/ dir is tracked
touch inbox/events/.gitkeep
```

- [ ] **Step 2: Commit**

```bash
git add inbox/
git commit -m "chore: scaffold inbox/ for Spore v0.1 event staging (Phase 0)"
```

### Task 19: Update path references in CLAUDE.md and README files

Two source files reference the OLD paths. Update them.

- [ ] **Step 1: Find references in vault-template/CLAUDE.md**

```bash
grep -n "borai-graph\|starter-vault\|starter-skills\|ops/borai-graph" vault-template/CLAUDE.md
```

Note each line number + old text. Common renames:
- `ops/borai-graph` → `graph` (path reference)
- `borai-graph` (when describing the daemon name) → keep as-is (still the project name in `graph/`)
- `starter-vault` → `vault-template`
- `starter-skills` → `skills-template`

- [ ] **Step 2: Apply edits to vault-template/CLAUDE.md**

For each match, use `sed` (single-substitution) or your editor. Example for the path `ops/borai-graph`:

```bash
sed -i 's|ops/borai-graph|graph|g' vault-template/CLAUDE.md
```

For multiple paths in one pass:
```bash
sed -i \
    -e 's|ops/borai-graph|graph|g' \
    -e 's|starter-vault|vault-template|g' \
    -e 's|starter-skills|skills-template|g' \
    vault-template/CLAUDE.md
```

Be careful: do NOT replace bare `borai-graph` (the daemon name); only the path form `ops/borai-graph`. The `sed` above is safe because it requires the `ops/` prefix.

- [ ] **Step 3: Apply same edits to skills-template/README.md**

```bash
sed -i \
    -e 's|ops/borai-graph|graph|g' \
    -e 's|starter-vault|vault-template|g' \
    -e 's|starter-skills|skills-template|g' \
    skills-template/README.md
```

- [ ] **Step 4: Apply to top-level README.md (if any path refs exist)**

```bash
grep -nE "ops/borai-graph|starter-vault|starter-skills" README.md && \
    sed -i \
        -e 's|ops/borai-graph|graph|g' \
        -e 's|starter-vault|vault-template|g' \
        -e 's|starter-skills|skills-template|g' \
        README.md
```

(The grep guard ensures sed only runs if there's something to replace.)

- [ ] **Step 5: Verify no stale path refs remain**

```bash
grep -rnE "ops/borai-graph|starter-vault|starter-skills" \
    vault-template/ skills-template/ README.md 2>/dev/null \
    | grep -v "/.git/" | grep -v "/node_modules/"
```

Expected: empty output. (If non-empty, those are intentional historical refs — review each.)

- [ ] **Step 6: Commit**

```bash
git add vault-template/CLAUDE.md skills-template/README.md README.md
git commit -m "chore: update path refs after restructure (Phase 0)"
```

---

## Phase E: Repo rename and cleanup (Tasks 20-22)

### Task 20: Remove the two sibling worktrees, then move `BorAI/` → `borai/`

The worktrees must be removed BEFORE the rename, otherwise their `.git` references break.

- [ ] **Step 1: From the BorAI worktree, remove the two siblings**

```bash
cd ~/code/BorAI
git worktree remove ~/code/BorAI-graph
git worktree remove ~/code/BorAI-swarm-wt
git worktree prune
```

Expected: `BorAI-graph/` and `BorAI-swarm-wt/` directories no longer exist.

- [ ] **Step 2: Confirm only one worktree remains**

```bash
git worktree list
```

Expected: only `~/code/BorAI` listed.

- [ ] **Step 3: Move repo dir**

```bash
cd ~/code
mv BorAI borai
```

- [ ] **Step 4: Verify `.git` is intact (not a worktree-style file)**

```bash
ls -la ~/code/borai/.git
```

Expected: `.git` is a directory containing `HEAD`, `config`, `objects/`, etc. (NOT a file pointing elsewhere — that would mean the rename broke a worktree reference).

- [ ] **Step 5: Verify git operations still work**

```bash
cd ~/code/borai
git status
git log --oneline -3
```

Expected: clean output; recent commits visible.

### Task 21: Archive ai-swarm-infra (source repo no longer needed)

The contents are now imported into `borai/docs/superpowers/superseded/`. Original repo can be archived.

- [ ] **Step 1: Move ai-swarm-infra to archive**

```bash
mkdir -p ~/code/_archived
mv ~/code/ai-swarm-infra ~/code/_archived/ai-swarm-infra-2025
```

The `_` prefix sorts to the bottom; `2025` suffix dates the archived state.

- [ ] **Step 2: Verify**

```bash
ls ~/code/ | grep -iE "swarm|borai"
```

Expected: `borai/` listed; no `ai-swarm-infra/`, no `BorAI/`, no `BorAI-graph/`, no `BorAI-swarm-wt/`. (`BorAI` worktrees were removed in Task 20; renamed dir is now `borai`.)

### Task 22: Update README at `borai/` root

The repo's README is still BorAI-original. Update for the new monorepo identity.

- [ ] **Step 1: Replace README.md content**

```bash
cd ~/code/borai
cat > README.md <<'EOF'
# BorAI

Open platform for AI-augmented work. Local-first. Apache 2.0.

## Components

- **`agents/spore/`** — BorAI Spore: Rust agent CLI. The user-facing surface. See [`docs/superpowers/specs/2026-04-27-borai-spore-design.md`](docs/superpowers/specs/2026-04-27-borai-spore-design.md).
- **`graph/`** — Local RAG knowledge graph (Python; Rust port targeted for Spore v0.3).
- **`vault-template/`** — Campaigns/chapters/scenes ontology starter.
- **`skills-template/`** — Starter Claude Code skill bundle.
- **`inbox/`** — Event-staging directory (consumer daemon ships in Spore v0.3).
- **`apps/`** — Reference implementations (Next.js: study-buddy, misled, talk-with-flavour).
- **`docs/superpowers/`** — Design specs, implementation plans, archived/superseded designs.

## Status

- **Spore v0.1:** in development (closed alpha, 6 users).
- **Public OSS open:** planned at v1.0 under Apache 2.0.

## Stack

- **Spore CLI:** Rust (workspace at `agents/spore/`)
- **Webapps:** Next.js + TypeScript + Tailwind (`apps/`)
- **Graph daemon:** Python + uv + Ollama embeddings (`graph/`)
- **Orchestration:** docker-compose (top-level `docker-compose.yml`)
EOF
```

- [ ] **Step 2: Stage and commit**

```bash
git add README.md
git commit -m "docs: replace BorAI README with monorepo overview"
```

---

## Phase F: Verification (Tasks 23-26)

### Task 23: Verify directory layout matches spec §3.1

- [ ] **Step 1: Top-level directory listing**

```bash
cd ~/code/borai
ls -F
```

Expected: `apps/`, `agents/`, `graph/`, `vault-template/`, `skills-template/`, `inbox/`, `docs/`, `docker-compose.yml`, `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, `README.md`, `turbo.json`.

- [ ] **Step 2: Detailed presence check**

```bash
[ -d apps/study-buddy ] && echo "apps/study-buddy: OK" || echo "apps/study-buddy: MISSING"
[ -d apps/misled ] && echo "apps/misled: OK" || echo "apps/misled: MISSING"
[ -d apps/talk-with-flavour ] && echo "apps/talk-with-flavour: OK" || echo "apps/talk-with-flavour: MISSING"
[ -d agents/spore ] && [ -f agents/spore/README.md ] && echo "agents/spore: OK" || echo "agents/spore: MISSING"
[ -d graph ] && [ -f graph/pyproject.toml ] && echo "graph: OK" || echo "graph: MISSING"
[ -d vault-template/campaigns ] && [ -f vault-template/CLAUDE.md ] && echo "vault-template: OK" || echo "vault-template: MISSING"
[ -d skills-template ] && echo "skills-template: OK" || echo "skills-template: MISSING"
[ -d inbox/events ] && [ -f inbox/README.md ] && echo "inbox: OK" || echo "inbox: MISSING"
[ -f docs/superpowers/specs/2026-04-27-borai-spore-design.md ] && echo "spore design spec: OK" || echo "spore design spec: MISSING"
[ -d docs/superpowers/superseded/orchestra-design-2026-04-24 ] && echo "superseded orchestra: OK" || echo "superseded orchestra: MISSING"
[ -f docs/superpowers/superseded/swarm-architecture-2025.md ] && echo "superseded swarm-arch: OK" || echo "superseded swarm-arch: MISSING"
```

Expected: all entries print `: OK`.

### Task 24: Verify pnpm workspace still works

- [ ] **Step 1: Reinstall (full clean)**

```bash
cd ~/code/borai
rm -rf node_modules apps/*/node_modules
pnpm install
```

Expected: install succeeds; no errors.

- [ ] **Step 2: Build study-buddy (the lightest webapp)**

```bash
pnpm --filter study-buddy build 2>&1 | tail -10
```

Expected: build exits 0.

- [ ] **Step 3: Lint (workspace-wide)**

```bash
pnpm lint 2>&1 | tail -10
```

Expected: lint passes (or matches the pre-migration baseline of warnings).

### Task 25: Verify graph/ Python project still builds

- [ ] **Step 1: Sync uv environment**

```bash
cd ~/code/borai/graph
uv sync --extra dev
```

Expected: succeeds; `.venv/` exists.

- [ ] **Step 2: Run tests**

```bash
uv run pytest 2>&1 | tail -20
```

Expected: tests pass (or same number pass as before migration).

### Task 26: Inspect git history for sanity

- [ ] **Step 1: Visualize recent history**

```bash
cd ~/code/borai
git log --oneline --graph --decorate -25
```

Expected: visible merge commits for the two branch reconciliations and the two external-repo imports; no broken history; restructure commits at the top.

- [ ] **Step 2: Verify the spore spec has its original commit history**

```bash
git log --follow --oneline docs/superpowers/specs/2026-04-27-borai-spore-design.md | head -5
```

Expected: at least one commit listed (the original "docs(specs): borai-spore design" commit from build-in-public).

- [ ] **Step 3: Verify the orchestra spec has its original commit history**

```bash
git log --follow --oneline docs/superpowers/superseded/orchestra-design-2026-04-24/spec.md | head -5
```

Expected: at least one commit listed (the original orchestra design commit from ai-swarm-infra).

---

## Phase G: GitHub setup and stash recovery (Tasks 27-29)

### Task 27: Create GitHub remote (private repo) and push

- [ ] **Step 1: Determine GitHub handle/org**

```bash
gh auth status 2>&1 | head -5
```

Note the username shown (e.g., `Logged in to github.com as <handle>`).

- [ ] **Step 2: Create private repo via gh CLI**

```bash
cd ~/code/borai
gh repo create <handle>/borai \
    --private \
    --description "Open platform for AI-augmented work. BorAI Spore + graph + vault + inbox." \
    --source . \
    --remote origin \
    --push
```

Replace `<handle>` with your handle (or org if pushing to an org). Expected: repo created on GitHub; first push succeeds.

- [ ] **Step 3 (manual fallback if gh fails): create empty repo on github.com via web UI, then push**

```bash
git remote add origin git@github.com:<handle>/borai.git
git push -u origin main
```

Expected: push succeeds.

- [ ] **Step 4: Verify push**

```bash
gh repo view <handle>/borai --web
```

Expected: opens GitHub repo page in browser; recent commits visible.

### Task 28: Restore stashed changes (if any)

- [ ] **Step 1: List stashes in `borai`**

```bash
cd ~/code/borai
git stash list
```

If the "pre-migration stash" entries from Task 3 are visible, decide whether to apply.

- [ ] **Step 2: Apply (if applicable)**

```bash
git stash apply  # most recent stash
```

Expected: clean apply OR conflicts to resolve. If conflicts: address per Task 6 Step 2 procedure.

- [ ] **Step 3: Drop the stash if applied cleanly**

```bash
git stash drop
```

- [ ] **Step 4: Decide: commit the restored changes or leave as working-tree edits**

If the changes look intentional: `git add` + commit. If they're WIP from before migration that the user wants to revisit: leave uncommitted.

### Task 29: Final smoke test

- [ ] **Step 1: Open a fresh shell and verify the repo works from scratch**

```bash
cd ~/code/borai
git status
git log --oneline -10
ls
echo "---"
gh repo view  # verify remote tracking
```

Expected: clean working tree (or only the optional restored stash changes); recent history visible; gh shows the new private repo.

- [ ] **Step 2: Document migration completion in MEMORY.md**

```bash
cat >> MEMORY.md 2>/dev/null <<'EOF' || cat > MEMORY.md <<'EOF'
- [Phase 0 Migration Complete](docs/superpowers/plans/2026-04-27-borai-monorepo-migration.md) — 2026-04-27 — BorAI/, BorAI-graph/, BorAI-swarm-wt/, ai-swarm-infra/ consolidated into ~/code/borai/. Three branches merged into main. ai-swarm-infra archived to ~/code/_archived/. Ready for Spore v0.1 build (Plan 2).
EOF

git add MEMORY.md
git commit -m "docs(memory): record Phase 0 migration completion"
git push
```

Expected: commit + push succeed.

- [ ] **Step 3: Declare Phase 0 done**

Migration plan is complete when:
1. `~/code/borai/` exists with the layout from spec §3.1.
2. All three BorAI branches are merged into `main`.
3. `ai-swarm-infra/orchestra/` and `swarm-architecture.md` are at their target paths under `docs/superpowers/superseded/` with history.
4. `docs/superpowers/specs/2026-04-27-borai-spore-design.md` is present with original history.
5. `pnpm install` and at least one webapp build succeed.
6. `uv run pytest` in `graph/` passes (or matches pre-migration baseline).
7. Repo is pushed to GitHub as private under the user's handle/org.

Next plan: **BorAI Spore v0.1 build** — covers cargo workspace scaffolding, the 14 crates, Anthropic + Ollama providers, manager mode (Pattern A+C), telemetry, serve mode, vault parser, skill loader, hooks, sessions, TUI, headless, CI, cargo-dist, and alpha onboarding. Generated via a separate writing-plans invocation after this plan is reviewed.

---

## Spec coverage check

Mapping spec §3.2 migration steps → tasks in this plan:

| Spec §3.2 step | This plan |
|---|---|
| 1. `git init ~/code/borai` | Task 20 (rename in-place — preserves history vs init-fresh) |
| 2. `git subtree add` / git-filter-repo for each source dir | Tasks 10-13 (filter-repo for ai-swarm-infra + build-in-public docs) |
| 3. Archive `BorAI-swarm-wt/` | Task 20 Step 1 (worktree remove) |
| 4. Move `ai-swarm-infra/orchestra/` → superseded | Task 10 Step 2 (filter-repo --path-rename) |
| 5. Move `ai-swarm-infra/swarm-architecture.md` → superseded with banner | Task 10 Step 2 (filter-repo); banner is part of separate "pivot artifacts" plan |
| 6. Update path refs in `vault-template/CLAUDE.md` and `skills-template/README.md` | Task 19 |
| 7. Initial commit + push to private GitHub repo | Task 27 |

Plan additions beyond spec §3.2:
- **Branch reconciliation (Phase B)** — required by user choice Q-BRANCH=d, not in original spec.
- **Snapshot tarball (Task 2)** — safety net; spec didn't require but recommended given destructive history rewrite.
- **Verification phase (Phase F)** — spec didn't require explicit checkpoints; included so failures are caught immediately.

Spec items deliberately NOT in this plan:
- **Banner addition to superseded files** (spec §13.1) — belongs in the separate "pivot artifacts" plan along with the new scene file.
- **Renumber chapter-arc slots** (spec §13.3) — also pivot-artifacts plan.
