# Workflow D: Knowledge Promotion

**Purpose:** Decisions, patterns, and lessons from sprint work become durable kctl entries that persist beyond the sprint.

This workflow typically runs at the end of a sprint or during a knowledge-focused session. It can also run during a sprint for high-value candidates.

---

## Normal path

```
sprint events → candidates identified → triage → draft entries → publish to docs/knowledge/
```

---

## Entry condition

- Items exist in the current (or recent) sprint with `pattern-noted` or `lesson-learned` events
- OR a sprint is wrapping up and knowledge capture hasn't happened yet
- OR you're running a dedicated knowledge-pass session

---

## Step-by-step

### Step 1: Collect candidates

sprintctl stores decisions and patterns as events. Review them directly:

```bash
# List all events for the sprint to find candidates
sprintctl event list --sprint-id <sprint-id> --type pattern-noted
sprintctl event list --sprint-id <sprint-id> --type lesson-learned
sprintctl event list --sprint-id <sprint-id> --type decision
sprintctl event list --sprint-id <sprint-id> --type risk-accepted

# Or get full event history in JSON for scripted review
sprintctl event list --sprint-id <sprint-id> --json
```

For each candidate item, read the full item and its events:

```bash
sprintctl item show --id <item-id>
```

If kctl is available, it reads these same events:

```bash
# kctl reads from sprintctl events — run its preflight check first
sprintctl maintain check --sprint-id <sprint-id>
kctl list --state candidate
```

### Step 2: Triage

Not every event becomes a published entry. Before drafting:

**Promote:** Decision with rationale, reusable pattern, accepted risk, recurring lesson
**Reject:** Mechanical progress, dead end that's genuinely over, obvious-in-hindsight, temporary workaround

Record the triage decision:

```bash
# For items you're rejecting as knowledge candidates
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "kctl-candidate rejected: one-time config choice specific to this repo, no reuse value" \
  --actor agent
```

### Step 3: Draft entries

For candidates that pass triage, write the knowledge entry as a markdown file in `docs/knowledge/`.

A good entry has:
- **Summary:** One sentence — what does this entry tell you?
- **Context/Rationale:** Why was this decision made or pattern adopted?
- **Application:** When and how to use this
- **Limitations:** When it doesn't apply
- **Origin:** Sprint name and item where it came from

The entry must be self-contained — readable without the sprint context.

```bash
# Create the knowledge file
mkdir -p docs/knowledge
touch docs/knowledge/<slug>.md
# Edit the file with the entry content
```

Record the draft in sprintctl:

```bash
sprintctl item note \
  --id <item-id> \
  --type pattern-noted \
  --summary "Drafted knowledge entry: docs/knowledge/<slug>.md" \
  --actor agent
```

### Step 4: Review and publish

Review your own draft:
- Is it readable cold (without the sprint context)?
- Is the slug descriptive?
- Are related entries cross-referenced?

```bash
# After review, record that the entry is published
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Published: docs/knowledge/<slug>.md. Entry covers: <one-sentence summary>." \
  --actor agent
```

If kctl is available, run its promotion commands per its own documentation.

---

## Example: full promotion of a real candidate

**Sprint item:** WF-003 — "Discover anchor-first naming order produces better sprint names"

During work, the agent recorded this event:

```bash
sprintctl item note \
  --id 3 \
  --type pattern-noted \
  --summary "kctl-candidate: sprint-naming-anchor-first — choosing anchor word first consistently produced more coherent names. Focus-first led to flat, literal combinations." \
  --detail "Source: WF-003, 2026-S01-hearth-workflow-overture. When naming sprints, pick anchor first to set the sprint's register, then constrain focus and phase vocabulary from there." \
  --actor agent
```

**Triage:** Promote. Reusable naming pattern with clear rationale.

**Draft** `docs/knowledge/sprint-naming-anchor-first.md`:

```markdown
# Sprint Naming: Choose Anchor First

**Origin:** 2026-S01-hearth-workflow-overture, WF-003
**Tags:** sprint-naming, workflow

## Summary
When constructing a sprint name (YYYY-SNN-anchor-focus-phase), choose the
anchor word before the focus and phase components.

## Rationale
During sprint naming in 2026-S01, choosing focus first led to flat, literal
names ("schema-schema-build"). Choosing anchor first set the sprint's register
and constrained vocabulary for the other components naturally — "forge" leads
to "build" or "weave"; "harbor" leads to "survey" or "harden".

## Application
1. Read the sprint's backlog to understand the work's character
2. Pick the anchor that fits the sprint's energy (see docs/sprint-naming.md)
3. Choose focus and phase that fit the anchor's implied register

## Limitations
Applies to naming new sprints. Not applicable when renaming an existing sprint
(don't rename sprints — the name is a fixed identifier).

## Related
- docs/sprint-naming.md — vocabulary and naming rules
```

**Record publication:**
```bash
sprintctl item note \
  --id 3 \
  --type decision \
  --summary "Published: docs/knowledge/sprint-naming-anchor-first.md" \
  --actor agent
```

---

## Example: rejecting a candidate

**Event on item DOC-012:**
```
pattern-noted: used h2 headers instead of h3 for workflow step headings
```

**Triage decision:** Reject. One-time formatting choice, no reuse value, obvious from reading the docs.

```bash
sprintctl item note \
  --id 12 \
  --type decision \
  --summary "kctl-candidate rejected: formatting preference with no reuse value. Obvious from docs." \
  --actor agent
```

---

## Artifacts produced

- Published entries in `docs/knowledge/<slug>.md`
- Triage decisions recorded on sprint items
- Events updated to reflect promotion/rejection outcomes

---

## Where claims/handoffs apply

Knowledge promotion doesn't usually require a claim unless you're doing a multi-session knowledge sprint.

If handing off mid-promotion:

```bash
sprintctl item note \
  --id <item-id> \
  --type claim-handoff \
  --summary "Triaged 8 candidates: 5 to promote, 3 rejected. Drafted 3 entries." \
  --detail "Next: Draft remaining 2 entries (slugs: claim-context-norms, track-sizing-heuristic). Then review and publish all 5. Files: docs/knowledge/ — 3 files created, 2 more needed." \
  --actor agent

sprintctl claim handoff \
  --id <claim-id> --claim-token <claim-token> \
  --actor next-session --mode rotate
```

---

## What to promote vs. skip

**Promote:**
- Non-obvious decisions with rationale
- Reusable patterns the next agent would rediscover without this
- Accepted risks with explicit tradeoffs
- Lessons that will likely matter again

**Skip:**
- Every implementation note
- Temporary dead ends that won't recur
- Ordinary mechanical progress
- Decisions that are obvious from reading the code

---

## Cadence recommendation

**During sprint:** Record `pattern-noted` and `lesson-learned` events in the moment. Context degrades fast.

**End of sprint:** Dedicate a focused session to triage and promotion before archiving.

**Between sprints:** New sprint items can reference published knowledge from the previous sprint.
