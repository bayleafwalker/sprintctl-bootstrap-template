# Sprint Workflow Contracts

The core loop: **idea/concept → backlog creation → direct agentic work → optional review → knowledge extraction**

Five stages. Each has a defined entry condition, typical artifacts, expected actions, and success criteria.

---

## Stage 1: Idea / Concept Capture

**What this is:** An unstructured observation, idea, or requirement that needs to exist somewhere before it disappears.

### Entry condition
An idea, requirement, or observation exists in someone's head, a conversation, or a scratchpad. It has not yet been shaped into a sprint item.

### Typical artifacts
- A bullet in a notes file
- A conversation log
- A raw text capture anywhere

### Expected sprintctl actions

```bash
# Find the active sprint ID
sprintctl sprint show --json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])"

# Capture as a pending item (pending = not yet started)
sprintctl item add \
  --sprint-id <sprint-id> \
  --track <appropriate-track> \
  --title "<idea as a short statement>"

# Add context as a note
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Raw capture: <longer description or context>" \
  --actor agent
```

No kctl actions at this stage. Ideas are not knowledge.

### When to stop
Stop when the idea is captured. Don't shape it now unless you have full context.

### Success criteria
- The idea is captured in sprintctl with enough detail that you (or another agent) can understand it cold
- It is not lost

---

## Stage 2: Backlog Shaping

**What this is:** Converting raw ideas and requirements into specific, actionable sprint items with clear scope and acceptance criteria.

### Entry condition
- One or more pending items exist that need shaping
- OR a new sprint is being created and needs to be populated
- OR a planning session is reviewing and refining scope

### Typical artifacts
- Items with descriptive titles and noted scope
- Sprint with a defined date range and name

### Expected sprintctl actions

```bash
# Review pending items to shape
sprintctl item list --sprint-id <sprint-id> --status pending

# Read an item to understand what was captured
sprintctl item show --id <item-id>

# Add shaping context via a note
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Shaped: <specific scope, what done looks like, any constraints>" \
  --actor agent

# Create a new sprint for shaped work
sprintctl sprint create \
  --name 2026-S02-forge-schema-weave \
  --status active \
  --start 2026-04-14 \
  --end 2026-04-27

# Add shaped items directly to the new sprint
sprintctl item add \
  --sprint-id <new-sprint-id> \
  --track <track-name> \
  --title "<specific, outcome-focused title>"
```

### When to stop
Stop when:
- All items in the sprint are specific enough that an agent could pick one up and know what to do
- The sprint has realistic scope (not overloaded)

### Success criteria
- Sprint has 5-15 shaped items
- Each item has a clear title that describes the outcome, not the activity
- No item is vague enough to be interpreted multiple ways
- Items are assigned to tracks

---

## Stage 3: Direct Claimed Work

**What this is:** An agent (or the developer) picks up a shaped item, claims it, does the work, and closes or hands off.

### Entry condition
- A shaped, pending, unclaimed item exists in the current sprint
- The agent has read AGENTS.md and checked current sprint state
- The agent understands the track and scope of the item

### Typical artifacts
- Active claim with agent identity
- Code, docs, config, or other work product
- Completion note on the item, OR
- Handoff events and transferred claim

### Expected sprintctl actions

```bash
# Claim the item before starting (save claim_id and claim_token from output)
sprintctl claim create \
  --item-id <item-id> \
  --actor <session-id> \
  --runtime-session-id "${CODEX_THREAD_ID:-manual-session}" \
  --branch feat/your-work \
  --json

# Move item to active (requires token proof)
sprintctl item status --id <item-id> --status active \
  --actor <session-id> --claim-id <claim-id> --claim-token <claim-token>

# Record intent and non-obvious decisions during work
sprintctl item note --id <item-id> --type decision \
  --summary "<decision and rationale>" \
  --actor <session-id>

# If done:
sprintctl item note --id <item-id> --type decision \
  --summary "Done: <brief summary of what was produced>" \
  --actor <session-id>
sprintctl item status --id <item-id> --status done \
  --actor <session-id> --claim-id <claim-id> --claim-token <claim-token>
sprintctl claim release --id <claim-id> --claim-token <claim-token>

# If handing off:
sprintctl item note --id <item-id> --type claim-handoff \
  --summary "Status: <what's done>. Next: <what to do next>." \
  --detail "<file locations, approach notes, blockers if any>" \
  --actor <session-id>
sprintctl claim handoff --id <claim-id> --claim-token <claim-token> \
  --actor <next-session-id> --mode rotate

# If blocked:
sprintctl item note --id <item-id> --type decision \
  --summary "Blocked: <reason, what's needed to unblock>" --actor <session-id>
sprintctl item status --id <item-id> --status blocked \
  --actor <session-id> --claim-id <claim-id> --claim-token <claim-token>
sprintctl claim release --id <claim-id> --claim-token <claim-token>
```

### When to stop / hand off
Stop and hand off when:
- The session is ending and the item isn't done
- A blocker appears that you can't resolve now
- Scope has grown beyond the original item (create a new item for the overflow)

### Success criteria
- Item is done with a completion note, OR
- Item has a handoff note and claim transferred to the next session, OR
- Item is blocked with a specific, actionable reason

---

## Stage 4: Optional Review

**What this is:** For wider-scope, architectural, or risky changes, an explicit review step before the work is considered done.

### Entry condition
- Item has a `review-required` note
- OR work involves schema changes, architectural decisions, or changes to AGENTS.md/workflow contracts
- OR the working agent flagged the item for review

### Typical artifacts
- Review note on the item
- Item closed or returned to pending

### Expected sprintctl actions

```bash
# Read the item and its full event history
sprintctl item show --id <item-id>

# Claim for review
sprintctl claim create --item-id <item-id> --actor reviewer --type review --json

# Move to active for review work
sprintctl item status --id <item-id> --status active \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>

# Record review outcome
sprintctl item note --id <item-id> --type decision \
  --summary "Review: Approved. <summary of findings>" --actor reviewer
# OR
sprintctl item note --id <item-id> --type decision \
  --summary "Review: Changes needed. <specific changes required>" --actor reviewer

# If approved: close
sprintctl item status --id <item-id> --status done \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>
sprintctl claim release --id <review-claim-id> --claim-token <review-claim-token>

# If changes needed: return to pending
sprintctl item status --id <item-id> --status pending \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>
sprintctl claim release --id <review-claim-id> --claim-token <review-claim-token>
```

### When review is required vs. optional

| Situation | Review |
|-----------|--------|
| Single-track doc addition | Optional |
| Schema changes | Required |
| AGENTS.md changes | Required |
| New track creation | Required |
| Cross-track architectural change | Required |
| Routine implementation in defined scope | Optional |

### Success criteria
- Review outcome is recorded on the item
- Item is closed or has clear next steps
- Findings that affect future work are captured as new items or knowledge candidates

---

## Stage 5: Knowledge Extraction / Publication

**What this is:** Durable decisions, patterns, and lessons from sprint work get promoted to `docs/knowledge/` as permanent entries.

### Entry condition
- Sprint work has produced decisions or patterns worth preserving (recorded as `pattern-noted`, `lesson-learned`, or `decision` events)
- OR a sprint is wrapping up and knowledge capture is the final step

### Typical artifacts
- Published knowledge entries in `docs/knowledge/`
- Archived sprint rendered to `docs/sprint/archive/`

### Expected sprintctl actions

```bash
# Collect candidates from sprint events
sprintctl event list --sprint-id <sprint-id> --type pattern-noted
sprintctl event list --sprint-id <sprint-id> --type lesson-learned

# Run preflight before knowledge work
sprintctl maintain check --sprint-id <sprint-id>

# (If kctl is available, it reads these events directly)
# kctl list --state candidate

# After publishing knowledge, render and archive the sprint
sprintctl render > docs/sprint/archive/2026-S01-hearth-workflow-overture.md

# Close the sprint
sprintctl sprint status --id <sprint-id> --status closed
```

### What qualifies for promotion

**Promote:**
- Decisions with rationale (especially ones that could be revisited)
- Patterns that worked and are reusable
- Accepted risks (what was accepted and why)
- Lessons that will likely recur

**Don't promote:**
- Implementation notes ("I used a for loop here")
- Dead ends that are genuinely over
- Mechanical progress
- Things obvious from reading the code

### Success criteria
- All candidate events from the sprint have been reviewed
- Published entries are in `docs/knowledge/` and are self-contained
- Sprint is archived
- Next sprint can reference relevant published entries
