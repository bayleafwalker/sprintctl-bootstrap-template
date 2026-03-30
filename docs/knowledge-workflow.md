# Knowledge Workflow

How knowledge flows from sprint events to durable kctl entries.

---

## What qualifies for promotion

Knowledge worth promoting has at least one of these properties:

**Durable decisions** — A non-obvious choice was made with rationale that future agents or developers should know about. The rationale, not just the outcome, needs preserving.

> "We chose JSON over YAML for sprint config files because sprintctl's merge behavior requires deterministic key ordering, and the Python JSON parser handles this better than PyYAML in the environments we're targeting."

**Reusable patterns** — Something was discovered or created that will be useful in future sprints or other repos. Worth writing down once rather than rediscovering.

> "Pattern for agent handoff on blocked items: always include the unblock condition, not just what's blocking. 'Blocked on: waiting for X' is useless. 'Blocked on: waiting for X; unblock by doing Y or confirming Z' is actionable."

**Accepted risks** — A risk was acknowledged and consciously accepted. Recording it prevents future agents from re-raising the same concern.

> "We are not validating sprint item IDs against a schema. Risk: agents could create items with invalid IDs. Accepted because: the tooling is simple enough that manual inspection catches this."

**Lessons likely to recur** — Something was learned that is non-obvious and will matter again.

> "When initializing sprintctl on a repo with existing markdown docs, check for path conflicts before committing snapshot paths."

---

## What does NOT qualify

**Every implementation note** — "I used a for loop in lines 45-52" doesn't need to be in kctl. Read the code.

**Dead ends that are genuinely dead** — Only record if the failure mode is a non-obvious trap others might repeat.

**Mechanical progress** — "Completed step 3 of 5" is a handoff note, not knowledge.

**Things obvious from reading the code or docs** — If someone can figure it out in 60 seconds by looking at the file, skip it.

**Temporary decisions** — Only promote if the workaround is likely to be seen again.

---

## The promotion path

```
sprint work → pattern-noted event → reviewed → published to docs/knowledge/
```

### Step 1: Record candidates during work

When you make a decision or discover a pattern worth preserving, record it as a `pattern-noted` or `lesson-learned` event on the item.

```bash
# Record a knowledge candidate directly on the item
sprintctl item note \
  --id <item-id> \
  --type pattern-noted \
  --summary "kctl-candidate: sprint-init-scan-order — run sprintctl scan dry-run before committing config on repos with existing docs" \
  --detail "Source: discovered during bootstrap of my-app. Full context: existing docs/ directory conflicted with default sprint-snapshots path. Running render first revealed the conflict before any state was committed." \
  --actor agent
```

**Don't save this for the end of the sprint.** Capture candidates when the context is fresh.

### Step 2: Review candidates

At end-of-sprint, collect and review candidate events:

```bash
# Find all candidates from the sprint
sprintctl event list --sprint-id <sprint-id> --type pattern-noted
sprintctl event list --sprint-id <sprint-id> --type lesson-learned

# Read the full item for context
sprintctl item show --id <item-id>
```

If kctl is available, it reads these events directly — run its commands per its own documentation.

During review:
- Is the summary accurate?
- Is the rationale present and complete?
- Would someone reading this cold understand when to apply it?
- Is it self-contained, or does it require reading the sprint to make sense?

If it requires reading the sprint to make sense, add more context before publishing.

### Step 3: Publish

Published entries live in `docs/knowledge/` as markdown files.

```bash
mkdir -p docs/knowledge
# Write the entry
touch docs/knowledge/<slug>.md
# Edit with full entry content (see format below)

# Record that it was published
sprintctl item note --id <item-id> --type decision \
  --summary "Published: docs/knowledge/<slug>.md" \
  --actor agent
```

If kctl is available: `kctl publish <slug>` creates the file automatically.

---

## Example candidate event

This is what a raw candidate looks like (recorded as a `pattern-noted` event on an item):

```
pattern-noted: sprint-naming-anchor-first

During sprint naming in 2026-S01, we discovered that picking the anchor word last
(after choosing focus and phase) resulted in awkward names that didn't scan well.

Pattern: choose the anchor word first — it sets the sprint's emotional register and
constrains the vocabulary for the other two components. "Forge" leads naturally to
"build" or "weave" phases. "Harbor" leads to "survey" or "harden".

Source: item WF-003, sprint 2026-S01-hearth-workflow-overture
```

---

## Example published entry

This is what a published entry looks like (`docs/knowledge/sprint-naming-anchor-first.md`):

```markdown
# Sprint Naming: Anchor First

**Origin:** 2026-S01-hearth-workflow-overture, item WF-003
**Tags:** sprint-naming, workflow

## Pattern

When naming a sprint, choose the anchor word first.

The anchor sets the sprint's emotional register and constrains vocabulary
for the focus and phase components. Choosing focus first and then finding
an anchor to fit often produces awkward, incoherent names.

## Rationale

Tested in sprint naming sessions during sprintctl bootstrap. Names built
anchor-first consistently felt more cohesive and were easier to recall.

Names built focus-first tended to be literal and flat ("build-schema-build",
"docs-docs-survey") because the anchor became an afterthought rather than a
grounding element.

## Application

1. Pick the anchor that fits the sprint's energy (see docs/sprint-naming.md)
2. Choose the focus that describes the primary activity
3. Choose the phase that fits the lifecycle stage

## Related

- docs/sprint-naming.md — full vocabulary and naming rules
```

---

## How to reference knowledge from sprint items

When creating items, reference relevant knowledge entries in the item's notes:

```bash
sprintctl item add \
  --sprint-id <sprint-id> \
  --track workflow \
  --title "Design track taxonomy for api-services repo"

sprintctl item note --id <item-id> --type decision \
  --summary "Relevant knowledge: sprint-naming-anchor-first for naming approach; track-taxonomy-sizing for track count guidance. See docs/knowledge/." \
  --actor agent
```

---

## Cadence

**During a sprint:** Record `pattern-noted` and `lesson-learned` events as you go. Don't batch for the end.

**End of sprint (before archiving):** Review all candidates, draft and publish what's ready, reject what isn't.

**Between sprints:** New sprint items can reference published knowledge from the previous sprint.

**Annually:** Consider a knowledge audit sprint (phase: `survey`) to review stale entries and retire knowledge that no longer applies.
