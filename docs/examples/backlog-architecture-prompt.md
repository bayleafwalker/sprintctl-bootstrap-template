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
| sprintctl running, backlog has 20+ raw/unshaped items | Yes |
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

  sprintctl sprint current
  sprintctl sprint list
  sprintctl item list --sprint current
  sprintctl item list --state backlog,raw
  sprintctl claim list
  kctl list --state candidate

Also read:
  AGENTS.md
  docs/sprint/current.md (if it exists)

## Step 2: Assess what's happening

Answer these questions (you don't need to write them out, just know the answers):
- What sprint is active? How much time is left?
- How many items are open, in-progress, done, blocked?
- Are there claims? Are they fresh or stale?
- Is the sprint on track or has scope drifted?
- Are there backlog items that should be in the current sprint?
- Are there any kctl candidates that need attention?

## Step 3: Decide what this session is for

Based on your assessment, you're doing one of these:

**A. Planning the next sprint** — Current sprint is done or nearly done. Create the next sprint with a good name, tracks, and shaped items.

**B. Reshaping the current sprint** — Sprint is active but backlog is messy or scope has drifted. Clean up items, reprioritize, remove or defer things that won't happen.

**C. Shaping backlog items** — There are raw/unshaped items that need to become specific, actionable items before agents can work on them.

**D. Mixed** — Some combination of the above.

State which you're doing before you start.

## Step 4: Execute

For planning a new sprint:
- Choose a sprint name (YYYY-SNN-<anchor>-<focus>-<phase>)
- Check docs/sprint-naming.md for vocabulary
- Create the sprint with correct dates
- Create 3-5 tracks appropriate for the work ahead
- Create 8-15 shaped items — specific outcomes, not activities
- Carry over any unfinished items from the previous sprint
- Archive the previous sprint if complete

For reshaping:
- List all open items
- For each: is it specific enough? Is it still relevant? Is it the right priority?
- Update, split, defer, or close items as needed
- The sprint should end with 8-15 active items that are all specific and prioritized

For shaping backlog items:
- List raw/backlog items
- For each: shape it into a specific outcome, assign to a track, set priority
- If an item is too big, split it
- If an item doesn't belong in this sprint, defer it

## Step 5: Verify

After shaping:
  sprintctl item list --sprint current --sort priority
  sprintctl sprint status

The sprint should have:
- Items with specific, outcome-oriented titles
- All items assigned to tracks
- Priorities set (not all high — realistic prioritization)
- No items in 'raw' state

## Step 6: Update docs/sprint/current.md

  sprintctl sprint render --output docs/sprint/current.md

## What good looks like

A well-architected sprint:
- Has a name that reflects the actual work (not just 'sprint-2')
- Has 3-5 tracks that cover the work without artificial splits
- Has 8-15 items that are each completable in a single agent session
- Has items ordered by actual priority, not creation order
- Has no items that are "figure out X" or "investigate Y" — those are research items, not sprint items
  (If research is needed, the item should be: "Document decision on X: evaluate options A, B, C and write recommendation")
```

---

## Annotation

### "Decide what this session is for" section

This forces the agent to be explicit about what it's doing. Without this, agents tend to do a little of everything and produce an inconsistent sprint state. Declaring intent upfront also makes it easier to hand off if the session ends early.

### "Specific outcomes, not activities" emphasis

The most common mistake in backlog shaping is activity-titled items. "Research caching options" is an activity. "Document caching decision: evaluate Redis, Memcached, in-process; write recommendation in docs/decisions/caching.md" is an outcome-titled item that's also a research item but has a concrete deliverable.

### Sprint name guidance

The prompt points agents to `docs/sprint-naming.md` rather than embedding vocabulary inline. This keeps the prompt shorter and ensures the agent uses the actual vocabulary rather than inventing its own.

### Carry over and archive

Agents often forget to carry over unfinished items when planning a new sprint, leading to orphaned work. The explicit reminder to carry over and archive keeps the sprint history clean.

---

## Example session intro

When starting a backlog architecture session, it helps to prefix the prompt with context:

```
[Context: Sprint 2026-S01-hearth-workflow-overture is ending in 3 days.
6 of 12 items are done. 3 are blocked, 3 are open.
The next sprint should focus on implementing the API layer now that schema is done.
Suggest sprint name: 2026-S02-shore-api-build]

[Then paste the prompt above]
```
