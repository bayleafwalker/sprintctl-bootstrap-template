# Workflow C: Wider-Scope Review

**Purpose:** An architectural or risky change goes through implementation and then an explicit review step before being considered complete.

This workflow applies when the change could affect multiple tracks, when the decision has lasting consequences, or when AGENTS.md or workflow contracts are being modified.

---

## Normal path

```
open item (review-required) → claim → implement → flag for review → review → close
```

---

## When review is required

| Change type | Review required |
|-------------|----------------|
| Schema changes (sprintctl config, kctl schema) | Yes |
| Changes to AGENTS.md | Yes |
| Changes to sprint naming conventions | Yes |
| New track creation mid-sprint | Yes |
| Changes to claim or review policy | Yes |
| Cross-track architectural decisions | Yes |
| New external dependencies | Yes |
| Single-track doc additions | No |
| Routine implementation within defined scope | No |
| kctl knowledge promotion | No |

When in doubt: if a future agent reading AGENTS.md would be misled without knowing about this change, it requires review.

---

## Entry condition

- Item is tagged `review-required`, OR
- You recognize while working that the change scope requires review
- The item is claimed or you are about to claim it

---

## Step-by-step

### Step 1: Orient and claim

```bash
# Check the item for existing review notes or context
sprintctl item show <item-id>

# Claim with explicit intent to flag for review
sprintctl claim create \
  --item <item-id> \
  --context "Implementing new track taxonomy for the api-services migration. Will flag for review before closing — affects AGENTS.md and existing item assignments."
```

### Step 2: Implement

Do the work. Document your decisions clearly — the reviewer needs to understand not just what you changed but why.

Leave inline notes or comments when making non-obvious decisions:

```bash
sprintctl item comment <item-id> \
  --note "Decision: merged 'api' and 'core' tracks into 'backend' because the split was creating artificial boundaries — most items touched both. This changes 12 existing items' track assignments."
```

### Step 3: Flag for review

When implementation is complete, flag the item before closing it.

```bash
sprintctl item update <item-id> --state review-pending

sprintctl item handoff <item-id> --note "
  Implementation complete. Flagging for review before close.

  What changed:
  - AGENTS.md: updated track taxonomy (api + core → backend)
  - 12 items re-assigned to backend track
  - docs/sprint-workflow.md: updated track references

  Why:
  - api/core split created artificial boundaries; most items touched both tracks
  - Pattern observed across 8 consecutive items during sprint execution

  Review focus:
  - Does the track consolidation make sense?
  - Are there cases where the split was useful that I haven't considered?
  - Any other AGENTS.md changes needed to reflect this?

  Risks:
  - Existing sprint archive references old track names — may need migration note
"
```

### Step 4: Review

The reviewer reads the item, the handoff note, and the changes.

```bash
# Read the item and changes
sprintctl item show <item-id>

# Review the diffs (check what was actually changed)
git diff --stat HEAD~1

# Add review comment
sprintctl item comment <item-id> \
  --note "Review: Approved. Track consolidation makes sense. One addition: AGENTS.md should note that archive references use old names — added a migration note to the track taxonomy section. No re-implementation needed."

# Close if approved
sprintctl item close <item-id> \
  --note "Reviewed and closed. Track consolidation approved. Minor addition to AGENTS.md by reviewer."
```

**If the review finds issues:**

```bash
sprintctl item comment <item-id> \
  --note "Review: Changes needed. The 'backend' track name is too broad — it will absorb future frontend work if the repo expands. Suggest 'server' instead of 'backend'. Also: migration note for archive references is missing."

sprintctl item update <item-id> \
  --state open \
  --note "Returned from review: rename 'backend' → 'server', add archive migration note"
```

---

## Artifacts produced

- Implementation work product
- Review comment on the item (approved, changes needed, or rejected)
- Closed item with review outcome recorded, OR
- Item returned to open with specific changes required

---

## Example: AGENTS.md change

**Scenario:** An agent discovers that the claim policy in AGENTS.md doesn't account for read-only exploration sessions and wants to add a clause.

**Claim:**
```bash
sprintctl claim create \
  --item WF-011 \
  --context "Adding read-only exploration clause to claim policy in AGENTS.md. Will flag for review — AGENTS.md changes require review per policy."
```

**Work:** Update AGENTS.md claim policy section to add "Exploration (read-only, no writes) does not require a claim."

**Flag for review:**
```bash
sprintctl item update WF-011 --state review-pending
sprintctl item handoff WF-011 --note "
  Implementation: added one bullet to claim policy (optional for read-only exploration).
  File changed: AGENTS.md, claim policy section, line ~45.
  Rationale: agents were creating claims for orientation reads, creating noise.
  Review: confirm the wording doesn't create an unintended loophole.
"
```

**Review:**
```bash
sprintctl item comment WF-011 \
  --note "Review: Approved with minor wording change. 'Read-only exploration' could be gamed — changed to 'Read-only orientation (no file writes, no sprintctl mutations)' to be specific. Wording updated in place."

sprintctl item close WF-011 \
  --note "Reviewed and closed. Claim policy updated with read-only exploration clause."
```

---

## When an agent recognizes review is needed mid-work

Sometimes you start an item as direct implementation (Workflow B) and realize mid-way that the scope has expanded into review territory.

```bash
# Update the item to flag review requirement
sprintctl item tag <item-id> --add review-required

sprintctl item comment <item-id> \
  --note "Escalating to review-required: discovered this change affects the sprint rendering path, which is used by AGENTS.md artifact references. Broader than originally scoped."
```

Then continue with Workflow C from Step 3.

---

## Common mistakes

**Closing without review when review is required:** This bypasses the safety check for high-impact changes. Check AGENTS.md review policy before every close.

**Vague review requests:** "Please review" gives the reviewer nothing to focus on. Always specify: what changed, why, and what to focus on.

**Reviewer making undocumented changes:** If the reviewer makes changes during review, those changes should be noted in the review comment, not silently applied.

**Not tagging kctl candidates from review outcomes:** Architectural decisions made or confirmed during review are prime kctl material. Tag them.
