# sprintctl Bootstrap Prompts

This file contains the prompts to use when initializing sprintctl + kctl on a fresh repository. There are two prompts: the main bootstrap prompt (use once on a fresh repo) and the workflow-only prompt (use when sprintctl is already initialized but you need to set up workflow patterns).

---

## When to use which prompt

| Situation | Use |
|-----------|-----|
| Fresh repo, no sprintctl, no structure | Main bootstrap prompt |
| sprintctl already set up, need to shape first sprint properly | Main bootstrap prompt (it's idempotent) |
| sprintctl running, need to shape backlog or start a new sprint | Workflow-only prompt |
| Repo has sprints but agent needs workflow orientation | Workflow-only prompt |

---

## Main Bootstrap Prompt

Paste this into an agent session when initializing sprintctl on a fresh or near-empty repository.

---

```
You are initializing the sprintctl + kctl workflow on this repository. Your job is to set up the execution control layer and knowledge layer from scratch, leaving the repo in a clean, working state with a first sprint ready to execute.

## Context

sprintctl manages sprint execution: sprints, tracks, items, claims, handoffs, and state transitions. kctl manages durable knowledge: decisions, patterns, risks, and lessons that should persist beyond a single sprint. sprintctl does NOT have an `init` command — the database is created automatically on first use.

This is a local-first, repo-native workflow. No external project trackers. One developer plus sparse agent sessions.

## What to do

### 1. Set up the database scope

Create an `.envrc` file scoping the database to this repo:

```bash
echo 'export SPRINTCTL_DB="${PWD}/.sprintctl/sprintctl.db"' > .envrc
source .envrc
```

Add to `.gitignore`:
```
.sprintctl/
handoff-*.json
sprint-*.json
```

### 2. Assess the repo

Read the following if they exist:
- README.md
- AGENTS.md
- `sprintctl sprint show` (if a sprint already exists)

Identify:
- What is this repo for?
- Is there an existing sprint? What state is it in?
- Are there open claims?
- What tracks make sense for this repo?

### 3. Create the first sprint

Choose a sprint name using the naming convention `YYYY-SNN-<anchor>-<focus>-<phase>`.

For a template/reference repo: `YYYY-S01-hearth-workflow-overture`
For an application repo: `YYYY-S01-forge-schema-overture` or similar

```bash
sprintctl sprint create \
  --name 2026-S01-hearth-workflow-overture \
  --status active \
  --start 2026-03-30 \
  --end 2026-04-12
```

Note the sprint ID from the output.

### 4. Create initial backlog items

Create 5-10 items representing the actual work. Tracks are created implicitly when you use `--track <name>`. Be specific — vague items like "set up project" are not useful.

```bash
# Use --sprint-id <id> from step 3
sprintctl item add \
  --sprint-id <sprint-id> \
  --track workflow \
  --title "Define track taxonomy and claim policy in AGENTS.md"

sprintctl item note --id <item-id> --type decision \
  --summary "Done when AGENTS.md has: repo classification, tracks, claim policy, review policy, artifact paths." \
  --actor setup

sprintctl item add \
  --sprint-id <sprint-id> \
  --track docs \
  --title "Write sprint-naming.md with anchor/focus/phase vocabulary"

sprintctl item note --id <item-id> --type decision \
  --summary "Done when naming convention, vocabulary, rules, and 8+ examples are documented." \
  --actor setup
```

### 5. Create AGENTS.md if it doesn't exist

AGENTS.md is the agent entry point. It must cover:
- Repo classification and purpose
- Sprint naming convention in use
- Track taxonomy
- Claim policy
- Review policy
- Artifact paths
- Knowledge promotion policy
- Source-of-truth order
- What NOT to do

Use docs/agent-guidance/ from the sprintctl-bootstrap-template as a reference if available.

### 6. Create docs/sprint/current.md

Render the current sprint state and commit it as the repo-visible snapshot:

```bash
mkdir -p docs/sprint/archive docs/knowledge
sprintctl render > docs/sprint/current.md
```

### 7. Verify the setup

```bash
sprintctl sprint show
sprintctl item list --sprint-id <sprint-id>
sprintctl claim list-sprint --sprint-id <sprint-id>
sprintctl maintain check --sprint-id <sprint-id>
```

Check that:
- Sprint is in active state with correct dates
- Items exist across tracks
- No stale claims from initialization
- AGENTS.md accurately describes the setup
- docs/sprint/current.md exists

## What success looks like

- `sprintctl sprint show` shows the active sprint with correct dates
- `sprintctl item list` shows 5+ shaped items across tracks
- AGENTS.md exists and accurately describes the workflow for this repo
- `docs/sprint/current.md` exists and shows current sprint state
- Maintenance check reports no issues

## What NOT to do

- Don't run `sprintctl init` — there is no init command; the DB is auto-created
- Don't create placeholder items ("TODO: figure out what to do here")
- Don't over-track — 3-5 tracks is right for most repos
- Don't set up knowledge entries during bootstrap unless there's an actual decision to record
- Don't create items for things that are already done
```

---

## Workflow-Only Prompt

Use this when sprintctl is already initialized but you need to set up a new sprint, shape backlog, or orient an agent to the running workflow.

---

```
You are picking up work on this repository which uses the sprintctl + kctl workflow. Your first job is to orient yourself, then execute or shape work as needed.

## Orientation (do this first)

1. Read AGENTS.md fully
2. Load the environment: source .envrc (or direnv allow)
3. Run: sprintctl sprint show
4. Run: sprintctl item list --sprint-id <id>
5. Run: sprintctl claim list-sprint --sprint-id <id>
6. Check for handoff events on any active items: sprintctl item show --id <id>

## Identify your role for this session

Based on what you find, you are in one of these situations:

**A. Continuing claimed work:** A claim exists with your session's context or a handoff note directs you to continue. Read the item events, assess state, and continue. Use `sprintctl claim resume` if you need to find your own claim.

**B. Picking up open work:** Items exist that are pending and unclaimed. Pick the highest priority item in your track, claim it, move it to active, and begin.

**C. Shaping new work:** The backlog is thin or the sprint is complete. Shape the next sprint by reviewing what's needed, creating items, or running the bootstrap prompt if this is a fresh start.

**D. Knowledge work:** Review sprint events for pattern-noted and lesson-learned entries, draft knowledge entries, and publish to docs/knowledge/.

## If shaping a new sprint

1. Review what was done in the last sprint: `sprintctl sprint list`
2. Identify carry-over items: `sprintctl item list --sprint-id <old-id> --status pending` and `--status blocked`
3. Choose a sprint name (see AGENTS.md or docs/sprint-naming.md)
4. Create the sprint: `sprintctl sprint create --name <name> --status active --start <date> --end <date>`
5. Add items with `sprintctl item add` — be specific, not vague
6. Carry over unfinished items: `sprintctl maintain carryover --from-sprint <old-id> --to-sprint <new-id>`

## Execution norms

- Claim before starting any non-trivial work: `sprintctl claim create --item-id <id> --actor <you> --json`
- Save the claim_token from the output — you need it to transition the item and release the claim
- Leave a handoff note when you stop: `sprintctl item note --id <id> --type claim-handoff ...`
- Transfer the claim when handing off: `sprintctl claim handoff --id <claim-id> --claim-token <token> --actor <next> --mode rotate`
- Record decisions during work: `sprintctl item note --id <id> --type decision ...`
- Close items when done: `sprintctl item status --id <id> --status done --claim-id <id> --claim-token <token>`
- Block items when blocked: `sprintctl item status --id <id> --status blocked --claim-id <id> --claim-token <token>`

## Before you stop

- Release claims on anything you won't continue: `sprintctl claim release --id <id> --claim-token <token>`
- Leave handoff notes on anything in-progress
- Update docs/sprint/current.md: `sprintctl render > docs/sprint/current.md`
- Record any decisions or patterns worth preserving: `sprintctl item note --id <id> --type pattern-noted ...`
```

---

## Expected outputs from the main bootstrap prompt

After running the bootstrap prompt on a fresh repo, you should have:

- `.envrc` scoping the database to this repo
- One active sprint with correct dates
- 3-5 tracks with 5-10 shaped items
- `AGENTS.md` with accurate content for this repo
- `docs/sprint/current.md` showing the current sprint state
- No stale claims or orphaned items

Total time for an agent to complete bootstrap: typically 10-20 minutes of session time.
