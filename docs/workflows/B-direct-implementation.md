# Workflow B: Direct Implementation

> **Template reference:** This bootstrap example is not canonical shared policy; consult `/projects/dev/agentops/templates/dispatch/` for current reusable workflow guidance.

**Purpose:** An agent reserves a scoped sprint item, does the work, and closes or hands off cleanly.

This is the most common workflow. It applies to any implementation work within a defined track and scope that doesn't require architectural review.

---

## Normal path

```
pending item → reserve → work → done (or handoff)
```

---

## Entry condition

- A shaped, pending, unreserved item exists in the current sprint
- The item is within a track the agent can work in
- No blocker is listed on the item
- You have read AGENTS.md and understand the track taxonomy

---

## Step-by-step

### Step 1: Orient

```bash
# Check current sprint state
sprintctl sprint show --detail

# List pending items (unreserved items are pending with no active reservation)
sprintctl item list --sprint-id <sprint-id> --status pending

# Check for stale active items (someone started but didn't finish)
sprintctl item list --sprint-id <sprint-id> --status active

# Read the item details including any handoff notes
sprintctl item show --id <item-id>
```

Check for:
- Any notes from a previous agent
- Related items that affect this one
- Whether a `review-required` note exists on the item

### Step 2: Claim

Reserve before starting any work. The reservation is the primary coordination signal.

```bash
sprintctl reservation reserve \
  --item-id <item-id> \
  --actor claude-session-1 \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --json
```

Save the returned reservation `id`. There is no token: a reservation carries no secret and proves nothing, so there is nothing to store securely or lose.

Good coordination context is implicit in your `--actor` + `--branch` combination. Use `item note` to
record intent before starting:

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Starting work: writing B-direct-implementation.md. Will cover reservation pattern, work pattern, close/handoff. ~150 lines with concrete examples." \
  --actor claude-session-1
```

### Step 3: Move item to active

```bash
REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status \
  --id <item-id> \
  --status active \
  --actor claude-session-1 \
  --expected-revision "$REV"
```

### Step 4: Work

Do the work. Record non-obvious decisions as you go — not at the end:

```bash
# When you make a decision worth preserving
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Decided to show commands in bash blocks rather than inline — copy-paste usability matters more than visual flow in agent guidance docs" \
  --actor claude-session-1
```

Refresh the activity clock during long sessions (optional — nothing expires):

```bash
sprintctl reservation touch \
  --id <reservation-id> \
  --session-id "${CODEX_THREAD_ID:-session-1}"
```

### Step 5: Close or hand off

**If done:**

```bash
# Record completion note
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Done. Created docs/workflows/B-direct-implementation.md. Covers reservation, work, handoff patterns. 185 lines." \
  --actor claude-session-1

# Move item to done
REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status \
  --id <item-id> \
  --status done \
  --actor claude-session-1 \
  --expected-revision "$REV"

# Release the reservation
sprintctl reservation release \
  --id <reservation-id> \
  --actor claude-session-1
```

**If stopping mid-work (handoff to next session):**

```bash
# Record handoff note on the item
sprintctl item note \
  --id <item-id> \
  --type update \
  --summary "Partial progress — steps 1-3 complete, step 4 not yet written." \
  --detail "Next: Write Step 4 section (close/handoff), then review whole doc for conciseness. File: docs/workflows/B-direct-implementation.md in progress." \
  --actor claude-session-1

# Reassign the reservation to the next session
sprintctl reservation reassign \
  --id <reservation-id> \
  --actor claude-session-2 \
  --session-id <next-session-id>
```

The handoff command mints a new token for the next session and returns it. The previous token is invalidated.

---

## Example: end-to-end doc item

**Item:** DOC-007 — "Write handoff-patterns.md with 4 concrete examples"

```bash
# Claim
sprintctl reservation reserve \
  --item-id 7 \
  --actor claude-session-1 \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --json
# → {"id": 3, "state": "active", ...}

# Move to active
REV=$(sprintctl item show --id 7 --json | jq -r '.status_revision')
sprintctl item status --id 7 --status active \
  --actor claude-session-1 \
  --expected-revision "$REV"

# Record intent
sprintctl item note --id 7 --type decision \
  --summary "Writing handoff-patterns.md: 4 patterns: normal-completion, blocked-waiting, partial-progress, decision-needed. Each pattern: when to use, template, example. ~200 lines." \
  --actor claude-session-1

# ... do the work ...

# Done in one session
sprintctl item note --id 7 --type decision \
  --summary "Done. docs/agent-guidance/handoff-patterns.md created with all 4 patterns. 210 lines." \
  --actor claude-session-1

REV=$(sprintctl item show --id 7 --json | jq -r '.status_revision')
sprintctl item status --id 7 --status done \
  --actor claude-session-1 \
  --expected-revision "$REV"

sprintctl reservation release --id 3 --actor claude-session-1
```

**If stopping after 3 of 4 patterns:**

```bash
# Record handoff
sprintctl item note --id 7 --type update \
  --summary "3 of 4 patterns written: normal-completion, blocked-waiting, partial-progress." \
  --detail "Next: Write decision-needed pattern (section 4), then add intro paragraph. File: docs/agent-guidance/handoff-patterns.md at line 147. No blockers." \
  --actor claude-session-1

# Transfer to next session
sprintctl reservation reassign \
  --id 3 \
  --actor claude-session-2 \
  --session-id <next-session-id>
# → same reservation id, actor is now claude-session-2
```

---

## Artifacts produced

- Work product (code, docs, config, etc.)
- `done` item with completion note, OR
- Handoff note with clear next steps and the reservation reassigned to the next session

---

## Where review applies

Direct implementation workflow does **not** require review unless:
- Item has a note tagged `review-required`
- Work involves schema changes
- Work affects AGENTS.md or sprint naming conventions

If review is required, use Workflow C instead.

---

## Common mistakes

**Forgetting to reserve:** Another agent picks up the same item concurrently. Always reserve first.

**Not recording intent:** Future you (or another agent) has no context. Add a note before starting.

**Not moving the reservation on handoff:** Leaving it naming the old session misleads whoever looks next. Use `reservation reassign` to transfer it in place, rather than releasing and hoping the next session reserves.

**Closing with no note:** "Done" is not useful. "Done. Created X with Y. 185 lines covering Z." is useful.

**Recording decisions at the end:** Context degrades. Note decisions in the moment.
