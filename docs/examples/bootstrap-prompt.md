# Bootstrap Prompt (Clean Copy-Paste Form)

This is the main bootstrap prompt in clean form, with annotation on key sections. Use this when you need to paste it into an agent session without the surrounding documentation from `docs/onboarding/sprintctl-bootstrap.md`.

For full context on when to use this vs. the workflow-only prompt, see `docs/onboarding/sprintctl-bootstrap.md`.

---

## The Prompt

```
You are initializing the sprintctl + kctl workflow on this repository. Your job is to set up the execution control layer and knowledge layer from scratch, leaving the repo in a clean, working state with a first sprint ready to execute.

sprintctl manages sprint execution: sprints, tracks, items, claims, handoffs, and state transitions. kctl manages durable knowledge: decisions, patterns, risks, and lessons that should persist beyond a single sprint. This is a local-first, repo-native workflow. No external project trackers. One developer plus sparse agent sessions.

## Step 1: Assess

Read README.md, AGENTS.md if it exists, and any existing sprintctl config. Identify: what is this repo for, is there an existing sprint, are there open claims, what tracks make sense.

## Step 2: Initialize sprintctl (if not initialized)

Run: sprintctl init
Configure: repo name, sprint naming convention YYYY-SNN-<anchor>-<focus>-<phase>, default sprint 14 days, sprint render path docs/sprint/, knowledge path docs/knowledge/

## Step 3: Initialize kctl (if not initialized)

Run: kctl init
Configure: knowledge path docs/knowledge/, candidate tag kctl-candidate, review-before-publish true

## Step 4: Create first sprint

Name it using the convention. For initial setup: YYYY-S01-hearth-workflow-overture. For jumping straight to implementation: YYYY-S01-forge-<focus>-overture. Use the current year and next sprint number.

sprintctl sprint create --name <name> --start <today> --end <today+14>

## Step 5: Create tracks

3-5 tracks based on repo purpose. For template/reference: workflow, docs, knowledge, tooling. For app repos: core, api, ui, infra, docs (adjust to fit).

sprintctl track create --sprint <sprint-name> --name <track>

## Step 6: Create shaped items

Create 8-12 specific, actionable items. Not placeholders. Each item title should describe the outcome, not the activity. Assign each to a track with a priority.

## Step 7: Create AGENTS.md

If AGENTS.md doesn't exist, create it. It must cover: repo purpose, sprint naming in use, track taxonomy, claim policy, review policy, artifact paths, knowledge promotion policy, how to start a sprint, how to hand off, what NOT to do.

## Step 8: Render current sprint

sprintctl sprint render --output docs/sprint/current.md

## Step 9: Verify

Run: sprintctl sprint current, sprintctl item list --sprint current, kctl list. Confirm: active sprint with dates, 8+ items, AGENTS.md exists, docs/sprint/current.md exists, no stale claims.
```

---

## Annotation

### "Assess first" section

This is the most important part. An agent that initializes without reading what exists will clobber config or create duplicate sprints. Always assess before initializing.

### Sprint naming

The prompt specifies `YYYY-SNN-hearth-workflow-overture` as a default but acknowledges this needs to be adapted. Agents should choose an anchor that fits the repo's actual energy, not just copy the example.

### Track count guidance

"3-5 tracks" is explicit because agents tend to over-track. The example track sets are starting points. The agent should adapt based on the repo.

### Items requirement: "Not placeholders"

This instruction prevents agents from creating items like "TODO: figure out auth" which are worse than having no item at all. The items created during bootstrap should be the actual first sprint's work.

### AGENTS.md as non-optional

Agents entering a repo without AGENTS.md have no coordination context. The bootstrap prompt makes AGENTS.md creation explicit so it doesn't get skipped.

### Verify step

Bootstrap is not done until the verification commands pass. Agents sometimes skip this — the explicit verification step in the prompt ensures the output is actually usable.

---

## Adapting the prompt

When pasting this into a session for a specific repo, you can prepend context:

```
[Context: This is a repo for <brief description>. It uses <tech stack>. The primary
tracks should probably be <tracks>. Use <year>-S<NN> for sprint numbering.]

[Then paste the prompt above]
```

This helps the agent make better choices for track names and item content without having to reverse-engineer the repo from scratch.
