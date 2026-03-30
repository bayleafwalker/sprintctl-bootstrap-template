# Workflow A: Idea to Backlog

**Purpose:** Convert an unstructured idea, observation, or requirement into shaped, ready-to-execute sprint items.

---

## Normal path

```
raw idea → quick capture → shaping session → shaped items in sprint
```

1. Capture the raw idea immediately (don't let it disappear)
2. Later (same session or next), shape it into one or more specific items
3. Assign to track, set priority, confirm scope is bounded
4. Item is now claimable

---

## Entry condition

- An idea, observation, or requirement exists that isn't in sprintctl yet
- OR a backlog of raw/unshaped items needs to be processed
- OR a new sprint is being created and needs to be populated

---

## Step-by-step

### Step 1: Capture

Capture immediately. Don't try to shape it now if you don't have full context.

```bash
# Quick capture as backlog item
sprintctl item create \
  --sprint current \
  --track docs \
  --title "Add handoff pattern for decision-needed blocks" \
  --state backlog \
  --note "Saw a case where agent didn't know how to record that a human decision was needed. Need a concrete pattern for this."

# If the sprint is unclear, use a staging area
sprintctl item create \
  --sprint backlog \
  --track unsorted \
  --title "Investigate sprintctl scan behavior on symlinked paths" \
  --state raw
```

### Step 2: Shape

Come back with context and turn raw items into specific, executable items.

```bash
# List unshaped items
sprintctl item list --state backlog,raw

# Shape an item: update title to be outcome-focused, add description
sprintctl item update <item-id> \
  --title "Document decision-needed handoff pattern in docs/agent-guidance/handoff-patterns.md" \
  --description "Add a 4th handoff pattern: decision-needed. Should include: when to use it, what to include, example note, how the next human or agent should respond." \
  --priority medium \
  --track docs \
  --state open
```

### Step 3: Validate scope

Before finalizing, check:
- Is this one item or should it be split into two?
- Is the acceptance criteria clear (what does "done" look like)?
- Is the priority right relative to other open items?

```bash
# Check what's already in the sprint to calibrate priority
sprintctl item list --sprint current --state open --sort priority

# If the item is too big, split it
sprintctl item create \
  --sprint current \
  --track docs \
  --title "Write decision-needed handoff example" \
  --state open \
  --parent <original-item-id>

sprintctl item create \
  --sprint current \
  --track docs \
  --title "Update entry-checklist.md to reference decision-needed pattern" \
  --state open \
  --parent <original-item-id>
```

---

## Artifacts produced

- One or more shaped items in sprintctl with state `open`
- Items assigned to tracks with priorities set
- Possibly parent/child relationships if a large item was split

---

## Entry/exit conditions

**Entry:**
- Raw idea exists somewhere (head, notes, conversation)

**Exit:**
- Idea is captured as a shaped sprintctl item (state: `open`)
- OR consciously rejected (add a comment explaining why and close it)
- OR deferred to a future sprint (state: `backlog`, no sprint assignment)

---

## Where claims/handoffs apply

**Claims:** Don't claim items during shaping. Shaping is not implementation work. Claim when you're about to start implementing.

**Handoffs:** If you're mid-shaping and need to stop, leave a note on unshaped items with enough context to resume. Don't leave items in a half-shaped state without explanation.

---

## Tips

**Title format:** "Do X to/in/for Y" or "Write X that covers Y" — outcomes, not activities.

Bad: `"Look into the handoff docs"`
Good: `"Add decision-needed pattern to docs/agent-guidance/handoff-patterns.md"`

**Size gauge:** If an item will take more than 2-3 hours of focused work, split it. If it takes less than 15 minutes, consider combining it with a related item.

**Don't shape during emergencies.** If something urgent is happening, capture raw and shape later. A bad item shape is worse than a rough capture.
