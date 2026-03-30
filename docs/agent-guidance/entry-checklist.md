# Agent Entry Checklist

What to do when entering this repo. Do these steps in order. Don't skip steps.

---

## Step 1: Read AGENTS.md

```bash
cat AGENTS.md
```

Read the whole thing. Key things to internalize:
- Track taxonomy (what tracks exist and what they cover)
- Claim policy (when claiming is required vs. optional)
- Review policy (what changes require review before close)
- Sprint naming convention in use

If AGENTS.md doesn't exist, your first task is to create it. See `docs/onboarding/sprintctl-bootstrap.md`.

---

## Step 2: Check current sprint state

```bash
sprintctl sprint current
sprintctl sprint status
```

What to note:
- Sprint name and dates (are we early, mid, or late in the sprint?)
- Overall item counts (done/in-progress/open/blocked)
- Whether the sprint is on track or has accumulated debt

If no active sprint exists, your first task is to create one. See `docs/workflows/E-fresh-repo-bootstrap.md`.

---

## Step 3: List all items

```bash
sprintctl item list --sprint current
```

Scan for:
- High-priority open items (potential work for this session)
- In-progress items that may have stale claims
- Blocked items that might now be unblockable

---

## Step 4: Check open claims

```bash
sprintctl claim list
```

For each claim, check:
- When was it created?
- Is the claiming agent still active, or is this stale?
- Is there a handoff note?

A claim with no recent activity and no handoff note is likely stale. Don't pick up stale-claimed items without first checking if the work is actually in progress.

**Staleness heuristic:** A claim with no updates in 24+ hours without a handoff note is probably stale. Release it if you're taking over the item.

```bash
# If taking over a stale claim
sprintctl claim release --item <item-id>
sprintctl claim create --item <item-id> --context "Picking up from stale claim. <your approach>"
```

---

## Step 5: Read handoff notes on items you're picking up

```bash
sprintctl item show <item-id>
```

Read the full handoff note. Don't skim it. The handoff note contains:
- What was done
- What to do next
- Any blockers or context the previous agent needed to record

---

## Step 6: Scan blocked items

```bash
sprintctl item list --sprint current --state blocked
```

For each blocked item:
- Read the block reason
- Is the block condition still valid?
- Can you unblock it now?

If you can unblock it, do so before claiming other work (unblocking is usually fast and high-value).

```bash
# If a blocked item can be unblocked
sprintctl item unblock <item-id> --note "Unblocked: <what resolved the block>"
```

---

## Step 7: Identify what track to work in

Based on your capabilities and the sprint state, identify your track for this session.

Considerations:
- Which track has the highest-priority open items?
- Are there in-progress items with handoffs that need continuation?
- Do you have the context/capability to work in this track?

Don't spread across all tracks in one session. Focus.

---

## Step 8: Decide whether to claim before starting

Per AGENTS.md claim policy:

**Claim before starting if:**
- Any implementation work (code, docs, config)
- Work likely to span more than 15-20 minutes
- Work another agent or human shouldn't duplicate

**No claim needed for:**
- Read-only orientation (what you're doing right now)
- Tiny edits (typo fixes, adding a sentence)

When in doubt, claim. A claim you release is better than no claim on real work.

```bash
sprintctl claim create \
  --item <item-id> \
  --context "<what you're going to do and how>"
```

---

## Quick entry summary

```bash
# The fast path
cat AGENTS.md
sprintctl sprint current
sprintctl item list --sprint current
sprintctl claim list
# Read any handoff notes
sprintctl item list --sprint current --state blocked
# Pick your work, claim it, start
```

Total time for a clean entry: 5-10 minutes.

---

## Red flags on entry

If you see any of these, stop and address before starting work:

- **No AGENTS.md** → Create it (see bootstrap docs)
- **No active sprint** → Create one (see bootstrap docs)
- **Stale claims everywhere** → Release stale claims, check for orphaned work
- **Multiple items in 'raw' state** → Shape them before claiming implementation work
- **Sprint is past its end date** → Archive it, create next sprint

Don't proceed with implementation work while the coordination layer is broken.
