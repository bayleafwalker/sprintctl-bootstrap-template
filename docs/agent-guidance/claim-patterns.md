# Claim Patterns

> **Template reference:** This bootstrap example is not canonical shared policy; consult `/projects/dev/agentops/templates/dispatch/` for current reusable workflow guidance.

When and how to use claims. Concrete examples for common situations.

---

## What claims are for

A claim signals: "I am actively working on this item. Don't pick it up."

Claims coordinate exclusive, time-limited ownership in a single-developer + sparse-agent-session workflow. Without claims, two sessions could work the same item concurrently, or an agent could pick up work already in progress.

**Ownership proof = claim_id + claim_token.** Both are required. The actor label, branch name, and instance ID are advisory metadata only — they are never proof of ownership.

---

## When to claim

**Claim before starting:**
- Any implementation work (code, docs, config, schema)
- Work that will take more than 15-20 minutes
- Work another session shouldn't duplicate

**No claim needed:**
- Read-only orientation (reading AGENTS.md, sprint state)
- Tiny edits under 10 lines with no dependencies
- Running verification or maintenance commands

When in doubt, claim. A claim you release after 5 minutes has zero cost.

---

## Claiming an item before starting

Always claim before writing a single line of output. The claim is a coordination signal, not a post-hoc announcement.

```bash
sprintctl claim create \
  --item-id <item-id> \
  --actor <your-session-id> \
  --runtime-session-id "${CODEX_THREAD_ID:-manual-session}" \
  --branch feat/your-work \
  --json
```

**Save the output.** The `claim_token` is returned once and not retrievable later (you can re-display it with `claim show` if you still hold it, but treat it as sensitive).

**Read the item's doc refs before writing anything.** Claim output echoes the
item's refs (a `Refs on item #N:` block in text, a `refs` array in `--json`).
A `[doc]` ref points at the plan/sprint doc holding the item's real scope —
per-task What/Where/How/Done-when. The item title is just the handle; the doc
is the spec. If the claim output shows `Refs: (none …)` on implementation
work, check the item's notes for an explicit "no doc" statement before
assuming the title is the whole scope. When your work changes what the doc
claims (e.g. a `Status:` field), update the doc in the same commit.

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
sprintctl claim create \
  --item-id 2 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch docs/agent-guidance \
  --json
# → {claim_id: 1, claim_token: "tok_abc123"}

sprintctl item note --id 2 --type decision \
  --summary "Writing all three agent-guidance docs: entry-checklist.md, handoff-patterns.md, claim-patterns.md. Working in order. Each ~100-200 lines. Entry checklist first since handoff and claim patterns reference it." \
  --actor claude-session-1
```

**Example — implementation item:**
```bash
sprintctl claim create \
  --item-id 3 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch feat/config-loader \
  --json

sprintctl item note --id 3 --type decision \
  --summary "Writing src/config.py: pydantic-settings for env var loading. Fields: DATABASE_URL (required), SECRET_KEY (required), PORT (default 8000), LOG_LEVEL (default info). Tests in tests/test_config.py alongside." \
  --actor claude-session-1
```

---

## Moving an item to active requires the token

```bash
sprintctl item status \
  --id <item-id> \
  --status active \
  --actor <your-session-id> \
  --claim-id <claim-id> \
  --claim-token <claim-token>
```

This is the enforcement gate. Sprintctl verifies `claim_id + claim_token` before allowing the transition.

---

## Keeping a claim alive during long sessions

Claims expire (default TTL: 300 seconds). Send heartbeats during long sessions:

```bash
sprintctl claim heartbeat \
  --id <claim-id> \
  --claim-token <claim-token> \
  --actor <your-session-id>
```

---

## Releasing a claim cleanly

**On completion:**

```bash
# Note completion first
sprintctl item note --id <item-id> --type decision \
  --summary "Done: <what you produced, file paths, summary>" \
  --actor <your-session-id>

# Move to done
sprintctl item status --id <item-id> --status done \
  --actor <your-session-id> \
  --claim-id <claim-id> --claim-token <claim-token>

# Release claim
sprintctl claim release \
  --id <claim-id> --claim-token <claim-token> \
  --actor <your-session-id>
```

**On handoff (passing to next session):**

```bash
# Record handoff note
sprintctl item note --id <item-id> --type claim-handoff \
  --summary "Partial progress: <what's done and what's next>" \
  --detail "<next steps, file locations, blockers if any>" \
  --actor <your-session-id>

# Transfer ownership — mints new token for next session
sprintctl claim handoff \
  --id <claim-id> --claim-token <claim-token> \
  --actor <next-session-id> \
  --mode rotate \
  --note "Handing off mid-work. <brief state summary>"
# → returns new claim_id and claim_token for next-session-id
```

The old token is invalidated. The item stays active. The next session picks up with fresh credentials.

**On block:**

```bash
# Record why blocked
sprintctl item note --id <item-id> --type decision \
  --summary "Blocked: <reason — what external condition must be met>" \
  --actor <your-session-id>

# Move to blocked
sprintctl item status --id <item-id> --status blocked \
  --actor <your-session-id> \
  --claim-id <claim-id> --claim-token <claim-token>

# Release claim — blocked items should not hold claims
sprintctl claim release \
  --id <claim-id> --claim-token <claim-token> \
  --actor <your-session-id>
```

---

## Checking for stale claims on entry

```bash
sprintctl claim list-sprint --sprint-id <sprint-id>

# Purge expired claims automatically
sprintctl maintain sweep --sprint-id <sprint-id>
```

Staleness signals:
- Claim created more than 24 hours ago with no heartbeat
- No handoff note on the item
- The claiming session is known to have ended

If taking over a legitimately stale-claimed item:

```bash
# Read the item first to understand the state
sprintctl item show --id <item-id>

# Use resume to find your own existing claims if re-entering
sprintctl claim resume --runtime-session-id "${CODEX_THREAD_ID}"

# Or create a new claim if the old one expired
sprintctl claim create \
  --item-id <item-id> \
  --actor <your-session-id> \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --json

# Record context for what you found
sprintctl item note --id <item-id> --type decision \
  --summary "Picking up from expired claim: <state observed, approach>" \
  --actor <your-session-id>
```

---

## Common claim mistakes

**Claiming without recording intent:**
```bash
# Bad — no one knows what "working on" means
sprintctl claim create --item-id 2 --actor session-1 --json
# (no follow-up note)
```

**Using handoff without claim transfer:**
```bash
# Bad — leaves old claim active, blocking the next session
sprintctl item note --id 2 --type claim-handoff --summary "..." --actor session-1
# (no claim handoff or release)
```

**Claiming complete items:**
```bash
# Bad — item is already done
sprintctl item show --id 1  # status: done
sprintctl claim create --item-id 1 --actor session-1 --json  # pointless
```

**Claiming as a reservation:**
```bash
# Bad — "I'll work on this later" is not a claim reason
# Claims are for active work, not scheduling
```

**Not having the token when you need it:**
The token is returned once at claim creation. If you didn't save it, use `claim show` immediately after claiming. If the claim has expired, you'll need to create a new one after the old one is swept.

```bash
sprintctl claim show --id <claim-id> --claim-token <token>
```
