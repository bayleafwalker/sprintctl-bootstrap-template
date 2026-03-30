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
6. record knowledge candidates during work
```

---

## Concrete example

**The idea:** "The entry checklist doesn't tell agents to check for blocked items that might be unblockable now."

---

### Step 1: Capture

```bash
# Find active sprint ID
sprintctl sprint show --json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])"
# → 1

sprintctl item add \
  --sprint-id 1 \
  --track docs \
  --title "Add 'scan blocked items' step to docs/agent-guidance/entry-checklist.md"
# → item id: 8

sprintctl item note --id 8 --type decision \
  --summary "Agents enter and don't scan blocked items they could unblock. Needs a step in the entry checklist after 'check open claims'." \
  --actor agent
```

---

### Step 2: Claim

```bash
sprintctl claim create \
  --item-id 8 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch docs/entry-checklist \
  --json
# → {claim_id: 3, claim_token: "tok_abc123..."}

# Save claim_id=3, claim_token=tok_abc123 for later steps

# Move to active
sprintctl item status --id 8 --status active \
  --actor claude-session-1 --claim-id 3 --claim-token tok_abc123
```

---

### Step 3: Work

Edit `docs/agent-guidance/entry-checklist.md`. Add the blocked items scan step.

---

### Step 4a: Close (if done)

```bash
sprintctl item note --id 8 --type decision \
  --summary "Done. Added step 7 'Scan blocked items' to entry-checklist.md. 8 lines added after 'check open claims' step." \
  --actor claude-session-1

sprintctl item status --id 8 --status done \
  --actor claude-session-1 --claim-id 3 --claim-token tok_abc123

sprintctl claim release --id 3 --claim-token tok_abc123 --actor claude-session-1
```

### Step 4b: Handoff (if stopping mid-work)

```bash
sprintctl item note --id 8 --type claim-handoff \
  --summary "File opened, context written. Actual edit not done yet." \
  --detail "Next: Add the step after line 34 in entry-checklist.md — scan blocked items for unblock conditions. No blockers." \
  --actor claude-session-1

sprintctl claim handoff \
  --id 3 --claim-token tok_abc123 \
  --actor next-session --mode rotate
# → new token minted for next-session
```

---

### Step 5: Record knowledge candidates during work

In this case: nothing notable — routine doc edit. No knowledge note needed.

If something non-obvious emerged:

```bash
sprintctl item note --id 8 --type pattern-noted \
  --summary "kctl-candidate: agents consistently miss blocked items on entry because the checklist didn't include it. Blocked-item scan should be in any workflow entry checklist, not just this one." \
  --actor claude-session-1
```

---

## What this demonstrates

- **Capture is separate from shaping.** Don't block on context you don't have.
- **Claim before starting.** Even for a 15-minute edit.
- **Ownership proof = claim_id + claim_token.** Both required. Save them.
- **Close with a note, not just a state change.** "Done" is not a close note.
- **Handoff transfers the claim.** Use `claim handoff`, not `claim release`, when handing off to the next session.
- **kctl tagging is conditional.** Most items don't produce durable knowledge.

---

## The anti-pattern

What this looks like when done wrong:

```bash
# No capture — idea stays in someone's head

# No claim — work starts without coordination signal

# Work happens

# No close note, no token proof
sprintctl item status --id 8 --status done  # fails: no claim-id/claim-token

# No handoff if stopping — item stays active with no coordination signal
```

Result: orphaned work, no history, potential duplication, lost context.

---

## Scaling up

Every complex workflow (A through E) is this pattern repeated and elaborated:
- More items
- More claims (one per item)
- Review step inserted between work and close (Workflow C)
- Knowledge promotion step after close (Workflow D)
- Multiple agents working the same sprint (each with their own claims)
