# Bootstrap Prompt (Clean Copy-Paste Form)

This is the main bootstrap prompt in clean form, with annotation on key sections. Use this when you need to paste it into an agent session without the surrounding documentation from `docs/onboarding/sprintctl-bootstrap.md`.

For full context on when to use this vs. the workflow-only prompt, see `docs/onboarding/sprintctl-bootstrap.md`.

---

## The Prompt

```
You are initializing the sprintctl + kctl workflow on this repository. Your job is to set up the execution control layer and knowledge layer from scratch, leaving the repo in a clean, working state with a first sprint ready to execute.

sprintctl manages sprint execution: sprints, tracks, items, claims, handoffs, and state transitions. kctl manages durable knowledge: decisions, patterns, risks, and lessons that should persist beyond a single sprint. This is a local-first, repo-native workflow. No external project trackers. One developer plus sparse agent sessions.

NOTE: sprintctl has no `init` command. The database is created automatically on first use. Set SPRINTCTL_DB to scope it to this repo.

## Step 1: Set up DB scope

Create an .envrc file:
  echo 'export SPRINTCTL_DB="${PWD}/.sprintctl/sprintctl.db"' > .envrc
  source .envrc

Add to .gitignore:
  .sprintctl/
  handoff-*.json
  sprint-*.json

## Step 2: Assess

Read README.md, AGENTS.md if it exists. Run: sprintctl sprint show (to see if a sprint already exists). Identify: what is this repo for, is there an existing sprint, what tracks make sense.

## Step 3: Create first sprint

Name using the convention: YYYY-SNN-<anchor>-<focus>-<phase>
For initial setup use phase `overture`. Example: 2026-S01-hearth-workflow-overture

  sprintctl sprint create --name <name> --status active --start <today> --end <today+14>

Note the sprint ID from the output.

## Step 4: Create shaped items

Create 8-12 specific, actionable items using: sprintctl item add --sprint-id <id> --track <name> --title "<outcome-focused title>"

Tracks are created implicitly — no separate track creation step needed. Use 3-5 tracks.

Add context notes: sprintctl item note --id <id> --type decision --summary "<scope, done condition>" --actor setup

## Step 5: Create AGENTS.md if it doesn't exist

Must cover: repo purpose, sprint naming in use, track taxonomy, claim policy, review policy, artifact paths, knowledge promotion policy, source-of-truth order, what NOT to do.

## Step 6: Create directory structure and render sprint

  mkdir -p docs/sprint/archive docs/knowledge docs/agent-guidance
  sprintctl render > docs/sprint/current.md

## Step 7: Verify

Run: sprintctl sprint show, sprintctl item list --sprint-id <id>, sprintctl claim list-sprint --sprint-id <id>, sprintctl maintain check --sprint-id <id>

Confirm: active sprint with dates, 8+ items, AGENTS.md exists, docs/sprint/current.md exists, no stale claims.
```

---

## Annotation

### "Assess first" section

This is the most important part. An agent that initializes without reading what exists will create duplicate sprints or overwrite config. Always assess before creating anything.

### "No init command" note

sprintctl does not have an `init` command. Agents sometimes hallucinate one. The database is created automatically on first use. The only setup needed is the `SPRINTCTL_DB` env var for per-project scoping.

### Sprint naming

The prompt specifies `hearth-workflow-overture` as a default but acknowledges this needs to be adapted. Agents should choose an anchor that fits the repo's actual energy, not just copy the example.

### Track count guidance

"3-5 tracks" is explicit because agents tend to over-track. Tracks are created implicitly via `--track <name>` on item creation — no separate creation command needed.

### Items requirement: "Not placeholders"

Agents tend to create items like "TODO: figure out auth" which are useless. Sprint items must have outcome-focused titles and enough note context to be claimable.

### AGENTS.md as non-optional

Agents entering a repo without AGENTS.md have no coordination context. The bootstrap prompt makes AGENTS.md creation explicit so it doesn't get skipped.

### Verify step

Bootstrap is not done until the verification commands pass. The explicit verification step ensures the output is actually usable.

---

## Adapting the prompt

When pasting this into a session for a specific repo, prepend context:

```
[Context: This is a repo for <brief description>. It uses <tech stack>. The primary
tracks should probably be <tracks>. Use <year>-S<NN> for sprint numbering.]

[Then paste the prompt above]
```

This helps the agent make better choices for track names and item content without having to reverse-engineer the repo from scratch.
