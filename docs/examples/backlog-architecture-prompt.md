# Backlog Architecture Prompt

Use this prompt when a repo already has sprintctl initialized but needs:
- A new sprint architected and populated
- An existing backlog shaped and prioritized
- A mid-sprint reset after scope drift
- A fresh agent orienting to an active project

This is **not** the bootstrap prompt. Don't use it on a fresh repo. Use `docs/onboarding/sprintctl-bootstrap.md` for fresh repos.

---

## When to use this

| Situation | Use |
|-----------|-----|
| sprintctl initialized, current sprint ending, need to plan next sprint | Yes |
| sprintctl running, backlog has many unshaped pending items | Yes |
| Agent entering mid-sprint, needs to understand what's happening | Yes (orientation part) |
| Scope has drifted significantly, need to re-plan | Yes |
| Fresh repo, nothing initialized | No — use bootstrap prompt |
| Single item needs shaping | No — just shape the item directly |

---

## The Prompt

```
You are working in a repository that uses the sprintctl + kctl workflow. Your task is to assess the current state and architect the next sprint (or reshape the current one if needed).

## Step 1: Full orientation

Run these commands and read the output:

  source .envrc  (or: direnv allow)
  sprintctl sprint show --detail
  sprintctl sprint list --include-backlog
  sprintctl item list --sprint-id <current-sprint-id>
  sprintctl item list --sprint-id <backlog-sprint-id>
  sprintctl claim list-sprint --sprint-id <current-sprint-id>

Also read:
  AGENTS.md
  docs/sprint/current.md (if it exists)

## Step 2: Assess what's happening

Answer these questions (you don't need to write them out, just know the answers):
- What sprint is active? How much time is left?
- How many items are pending, active, done, blocked?
- Are there claims? Are they fresh or stale (run: sprintctl maintain check)?
- Is the sprint on track or has scope drifted?
- Are there backlog items that should be in the current sprint?
- Are there any pattern-noted or lesson-learned events worth promoting?

## Step 3: Decide what this session is for

Based on your assessment, you're doing one of these:

**A. Planning the next sprint** — Current sprint is done or nearly done. Create the next sprint with a good name, tracks, and shaped items.

**B. Reshaping the current sprint** — Sprint is active but scope has drifted. Reprioritize items, create missing ones, block or remove things that won't happen.

**C. Shaping backlog items** — There are pending items that need to become specific, actionable items before agents can work on them.

**D. Mixed** — Some combination of the above.

State which you're doing before you start.

## Step 4: Execute

For planning a new sprint:
- Choose a sprint name (YYYY-SNN-<anchor>-<focus>-<phase>)
- Check docs/sprint-naming.md for vocabulary
- Create the sprint:
    sprintctl sprint create --name <name> --status active --start <date> --end <date>
- Note the sprint ID
- Add 8-15 shaped items across 3-5 tracks:
    sprintctl item add --sprint-id <id> --track <name> --title "<outcome-focused title>"
    sprintctl item note --id <item-id> --type decision --summary "<scope, done condition>" --actor setup
- Carry over unfinished items from the previous sprint:
    sprintctl maintain carryover --from-sprint <old-id> --to-sprint <new-id>
- Archive the previous sprint if complete:
    sprintctl sprint status --id <old-id> --status closed
    sprintctl render > docs/sprint/archive/<old-sprint-name>.md

For reshaping:
- Read all items: sprintctl item list --sprint-id <id>
- For each: is it specific enough? Is it still relevant? Is it the right priority?
- Add notes to clarify scope: sprintctl item note --id <id> --type decision --summary "<refined scope>"
- Block stale items: sprintctl item status --id <id> --status blocked --actor setup --claim-id ... (if claimed) or just note the reason

For shaping backlog items:
- List pending items: sprintctl item list --sprint-id <backlog-id>
- For each: read it, add a shaping note with clear scope and done condition
- If an item is too big, split it with separate sprintctl item add calls

## Step 5: Verify

After shaping:
  sprintctl sprint show --detail
  sprintctl item list --sprint-id <new-sprint-id>
  sprintctl maintain check --sprint-id <new-sprint-id>

The sprint should have:
- Items with specific, outcome-oriented titles
- All items assigned to tracks
- A realistic number of items (8-15 for a 2-week sprint)
- No vague or unshapeable items

## Step 6: Update docs/sprint/current.md

  sprintctl render > docs/sprint/current.md

## What good looks like

A well-architected sprint:
- Has a name that reflects the actual work (not just 'sprint-2')
- Has 3-5 tracks that cover the work without artificial splits
- Has 8-15 items that are each completable in a single focused agent session
- Has items ordered by logical dependencies and priority
- Has no items that are just "figure out X" — if research is needed, the item should be: "Document decision on X: evaluate options A, B, C and write recommendation in docs/decisions/X.md"
```

---

## Annotation

### "Decide what this session is for" section

This forces the agent to be explicit about what it's doing. Without this, agents tend to do a little of everything and produce an inconsistent sprint state. Declaring intent upfront also makes it easier to hand off if the session ends early.

### "Specific outcomes, not activities" emphasis

The most common mistake in backlog shaping is activity-titled items. "Research caching options" is an activity. "Document caching decision: evaluate Redis, Memcached, in-process; write recommendation in docs/decisions/caching.md" is an outcome-titled item with a concrete deliverable.

### Sprint name guidance

The prompt points agents to `docs/sprint-naming.md` rather than embedding vocabulary inline. This keeps the prompt shorter and ensures the agent uses the actual vocabulary.

### Carryover and archive

Agents often forget to carry over unfinished items when planning a new sprint, leading to orphaned work. The explicit `maintain carryover` command handles this correctly.

---

## Example session intro

When starting a backlog architecture session, it helps to prefix the prompt with context:

```
[Context: Sprint 2026-S01-hearth-workflow-overture is ending in 3 days.
6 of 12 items are done. 3 are blocked, 3 are pending.
The next sprint should focus on implementing the API layer now that schema is done.
Suggested sprint name: 2026-S02-shore-api-build]

[Then paste the prompt above]
```
