# Agent Entry Checklist

> **Template reference:** This bootstrap example is not canonical shared policy; consult `/projects/dev/agentops/templates/dispatch/` for current reusable workflow guidance.

What to do when entering this repo. Do these steps in order. Don't skip steps.

---

## Step 1: Read AGENTS.md

```bash
cat AGENTS.md
```

Read the whole thing. Key things to internalize:
- Track taxonomy (what tracks exist and what they cover)
- Reservation policy (when reserving is required vs. optional)
- Review policy (what changes require review before close)
- Sprint naming convention in use

If AGENTS.md doesn't exist, your first task is to create it. See `docs/onboarding/sprintctl-bootstrap.md`.

---

## Step 2: Load environment

```bash
# If using direnv
direnv allow

# Or source manually
source .envrc
```

Verify the DB path is scoped to this repo (not the global default):

```bash
echo $SPRINTCTL_DB
# Should be something like /path/to/repo/.sprintctl/sprintctl.db
```

---

## Step 3: Check current sprint state

```bash
sprintctl sprint show
sprintctl sprint show --detail
```

What to note:
- Sprint name and dates (early, mid, or late in sprint?)
- Overall item counts (done/active/pending/blocked)
- Whether the sprint is on track or has accumulated debt

If no active sprint exists, your first task is to create one. See `docs/workflows/E-fresh-repo-bootstrap.md`.

---

## Step 4: List all items

```bash
# Get the active sprint ID from the show output, then:
sprintctl item list --sprint-id <sprint-id>
```

Scan for:
- Pending items (potential work for this session)
- Active items that may have stale reservations
- Blocked items that might now be unblockable

---

## Step 5: Check open reservations

```bash
sprintctl reservation list --all --json
```

For each reservation, check:
- When was it created?
- Is the holding session still active, or is this abandoned?
- Is there a handoff note on the item?

A reservation with no recent activity and no handoff note on the item is likely
abandoned.

**Staleness heuristic:** `stale` in `reservation list` means inactive past the
threshold (4h by default). It is a *display* signal, not an expiry — nothing
lapses and nothing transfers on its own, so a stale reservation still holds
the item. `maintain sweep` marks genuinely abandoned ones as interrupted:

```bash
sprintctl maintain sweep --sprint-id <sprint-id>
```

If you're taking over an abandoned item, decide between reassigning and
overriding — there is no adoption step, because there is no credential to
adopt:

```bash
# First check what's on the item and who holds it
sprintctl item show --id <item-id> --json
sprintctl reservation list --item-id <item-id> --all --json

# Holder is gone: move the existing reservation to you
sprintctl reservation reassign \
  --id <reservation-id> \
  --actor your-session-id \
  --session-id "${CODEX_THREAD_ID:-session-1}"

# Holder may still be live: this interrupts them, and says so on the record
sprintctl reservation reserve \
  --item-id <item-id> \
  --actor your-session-id \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --interrupt-existing --json
```

---

## Step 6: Read handoff notes and doc refs on items you're picking up

```bash
sprintctl item show --id <item-id>
```

Read the full event history. Don't skim it. The handoff events contain:
- What was done
- What to do next
- Any blockers or context the previous agent needed to record

Then check the `Refs:` section. A `[doc]` ref points at the plan/sprint doc
that holds the item's real scope — read that doc before starting. If the item
has no refs and no "no doc" note, the title may not be the whole scope; look
for a matching doc in `docs/plans/` or `docs/sprints/` and attach it:

```bash
sprintctl item ref add --id <item-id> --type doc \
  --url docs/plans/<doc>.md --label <doc_id>
```

---

## Step 7: Scan blocked items

```bash
sprintctl item list --sprint-id <sprint-id> --status blocked
```

For each blocked item:
- Read the block reason in events (`sprintctl item show --id <item-id>`)
- Is the block condition still valid?
- Can you unblock it now?

If you can unblock it:

```bash
# Return the item to active (or pending if no reservation will be taken immediately)
sprintctl item status --id <item-id> --status pending --actor your-session-id

sprintctl item note \
  --id <item-id> \
  --type blocker-resolved \
  --summary "Unblocked: <what resolved the block>" \
  --actor your-session-id
```

---

## Step 8: Identify what track to work in

Based on your capabilities and the sprint state, identify your track for this session.

Considerations:
- Which track has the highest-priority pending items?
- Are there active items with handoffs that need continuation?
- Do you have the context/capability to work in this track?

Don't spread across all tracks in one session. Focus.

---

## Step 9: Decide whether to reserve before starting

Per AGENTS.md reservation policy:

**Claim before starting if:**
- Any implementation work (code, docs, config)
- Work likely to span more than 15-20 minutes
- Work another agent or human shouldn't duplicate

**No reservation needed for:**
- Read-only orientation (what you're doing right now)
- Tiny edits (typo fixes, adding a sentence)

When in doubt, reserve. A reservation you release after 5 minutes has zero cost.

```bash
sprintctl reservation reserve \
  --item-id <item-id> \
  --actor your-session-id \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --json
# Save the returned reservation id

REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status --id <item-id> --status active \
  --actor your-session-id --expected-revision "$REV"
```

---

## Quick entry summary

```bash
# The fast path (adapt sprint-id to your actual ID)
cat AGENTS.md
source .envrc
sprintctl sprint show
sprintctl item list --sprint-id 1
sprintctl reservation list --all --json
# Read any item handoff notes
sprintctl item list --sprint-id 1 --status blocked
# Pick your work, reserve it, start
```

Total time for a clean entry: 5-10 minutes.

---

## Red flags on entry

If you see any of these, stop and address before starting work:

- **No AGENTS.md** → Create it (see bootstrap docs)
- **No active sprint** → Create one (see `docs/workflows/E-fresh-repo-bootstrap.md`)
- **Many stale reservations** → Run `sprintctl maintain sweep`, then check for orphaned work
- **Sprint is past its end date** → Archive it, create next sprint with `maintain carryover`

Don't proceed with implementation work while the coordination layer is broken.
