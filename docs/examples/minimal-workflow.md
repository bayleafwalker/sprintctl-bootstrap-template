# Minimal Workflow

The shortest possible demonstration of the pattern: one item from idea to handoff.

Use this as a "show me the pattern" reference. Every real workflow is an elaboration of this.

---

## The pattern in six steps

```
1. idea exists
2. shape it into an item
3. claim it
4. do the work
5. close (or handoff if stopping)
6. tag knowledge candidates
```

---

## Concrete example

**The idea:** "The entry checklist doesn't tell agents to check for blocked items that might be unblockable now."

---

### Step 1: Capture

```bash
sprintctl item create \
  --sprint current \
  --track docs \
  --title "Add 'check blocked items' step to entry-checklist.md" \
  --state backlog \
  --note "Agents enter and don't scan for blocked items they could unblock. Blocked items need a slot in the entry checklist."
```

---

### Step 2: Shape (can be combined with capture if context is clear)

```bash
sprintctl item update DOC-008 \
  --title "Add 'scan blocked items' step to docs/agent-guidance/entry-checklist.md" \
  --description "Add step after 'check open claims': scan blocked items, review block reasons, unblock or leave if dependency still outstanding. One sentence per blocked item in the note." \
  --priority low \
  --state open
```

---

### Step 3: Claim

```bash
sprintctl claim create \
  --item DOC-008 \
  --context "Adding one step to entry-checklist.md for scanning blocked items. Small addition, ~10 lines."
```

---

### Step 4: Work

Edit `docs/agent-guidance/entry-checklist.md`. Add the step.

---

### Step 5a: Close (if done)

```bash
sprintctl item close DOC-008 \
  --note "Done. Added step 5 'Scan blocked items' to entry-checklist.md. 8 lines added."
```

### Step 5b: Handoff (if stopping mid-work)

```bash
sprintctl item handoff DOC-008 --note "
  Status: File opened, context written. Actual edit not done yet.
  Next: Add the step after line 34 in entry-checklist.md.
  Blockers: none.
"
sprintctl claim release --item DOC-008
```

---

### Step 6: Tag knowledge (if anything worth keeping emerged)

In this case: nothing notable — it was a routine doc edit. No kctl tag needed.

If you had discovered something non-obvious during work:
```bash
sprintctl item tag DOC-008 --add kctl-candidate
sprintctl item comment DOC-008 \
  --note "kctl-candidate: agents consistently miss blocked items on entry because the checklist didn't include it. Blocked-item scan should be standard in any workflow entry checklist, not just this one."
```

---

## What this demonstrates

- **Capture is separate from shaping.** Don't block on context you don't have.
- **Claim before starting.** Even for a 15-minute edit.
- **Close with a note, not just a state change.** "Done" is not a close note.
- **Handoff releases the claim.** An unclaimed handoff is the expected state for in-progress items not actively being worked.
- **kctl tagging is conditional.** Not every item produces knowledge. Most don't.

---

## The anti-pattern

What this looks like when done wrong:

```bash
# No capture — idea stays in someone's head

# No claim — work starts without coordination signal

# Work happens

# No close note
sprintctl item close DOC-008

# No handoff if stopping — item stays claimed with no signal
```

Result: orphaned work, no history, potential duplication, lost context.

---

## Scaling up

Every complex workflow (A through E) is this pattern repeated and elaborated:
- More items
- More claims (one per item)
- Review step inserted between work and close (Workflow C)
- Knowledge promotion step added after close (Workflow D)
- Multiple agents working the same sprint (each with their own claims)
