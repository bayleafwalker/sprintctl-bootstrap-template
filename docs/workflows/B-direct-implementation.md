# Workflow B: Direct Implementation

> **Template reference:** This bootstrap example is not canonical shared policy; consult `/projects/dev/agentops/templates/dispatch/` for current reusable workflow guidance.

**Purpose:** An agent claims a scoped sprint item, does the work, and closes or hands off cleanly.

This is the most common workflow. It applies to any implementation work within a defined track and scope that doesn't require architectural review.

---

## Normal path

```
pending item → claim → work → done (or handoff)
```

---

## Entry condition

- A shaped, pending, unclaimed item exists in the current sprint
- The item is within a track the agent can work in
- No blocker is listed on the item
- You have read AGENTS.md and understand the track taxonomy

---

## Step-by-step

### Step 1: Orient

```bash
# Check current sprint state
sprintctl sprint show --detail

# List pending items (unclaimed items are pending with no active claim)
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

Claim before starting any work. The claim context is the primary coordination signal.

```bash
sprintctl claim create \
  --item-id <item-id> \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-manual-session}" \
  --branch feat/handoff-patterns \
  --json
```

Save the returned `claim_id` and `claim_token` — you need both to prove ownership later.

Good claim context is implicit in your `--actor` + `--branch` combination. Use `item note` to
record intent before starting:

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Starting work: writing B-direct-implementation.md. Will cover claim pattern, work pattern, close/handoff. ~150 lines with concrete examples." \
  --actor claude-session-1
```

### Step 3: Move item to active

```bash
sprintctl item status \
  --id <item-id> \
  --status active \
  --actor claude-session-1 \
  --claim-id <claim-id> \
  --claim-token <claim-token>
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

Keep the claim alive for long sessions:

```bash
sprintctl claim heartbeat \
  --id <claim-id> \
  --claim-token <claim-token> \
  --actor claude-session-1
```

### Step 5: Close or hand off

**If done:**

```bash
# Record completion note
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Done. Created docs/workflows/B-direct-implementation.md. Covers claim, work, handoff patterns. 185 lines." \
  --actor claude-session-1

# Move item to done
sprintctl item status \
  --id <item-id> \
  --status done \
  --actor claude-session-1 \
  --claim-id <claim-id> \
  --claim-token <claim-token>

# Release claim
sprintctl claim release \
  --id <claim-id> \
  --claim-token <claim-token> \
  --actor claude-session-1
```

**If stopping mid-work (handoff to next session):**

```bash
# Record handoff note on the item
sprintctl item note \
  --id <item-id> \
  --type claim-handoff \
  --summary "Partial progress — steps 1-3 complete, step 4 not yet written." \
  --detail "Next: Write Step 4 section (close/handoff), then review whole doc for conciseness. File: docs/workflows/B-direct-implementation.md in progress." \
  --actor claude-session-1

# Transfer claim ownership to next session
sprintctl claim handoff \
  --id <claim-id> \
  --claim-token <claim-token> \
  --actor claude-session-2 \
  --mode rotate \
  --note "Step 4 not yet written. File in progress at docs/workflows/B-direct-implementation.md"
```

The handoff command mints a new token for the next session and returns it. The previous token is invalidated.

---

## Example: end-to-end doc item

**Item:** DOC-007 — "Write handoff-patterns.md with 4 concrete examples"

```bash
# Claim
sprintctl claim create \
  --item-id 7 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch docs/handoff-patterns \
  --json
# → claim_id: 3, claim_token: tok_abc123

# Move to active
sprintctl item status --id 7 --status active \
  --actor claude-session-1 --claim-id 3 --claim-token tok_abc123

# Record intent
sprintctl item note --id 7 --type decision \
  --summary "Writing handoff-patterns.md: 4 patterns: normal-completion, blocked-waiting, partial-progress, decision-needed. Each pattern: when to use, template, example. ~200 lines." \
  --actor claude-session-1

# ... do the work ...

# Done in one session
sprintctl item note --id 7 --type decision \
  --summary "Done. docs/agent-guidance/handoff-patterns.md created with all 4 patterns. 210 lines." \
  --actor claude-session-1

sprintctl item status --id 7 --status done \
  --actor claude-session-1 --claim-id 3 --claim-token tok_abc123

sprintctl claim release --id 3 --claim-token tok_abc123 --actor claude-session-1
```

**If stopping after 3 of 4 patterns:**

```bash
# Record handoff
sprintctl item note --id 7 --type claim-handoff \
  --summary "3 of 4 patterns written: normal-completion, blocked-waiting, partial-progress." \
  --detail "Next: Write decision-needed pattern (section 4), then add intro paragraph. File: docs/agent-guidance/handoff-patterns.md at line 147. No blockers." \
  --actor claude-session-1

# Transfer to next session
sprintctl claim handoff \
  --id 3 --claim-token tok_abc123 \
  --actor claude-session-2 --mode rotate \
  --note "3/4 patterns done. Need decision-needed pattern + intro."
# → new claim_token minted for claude-session-2
```

---

## Artifacts produced

- Work product (code, docs, config, etc.)
- `done` item with completion note, OR
- Handoff note with clear next steps and claim transferred to next session

---

## Where review applies

Direct implementation workflow does **not** require review unless:
- Item has a note tagged `review-required`
- Work involves schema changes
- Work affects AGENTS.md or sprint naming conventions

If review is required, use Workflow C instead.

---

## Common mistakes

**Forgetting to claim:** Another agent picks up the same item concurrently. Always claim first.

**Not recording intent:** Future you (or another agent) has no context. Add a note before starting.

**Not transferring the claim on handoff:** Leaving the old claim active blocks others from picking it up. Use `claim handoff` to rotate ownership, not just `claim release`.

**Closing with no note:** "Done" is not useful. "Done. Created X with Y. 185 lines covering Z." is useful.

**Recording decisions at the end:** Context degrades. Note decisions in the moment.
