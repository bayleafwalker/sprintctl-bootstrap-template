# Workflow D: Knowledge Promotion

**Purpose:** Decisions, patterns, and lessons from sprint work become durable kctl entries that persist beyond the sprint.

This workflow typically runs at the end of a sprint or during a knowledge-focused session. It can also run during a sprint for high-value candidates.

---

## Normal path

```
sprint events → kctl-candidate tags → review candidates → draft entries → publish
```

---

## Entry condition

- Items exist in the current (or recent) sprint tagged `kctl-candidate`
- OR a sprint is wrapping up and knowledge capture hasn't happened yet
- OR you're running a dedicated knowledge sprint (phase: `archive` or `survey`)

---

## Step-by-step

### Step 1: Collect candidates

```bash
# List all candidates from current sprint
kctl list --state candidate --sprint current

# List candidates across all sprints (if doing a larger knowledge pass)
kctl list --state candidate

# Also check items with kctl-candidate tag that may not be in kctl yet
sprintctl item list --sprint current --tag kctl-candidate
```

For each candidate, read the original item and its comments to understand the full context.

```bash
sprintctl item show <item-id>
```

### Step 2: Triage

Not every candidate becomes a published entry. Before drafting, triage:

**Promote:** Decision with rationale, reusable pattern, accepted risk, recurring lesson
**Reject:** Mechanical progress, dead end that's genuinely dead, obvious-in-hindsight, temporary workaround

```bash
# Reject a candidate
kctl candidate reject <slug> \
  --reason "Dead end — approach was abandoned and alternative is obvious from code"

# Or just note rejection in the item
sprintctl item comment <item-id> \
  --note "kctl-candidate rejected: not worth promoting — this was a one-time config choice specific to this repo with no reuse value"
```

### Step 3: Draft entries

For candidates that pass triage, draft the knowledge entry.

```bash
# Create a draft entry
kctl draft <slug>
```

A good entry has:
- **Summary:** One sentence — what does this entry tell you?
- **Context/Rationale:** Why was this decision made or pattern adopted?
- **Application:** When and how to use this
- **Limitations/caveats:** When it doesn't apply
- **Origin:** Sprint and item where it came from

The entry must be self-contained — readable without the sprint context.

### Step 4: Promote to reviewed

```bash
# Mark the draft as ready for review
kctl promote <slug>

# Or review it yourself if you have enough distance
kctl review <slug>
# (Opens the entry for editing, then mark as reviewed)
kctl mark-reviewed <slug>
```

### Step 5: Publish

```bash
# Publish the entry (creates docs/knowledge/<slug>.md)
kctl publish <slug>
```

Verify the published entry:
- Is it readable cold?
- Is the slug descriptive?
- Are related entries cross-referenced?

```bash
# List all published entries
kctl list --state published
```

---

## Example: full promotion of a real candidate

**Sprint item:** WF-003 — "Discover anchor-first naming order produces better sprint names"

During work, the agent tagged the item and left this candidate note:

```
kctl-candidate: sprint-naming-anchor-first
When naming sprints in this session, choosing the anchor word first (before focus
and phase) consistently produced more coherent names. Focus-first led to flat,
literal combinations. This pattern is worth recording.
Source: WF-003, 2026-S01-hearth-workflow-overture
```

**Draft the entry:**

```bash
kctl draft sprint-naming-anchor-first
```

Write the entry:

```markdown
# Sprint Naming: Choose Anchor First

**Origin:** 2026-S01-hearth-workflow-overture, WF-003
**Tags:** sprint-naming, workflow
**State:** candidate → reviewed → published

## Summary
When constructing a sprint name (YYYY-SNN-anchor-focus-phase), choose the
anchor word before the focus and phase components.

## Rationale
During sprint naming sessions in 2026-S01, choosing focus first led to flat,
literal names ("schema-schema-build"). Choosing anchor first set the sprint's
register and constrained vocabulary for the other two components naturally.
"Forge" leads to "build" or "weave"; "harbor" leads to "survey" or "harden".

## Application
1. Read the sprint's backlog to understand the work's character
2. Pick the anchor that fits the sprint's energy (see docs/sprint-naming.md)
3. Choose focus and phase from the constrained vocabulary that fits the anchor

## Limitations
Applies to naming new sprints. Not applicable when renaming existing sprints
(don't rename sprints — the name is a fixed identifier).

## Related
- docs/sprint-naming.md — vocabulary and naming rules
```

**Promote and publish:**

```bash
kctl promote sprint-naming-anchor-first
kctl publish sprint-naming-anchor-first
# Creates: docs/knowledge/sprint-naming-anchor-first.md
```

---

## Example: rejecting a candidate

**Candidate note on item DOC-012:**
```
kctl-candidate: used h2 headers instead of h3 for workflow step headings
```

**Triage decision:** Reject. This is a one-time formatting choice with no reuse value and is obvious from reading the docs.

```bash
kctl candidate reject doc-012-header-level \
  --reason "Formatting preference, not a reusable pattern. Obvious from docs."
```

---

## Artifacts produced

- Published entries in `docs/knowledge/<slug>.md`
- Rejected candidates with documented reasons
- Sprint summary updated with knowledge promotion record

---

## Where claims/handoffs apply

Knowledge promotion work doesn't usually require a claim unless you're doing a multi-session knowledge sprint. For end-of-sprint knowledge passes, it's usually a single focused session.

If handing off mid-promotion:

```bash
sprintctl item handoff KN-001 --note "
  Status: Triaged 8 candidates — 5 to promote, 3 rejected. Drafted 3 entries.
  Next: Draft remaining 2 entries (slugs: claim-context-norms, track-sizing-heuristic).
    Then promote and publish all 5.
  Files: docs/knowledge/ — 3 files created, 2 more needed.
"
```

---

## Cadence recommendation

**During sprint:** Tag candidates in the moment. Don't save this for the end — context degrades.

**End of sprint:** Dedicate a session to triage and promotion before archiving the sprint.

**Between sprints:** New sprint items can reference published knowledge from the previous sprint.

**Annual:** Consider a `kctl-audit` item to review stale entries and retire knowledge that no longer applies.
