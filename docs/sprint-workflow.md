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
- A GitHub issue (if the project uses them as inputs)
- A raw text file in the repo

### Expected sprintctl/kctl actions
```bash
# Capture as a raw backlog item (unshaped)
sprintctl item create \
  --sprint current \
  --track <appropriate-track> \
  --title "<idea as a short statement>" \
  --state backlog \
  --note "Raw capture: <longer description or context>"

# Alternatively, add to a staging track if the idea needs shaping before assigning
sprintctl item create --track backlog --title "..." --state raw
```

No kctl actions at this stage. Ideas are not knowledge.

### When to stop / hand off
Stop when the idea is captured. Don't shape it now unless you have full context. A badly shaped item is worse than an unshaped one.

### Success criteria
- The idea is captured somewhere in sprintctl with enough detail that you (or another agent) can understand it cold
- It is not lost

---

## Stage 2: Backlog Shaping

**What this is:** Converting raw ideas and requirements into specific, actionable sprint items with clear scope and acceptance criteria.

### Entry condition
- One or more raw/backlog items exist that need shaping
- OR a new sprint is being created and needs to be populated
- OR a planning session is happening to review and refine scope

### Typical artifacts
- Shaped sprint items with clear titles, descriptions, and acceptance criteria
- Updated item priorities
- Items assigned to tracks
- Sprint with a defined date range and name

### Expected sprintctl/kctl actions
```bash
# Shape an existing raw item
sprintctl item update <item-id> \
  --title "<specific, scoped title>" \
  --description "<what done looks like>" \
  --priority <high|medium|low> \
  --track <track-name> \
  --state open

# Review existing backlog
sprintctl item list --state backlog,raw

# Create a shaped sprint
sprintctl sprint create \
  --name 2026-S02-forge-schema-weave \
  --start 2026-04-14 \
  --end 2026-04-27

# Move items to new sprint
sprintctl item migrate --item <id> --to 2026-S02-forge-schema-weave
```

### When to stop / hand off
Stop when:
- All items in the sprint are specific enough that an agent could pick one up and know what to do
- Priorities are set
- The sprint has a realistic scope (not overloaded)

Don't keep shaping indefinitely. "Good enough to start" is the target.

### Success criteria
- Sprint has 5-15 shaped items (more than 15 usually means scope creep)
- Each item has a clear title that describes the outcome, not the activity
- No item is vague enough to be interpreted multiple ways
- Items are assigned to tracks and have priorities

---

## Stage 3: Direct Claimed Work

**What this is:** An agent (or the developer) picks up a shaped item, claims it, does the work, and closes or hands off.

### Entry condition
- A shaped, open, unclaimed item exists in the current sprint
- The agent has read AGENTS.md and checked current sprint state
- The agent understands the track and scope of the item

### Typical artifacts
- Claim with agent context
- Code, docs, config, or other work product
- Handoff note (if not completing in one session)
- Closed item (if completing in one session)

### Expected sprintctl/kctl actions
```bash
# Claim the item before starting
sprintctl claim create \
  --item <item-id> \
  --context "Implementing X by doing Y. Will create files A, B, C."

# Update claim if approach changes mid-work
sprintctl claim update --item <item-id> \
  --context "Changed approach: doing Z instead of Y because <reason>"

# Tag kctl candidates during work (don't wait until the end)
sprintctl item tag <item-id> --add kctl-candidate \
  --note "Decision: chose approach X over Y because <rationale>"

# Close when done
sprintctl item close <item-id> --note "Done. <brief summary of what was produced>"

# OR hand off if stopping mid-work
sprintctl item handoff <item-id> --note "
  Status: <what's done>
  Next: <what to do next>
  Blockers: none
"

# OR block if genuinely blocked
sprintctl item block <item-id> --reason "<what's blocking and what's needed to unblock>"
```

### When to stop / hand off
Stop and hand off when:
- The session is ending and the item isn't done
- A dependency or blocker appears that you can't resolve now
- Scope has grown beyond the original item (create a new item for the overflow)

### Success criteria
- Item is closed with a completion note, OR
- Item has a handoff note that a fresh agent could use to continue, OR
- Item is blocked with a specific, actionable reason

---

## Stage 4: Optional Review

**What this is:** For wider-scope, architectural, or risky changes, an explicit review step before the work is considered done.

### Entry condition
- Item is tagged `review-required`
- OR work involves schema changes, architectural decisions, or changes to AGENTS.md/workflow contracts
- OR the working agent flagged the item for review before handing off

### Typical artifacts
- Review comment on the item
- Updated handoff note with review outcome
- New items created from review findings
- Item closed or returned to open

### Expected sprintctl/kctl actions
```bash
# Review the work (read files, check diffs, evaluate approach)
# Add review comment
sprintctl item comment <item-id> --note "Review: <findings, concerns, approvals>"

# If approved: close the item
sprintctl item close <item-id> --note "Reviewed and approved. <summary>"

# If changes needed: return to open
sprintctl item update <item-id> --state open \
  --note "Review: needs changes. <specific changes required>"

# If the review surfaced a new architectural item
sprintctl item create \
  --track workflow \
  --title "Address: <finding from review>" \
  --note "Surfaced during review of <item-id>"
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
| Item explicitly tagged review-required | Required |

### When to stop / hand off
Stop when:
- Review is complete and outcome is documented
- Any follow-up items have been created

### Success criteria
- Review outcome is recorded on the item
- Item is closed or has clear next steps
- Findings that affect future work are captured as new items or kctl candidates

---

## Stage 5: Knowledge Extraction / Publication

**What this is:** Durable decisions, patterns, and lessons from sprint work get promoted to kctl as permanent knowledge entries.

### Entry condition
- Sprint work has produced decisions, patterns, or lessons worth preserving
- Items tagged `kctl-candidate` exist and are ready for review
- OR a sprint is wrapping up and knowledge capture is the final step

### Typical artifacts
- kctl candidate entries (tagged on items during work)
- Reviewed knowledge entries
- Published knowledge entries in `docs/knowledge/`
- Updated sprint summary referencing knowledge promotions

### Expected sprintctl/kctl actions
```bash
# List candidates from current sprint
kctl list --state candidate --sprint current

# Review a candidate and draft the entry
kctl draft <slug>

# Promote to reviewed
kctl promote <slug>

# Publish (move to docs/knowledge/)
kctl publish <slug>

# Reference knowledge from a future sprint item
sprintctl item create \
  --title "..." \
  --note "See knowledge: docs/knowledge/<slug>.md"

# Archive the sprint when complete
sprintctl sprint archive --render-output docs/sprint/archive/2026-S01-hearth-workflow-overture.md
```

### What qualifies for promotion

**Promote:**
- Decisions with rationale (especially ones that could be revisited)
- Patterns that worked and are reusable
- Accepted risks (what was accepted and why)
- Lessons that will likely recur

**Don't promote:**
- Implementation notes ("I used a for loop here")
- Dead ends that are genuinely done
- Mechanical progress
- Things obvious from reading the code or docs

### When to stop / hand off
Stop when all candidates from the sprint have been reviewed and either promoted/published or consciously rejected.

### Success criteria
- All `kctl-candidate` tagged items have been processed
- Published entries are in `docs/knowledge/` and are self-contained
- Sprint is archived if complete
- Next sprint can reference relevant published entries
