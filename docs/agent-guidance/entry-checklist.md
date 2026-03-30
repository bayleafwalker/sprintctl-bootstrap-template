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
- Active items that may have stale claims
- Blocked items that might now be unblockable

---

## Step 5: Check open claims

```bash
sprintctl claim list-sprint --sprint-id <sprint-id>
```

For each claim, check:
- When was it created?
- Is the claiming agent still active, or is this stale?
- Is there a handoff note on the item?

A claim with no recent activity and no handoff note on the item is likely stale.

**Staleness heuristic:** A claim created more than 24 hours ago with no heartbeat activity and no handoff note is probably stale. Use `maintain sweep` to purge expired claims:

```bash
sprintctl maintain sweep --sprint-id <sprint-id>
```

If you're taking over a legitimately stale-claimed item, you'll need to use the adopt path:

```bash
# First check what's on the item
sprintctl item show --id <item-id>

# Then create your own claim using legacy adopt (for pre-token claims)
sprintctl claim create \
  --item-id <item-id> \
  --actor your-session-id \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --json
```

---

## Step 6: Read handoff notes on items you're picking up

```bash
sprintctl item show --id <item-id>
```

Read the full event history. Don't skim it. The handoff events contain:
- What was done
- What to do next
- Any blockers or context the previous agent needed to record

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
# Return the item to active (or pending if no claim will be taken immediately)
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

## Step 9: Decide whether to claim before starting

Per AGENTS.md claim policy:

**Claim before starting if:**
- Any implementation work (code, docs, config)
- Work likely to span more than 15-20 minutes
- Work another agent or human shouldn't duplicate

**No claim needed for:**
- Read-only orientation (what you're doing right now)
- Tiny edits (typo fixes, adding a sentence)

When in doubt, claim. A claim you release after 5 minutes has zero cost.

```bash
sprintctl claim create \
  --item-id <item-id> \
  --actor your-session-id \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch feat/your-work \
  --json
# Save claim_id and claim_token from output

sprintctl item status --id <item-id> --status active \
  --actor your-session-id --claim-id <claim-id> --claim-token <claim-token>
```

---

## Quick entry summary

```bash
# The fast path (adapt sprint-id to your actual ID)
cat AGENTS.md
source .envrc
sprintctl sprint show
sprintctl item list --sprint-id 1
sprintctl claim list-sprint --sprint-id 1
# Read any item handoff notes
sprintctl item list --sprint-id 1 --status blocked
# Pick your work, claim it, start
```

Total time for a clean entry: 5-10 minutes.

---

## Red flags on entry

If you see any of these, stop and address before starting work:

- **No AGENTS.md** → Create it (see bootstrap docs)
- **No active sprint** → Create one (see `docs/workflows/E-fresh-repo-bootstrap.md`)
- **Many stale claims** → Run `sprintctl maintain sweep`, then check for orphaned work
- **Sprint is past its end date** → Archive it, create next sprint with `maintain carryover`

Don't proceed with implementation work while the coordination layer is broken.
