# Workflow A: Idea to Backlog

**Purpose:** Convert an unstructured idea, observation, or requirement into shaped, ready-to-execute sprint items.

---

## Normal path

```
raw idea → quick capture → shaping session → shaped items in sprint
```

1. Capture the raw idea immediately — don't lose it
2. Later (same session or next), shape it into one or more specific items
3. Assign to track, confirm scope is bounded
4. Item is now claimable

---

## Entry condition

- An idea, observation, or requirement exists that isn't in sprintctl yet
- OR unshaped backlog items need to be processed
- OR a new sprint is being created and needs to be populated

---

## Step-by-step

### Step 1: Capture

Capture immediately. Don't try to shape now if you don't have full context.

```bash
# Find the active sprint ID
sprintctl sprint show --json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])"

# Quick capture as pending item (pending = not yet started, ready to shape/claim)
sprintctl item add \
  --sprint-id <sprint-id> \
  --track docs \
  --title "Add handoff pattern for decision-needed blocks"

# Capture context via a note on the item
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Capture: need a pattern for when an agent can't proceed without a human decision" \
  --actor agent
```

If the right sprint isn't clear, add to a backlog sprint:

```bash
# Find or list all sprints including backlog
sprintctl sprint list --include-backlog

sprintctl item add \
  --sprint-id <backlog-sprint-id> \
  --track unsorted \
  --title "Investigate sprintctl scan behavior on symlinked paths"
```

### Step 2: Shape

Come back with context and make items specific and executable.

```bash
# List pending (unstarted) items in the sprint
sprintctl item list --sprint-id <sprint-id> --status pending

# Read item details including any existing notes
sprintctl item show --id <item-id>
```

Shaping is done through notes. If the original title was a rough capture, add a note
clarifying the actual scope and done condition:

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Shaped: scope is to add a decision-needed pattern to docs/agent-guidance/handoff-patterns.md" \
  --detail "Cover: when to use, what to include, example note, how the next agent/human should respond. Done when pattern is written and entry-checklist references it." \
  --actor agent
```

**Attach the governing doc.** An item is not shaped until it carries either a
doc ref pointing at the plan/sprint doc that holds its real scope, or an
explicit "no doc" note. Doc refs accept repo-relative paths; put the doc's
`doc_id` (from its frontmatter) in the label:

```bash
# Item's scope lives in a doc — link it
sprintctl item ref add \
  --id <item-id> \
  --type doc \
  --url docs/plans/my-feature-plan.md \
  --label my-feature-plan

# Or: item is genuinely self-contained — say so explicitly
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "No doc: scope fits entirely in the item title and shaping note." \
  --actor agent
```

The ref is what puts the doc path in front of the claiming agent later —
`claim start`, `next-work --explain`, and `session resume` all render it.

If an item is too big, split it into focused sub-items and block the original:

```bash
# Create specific sub-items
sprintctl item add \
  --sprint-id <sprint-id> \
  --track docs \
  --title "Write decision-needed handoff example in handoff-patterns.md"

sprintctl item add \
  --sprint-id <sprint-id> \
  --track docs \
  --title "Update entry-checklist.md to reference decision-needed pattern"

# Mark original as blocked (was split; depends on sub-items)
sprintctl item status --id <original-id> --status blocked --actor agent
sprintctl item note \
  --id <original-id> \
  --type decision \
  --summary "Split into two focused items. Blocked pending completion of sub-items." \
  --actor agent
```

### Step 3: Validate scope

Before considering an item shaped, check:
- Is the acceptance criteria clear (what does "done" look like)?
- Is it small enough to complete in a focused session?
- Is the track assignment right?
- Does it carry a doc ref to its governing doc, or an explicit "no doc" note?

```bash
# Review the sprint shape overall
sprintctl sprint show --detail
sprintctl item list --sprint-id <sprint-id> --status pending
```

---

## Artifacts produced

- One or more pending items in sprintctl with clear titles
- Notes with rationale and "done" conditions
- A doc ref on each item whose scope lives in a repo doc (or a "no doc" note)
- Possibly blocked parent items if something was split

---

## Entry/exit conditions

**Entry:**
- Raw idea exists somewhere (head, notes, conversation)

**Exit:**
- Idea is captured as a pending sprintctl item with clear scope,
  carrying a doc ref or an explicit "no doc" note
- OR consciously rejected (add a note explaining why, mark done)
- OR deferred to backlog sprint (pending, in backlog sprint)

---

## Where claims/handoffs apply

**Claims:** Don't claim items during shaping. Shaping is not implementation work. Claim when you're about to start implementing.

**Handoffs:** If you're mid-shaping and need to stop, leave a note on unshaped items with enough context to resume.

---

## Tips

**Title format:** "Do X to/in/for Y" or "Write X that covers Y" — outcomes, not activities.

Bad: `"Look into the handoff docs"`
Good: `"Add decision-needed pattern to docs/agent-guidance/handoff-patterns.md"`

**Size gauge:** If an item will take more than 2-3 hours of focused work, split it. If it takes less than 15 minutes, consider combining it with a related item.

**Don't shape during emergencies.** Capture raw and shape later. A rough capture is better than a badly-shaped item.
