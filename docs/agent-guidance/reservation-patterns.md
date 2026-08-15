# Reservation Patterns

> **Template reference:** This bootstrap example is not canonical shared policy; consult `/projects/dev/agentops/templates/dispatch/` for current reusable workflow guidance.

When and how to use reservations. Concrete examples for common situations.

> Supersedes the earlier claim-patterns guidance. Claims were credential-bearing
> leases with tokens, TTLs, and heartbeats; reservations are advisory and carry
> no secret. Run `sprintctl agent-protocol --json` for the canonical,
> machine-readable command shapes — prefer it over anything written out here.

---

## What reservations are for

A reservation signals: "I am actively working on this item. Don't pick it up."

That is the whole contract. It is a coordination signal, not a lock.

**There is no ownership proof.** No token, no credential, nothing to store or
lose. No sprintctl mutation checks who holds a reservation — `item status` is
guarded by a revision compare-and-swap, not by ownership. The database enforces
exactly one thing: at most one *active* `execute` reservation per item.

That means conflicts are *detected and surfaced*, not prevented. `reserve`
refuses when someone already holds the item and tells you who. `--override`
always succeeds. Both outcomes are visible to an operator, which is the point:
the control is that a person can see what happened, not that the tool said no.

---

## When to reserve

**Reserve before starting:**
- Any implementation work (code, docs, config, schema)
- Work that will take more than 15-20 minutes
- Work another session shouldn't duplicate

**No reservation needed:**
- Read-only orientation (reading AGENTS.md, sprint state)
- Tiny edits under 10 lines with no dependencies
- Running verification or maintenance commands

When in doubt, reserve. A reservation you release after 5 minutes has zero cost.

---

## Reserving an item before starting

Always reserve before writing a single line of output. The reservation is a
coordination signal, not a post-hoc announcement.

```bash
sprintctl reservation reserve \
  --item-id <item-id> \
  --actor <your-session-id> \
  --session-id "${CODEX_THREAD_ID:-manual-session}" \
  --json
```

**Save the returned `id`.** That is all you need — there is no token, and
nothing is returned once-only. `sprintctl reservation show --id <id> --json`
re-reads it at any time.

**Read the item's doc refs before writing anything.** `sprintctl item show --id
<item-id> --json` echoes the item's refs. A `[doc]` ref points at the
plan/sprint doc holding the item's real scope — per-task What/Where/How/Done-when.
The item title is just the handle; the doc is the spec. If an implementation
item has no refs, check its notes for an explicit "no doc" statement before
assuming the title is the whole scope. When your work changes what the doc
states (e.g. a `Status:` field), update the doc in the same commit.

Record your intent before starting:

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Starting: <what you're building, approach, expected scope>" \
  --actor <your-session-id>
```

**Example — doc item:**
```bash
sprintctl reservation reserve \
  --item-id 2 \
  --actor claude-session-1 \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --json
# → {"id": 1, "state": "active", "role": "execute", ...}

sprintctl item note --id 2 --type decision \
  --summary "Writing all three agent-guidance docs: entry-checklist.md, handoff-patterns.md, reservation-patterns.md. Working in order. Each ~100-200 lines. Entry checklist first since handoff and reservation patterns reference it." \
  --actor claude-session-1
```

**Example — implementation item:**
```bash
sprintctl reservation reserve \
  --item-id 3 \
  --actor claude-session-1 \
  --session-id "${CODEX_THREAD_ID:-session-1}" \
  --json

sprintctl item note --id 3 --type decision \
  --summary "Writing src/config.py: pydantic-settings for env var loading. Fields: DATABASE_URL (required), SECRET_KEY (required), PORT (default 8000), LOG_LEVEL (default info). Tests in tests/test_config.py alongside." \
  --actor claude-session-1
```

---

## Moving an item to active uses the revision, not the reservation

```bash
REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status \
  --id <item-id> \
  --status active \
  --actor <your-session-id> \
  --expected-revision "$REV"
```

This is the enforcement gate, and it is about *staleness*, not ownership: a
transition whose basis revision has moved is durably rejected without effect.
Holding the reservation is not what lets you transition; having read current
state is.

---

## Keeping a reservation alive during long sessions

Nothing expires. There is no TTL and no heartbeat requirement, so a long task
cannot lapse mid-flight.

Touching a reservation refreshes its activity clock, which only affects whether
maintenance *displays* it as stale:

```bash
sprintctl reservation touch --id <reservation-id> --session-id <your-session-id>
```

This is optional. Skipping it loses nothing except a fresher timestamp.

---

## Releasing a reservation cleanly

**On completion:**

```bash
# Note completion first
sprintctl item note --id <item-id> --type decision \
  --summary "Done: <what you produced, file paths, summary>" \
  --actor <your-session-id>

# Move to done, guarded by the current revision
REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status --id <item-id> --status done \
  --actor <your-session-id> --expected-revision "$REV"

# Release the reservation
sprintctl reservation release --id <reservation-id> --actor <your-session-id>
```

**On handoff (passing to next session):**

```bash
# Record handoff context
sprintctl item note --id <item-id> --type update \
  --summary "Partial progress: <what's done and what's next>" \
  --detail "<next steps, file locations, blockers if any>" \
  --actor <your-session-id>

# Transfer the reservation in place
sprintctl reservation reassign \
  --id <reservation-id> \
  --actor <next-session-actor> \
  --session-id <next-session-id>
```

The same reservation row changes hands; the item stays active. Nothing is
minted and nothing is invalidated, so the next session needs no credentials —
it just needs the reservation id, which `reservation list` will tell it.

**On block:**

```bash
# Record why blocked
sprintctl item note --id <item-id> --type decision \
  --summary "Blocked: <reason — what external condition must be met>" \
  --actor <your-session-id>

# Move to blocked
REV=$(sprintctl item show --id <item-id> --json | jq -r '.status_revision')
sprintctl item status --id <item-id> --status blocked \
  --actor <your-session-id> --expected-revision "$REV"

# Release — blocked items should not hold reservations
sprintctl reservation release --id <reservation-id> --actor <your-session-id>
```

---

## Checking for stale reservations on entry

```bash
sprintctl reservation list --all --json

# Sweep genuinely abandoned work (default staleness threshold: 4h)
sprintctl maintain sweep --sprint-id <sprint-id>
```

`stale` is a *display* heuristic based on inactivity, not an expiry. A stale
reservation still holds the item, and nothing transfers automatically.

Staleness signals worth acting on:
- Marked `stale` with no recent activity and no handoff note on the item
- The holding session is known to have ended

If taking over a genuinely abandoned item:

```bash
# Read the item and the reservation first
sprintctl item show --id <item-id> --json
sprintctl reservation list --item-id <item-id> --all --json

# Prefer a reassign when you know the holder is gone
sprintctl reservation reassign --id <reservation-id> \
  --actor <your-session-id> --session-id "${CODEX_THREAD_ID:-session-1}"

# Override only when you are deliberately interrupting a live session
sprintctl reservation reserve --item-id <item-id> \
  --actor <your-session-id> --session-id "${CODEX_THREAD_ID:-session-1}" \
  --override --json

# Record what you found either way
sprintctl item note --id <item-id> --type decision \
  --summary "Picking up abandoned work: <state observed, approach>" \
  --actor <your-session-id>
```

An override interrupts the previous reservation and records the reason on it,
so the interrupted session can see what happened. That audit trail is the
control — use it, don't route around it.

---

## Common reservation mistakes

**Reserving without recording intent:**
```bash
# Bad — no one knows what "working on" means
sprintctl reservation reserve --item-id 2 --actor session-1 --json
# (no follow-up note)
```

**Writing a handoff note without moving the reservation:**
```bash
# Bad — leaves the reservation on the old session, so `reservation list`
# still shows the wrong holder
sprintctl item note --id 2 --type update --summary "..." --actor session-1
# (no reassign or release)
```

**Reserving completed items:**
```bash
# Bad — item is already done
sprintctl item show --id 1 --json  # status: done
sprintctl reservation reserve --item-id 1 --actor session-1 --json  # pointless
```

**Reserving to schedule rather than to work:**
```bash
# Bad — "I'll get to this next week" blocks the queue for everyone else.
# Reserve when you start, not when you plan.
```

**Reaching for an ownership check that does not exist:**
There is no token to produce and no proof to verify. If a workflow step seems
to need one, the step is written against the retired claim model — re-read it
against `sprintctl agent-protocol --json`.

**Overriding to avoid a conversation:**
`--override` always works, which makes it a coordination decision rather than a
technical one. Reassign when the holder is gone; override when you are
knowingly interrupting someone, and say so in a note.
