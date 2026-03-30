# Workflow B: Direct Implementation

**Purpose:** An agent claims a scoped sprint item, does the work, and closes or hands off cleanly.

This is the most common workflow. It applies to any implementation work within a defined track and scope that doesn't require architectural review.

---

## Normal path

```
open item → claim → work → close (or handoff)
```

---

## Entry condition

- A shaped, open, unclaimed item exists in the current sprint
- The item is within a track the agent can work in
- No blocker is listed on the item
- You have read AGENTS.md and understand the track taxonomy

---

## Step-by-step

### Step 1: Orient

```bash
# Check current sprint state
sprintctl sprint current

# Find open, unclaimed items
sprintctl item list --sprint current --state open --unclaimed

# Read the item details
sprintctl item show <item-id>
```

Check for:
- Any handoff notes from a previous agent
- Related items that affect this one
- Tags (especially `review-required` or `kctl-candidate`)

### Step 2: Claim

Claim before starting any work. The claim context should describe your approach, not just "working on this."

```bash
sprintctl claim create \
  --item <item-id> \
  --context "Writing the B-direct-implementation workflow doc. Will cover: claim pattern, work pattern, close/handoff pattern. Target: 150-200 lines, concrete examples throughout."
```

Good claim context includes:
- What you're going to produce
- Any approach decisions you've already made
- Estimated scope (rough is fine)

### Step 3: Work

Do the work. Update the claim context if your approach changes significantly.

```bash
# If approach changes materially
sprintctl claim update \
  --item <item-id> \
  --context "Changed approach: splitting the doc into two files because the content for claimed/unclaimed scenarios is substantially different. Creating B-direct-implementation.md and B-direct-implementation-unclaimed.md"
```

**Tag kctl candidates as you go**, not at the end:

```bash
# When you make a non-obvious decision
sprintctl item tag <item-id> --add kctl-candidate
sprintctl item comment <item-id> \
  --note "kctl-candidate: decided to show commands in bash blocks rather than inline because copy-paste usability matters more than visual flow in agent guidance docs"
```

### Step 4: Close or hand off

**If done:**

```bash
sprintctl item close <item-id> \
  --note "Done. Created docs/workflows/B-direct-implementation.md with claim, work, and handoff patterns. 185 lines."
```

**If stopping mid-work (handoff):**

```bash
sprintctl item handoff <item-id> --note "
  Status: Draft complete through Step 3. Step 4 (close/handoff) not written yet.
  Next: Write Step 4 section, then review the whole doc for conciseness.
  Files: docs/workflows/B-direct-implementation.md (in progress)
  Blockers: none
"
# Release the claim so the next agent can pick it up
sprintctl claim release --item <item-id>
```

---

## Example claim / handoff pattern

This is a concrete end-to-end example for a docs item.

**Item:** `DOC-007 — Write handoff-patterns.md with 4 concrete examples`

**Claim:**
```bash
sprintctl claim create \
  --item DOC-007 \
  --context "Writing handoff-patterns.md. Will include 4 patterns: normal-completion, blocked-waiting, partial-progress, decision-needed. Each pattern: when to use, template, example. Targeting ~200 lines."
```

**Work:** Create the file, write the content.

**Close (if done in one session):**
```bash
sprintctl item close DOC-007 \
  --note "Done. docs/agent-guidance/handoff-patterns.md created with all 4 patterns. 210 lines."
```

**Handoff (if stopping mid-work):**
```bash
sprintctl item handoff DOC-007 --note "
  Status: 3 of 4 patterns written (normal-completion, blocked-waiting, partial-progress).
  Next: Write decision-needed pattern (section 4), then add intro paragraph.
  File: docs/agent-guidance/handoff-patterns.md — currently at line 147.
  Blockers: none — the pattern is clear from the first three examples.
"
sprintctl claim release --item DOC-007
```

---

## Artifacts produced

- Work product (code, docs, config, etc.)
- Closed item with completion note, OR
- Handoff note with clear next steps and released claim

---

## Where review applies

Direct implementation workflow does **not** require review unless:
- Item is tagged `review-required`
- Work involves schema changes
- Work affects AGENTS.md or sprint naming conventions

If review is required, use Workflow C instead.

---

## Common mistakes

**Forgetting to claim:** Another agent picks up the same item concurrently. Always claim first.

**Vague claims:** "Working on docs" gives no information. Future you (or another agent) can't use it.

**Not releasing claims on handoff:** The claim holds the item, blocking others from picking it up. Release claims when you hand off.

**Closing with no note:** "Done" is not a useful close note. "Done. Created X with Y. 185 lines covering Z." is useful.

**Forgetting kctl tags:** Making a non-obvious decision and not tagging it. It will be lost. Tag in the moment.
