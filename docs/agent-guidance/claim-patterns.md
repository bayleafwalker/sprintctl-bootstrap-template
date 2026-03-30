# Claim Patterns

When and how to use claims. Concrete examples for common situations.

---

## What claims are for

A claim signals: "I am actively working on this item. Don't pick it up."

Claims provide coordination in a single-developer + sparse-agent-session workflow. Without claims, two sessions could work the same item concurrently, or an agent could pick up an item that's already in progress.

The claim context field is the primary signal. "Claimed" with no context is nearly useless.

---

## When to claim

**Claim before starting:**
- Any implementation work (code, docs, config, schema)
- Work that will take more than 15-20 minutes
- Work another session shouldn't duplicate

**No claim needed:**
- Read-only orientation (reading AGENTS.md, sprint state)
- Tiny edits under 10 lines with no dependencies
- Running verification commands

When in doubt, claim. A claim you release after 5 minutes has zero cost.

---

## Claiming an item before starting

Always claim before writing a single line of output. The claim is a coordination signal, not a post-hoc announcement.

**Template:**
```bash
sprintctl claim create \
  --item <item-id> \
  --context "<what you're building/writing, approach, expected scope>"
```

**Example — doc item:**
```bash
sprintctl claim create \
  --item DOC-002 \
  --context "Writing all three agent-guidance docs: entry-checklist.md, handoff-patterns.md, claim-patterns.md. Working in order. Each ~100-200 lines. Entry checklist first since handoff and claim patterns reference it."
```

**Example — implementation item:**
```bash
sprintctl claim create \
  --item CORE-003 \
  --context "Writing src/config.py config loader. Will use pydantic-settings for env var loading. Fields: DATABASE_URL (required), SECRET_KEY (required), PORT (default 8000), LOG_LEVEL (default info). Will write unit tests in tests/test_config.py alongside."
```

**Example — infra item:**
```bash
sprintctl claim create \
  --item INFRA-001 \
  --context "Creating Dockerfile for dev. Python 3.12-slim base, pip install from requirements.txt, copy src. Expose 8000. Will also add .dockerignore."
```

---

## What to put in claim context

A useful claim context answers three questions:
1. **What am I producing?** (file paths, feature, change)
2. **How am I approaching it?** (key decisions already made)
3. **What's the rough scope?** (so others know if this will be 30 minutes or 3 hours)

**Too sparse:**
```
--context "Working on the docs"
```

**Too verbose:**
```
--context "I'm going to start by reading the existing docs to understand the current state and then I'll figure out what's missing and then write the content for each section and make sure each section has examples and then I'll review the whole thing and make sure it flows well..."
```

**Right:**
```
--context "Writing entry-checklist.md: 8-step checklist for agent entry. Steps: read AGENTS.md, check sprint, list items, check claims, read handoffs, scan blocked items, identify track, decide whether to claim. ~120 lines with command examples."
```

---

## Updating a claim mid-work

Update the claim context if your approach changes materially. Don't update for minor variations.

**When to update:**
- You're going to produce different artifacts than originally planned
- You discovered the scope is significantly larger or smaller
- You changed your technical approach

```bash
sprintctl claim update \
  --item DOC-002 \
  --context "Changed approach: splitting entry-checklist into two files. Steps 1-5 (orientation) stay in entry-checklist.md. Steps 6-8 (action) moving to a new starting-work.md. Original plan was one file but it was getting too long."
```

**When not to update:**
- You're 10 lines further than when you claimed
- Minor wording changes
- Adding one more example than planned

---

## Releasing a claim cleanly

Release the claim when you're done with the item (or handing off).

**On close:** Claims are automatically released when you close an item. No explicit release needed.

```bash
# This releases the claim automatically
sprintctl item close DOC-002 --note "Done. All three agent-guidance docs written."
```

**On handoff:** Release the claim explicitly after leaving the handoff note.

```bash
sprintctl item handoff DOC-002 --note "
  Status: entry-checklist.md and handoff-patterns.md complete. claim-patterns.md not started.
  Next: Write claim-patterns.md. Structure: when-to-claim, what-to-put-in-context, updating, releasing.
  Blockers: none.
"
sprintctl claim release --item DOC-002
```

**On block:** Release the claim when blocking an item you won't actively continue.

```bash
sprintctl item block DOC-002 --reason "..."
sprintctl claim release --item DOC-002
```

**Do not:** Leave a claim held on an item you've handed off or blocked. A held claim with no active work blocks others and degrades the claim signal quality.

---

## Checking for stale claims

On entry to a repo, check for claims that may have been abandoned.

```bash
sprintctl claim list
```

Staleness signals:
- Claim created more than 24 hours ago with no updates
- No corresponding handoff note on the item
- The claiming session is known to have ended

If you're taking over a stale-claimed item:

```bash
# Read the item first to understand the state
sprintctl item show <item-id>

# Release the stale claim
sprintctl claim release --item <item-id>

# Create your own claim
sprintctl claim create \
  --item <item-id> \
  --context "Picking up from stale claim (previous session ended without handoff). <your approach and any context from the item>"
```

Don't just release stale claims silently — add a note to the item explaining what you found.

---

## Common claim mistakes

**Claiming without context:**
```bash
# Bad — no one knows what "working on" means
sprintctl claim create --item DOC-002 --context "working on this"
```

**Not releasing on handoff:**
```bash
# Bad — item is handed off but claim is still held
sprintctl item handoff DOC-002 --note "..."
# (no claim release)
```

**Claiming complete items:**
```bash
# Bad — item is already done, claim is pointless
sprintctl claim create --item DOC-001  # DOC-001 state: done
```

**Claiming without intent to work:**
```bash
# Bad — "reserving" an item without actually working on it
# Don't hold claims as reservations
sprintctl claim create --item DOC-005 --context "I'll get to this later"
```

Claims are for active work, not reservations. If you're planning to work on something in a future session, leave it open and claim it when you start.
