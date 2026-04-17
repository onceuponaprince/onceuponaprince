#!/usr/bin/env bash
# setup-vault.sh
# Deploys the full AI Command Centre vault structure.
# Usage: ./setup-vault.sh [--force] [--git]

set -euo pipefail

# ──────────────────────────────────────────────────────────────────
# Args
# ──────────────────────────────────────────────────────────────────
FORCE=0
INIT_GIT=0
for arg in "$@"; do
    case $arg in
        --force) FORCE=1 ;;
        --git) INIT_GIT=1 ;;
        -h|--help)
            cat <<'HELP'
AI Command Centre vault deployment.

Usage:
  ./setup-vault.sh [--force] [--git]

Options:
  --force  Overwrite existing files
  --git    Initialize git and commit after deployment
  -h       Show this help

Run in your intended vault directory.
HELP
            exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# ──────────────────────────────────────────────────────────────────
# Safety
# ──────────────────────────────────────────────────────────────────
if [[ -f "CLAUDE.md" && $FORCE -eq 0 ]]; then
    echo "Error: CLAUDE.md already exists. Run with --force to overwrite." >&2
    exit 1
fi

echo "Deploying AI Command Centre vault in $(pwd)..."

# ──────────────────────────────────────────────────────────────────
# Directory structure
# ──────────────────────────────────────────────────────────────────
mkdir -p campaigns/command-centre/chapters/01-origin/scenes
mkdir -p characters
mkdir -p templates
mkdir -p artifacts/chapter-1
mkdir -p assets
mkdir -p .claude/commands

# ──────────────────────────────────────────────────────────────────
# CLAUDE.md
# ──────────────────────────────────────────────────────────────────
cat > CLAUDE.md <<'VAULT_FILE_END'
# CLAUDE.md — AI Command Centre Vault

*Operating guide for Claude Code inside this vault. Load at the start of every session. When anything below conflicts with a momentary instruction from the founder, the founder wins — but ask first, don't assume.*

---

## What this vault is

The working space for a SaaS project called the **AI Command Centre** and for the sibling campaigns it shares a universe with (`yurika`, `the-guild`, the agency's client work). Every piece of work is organised as a **scene** inside a **chapter** inside a **campaign**. The vault is markdown-only, owned by the founder, portable forever.

## Your role

You are the **intelligence layer** of a three-layer product: vault (data) → agent (you) → webapp (interface, not yet built). Function as the command centre's agent via Claude Code terminal sessions.

Practically:
- **Read the vault before acting.** Load relevant upstream context before drafting.
- **Respect the scene structure.** Never skip Set Stage. Never conclude without the five questions.
- **Draft, don't decide.** The founder edits your output.
- **Stay in voice.** British English. Sophisticated register. No marketing speak.

## The thesis (non-negotiable)

> *Building a startup should feel like playing a game — and the act of playing it should produce the narrative that sells it.*

Maxim form: *Build should feel like play. Play should write the story.*

If an action would make the work feel more like filing taxes or less like playing, surface the tension before proceeding.

## The four design laws

1. **Every feature must argue the thesis.** If it doesn't, flag it.
2. **Friction drives the product.** Thematic friction between old and new is the engine.
3. **Pacing is composed.** Peaks, rests, crescendos, callbacks.
4. **Always give the user something to do.** No dead-end empty states.

## Vault structure

```
/campaigns/<campaign-slug>/
    campaign.md
    /chapters/<NN-chapter-slug>/
        chapter.md
        /scenes/<NN-scene-slug>.md
/characters/<n>.md
/templates/
/artifacts/<chapter-slug>/<NN-scene-slug>.md
/assets/
/.claude/commands/
```

### Naming

- Scenes: `NN-kebab-case.md`, zero-padded two-digit.
- Chapters: `NN-kebab-slug/` directories.
- Characters: kebab-case filenames.
- Artifacts: mirror source scene's slug.

### Wikilinks

- `[[slug]]` resolves against file stems.
- Characters are global.
- Scenes are campaign-local.
- Unresolved wikilinks are *prompts to create the missing file* — ask whether to generate.

## Frontmatter schemas

**Scene:**
```yaml
---
campaign: "[[campaign-slug]]"
chapter: "NN-chapter-slug"
scene: N
title: "Scene title"
status: not-started | in-progress | concluded | shipped
date_opened: YYYY-MM-DD
date_concluded: YYYY-MM-DD
characters: ["[[slug]]"]
artifact_format: thread | newsletter | video | essay | none
artifact_file: "[[artifact-filename]]"
tags: []
---
```

**Chapter / Campaign / Character:** see `templates/`.

## The scene structure

### Set the Stage

- How did we get here?
- Where are we going?
- State of the world (project context)
- State of the hero (user/audience)
- State of the protagonist (person doing the work)
- This moment in relation to goals
- Why now?

### Progress the moment

- Goal for this session
- Moment-by-moment capture
- What's changing?

### Conclude

- How is now different from the start?
- What are the consequences?
- What did we learn?
- Progress to thesis
- Progress to goal
- Next scene
- Artifact format

The Conclude block's five core questions are the exact five-beat structure of a build-in-public post. Never treat Conclude as paperwork. It is the product.

## Workflows

### Opening a new scene

1. Read `campaign.md`, `chapter.md`, prior scene's Conclude.
2. Copy `templates/scene-template.md` to correct path.
3. Fill frontmatter.
4. Draft Set Stage from loaded context.
5. Present for edit. Don't commit until sign-off.

### Capturing during work

1. Identify the active scene (`status: in-progress`).
2. Append to **Moment-by-moment capture**.
3. Update **What's changing?** if understanding shifts.
4. Don't modify Set Stage silently.
5. Don't over-prompt.

### Concluding a scene

1. Load scene, thesis, chapter arc.
2. Draft all seven Conclude answers from captured material.
3. Lessons can be sober or negative. Not marketing.
4. Present for edit.
5. On sign-off: `status: concluded`, `date_concluded`, `artifact_format`. Update chapter checklist.

### Publishing an artifact

1. Create `/artifacts/<chapter>/NN-<scene-slug>.md`.
2. Adapt Conclude into chosen format.
3. Preserve voice. No added optimism.
4. On external publish: `status: shipped`, set `artifact_file`.

### Creating a new character

1. Ask whether to create or leave unresolved.
2. Copy `templates/character-template.md`.
3. Fill frontmatter.
4. For real people you don't know well: leave sections as *To be filled by the founder*.
5. For archetypes: draft fully — they're design artefacts.

## Voice guide

**Register:** British English. Sophisticated. Specific over abstract. Low emoji.

**Spelling:** realise, colour, organise, -ise endings.

**In-voice phrases:** load-bearing, earns its place, compounds, subversion, the shape of the thing, empire in their head, filing taxes, the atom of [X].

**Out-of-voice:** game-changer, disruptor, synergy, leverage (performative), unlock (marketingly), in today's fast-paced world, here's the thing (as opener), at the end of the day, let's dive in, let's break this down.

**Sentence shapes:** short declarative openings; colons that earn their keep; em dashes for the thought behind the thought.

**Don't hedge opinions into consensus-safe mush.** If a draft is wrong, say so and propose the alternative.

## Forbidden moves

1. Don't fabricate character interiors.
2. Don't collapse want and need.
3. Don't draft optimistic-marketing Conclude blocks.
4. Don't pad scenes.
5. Don't suggest features that serve institutional founders better than solo ones.
6. Don't modify Set Stage silently.
7. Don't invent a sixth Conclude question.
8. Don't reference three-layer architecture in external artifacts unless the scene is about it.

## When in doubt

1. Ask the founder.
2. Consult the campaign's thesis.
3. Consult the four design laws.
4. Consult the solo-thesis-holder's archetype constraints.
5. Draft, flag uncertainty, let the founder decide.

## Session open ritual

1. Read this file.
2. Read active campaign's `campaign.md`.
3. Read active chapter's `chapter.md`.
4. Identify any `status: in-progress` scene and load it.
5. Greet with *one line*: current scene, goal, next move.
6. Wait.

Brevity is the opposite of filing taxes.

---

*Living documentation. Update via scenes, not drive-by edits.*
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Templates
# ──────────────────────────────────────────────────────────────────

cat > templates/scene-template.md <<'VAULT_FILE_END'
---
campaign: "[[]]"
chapter: ""
scene: 
title: ""
status: not-started
date_opened: 
date_concluded: 
characters:
  - "[[]]"
artifact_format: 
tags:
  - 
---

# Scene XX — [title]

*Chapter X — [chapter name] · Campaign: [[]]*

*One-line summary of what this scene is and why it exists in the chapter arc.*

---

## Set the Stage

### How did we get here?
*Context for this scene.*

### Where are we going?
*The destination of the scene.*

### State of the world (project context)
*Environment, stack state, assets, integrations.*

### State of the hero ([[character]])
*The user or audience this scene ultimately serves. Wants vs needs. Dominant objection.*

### State of the protagonist ([[character]])
*The person doing the work. Their emotional and cognitive state.*

### This moment in relation to goals
*Where does this scene sit in the campaign arc?*

### Why now?
*What makes this the scene to play today?*

---

## Progress the moment

### Goal for this session
*What ships by end? Be specific.*

- 

### Moment-by-moment capture
*Commits, decisions, surprises.*

- [ ] 

### What's changing?
*Reversals, pivots, new information.*

- 

---

## Conclude

*Filled at end of session.*

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format
*Thread / newsletter / video / essay / none.*

---

## Notes
*Free space.*
VAULT_FILE_END

cat > templates/chapter-template.md <<'VAULT_FILE_END'
---
campaign: "[[]]"
chapter: 
title: ""
status: not-started
date_opened: 
date_concluded: 
climax_artifact: 
tags:
  - chapter
---

# Chapter XX — [title]

*Campaign: [[]]*

## Arc

*One paragraph. The transformation between open and close.*

## Thesis progress

*What does this chapter specifically test or advance about the thesis?*

## Scenes

- [ ] **[[01-scene-title]]** — *One-line description. Status.*
- [ ] **[[02-scene-title]]** — *One-line description. Status.*

## Climax

*The publishing moment that closes the chapter.*

## Constraints for this chapter

*What's off-limits during this chapter?*

- 

## Carry-over to next chapter

*Filled at chapter close.*

- 

---

*Opened during the first scene; updated at each Conclude.*
VAULT_FILE_END

cat > templates/campaign-template.md <<'VAULT_FILE_END'
---
type: campaign
campaign: ""
title: ""
status: planning
date_opened: 
date_shipped: 
thesis_one_liner: ""
universe: ""
tags:
  - campaign
---

# Campaign: [Name]

## Thesis

*One sentence. "The world would be better if X." Must have at least one genuine subversion.*

## Basal assumptions

*Three minimum. Foundational truths this product takes for granted.*

1. 
2. 
3. 

## Hero

- **Archetype:**
- **Wound:**
- **Want:**
- **Need:**
- **Weakness:**
- **Support system:**

## Call to adventure

*One vivid scene of the moment before they find your product.*

## Mentor (the product)

*How the product shows up in the hero's story. What role — Gandalf, handbook, sword, map, mirror?*

## Trials (user journey)

1. 
2. 
3. 
4. 
5. 

## Cost

*What the hero must give up. Frame as sacrifice.*

## Endings

- **Good:**
- **Neutral:**
- **Bad:**

## Universe consistency

- **Sibling campaigns:** 
- **Shared universe law:** 

## Chapters

- **Chapter 1 —** 
- **Chapter 2 —** 
- **Chapter 3 —** 
- **Chapter 4 —** 
- **Chapter 5 —** 

---

*Updated when the thesis sharpens or the arc shifts.*
VAULT_FILE_END

cat > templates/character-template.md <<'VAULT_FILE_END'
---
type: character
archetype: ""
real_or_fictional: 
universe: ""
scenes:
  - "[[]]"
tags:
  - character
---

# [Name]

*Archetype: [archetype] · Universe: [universe]*

*One line on who this character is.*

---

## Relation to the central idea

*How does this character relate to the campaign's thesis?*

## Wound

*What is broken about their situation. Present tense.*

## Want

*Surface-level goal.*

## Need

*Deeper thing underneath the want.*

## Weakness

*What they bring that gets in their own way.*

## Motivations

- 

## Character-defining moments

- 

## Support system

- 

## Appearance in the world

*Privileged or under-privileged? In what dimensions?*

---

## Audience (if protagonist)

## Protagonists reaching for this character (if audience)

## Scenes featuring this character

- [[]] — *Role.*

## Notes
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Campaign: command-centre
# ──────────────────────────────────────────────────────────────────
cat > campaigns/command-centre/campaign.md <<'VAULT_FILE_END'
---
type: campaign
campaign: command-centre
title: "AI Command Centre"
status: planning
date_opened: 
date_shipped: 
thesis_one_liner: "Building a startup should feel like playing a game — and the act of playing it should produce the narrative that sells it."
universe: "yurika, the-guild, agency"
tags:
  - campaign
  - ai
  - founder-tools
---

# Campaign: AI Command Centre

## Thesis

Building a startup should feel like playing a game —
and the act of playing it should produce the narrative that sells it.

## Basal assumptions

1. Solo founders' most valuable asset is narrative momentum, not operational efficiency.
2. The tools used to do the work and the channels used to publicise the work should not be separate.
3. AI is most useful to a founder when deployed as cast, not as crew.

## Hero

- **Archetype:** [[solo-thesis-holder]]
- **Wound:** The empire in their head is invisible to everyone else
- **Want:** A task manager that keeps them organised
- **Need:** The felt sense that the work is becoming a story worth telling
- **Weakness:** Context-switching eats their cognition
- **Support system:** Partner, scattered peers, occasional mentor — none of whom fill this gap

## Call to adventure

Monday morning. 47 tabs. A half-written post from three weeks ago.
A feature speccing itself in a notebook. An unanswered email from someone
who could change everything. The quiet terror that none of it is connecting.

## Mentor (the product)

Not a PM. Not an assistant. A narrator. Takes the day's work and structures
it into a day's chapter. At week's end, the chapter is a publishable post.
The founder did the work; the system did the writing.

## Trials (user journey)

1. Onboarding as world-building — write thesis, assumptions, hero
2. Morning check-in as scene-setting — what scene today?
3. Working as scene-capturing — LLM watches, logs artifacts
4. End-of-day as scene-concluding — what changed? what's the consequence?
5. End-of-week as chapter-publishing — the draft assembles itself

## Cost

Real emotional labour during onboarding. Writing a thesis is harder than
connecting a Google Calendar. This cost is a feature, not a bug —
it filters for founders who are ready.

## Endings

- **Good:** founder publishes, audience grows, work compounds
- **Neutral:** founder finishes the campaign but the thesis is softer than hoped
- **Bad:** the thesis reveals itself as hollow; the tool forces an earlier
  confrontation with that than would otherwise have happened
- All three are wins, because the system's job is to make reality legible,
  not to make it flattering

## Universe consistency

- **Sibling campaigns:** [[yurika]] (funding infrastructure for underrepresented founders), [[the-guild]] (gig economy reputation), the agency (services arm)
- **Shared universe law:** underrepresented and non-traditional founders deserve infrastructure equal to their ambition

## Chapters

- **Chapter 1 — Origin.** Campaign Book written. Manual-run proof. First founding-thesis post shipped.
- **Chapter 2 — The ritual.** Webapp MVP (Set Stage + Conclude only).
- **Chapter 3 — The watcher.** Capture layer added. Agent drafts Conclude blocks.
- **Chapter 4 — First followers.** Waitlist opens.
- **Chapter 5 — First player.** First external founder onboarded.
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Chapter: 01-origin
# ──────────────────────────────────────────────────────────────────
cat > campaigns/command-centre/chapters/01-origin/chapter.md <<'VAULT_FILE_END'
---
campaign: "[[command-centre]]"
chapter: 01
title: "Origin"
status: in-progress
date_opened: 
date_concluded: 
climax_artifact: 
tags:
  - chapter
  - chapter-1
  - manual-proof
---

# Chapter 01 — Origin

*Campaign: [[command-centre]]*

## Arc

From insight to manual proof.

The founder realises the business-person OS isn't native. They switch to the storytelling-and-gaming OS they already trust. They prove the switch works by running the system *manually* — no webapp, no agent, just markdown files and discipline — on real client work for one week. By chapter close, the system has produced at least one shipped deliverable *and* at least one publishable artifact without either labour feeling extra.

## Thesis progress

Tests the campaign thesis in its weakest form: can one human do this with discipline alone? If yes, the thesis has legs. If no, the thesis needs revision before any code is written.

## Scenes

- [x] **[[01-onboarding-yourself]]** — Campaign Book written. *Concluded. Artifact: [[01-build-should-feel-like-play]].*
- [ ] **[[02-talk-with-flavour-landing-page]]** — First client deliverable through the scene structure. *Open, not started.*
- [ ] **03 — [next client landing page]** — Second proof point.
- [ ] **04 — [third client landing page or buffer]** — Third data point.
- [ ] **05 — Chapter 1 close** — Weekly synthesis.

## Climax

The Chapter 1 close artifact — a long-form essay synthesising the week's evidence.

## Constraints for this chapter

- **No building the webapp.** Chapter 1 is discipline-only.
- **Every scene's Conclude gets published.** Even bad weeks.
- **Scenes run on client work, not internal work.**

## Carry-over to Chapter 2

- *(Filled at chapter close)*
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Scenes
# ──────────────────────────────────────────────────────────────────
cat > campaigns/command-centre/chapters/01-origin/scenes/01-onboarding-yourself.md <<'VAULT_FILE_END'
---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 01
title: "Onboarding yourself into the command centre"
status: concluded
date_opened: 
date_concluded: 
characters:
  - "[[solo-thesis-holder]]"
  - "[[prince]]"
artifact_format: essay
artifact_file: "[[01-build-should-feel-like-play]]"
tags:
  - meta-scene
  - chapter-1
---

# Scene 01 — Onboarding yourself into the command centre

*Chapter 1 — Origin · Campaign: [[command-centre]]*

A meta-scene. The founder writes the Campaign Book for the product they're about to build — in the vault the product will run on.

---

## Set the Stage

### How did we get here?
The realisation that the business-person OS — TAM, lean canvas, GTM — wasn't native. The native OS is storytelling and gaming. A trusted writing planner already exists. A working AI agent pipeline already exists. Ten-plus live client projects create the pressure; the leverage needed is structural, not technical.

### Where are we going?
A complete Campaign Book for the command centre at `/campaigns/command-centre/campaign.md`.

### State of the world (project context)
- Obsidian vault initialised
- Claude Code installed
- `yurika-web-template` available for Chapter 2
- [[yuri]] available for ops-side input
- No prior files to conflict with

### State of the hero ([[solo-thesis-holder]])
Future users of the command centre. Their wound: the empire in their head is invisible. They want a task manager; they need to feel their work is becoming a story.

### State of the protagonist ([[prince]])
Conviction and momentum present. What's absent is a document to point at when a decision needs anchoring.

### This moment in relation to goals
Chapter 1's first beat. Nothing downstream works without this file.

### Why now?
Scene 02 needs a thesis to cite.

---

## Progress the moment

### Goal for this session
Complete `campaign.md` in the vault.

### Moment-by-moment capture

- [x] Campaign Book template drafted
- [x] Thesis merged from two candidates
- [x] Three basal assumptions committed
- [x] Hero archetype written
- [x] Five-trial user journey mapped
- [x] `campaign.md` placed

### What's changing?
- Thesis landed cleaner once merged — "and" unlocked it
- Basal assumption #2 emerged as the sharpest
- Writing the Hero's *need* was harder than the *want*

---

## Conclude

### How is now different from the start?
There's a written thesis the whole campaign can reference.

### What are the consequences?
Every future scene cites this file. The first draft of a founding-thesis post exists.

### What did we learn?
That we shouldn't be forcing ourselves into unnatural shapes in the name of business. We can just create systems that play to our strengths.

### Progress to thesis
The thesis now exists in a form you can stare at.

### Progress to goal
Chapter 1 Scene 1 complete.

### Next scene
[[02-talk-with-flavour-landing-page]] — run the system on outstanding client work.

### Artifact format
**Essay.** [[01-build-should-feel-like-play]].

---

## Notes
The self-referential structure is the point. Keep an eye on whether the pattern holds in Scene 02 where the work is not the writing of a spec.
VAULT_FILE_END

cat > campaigns/command-centre/chapters/01-origin/scenes/02-talk-with-flavour-landing-page.md <<'VAULT_FILE_END'
---
campaign: "[[command-centre]]"
chapter: "01-origin"
scene: 02
title: "Talk with Flavour landing page"
status: not-started
date_opened: 
date_concluded: 
characters:
  - "[[nathan]]"
  - "[[restaurant-owner-archetype]]"
artifact_format: 
tags:
  - client-work
  - landing-page
  - chapter-1
  - yurika-web-template
---

# Scene 02 — Talk with Flavour landing page

*Chapter 1 — Origin · Campaign: [[command-centre]]*

First real test of the manual system on a live client deliverable.

---

## Set the Stage

### How did we get here?
[[nathan]] is a restaurant videographer with strong footage and no funnel. Work has been coming through word-of-mouth, which is volatile. He needs a URL he can point at that does his selling.

### Where are we going?
A landing page that moves a skeptical restaurant owner from *"interested"* to *"booked a call"*. Preview URL by end of session. Live by end of week.

### State of the world (project context)
- Fresh scaffold from `yurika-web-template`
- Theme not yet applied
- Assets: reel, three past-client shoots, opinionated pricing
- Deployment target: Vercel preview → production
- Supabase for booking form, Resend for notifications

### State of the hero ([[restaurant-owner-archetype]])
90 seconds max on a page. Been burned before. Wants better food video; *needs* confidence working with Nathan won't disrupt service. Dominant objection is logistical risk, not price.

### State of the protagonist ([[nathan]])
Creative. Hates selling himself. Work is strong; self-presentation isn't.

### This moment in relation to goals
First infrastructure move for Talk with Flavour. Every downstream acquisition move routes here.

### Why now?
Body of work has reached critical mass. Bottleneck is conversion, not capability.

---

## Progress the moment

### Goal for this session
Ship preview URL. Required sections:

1. Hero with reel (footage-led)
2. Logistics-pre-empted second section
3. Three case studies, visual-first
4. Opinionated pricing visible
5. Booking flow, one-click

### Moment-by-moment capture

- [ ] Theme picked and applied
- [ ] Hero section with reel embedded
- [ ] Logistics section drafted
- [ ] Case studies laid out
- [ ] Pricing section
- [ ] Booking flow wired
- [ ] Preview deployed

### What's changing?

- 

---

## Conclude

### How is now different from the start?

### What are the consequences?

### What did we learn?

### Progress to thesis

### Progress to goal

### Next scene

### Artifact format
Leading candidate: **thread**. Visuals + logistics-objection lesson + reusable pattern.

---

## Notes
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Characters
# ──────────────────────────────────────────────────────────────────
cat > characters/solo-thesis-holder.md <<'VAULT_FILE_END'
---
type: character
archetype: "The solo thesis-holder"
real_or_fictional: archetype
universe: "[[command-centre]]"
scenes:
  - "[[01-onboarding-yourself]]"
tags:
  - character
  - archetype
  - hero
  - end-user
---

# The Solo Thesis-Holder

*Archetype · Universe: [[command-centre]]*

The intended end user of the [[command-centre]]. Every feature decision tests against whether it serves this character.

---

## Relation to the central idea

This archetype *is* the central idea, in user-shape. [[prince]] embodied the archetype in [[01-onboarding-yourself]] as the product's first user.

## Wound

The empire in their head is invisible to everyone else, including themselves on bad days.

They have conviction. They have craft. Momentum on the inside. What they don't have is a public narrative that compounds.

## Want

A task manager that keeps them organised. Cleaner operational layer. Less context-switching.

## Need

The felt sense that their work is becoming a story worth telling.

Not productivity — *legibility*. To themselves first, audience second.

## Weakness

Context-switching eats their cognition. Ten tabs by 10am. A preference for building new things over finishing existing things.

## Motivations

- Prove their thesis is real
- Compound audience around their work
- Stop feeling behind their own idea of themselves

## Character-defining moments

- Realisation that the business-person OS wasn't native
- *(More as real users onboard)*

## Support system

- A partner, often unnamed in public
- Scattered peers across timezones
- No institutional structure — this is definitional

## Appearance in the world

Often underrepresented along one or more dimensions. Usually privileged in craft, under-privileged in visibility infrastructure. The gap is the defining feature.

Operates from home, cafes, trains. Tends toward one or two deep-work tools.

---

## Protagonists reaching for this character

- [[prince]] — via the command centre; also a member of the archetype
- *(Extended as the product ships)*

## Scenes featuring this character

- [[01-onboarding-yourself]] — *Hero. [[prince]] plays the role.*

## Archetype constraints (read before major product decisions)

1. If the answer serves institutionally-backed founders more than solo ones, the answer is wrong.
2. If the answer assumes a team member in another role, the answer is wrong.
3. If the answer optimises for speed at the cost of legibility, the answer is wrong.
4. If the answer treats narrative as downstream of work, the answer is wrong.

The archetype's job is to say no to seductive wrong answers.

## Notes
VAULT_FILE_END

cat > characters/prince.md <<'VAULT_FILE_END'
---
type: character
archetype: "The thesis-holder as builder"
real_or_fictional: real
universe: "command-centre, [[yurika]], [[the-guild]], agency"
scenes:
  - "[[01-onboarding-yourself]]"
  - "[[02-talk-with-flavour-landing-page]]"
tags:
  - character
  - protagonist
  - builder
  - founder
---

# Prince

*Archetype: The thesis-holder as builder · Universe: command-centre, [[yurika]], [[the-guild]], agency*

Real person. Builder of [[command-centre]]. Co-founder of [[yurika]]. Runs the agency alongside [[yuri]].

---

## Relation to the central idea

In the command-centre campaign, protagonist *and* — in Scene 01 specifically — an embodiment of the [[solo-thesis-holder]] archetype. The product is being built by its own first user. Across sibling campaigns, he's the operator-protagonist building infrastructure for the demographic he belongs to.

## Wound

Ten-plus live projects, trusted infrastructure, and — until recently — a sense that the empire was invisible from outside. Work compounding internally but not narratively. Executing on a thesis he hadn't yet articulated, in an OS that wasn't native.

## Want

Leverage. A system that lets him execute at the pace of his thinking.

## Need

1. Public proof the storytelling-and-gamer OS is a real advantage, not a vanity.
2. A narrative layer that turns individual campaigns into a universe.

## Weakness

Context-switching across 10+ campaigns. A preference for *building the system* over *running the system* — the trap the command centre exists to break.

## Motivations

- Prove underrepresented founders can operate at scale with comparable infrastructure
- Generate compounding narrative momentum
- Make the work feel like the thing it's supposed to feel like

## Character-defining moments

- Realisation that the business-person OS wasn't native
- Naming the storyteller/gamer identity as an operating principle
- *(More as scenes develop)*

## Support system

- [[yuri]] — partner in the agency
- Peers scattered across the founder community
- The writing planner itself — oldest and most trusted collaborator

## Appearance in the world

Privileged in craft, cultural capital, multilingual. Under-privileged in institutional dimensions — mainstream venture, cohort-based accelerator access. The gap is why [[yurika]] exists.

---

## Audience

- **[[command-centre]]:** [[solo-thesis-holder]]
- **[[yurika]]:** underrepresented founders
- **[[the-guild]]:** gig workers
- **Agency:** small-business operators ([[nathan]], Youpree brands)

## Scenes featuring Prince

- [[01-onboarding-yourself]] — *Protagonist + hero.*
- [[02-talk-with-flavour-landing-page]] — *Protagonist.*

## Notes
VAULT_FILE_END

cat > characters/yuri.md <<'VAULT_FILE_END'
---
type: character
archetype: "The operational counterweight"
real_or_fictional: real
universe: "[[yurika]], agency, [[command-centre]]"
scenes: []
tags:
  - character
  - partner
  - operations
---

# Yuri

*Archetype: The operational counterweight · Universe: [[yurika]], agency, [[command-centre]]*

Real person. Partner and co-founder alongside [[prince]]. Operational layer of the agency and [[yurika]].

---

## Relation to the central idea

Yuri proves one of the command centre's basal assumptions in reverse: solo founders need narrative leverage *and* operational leverage. Without her, the agency's output wouldn't match the thesis's ambition.

## Wound

*To be filled by Prince.*

## Want

*To be filled by Prince.*

## Need

*To be filled by Prince.*

## Weakness

*To be filled by Prince.*

## Motivations

*To be filled by Prince.*

- 

## Character-defining moments

*To be filled by Prince.*

- 

## Support system

- [[prince]] — partner, co-founder

## Appearance in the world

*To be filled by Prince.*

---

## Scenes featuring Yuri

- 

## Protagonists she supports

- [[prince]] — across all active campaigns

## Notes
Deliberately under-drafted. Yuri's interior is Prince's to write — ideally at the start of a quiet week, not under deadline pressure.
VAULT_FILE_END

cat > characters/nathan.md <<'VAULT_FILE_END'
---
type: character
archetype: "The reluctant self-promoter"
real_or_fictional: real
universe: "[[yurika]] / agency"
scenes:
  - "[[02-talk-with-flavour-landing-page]]"
tags:
  - character
  - client
  - hospitality
  - videography
---

# Nathan

*Archetype: The reluctant self-promoter · Universe: agency client roster*

Real person. Restaurant videographer. Founder of **Talk with Flavour**.

---

## Relation to the central idea

Not a character in the command-centre campaign directly — he's in the agency's work that *intersects* the command-centre at [[02-talk-with-flavour-landing-page]]. The thesis is being tested on his deliverable.

## Wound

Extraordinary craft, ordinary distribution.

## Want

More bookings. Better clients. A landing page that represents his work's quality.

## Need

A funnel that doesn't require him to sell himself.

## Weakness

Hates self-presentation. Will write "about me" copy that undersells him.

## Motivations

- Have his craft seen at the level it operates at
- Work with restaurants that understand what good food video does for them
- A predictable pipeline so he can turn down mismatched work

## Character-defining moments

- *(To fill as the relationship develops)*

## Support system

- [[prince]] and [[yuri]]

## Appearance in the world

Privileged in craft, under-privileged in distribution. The landing page scene is the first infrastructural move to rebalance.

---

## Audience

The character Nathan is trying to reach: [[restaurant-owner-archetype]].

## Scenes featuring Nathan

- [[02-talk-with-flavour-landing-page]] — *Protagonist.*

## Notes
VAULT_FILE_END

cat > characters/restaurant-owner-archetype.md <<'VAULT_FILE_END'
---
type: character
archetype: "The hospitality operator"
real_or_fictional: archetype
universe: "[[yurika]] / agency"
scenes:
  - "[[02-talk-with-flavour-landing-page]]"
tags:
  - character
  - archetype
  - audience
  - hospitality
---

# The Restaurant-Owner Archetype

*Archetype · Universe: agency client roster*

An archetype representing the audience [[nathan]]'s landing page converts.

---

## Relation to the central idea

Ultimate beneficiary of [[02-talk-with-flavour-landing-page]]. Their wants and needs determine every design decision on the page.

## Wound

Burned before. Previous creative vendors who didn't understand operational reality — photographers who wanted service-hour shoots, videographers who couldn't move out of the way.

## Want

Better food video. Visible quality matching the restaurant's position.

## Need

**Confidence that working with a videographer won't disrupt service.** Not price. Not quality. *Operational risk.*

## Weakness

- 90-second decision window
- Decides fast, often on gut
- Relies on past-work evidence more than brand claim

## Motivations

- Rising check averages in a competitive market
- Standing out on delivery platforms
- Protecting the brand they've built
- Not looking amateurish next to competitors

## Support system

- GM, head chef, social media consultant — all with opinions

## Appearance in the world

Time-poor, operationally conservative. Responds to evidence of logistical sensitivity faster than claims of aesthetic quality.

---

## Decision factors (ranked)

1. Past work matching their own restaurant's positioning
2. Explicit answer to the logistical-disruption question
3. Clear, unhidden pricing
4. Booking friction — low is better
5. Brand warmth — distant last

## Scenes featuring this archetype

- [[02-talk-with-flavour-landing-page]] — *Hero.*

## Related characters

- [[nathan]] — *The protagonist trying to reach this hero*

## Notes
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Artifact
# ──────────────────────────────────────────────────────────────────
cat > artifacts/chapter-1/01-build-should-feel-like-play.md <<'VAULT_FILE_END'
# Build should feel like play. Play should write the story.

I have ten client projects in flight, a working AI agent pipeline, and — until recently — a creeping sense that I'd been running the wrong operating system.

It took me a while to name the problem, because on paper nothing was wrong. The projects were shipping. The infrastructure was real. Yuri and I were moving. And yet every time I sat down to plan the next move, I was reaching for frameworks that felt like a suit that didn't fit — TAM slides, lean canvas, go-to-market plans. Fluent in them, but not native.

Then I realised: I'm not a business person. I'm a storyteller and a gamer. And I've been trying to build SaaS in an OS that isn't mine.

Here's what I've switched to.

## The thesis

*Building a startup should feel like playing a game — and the act of playing it should produce the narrative that sells it.*

Two subversions in one sentence, which is how I know it's worth arguing.

Against the dominant startup aesthetic: building isn't grim ops work. It's a game — with a loop, a progression, real choices, and characters.

Against the dominant content aesthetic: narrative isn't a separate step you do after the work. The doing and the telling should be the same act.

## The system I already had

I've been running a writing planner for years. Premise, world, characters, conflict, scene. It produces stories I'm proud of.

The insight was small and embarrassing in retrospect: the same system, pointed at SaaS instead of fiction, produces products.

Every product is a story arguing a thesis. Every user is a hero with a wound, a want, and a deeper need. Every feature is a scene with a set-stage, a progress, and a conclude. And every scene's Conclude block — *how is now different, what are the consequences, what did we learn, what's the progress to the central idea* — is the exact five-beat structure of a build-in-public post.

Which means this: if I run every task as a scene, the work of doing and the work of writing collapse into one action. Two birds, one atom.

## The playthrough

I'm now building a product that makes this explicit. Working title: *the AI command centre*. It lives in three layers.

A vault of markdown files in Obsidian — campaigns, chapters, scenes. Your story, yours forever. No lock-in, ever. An AI agent that watches the work — commits, browser tabs, writing sessions — and drafts the Conclude block before you sit down for the evening ritual. And a webapp that enforces the ritual itself: morning Set Stage, evening Conclude, end-of-week chapter publish.

I'm building it by using it. Scene 1 was writing the Campaign Book for the product itself. Scene 2, this week: running the system manually on outstanding client work — three live landing pages, captured and concluded through the scene structure as I build them. By Chapter 2, the webapp MVP ships.

Five chapters, roughly three months. Each chapter ends in a publishing moment that *is* the milestone.

## What Scene 1 taught me

That I shouldn't be forcing myself into unnatural shapes in the name of business. I can just create systems that play to my strengths.

That's the Conclude block from Scene 1. It's also, mechanically, the thing you just read — which is the point. The scene structure produces the post. The post *is* the scene closing.

If you want to follow the playthrough, stick around. Scene 2 ships this week.
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Slash commands
# ──────────────────────────────────────────────────────────────────
cat > .claude/commands/set-stage.md <<'VAULT_FILE_END'
---
description: Open a new scene and draft its Set Stage block
---

Open the scene specified in $ARGUMENTS (or ask me which if I haven't said).

Before drafting:
1. Read the campaign's `campaign.md` for thesis and basal assumptions
2. Read the chapter's `chapter.md` for arc and constraints
3. Read the prior scene's Conclude block if there is one

Then:
1. If the scene file doesn't exist, copy `templates/scene-template.md` to the right path
2. Fill frontmatter: campaign, chapter, scene, title, status: in-progress, date_opened, characters
3. Draft all seven Set Stage questions from loaded context
4. Present the draft for my edit
5. Wait for sign-off before saving

Follow the voice guide and forbidden-moves list in `CLAUDE.md`.

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/capture.md <<'VAULT_FILE_END'
---
description: Log a moment to the active scene's capture section
---

Identify the active scene (status: in-progress). Append $ARGUMENTS to its Moment-by-moment capture section.

Rules:
1. One active scene at a time — if there are zero or more than one, ask which
2. If the observation changes understanding of hero, protagonist, or world, also update What's changing?
3. Never modify Set Stage silently
4. Don't prompt for more capture — just log what I gave you and stop

Short entries as checklist items, longer observations as prose bullets. Match the existing entries' shape.

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/conclude.md <<'VAULT_FILE_END'
---
description: Draft the Conclude block for the active scene
---

Conclude the active scene (status: in-progress).

1. Load the scene file, campaign.md (for thesis), chapter.md (for arc)
2. Draft all seven Conclude answers from the captured material:
   - How is now different from the start?
   - What are the consequences?
   - What did we learn? (sober or negative is fine — not marketing)
   - Progress to thesis
   - Progress to goal
   - Next scene (propose candidates, pick one, justify)
   - Artifact format (detect from scene shape)
3. Present for my edit
4. On sign-off: set status: concluded, fill date_concluded and artifact_format, update the chapter's scenes checklist

Respect the forbidden moves in CLAUDE.md. Especially: no optimistic marketing in What did we learn.

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/publish.md <<'VAULT_FILE_END'
---
description: Convert a concluded scene's Conclude block into a publishable artifact
---

Publish the scene specified in $ARGUMENTS (or the most recently concluded scene if unspecified).

1. Load the scene's Conclude block and its artifact_format
2. Create `/artifacts/<chapter-slug>/<NN-scene-slug>.md`
3. Adapt the Conclude into the format:
   - Thread: hook → 4-8 beats → close with link or CTA
   - Newsletter: subject-line field, opener, 2-3 sections, close
   - Essay: long-form, sectioned headings, forward-motion close
   - Video: shot/beat markers, cold open, three acts, close
4. Preserve the founder's voice. No added optimism.
5. Present for edit
6. On sign-off: fill artifact_file in the scene's frontmatter. Set status: shipped once I publish externally.

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/new-character.md <<'VAULT_FILE_END'
---
description: Create a new character file from the character template
---

Create a character file for the name or archetype in $ARGUMENTS.

1. Copy `templates/character-template.md` to `/characters/<slug>.md`
2. Fill frontmatter: archetype, real_or_fictional, universe, starting scene(s), tags
3. For real people you don't know well: leave Wound/Want/Need/Weakness as "To be filled by the founder" — don't fabricate
4. For archetypes: draft the full structure — they're design artefacts that need a complete draft to edit against
5. Present for edit
6. On sign-off: save and update any referring scenes with the new [[wikilink]]

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/new-scene.md <<'VAULT_FILE_END'
---
description: Create a blank scene file without filling Set Stage
---

Create a new empty scene file for $ARGUMENTS.

Unlike /set-stage, this just stamps out the file and stops — no context loading, no drafting. Use when you want the scaffolding now and will fill Set Stage later.

1. Determine campaign, chapter, scene number, title from $ARGUMENTS (ask if unclear)
2. Copy templates/scene-template.md to the right path
3. Fill only the frontmatter: campaign, chapter, scene, title, status: not-started
4. Leave the body as the template's prompts
5. Report the created path

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/new-chapter.md <<'VAULT_FILE_END'
---
description: Bootstrap a new chapter directory with chapter.md and empty scenes folder
---

Create a new chapter for $ARGUMENTS.

1. Determine campaign, chapter number, chapter title from $ARGUMENTS
2. Create `/campaigns/<campaign>/chapters/<NN-slug>/scenes/` directory
3. Copy `templates/chapter-template.md` to `<NN-slug>/chapter.md`
4. Fill frontmatter: campaign, chapter, title, status: not-started
5. Draft the Arc and Thesis progress sections from campaign context
6. Present for edit, save on sign-off
7. Update the parent campaign.md's Chapters list with the new chapter

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/new-campaign.md <<'VAULT_FILE_END'
---
description: Bootstrap a new campaign with campaign.md
---

Create a new campaign for $ARGUMENTS.

1. Determine slug and title from $ARGUMENTS
2. Create `/campaigns/<slug>/chapters/` directory
3. Copy `templates/campaign-template.md` to `/campaigns/<slug>/campaign.md`
4. Fill frontmatter: campaign slug, title, status: planning
5. Ask me the thesis. A campaign without a thesis isn't ready to open.
6. Draft from my thesis answer: basal assumptions (propose three), hero archetype (link to existing or propose new), call to adventure, mentor, trials, cost, endings, universe consistency
7. Present for edit, save on sign-off
8. Do not open any chapters yet — that's /new-chapter's job when I'm ready

$ARGUMENTS
VAULT_FILE_END

cat > .claude/commands/status.md <<'VAULT_FILE_END'
---
description: Show vault status — active campaigns, in-progress scenes, recent artifacts
---

Report the current state of the vault. Read-only; don't modify anything.

1. List all campaigns and their status
2. For each campaign, identify the active chapter (status: in-progress)
3. For each active chapter, list scenes by status (in-progress, not-started, concluded, shipped)
4. List the three most recent artifacts
5. Flag any unresolved wikilinks across scene/character files
6. Present as a brief report, not a dump

Format: concise paragraphs, not a long bullet list. The status check is meant to orient me in 30 seconds, not overwhelm.
VAULT_FILE_END

cat > .claude/commands/archetype-check.md <<'VAULT_FILE_END'
---
description: Check a proposed decision against the solo-thesis-holder archetype constraints
---

Check the decision in $ARGUMENTS against the four archetype constraints in `/characters/solo-thesis-holder.md`:

1. Does the answer serve institutionally-backed founders more than solo ones? If yes → wrong
2. Does the answer assume a team member in another role? If yes → wrong
3. Does the answer optimise for speed at the cost of legibility? If yes → wrong
4. Does the answer treat narrative as downstream of work? If yes → wrong

For each of the four, give a short verdict (pass / fail / uncertain) with a one-sentence reason.

If any fail, propose an alternative that clears the constraint. Don't soften the verdict — the archetype's job is to say no to seductive wrong answers.

$ARGUMENTS
VAULT_FILE_END

# ──────────────────────────────────────────────────────────────────
# Git init
# ──────────────────────────────────────────────────────────────────
if [[ $INIT_GIT -eq 1 ]]; then
    if [[ ! -d .git ]]; then
        git init -q
        cat > .gitignore <<'GITIGNORE'
.DS_Store
.obsidian/workspace*
.obsidian/cache
GITIGNORE
        git add .
        git commit -q -m "Initialize command centre vault"
        echo "Git repo initialized with initial commit."
    else
        echo "Git repo already exists, skipping init."
    fi
fi

# ──────────────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────────────
echo ""
echo "Vault deployed in $(pwd)."
echo ""
echo "Files created:"
find . -type f \( -name "*.md" -o -name ".gitignore" \) | sort | sed 's|^\./|  |'
echo ""
echo "Next steps:"
echo "  1. (optional) Open the folder as an Obsidian vault"
echo "  2. Run 'claude' to start Claude Code — it will load CLAUDE.md automatically"
echo "  3. Try '/status' to orient, or '/set-stage Scene 02 — Talk with Flavour landing page' to begin"
echo ""
echo "Paste the thesis on the wall of your vault:"
echo "  Build should feel like play. Play should write the story."
