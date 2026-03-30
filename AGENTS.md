# AGENTS.md — sprintctl-bootstrap-template

## Repo classification

**Type:** bootstrap template / reference implementation
**Purpose:** demonstrate correct sprintctl + kctl workflow setup from scratch
**Audience:** agents onboarding to the workflow; developers forking this as a starting point
**Sensitivity:** none — this is a public reference repo

---

## Read this first

This repo uses `sprintctl` for sprint/track/item/claim management and `kctl` for durable knowledge management. Both are local-first CLI tools operating directly on repo-native files.

Before doing any work:
1. Check current sprint: `sprintctl sprint current`
2. Check open claims: `sprintctl claim list`
3. Check any handoff notes on items you're picking up
4. Identify which track your work belongs to
5. Claim before starting any non-trivial work

---

## Sprint naming convention

Format: `YYYY-SNN-<anchor>-<focus>-<phase>`

- `YYYY` — calendar year
- `SNN` — sprint number within the year (S01, S02, ... S52)
- `anchor` — grounding metaphor from the anchor vocabulary
- `focus` — what the sprint is doing from the focus vocabulary
- `phase` — lifecycle stage from the phase vocabulary

Example: `2026-S01-hearth-workflow-overture`

Full vocabulary: see `docs/sprint-naming.md`

---

## Track taxonomy

Tracks in this repo:

| Track | Scope |
|-------|-------|
| `workflow` | Core workflow design, contracts, process definition |
| `docs` | Documentation, examples, reference material |
| `knowledge` | Knowledge promotion, kctl entry management |
| `tooling` | Makefile, scripts, helper tooling |

When creating items, always assign a track. If an item spans tracks, put it in the track where most of the work happens.

---

## Claim policy

**Required for:**
- Any implementation work (code, schema changes, major doc rewrites)
- Any work expected to span more than one session
- Any work that another agent or human should not duplicate

**Optional for:**
- Small doc edits (typo fixes, clarifications under 10 lines)
- Reading/exploration with no writes

**How to claim:**
```
sprintctl claim create --item <item-id> --context "brief description of approach"
```

Always include meaningful context. "Working on this" is not useful. "Drafting the handoff-patterns doc, focusing on blocked and partial-progress cases" is useful.

---

## Review policy

**Review required for:**
- Schema changes (sprintctl config, kctl schema)
- Architectural decisions that affect multiple tracks
- Changes to AGENTS.md or sprint naming conventions
- Any item explicitly marked `review-required`
- Work that introduces new external dependencies

**Review not required for:**
- Single-track implementation work within defined scope
- Doc additions that don't change existing contracts
- Knowledge entry promotions (routine promotion is agent-autonomous)

**How to flag for review:**
```
sprintctl item update <item-id> --tag review-required --handoff "Needs review: <reason>"
```

---

## Artifact paths

| Artifact | Path |
|----------|------|
| Rendered current sprint | `docs/sprint/current.md` |
| Archived sprints | `docs/sprint/archive/YYYY-SNN-<name>.md` |
| Published knowledge entries | `docs/knowledge/<slug>.md` |
| Knowledge candidates | tagged in sprint items with `kctl-candidate` |

Full path reference: `docs/artifacts/paths.md`

---

## Knowledge promotion policy

Promote to kctl when:
- A decision was made that will affect future work (and the rationale should be preserved)
- A pattern was discovered that is reusable across sessions or projects
- A risk was accepted (record what was accepted and why)
- A lesson is likely to recur

Do not promote:
- Every implementation note
- Dead ends that are genuinely dead
- Mechanical progress ("I completed step 3 of 5")
- Things obvious from reading the code

Promotion path: `candidate` (tagged in item) → `reviewed` → `published` (in `docs/knowledge/`)

Full policy: `docs/knowledge-workflow.md`

---

## How to start a new sprint

1. Close or carry over open items from previous sprint
2. Choose a sprint name following the naming convention
3. Create the sprint: `sprintctl sprint create --name <name> --start <date> --end <date>`
4. Create tracks: `sprintctl track create --sprint <name> --name <track>`
5. Add items from backlog or create new ones
6. Assign items to tracks
7. Update `docs/sprint/current.md` if rendering manually

Template for new sprint initialization: `docs/workflows/E-fresh-repo-bootstrap.md`

---

## How to hand off work

When leaving work mid-session or mid-item:

```
sprintctl item handoff <item-id> --note "
  Status: <what's done>
  Next: <what to do next>
  Blockers: <anything blocking>
  Context: <anything the next agent needs to know>
"
```

Then release or retain the claim based on whether the item is truly paused or just waiting.

Handoff patterns: `docs/agent-guidance/handoff-patterns.md`

---

## What NOT to do

- **Don't start work without checking current sprint state** — you may duplicate effort or work on something already claimed
- **Don't claim items you won't touch** — stale claims block others and degrade signal
- **Don't promote every implementation note to kctl** — noise degrades the knowledge base
- **Don't skip handoff notes** — the next agent (or future you) will have no context
- **Don't create new tracks mid-sprint without noting why** — track taxonomy should be stable within a sprint
- **Don't close items as done when they're blocked** — use the `blocked` state with a reason
- **Don't let sprints run indefinitely** — if scope has drifted significantly, create a new sprint with a new name
- **Don't edit AGENTS.md without a review** — it's the single most important coordination file

---

## Quick reference commands

```bash
# Sprint state
sprintctl sprint current
sprintctl sprint status

# Items
sprintctl item list --sprint current
sprintctl item list --track workflow --state open
sprintctl item create --track docs --title "..." --sprint current

# Claims
sprintctl claim list
sprintctl claim create --item <id> --context "..."
sprintctl claim release --item <id>

# Handoffs
sprintctl item handoff <id> --note "..."

# Knowledge
kctl candidate add --item <id> --summary "..."
kctl list --state candidate
kctl promote <slug>
kctl publish <slug>
```
