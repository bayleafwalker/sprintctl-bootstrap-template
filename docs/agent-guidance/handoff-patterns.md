# Handoff Patterns

Concrete patterns for handing off sprint items when stopping work. Use the pattern that matches your situation.

---

## When to leave a handoff note

Leave a handoff note whenever:
- You're stopping work on an item that isn't done
- You're blocking an item (block reason is a type of handoff)
- You've made decisions during work that the next agent needs to know

Don't leave handoff notes for items you're closing cleanly — the completion note is enough.

---

## Pattern 1: Normal Completion

Use when: Work is done. The item is being closed.

**Template:**
```
Done: <what was produced, file paths, line counts>
Notes: <anything a future agent should know about the work>
Next item suggestion: <optional — what logically follows>
```

**Example:**
```bash
# Record completion note
sprintctl item note --id 2 --type decision \
  --summary "Done. Produced: entry-checklist.md (8 steps, ~120 lines), handoff-patterns.md (4 patterns), claim-patterns.md (3 scenarios, ~90 lines). Note: entry-checklist references claim-patterns.md in step 8 — if claim-patterns changes substantially, update that reference." \
  --actor claude-session-1

# Close the item
sprintctl item status --id 2 --status done \
  --actor claude-session-1 --claim-id 1 --claim-token tok_abc

# Release claim
sprintctl claim release --id 1 --claim-token tok_abc --actor claude-session-1
```

---

## Pattern 2: Blocked / Waiting

Use when: Work cannot continue until something external resolves.

**When to use:**
- Waiting on a dependency (another item, a decision, external input)
- Encountered an error requiring investigation outside this session
- Item needs human input before continuing

**Template:**
```
Blocked: <specific description of what's blocking>
Done so far: <what was completed before the block>
Unblock condition: <exactly what needs to happen to unblock>
Files: <any in-progress files, their state>
```

**Critical:** Always include the unblock condition. "Blocked on: X" is useless. "Blocked on: X; unblock by doing Y or confirming Z" is actionable.

**Example:**
```bash
# Record block context
sprintctl item note --id 5 --type decision \
  --summary "Blocked: Makefile knowledge-status and validate-docs targets need kctl list output format. Can't write instructions without knowing what the command returns." \
  --detail "Done so far: Makefile created with help and sprint-current targets (3 of 5 done). Unblock: run 'kctl list' in a repo with entries and record output format, OR check kctl docs. Files: Makefile in progress, targets 1-3 done, 4-5 marked TODO." \
  --actor claude-session-1

# Block the item
sprintctl item status --id 5 --status blocked \
  --actor claude-session-1 --claim-id 3 --claim-token tok_ghi

# Release claim — blocked items should not hold claims
sprintctl claim release --id 3 --claim-token tok_ghi --actor claude-session-1
```

---

## Pattern 3: Partial Progress Handoff

Use when: Work is underway but you're stopping mid-task. Not done, not blocked — just paused.

**When to use:**
- Session is ending with work incomplete
- Context switching to a higher-priority item
- Work is going well but will take more time than available

**Template:**
```
Status: In progress. <milestone or percentage complete>
Done: <list of what's complete>
Next: <exactly what to do next — specific enough for a cold agent>
Files: <files changed, their state, relevant line numbers if helpful>
Blockers: none (or describe if any)
```

**Example:**
```bash
# Record handoff note on the item
sprintctl item note --id 1 --type claim-handoff \
  --summary "In progress: 3 of 5 workflow docs complete." \
  --detail "Done: A-idea-to-backlog.md, B-direct-implementation.md, C-wider-scope-review.md (all complete). Next: Write D-knowledge-promotion.md (see docs/sprint-workflow.md stage 5 for content outline), then E-fresh-repo-bootstrap.md (walkthrough style, not reference). Files: docs/workflows/ — A, B, C done; D and E don't exist yet. Blockers: none." \
  --actor claude-session-1

# Transfer claim to next session (mints new token)
sprintctl claim handoff \
  --id 1 --claim-token tok_abc \
  --actor claude-session-2 --mode rotate \
  --note "3/5 workflow docs done. D and E remaining."
```

---

## Pattern 4: Decision-Needed

Use when: Work is blocked specifically because a decision needs to be made that is above the agent's authority or requires human input.

**When to use:**
- An architectural choice came up that the agent shouldn't make unilaterally
- Conflicting requirements were discovered and someone needs to choose
- A policy question arose (e.g., "should claims be required for doc edits?")
- A risk was discovered that needs human acknowledgment

**Template:**
```
Paused — decision needed.
Context: <what was discovered or what requires a decision>
Decision needed: <specific question>
Options: <list options with brief tradeoffs>
Impact: <what changes depending on the decision>
Work state: <what's done, what's waiting>
```

**Example:**
```bash
# Record the decision-needed handoff
sprintctl item note --id 8 --type claim-handoff \
  --summary "Paused — decision needed: what counts as a 'schema change' for review policy?" \
  --detail "Context: writing AGENTS.md review policy — 'schema changes require review' but no formal schema exists. Decision: does 'schema change' mean (a) .sprintctl config changes only, (b) track taxonomy changes in AGENTS.md only, or (c) both? Options: (a) narrow, misses AGENTS.md track changes; (b) broader, catches track changes; (c) broadest, most consistent. Impact: defines which items need Workflow C vs B. Work state: AGENTS.md review policy written up to the schema-change clause. Can continue once decision is made." \
  --actor claude-session-1

# Block the item pending the decision
sprintctl item status --id 8 --status blocked \
  --actor claude-session-1 --claim-id 5 --claim-token tok_xyz

# Release claim
sprintctl claim release --id 5 --claim-token tok_xyz --actor claude-session-1
```

After a decision-needed block, the human or a future session should:
1. Record the decision as a note on the item
2. Return the item to pending
3. Claim and continue

```bash
# Resolving a decision-needed block
sprintctl item note --id 8 --type decision \
  --summary "Decision: option (c) — schema changes = config file changes OR track taxonomy changes in AGENTS.md." \
  --actor human

sprintctl item status --id 8 --status pending --actor human
```

---

## Handoff anti-patterns

**The ghost handoff:**
```bash
# Bad — tells the next agent nothing
sprintctl item note --id 1 --type claim-handoff --summary "Working on this" --actor session
```

**The incomplete block:**
```bash
# Bad — no unblock condition
sprintctl item note --id 5 --type decision --summary "Blocked on kctl output format" --actor session
```

**The claim-holding partial:**
```bash
# Bad — left a handoff note but didn't transfer or release the claim
sprintctl item note --id 1 --type claim-handoff --summary "In progress, 3 of 5 done" --actor session
# (no claim handoff or release — claim still held, blocking others)
```
Always use `claim handoff` (to pass to next session) or `claim release` (to free the item) when leaving a partial. Never leave a claim held on an item you're no longer actively working.

**The wall of text:**
Keep handoffs structured and scannable. The next agent needs to start working within 2 minutes of reading it.
