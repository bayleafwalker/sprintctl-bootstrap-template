# sprintctl Bootstrap Prompts

This file contains the prompts to use when initializing sprintctl + kctl on a fresh repository. There are two prompts: the main bootstrap prompt (use once on a fresh repo) and the workflow-only prompt (use when sprintctl is already initialized but you need to set up workflow patterns).

---

## When to use which prompt

| Situation | Use |
|-----------|-----|
| Fresh repo, no sprintctl, no structure | Main bootstrap prompt |
| sprintctl initialized, need to set up first sprint properly | Main bootstrap prompt (it's idempotent) |
| sprintctl running, need to shape backlog or start a new sprint | Workflow-only prompt |
| Repo has sprints but agent needs workflow orientation | Workflow-only prompt |

---

## Main Bootstrap Prompt

Paste this into an agent session when initializing sprintctl on a fresh or near-empty repository.

---

```
You are initializing the sprintctl + kctl workflow on this repository. Your job is to set up the execution control layer and knowledge layer from scratch, leaving the repo in a clean, working state with a first sprint ready to execute.

## Context

sprintctl manages sprint execution: sprints, tracks, items, claims, handoffs, and state transitions. kctl manages durable knowledge: decisions, patterns, risks, and lessons that should persist beyond a single sprint.

This is a local-first, repo-native workflow. No external project trackers. One developer plus sparse agent sessions.

## What to do

### 1. Assess the repo

Read the following if they exist:
- README.md
- AGENTS.md
- Any existing sprintctl config

Identify:
- What is this repo for?
- Is there an existing sprint? What state is it in?
- Are there open claims?
- What tracks make sense for this repo?

### 2. Initialize sprintctl (if not initialized)

```
sprintctl init
```

When prompted or configuring:
- Set the repo name to match the directory/project name
- Sprint naming convention: YYYY-SNN-<anchor>-<focus>-<phase>
- Default sprint length: 2 weeks (adjust if the project suggests otherwise)
- Knowledge path: docs/knowledge/
- Sprint render path: docs/sprint/

### 3. Initialize kctl (if not initialized)

```
kctl init
```

When prompted:
- Knowledge entries path: docs/knowledge/
- Candidate tag: kctl-candidate
- Review required before publish: true

### 4. Create the first sprint

Choose a sprint name using the naming convention. The anchor should ground the sprint metaphorically. The focus should describe what the sprint is actually doing. The phase should be `overture` for a first sprint (setup/initialization) or `build` for one that's jumping straight to implementation.

For a template/reference repo, first sprint: `YYYY-S01-hearth-workflow-overture`
For an application repo starting from scratch: `YYYY-S01-forge-schema-overture` or similar

```
sprintctl sprint create \
  --name 2026-S01-hearth-workflow-overture \
  --start 2026-03-30 \
  --end 2026-04-12
```

### 5. Create tracks

Based on the repo's purpose, create 3-5 tracks. More than 5 is usually a sign of over-structuring.

For this template repo:
```
sprintctl track create --sprint 2026-S01-hearth-workflow-overture --name workflow
sprintctl track create --sprint 2026-S01-hearth-workflow-overture --name docs
sprintctl track create --sprint 2026-S01-hearth-workflow-overture --name knowledge
sprintctl track create --sprint 2026-S01-hearth-workflow-overture --name tooling
```

For a typical application repo, tracks might be: `core`, `api`, `ui`, `infra`, `docs`

### 6. Create initial backlog items

Create 5-10 items that represent the actual work for this sprint. Be specific. Vague items like "set up project" are not useful. Specific items like "create sprintctl config with tracks for api, ui, infra" are useful.

```
sprintctl item create \
  --sprint 2026-S01-hearth-workflow-overture \
  --track workflow \
  --title "Define track taxonomy and claim policy in AGENTS.md" \
  --priority high

sprintctl item create \
  --sprint 2026-S01-hearth-workflow-overture \
  --track docs \
  --title "Write sprint-naming.md with anchor/focus/phase vocabulary" \
  --priority high
```

### 7. Create AGENTS.md if it doesn't exist

AGENTS.md is the agent entry point. It should cover:
- Repo classification and purpose
- Sprint naming convention in use
- Track taxonomy
- Claim policy
- Review policy
- Artifact paths
- Knowledge promotion policy
- How to start a new sprint
- How to hand off work
- What NOT to do

Use docs/agent-guidance/ from the sprintctl-bootstrap-template as a reference if available.

### 8. Create docs/sprint/current.md

Render the current sprint state:
```
sprintctl sprint render --output docs/sprint/current.md
```

Or create it manually if render is not available yet.

### 9. Verify the setup

```
sprintctl sprint current
sprintctl item list --sprint current
kctl list
```

Check that:
- Sprint is in active state
- Tracks exist and have items
- No stale claims from initialization
- AGENTS.md accurately describes the setup

## What success looks like

- `sprintctl sprint current` shows the active sprint with correct dates
- `sprintctl item list` shows 5+ shaped, specific items across tracks
- AGENTS.md exists and accurately describes the workflow for this repo
- `docs/sprint/current.md` exists and shows current sprint state
- `kctl list` works without errors

## What NOT to do

- Don't create placeholder items ("TODO: figure out what to do here")
- Don't over-track — 3-5 tracks is right for most repos
- Don't set up knowledge entries during bootstrap unless there's an actual decision to record
- Don't initialize and then immediately close the sprint
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
2. Run: sprintctl sprint current
3. Run: sprintctl item list --sprint current
4. Run: sprintctl claim list
5. Check for handoff notes on any claimed or in-progress items

## Identify your role for this session

Based on what you find, you are in one of these situations:

**A. Continuing claimed work:** A claim exists with your context or a handoff note directs you to continue. Read the handoff, assess state, and continue. Update the claim context if your approach has changed.

**B. Picking up open work:** Items exist that are open and unclaimed. Pick the highest priority item in your track, claim it, and begin.

**C. Shaping new work:** The backlog is thin or the sprint is complete. Shape the next sprint by reviewing what's needed, creating items, or running the bootstrap prompt if this is a fresh start.

**D. Knowledge work:** Items tagged kctl-candidate need promotion. Review candidates, draft knowledge entries, promote to reviewed, publish if appropriate.

## If shaping a new sprint

1. Review what was done in the last sprint: `sprintctl sprint list`
2. Identify carry-over items: `sprintctl item list --state open,blocked`
3. Choose a sprint name (see AGENTS.md or docs/sprint-naming.md)
4. Create the sprint and tracks
5. Add items — be specific, not vague
6. Carry over unfinished items: `sprintctl item migrate --to <new-sprint>`

## Execution norms

- Claim before you start any non-trivial work
- Leave a handoff note when you stop, even if you finished
- Tag kctl candidates during work, don't try to do knowledge work at the end of a long session
- Close items when done, block them when genuinely blocked (with a reason)

## Before you stop

- Release claims on anything you won't continue
- Leave handoff notes on anything in-progress
- Close completed items
- Tag any decisions or patterns worth preserving with kctl-candidate
```

---

## Expected outputs from the main bootstrap prompt

After running the bootstrap prompt on a fresh repo, you should have:

- `sprintctl` initialized with sprint naming convention configured
- `kctl` initialized with knowledge paths configured
- One active sprint with correct dates
- 3-5 tracks with 5-15 shaped items
- `AGENTS.md` with accurate content for this repo
- `docs/sprint/current.md` showing the current sprint state
- No stale claims or orphaned items

Total time for an agent to complete bootstrap: typically 10-20 minutes of session time, producing 5-10 files and 10-20 sprintctl/kctl commands executed.
