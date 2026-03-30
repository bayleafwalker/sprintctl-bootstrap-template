# Handoff Patterns

Concrete patterns for handing off sprint items when stopping work. Use the pattern that matches your situation.

---

## When to leave a handoff note

Leave a handoff note whenever:
- You're stopping work on an item that isn't done
- You're closing an item with useful context for future work
- You're blocking an item (block reason is a type of handoff)
- You've made decisions during work that the next agent needs to know

Don't leave handoff notes for items you're closing clean with a summary — just use the close note.

---

## Pattern 1: Normal Completion Handoff

Use when: Work is done. Closing the item but the close note isn't enough to capture what was produced.

**When to use:**
- Item is complete
- The work produced multiple files or non-obvious artifacts
- Future work in this track needs to know what was produced

**Template:**
```
Status: Complete.
Produced: <list of files/changes/artifacts>
Notes: <anything a future agent should know about the work>
Next item suggestion: <optional — what logically follows>
```

**Example:**
```bash
sprintctl item close DOC-002 --note "
  Status: Complete.
  Produced:
    - docs/agent-guidance/entry-checklist.md (8 steps, ~120 lines)
    - docs/agent-guidance/handoff-patterns.md (4 patterns, this file)
    - docs/agent-guidance/claim-patterns.md (3 scenarios, ~90 lines)
  Notes: Entry checklist references claim-patterns.md in step 8 — if claim-patterns
    changes substantially, update the reference.
  Next item suggestion: DOC-003 (examples/ docs) is the logical next track item.
"
```

No claim release needed — closing the item releases the claim automatically.

---

## Pattern 2: Blocked / Waiting Handoff

Use when: Work cannot continue until something external resolves.

**When to use:**
- Waiting on a dependency (another item, a decision, external input)
- Encountered an error that requires investigation outside this session
- Discovered the item needs human input before continuing

**Template:**
```
Status: Blocked.
Done so far: <what was completed before the block>
Block: <specific description of what's blocking>
Unblock condition: <exactly what needs to happen to unblock>
Files: <any in-progress files, their state>
```

**Critical:** Always include the unblock condition. "Blocked on: X" is useless. "Blocked on: X; unblock by doing Y or confirming Z" is actionable.

**Example:**
```bash
sprintctl item block WF-005 --reason "
  Status: Blocked.
  Done so far: Makefile created with help and sprint-current targets. 3 of 5 targets done.
  Block: knowledge-status and validate-docs targets need to know the kctl list output
    format — can't write the instructions without knowing what the command returns.
  Unblock condition: Run 'kctl list' in a repo with knowledge entries and record the
    output format, OR check kctl docs for list output format.
  Files: Makefile (in progress, targets 1-3 done, 4-5 incomplete, clearly marked TODO).
"
sprintctl claim release --item WF-005
```

---

## Pattern 3: Partial Progress Handoff

Use when: Work is underway but you're stopping mid-task. The item is not done, not blocked — just paused.

**When to use:**
- Session is ending with work incomplete
- Context switching to a higher-priority item
- Work is going well but will take more time than available

**Template:**
```
Status: In progress. <percentage or milestone complete>
Done: <list of what's complete>
Next: <exactly what to do next — be specific enough that a cold agent can continue>
Files: <files changed, their state, relevant line numbers if helpful>
Blockers: none (or describe if any)
```

**Example:**
```bash
sprintctl item handoff DOC-001 --note "
  Status: In progress. 3 of 5 workflow docs complete.
  Done:
    - docs/workflows/A-idea-to-backlog.md (complete, ~150 lines)
    - docs/workflows/B-direct-implementation.md (complete, ~180 lines)
    - docs/workflows/C-wider-scope-review.md (complete, ~170 lines)
  Next:
    - Write D-knowledge-promotion.md (see docs/sprint-workflow.md stage 5 for content outline)
    - Write E-fresh-repo-bootstrap.md (should feel like a walkthrough, not a reference doc)
  Files: docs/workflows/ directory. A, B, C done. D and E don't exist yet.
  Blockers: none.
"
sprintctl claim release --item DOC-001
```

---

## Pattern 4: Decision-Needed Handoff

Use when: Work is blocked or paused specifically because a decision needs to be made that is above the agent's authority or requires human input.

**When to use:**
- An architectural choice came up that the agent shouldn't make unilaterally
- Conflicting requirements were discovered and someone needs to choose
- A policy question arose (e.g., "should claims be required for doc edits?")
- A risk was discovered that needs human acknowledgment

**Template:**
```
Status: Paused — decision needed.
Context: <what was discovered or what requires a decision>
Decision needed: <specific question that needs answering>
Options: <if applicable, list the options with brief tradeoffs>
Impact: <what changes depending on the decision>
Work state: <what's done, what's waiting>
```

**Example:**
```bash
sprintctl item handoff WF-008 --note "
  Status: Paused — decision needed.
  Context: While writing the review policy section of AGENTS.md, found that the
    current policy says 'schema changes require review' but doesn't define what
    counts as a schema change for this repo (no formal schema exists).
  Decision needed: Should 'schema change' in review policy mean:
    (a) any change to .sprintctl/config.yaml or .kctl/config.yaml
    (b) any change to the track taxonomy in AGENTS.md
    (c) both of the above
  Options:
    (a) narrow — only catches config file changes, misses AGENTS.md track changes
    (b) broader — catches track changes but might feel heavyweight for minor updates
    (c) broadest — most consistent with the spirit of the policy
  Impact: Defines which items need the Workflow C path vs. Workflow B.
  Work state: AGENTS.md review policy section written up to the schema-change
    clause. File saved. Can continue once decision is made.
"
sprintctl item tag WF-008 --add decision-needed
sprintctl claim release --item WF-008
```

After a decision-needed handoff, the item stays in the sprint. The human or a future session should:
1. Make the decision
2. Comment it on the item
3. Remove the `decision-needed` tag
4. Re-open the item for continuation

```bash
# Human or future agent resolving a decision-needed handoff
sprintctl item comment WF-008 \
  --note "Decision: Use option (c) — schema changes = config file changes OR track taxonomy changes in AGENTS.md."
sprintctl item tag WF-008 --remove decision-needed
sprintctl item update WF-008 --state open
```

---

## Handoff anti-patterns

**The ghost handoff:**
```
# Bad
sprintctl item handoff DOC-001 --note "Working on this"
```
Tells the next agent nothing. Might as well not exist.

**The incomplete block:**
```
# Bad
sprintctl item block WF-005 --reason "Blocked on kctl output format"
```
What does "unblocked" look like? How does anyone fix this?

**The claim-holding partial:**
```
# Bad
sprintctl item handoff DOC-001 --note "In progress, 3 of 5 done"
# (claim not released)
```
Claim is still held, blocking others from picking it up. Always release on handoff.

**The novel without signal:**
```
# Bad (too long, no structure, no clear next action)
sprintctl item handoff DOC-001 --note "
  I spent a lot of time working on this and got through A and B but C was tricky
  because I had to figure out the right structure for the review table and I went
  back and forth on whether to use a table or a list and eventually went with a
  table but then realized the review required vs optional distinction needed more
  nuance so I added some examples but I'm not sure if they're complete..."
```

Keep handoffs structured and scannable. The next agent needs to start working within 2 minutes of reading it.
