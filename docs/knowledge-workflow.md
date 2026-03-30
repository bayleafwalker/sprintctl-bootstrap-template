# Knowledge Workflow

How knowledge flows from sprint events to durable kctl entries.

---

## What qualifies for promotion

Knowledge worth promoting has at least one of these properties:

**Durable decisions** — A non-obvious choice was made with rationale that future agents or developers should know about. The rationale, not just the outcome, needs preserving.

> "We chose JSON over YAML for sprint config files because sprintctl's merge behavior requires deterministic key ordering, and the Python JSON parser handles this better than PyYAML in the environments we're targeting."

**Reusable patterns** — Something was discovered or created that will be useful in future sprints or other repos. It's worth writing down once rather than rediscovering.

> "Pattern for agent handoff on blocked items: always include the unblock condition, not just what's blocking. 'Blocked on: waiting for X' is useless. 'Blocked on: waiting for X; unblock by running Y or confirming Z' is actionable."

**Accepted risks** — A risk was acknowledged and consciously accepted. Recording it prevents future agents from re-raising the same concern.

> "We are not validating sprint item IDs against a schema. Risk: agents could create items with invalid IDs that are hard to query. Accepted because: the tooling is simple enough that manual inspection catches this, and the overhead of schema validation exceeds the risk for this repo's scale."

**Lessons likely to recur** — Something was learned that is non-obvious and will matter again. The lesson doesn't have to be earth-shattering; it just has to be worth 5 minutes of future time.

> "When initializing sprintctl on a repo with existing markdown docs, run `sprintctl scan --dry-run` first to check for conflicts with existing file paths before committing the config."

---

## What does NOT qualify

**Every implementation note** — "I used a for loop in lines 45-52 to iterate over tracks" does not need to be in kctl. Read the code.

**Dead ends that are genuinely dead** — "I tried using approach X and it didn't work because Y" is only worth recording if Y is a non-obvious trap others might fall into. If it's obvious in hindsight, skip it.

**Mechanical progress** — "Completed step 3 of 5" is a handoff note, not knowledge.

**Things obvious from reading the code or docs** — If someone can figure it out in 60 seconds by looking at the file, it doesn't need to be in kctl.

**Temporary decisions** — "For this sprint, we're using a temporary workaround for X" — only promote if the workaround is likely to be seen again.

---

## The promotion path

```
sprint work → kctl-candidate (tagged on item) → reviewed → published
```

### Step 1: Candidate (tag during work)

During sprint execution, when you make a decision or discover a pattern worth preserving, tag the item and add a candidate note.

```bash
# Tag the item as having a knowledge candidate
sprintctl item tag <item-id> --add kctl-candidate

# Add a note describing the candidate
sprintctl item comment <item-id> --note "kctl-candidate: <brief description of what to capture>"

# Or use kctl directly to create a draft
kctl candidate add \
  --item <item-id> \
  --slug "sprint-init-scan-order" \
  --summary "Run sprintctl scan --dry-run before committing config on repos with existing docs"
```

**Don't save this for the end of the sprint.** Capture candidates when the context is fresh. Trying to reconstruct decisions from closed items two weeks later produces thin entries.

### Step 2: Reviewed

A candidate entry gets reviewed for accuracy, completeness, and genuine utility.

```bash
# List candidates
kctl list --state candidate

# Review a specific candidate (opens draft for editing)
kctl review <slug>

# Mark as reviewed (ready for publication)
kctl promote <slug>
```

During review:
- Is the summary accurate?
- Is the rationale present and complete?
- Would someone reading this cold understand when to apply it?
- Is it self-contained, or does it require reading the sprint to make sense?

If it requires reading the sprint to make sense, it's not ready for kctl — add more context.

### Step 3: Published

Published entries live in `docs/knowledge/` and are the durable record.

```bash
kctl publish <slug>
# Creates docs/knowledge/<slug>.md
```

Published entries should be:
- Self-contained (readable without the sprint context)
- Timestamped with the sprint where they originated
- Tagged with the relevant tracks/domains
- Cross-referenced if they relate to other entries

---

## Example candidate entry

This is what a raw candidate looks like (lives in sprintctl item comments, not yet in kctl):

```
kctl-candidate: sprint-naming-anchor-first

During sprint naming in 2026-S01, we discovered that picking the anchor word last
(after choosing focus and phase) resulted in awkward names that didn't scan well.

Pattern: choose the anchor word first — it sets the sprint's emotional register and
constrains the vocabulary for the other two components. "Forge" leads naturally to
"build" or "weave" phases. "Harbor" leads to "survey" or "harden".

Source: item WF-003, sprint 2026-S01-hearth-workflow-overture
```

---

## Example published entry

This is what a published entry looks like (lives in `docs/knowledge/sprint-naming-anchor-first.md`):

```markdown
# Sprint Naming: Anchor First

**Origin:** 2026-S01-hearth-workflow-overture, item WF-003
**Tags:** sprint-naming, workflow
**State:** published

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

The anchor vocabulary in docs/sprint-naming.md is ordered by use case to help
with this selection.

## Related

- docs/sprint-naming.md — full vocabulary and naming rules
```

---

## How to reference knowledge from sprint items

When creating or updating sprint items, reference relevant knowledge entries:

```bash
sprintctl item create \
  --track workflow \
  --title "Design track taxonomy for api-services repo" \
  --description "Create 4-5 tracks. See knowledge: sprint-naming-anchor-first for naming approach. See knowledge: track-taxonomy-sizing for track count guidance."
```

Or in item notes:

```bash
sprintctl item comment <item-id> \
  --note "Relevant knowledge: docs/knowledge/track-taxonomy-sizing.md"
```

---

## Cadence

**During a sprint:** Tag candidates as you go. Don't batch this for the end.

**End of sprint (before archiving):** Review all candidates, promote what's ready, reject what isn't, publish what's reviewed.

**Between sprints:** New sprint items can reference published knowledge from the previous sprint.

**Annually:** Consider a knowledge audit sprint (phase: `survey` or `archive`) to review stale entries and retire knowledge that no longer applies.
