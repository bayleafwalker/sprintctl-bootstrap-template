# Workflow C: Wider-Scope Review

**Purpose:** An architectural or risky change goes through implementation and then an explicit review step before being considered complete.

This workflow applies when the change could affect multiple tracks, when the decision has lasting consequences, or when AGENTS.md or workflow contracts are being modified.

---

## Normal path

```
pending item (review-required) → claim → implement → block for review → review → done
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

- Item has a `review-required` note, OR
- You recognize while working that the change scope requires review
- The item is claimed or you are about to claim it

---

## Step-by-step

### Step 1: Orient and claim

```bash
# Check the item for existing notes or context
sprintctl item show --id <item-id>

# Claim with intent to flag for review
sprintctl claim create \
  --item-id <item-id> \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch feat/track-taxonomy-update \
  --json
# → claim_id, claim_token

# Move to active
sprintctl item status --id <item-id> --status active \
  --actor claude-session-1 --claim-id <claim-id> --claim-token <claim-token>

# Record intent (note the review plan)
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Implementing new track taxonomy for api-services migration. Will flag for review before closing — affects AGENTS.md and existing item assignments." \
  --actor claude-session-1
```

### Step 2: Implement

Do the work. Document non-obvious decisions in notes — the reviewer needs to understand
not just what changed but why.

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Merged 'api' and 'core' tracks into 'backend': the split created artificial boundaries; most items touched both. Affects 12 existing item track assignments." \
  --actor claude-session-1
```

### Step 3: Flag for review

When implementation is complete, block the item pending review and leave a detailed handoff note.

```bash
# Record the review handoff
sprintctl item note \
  --id <item-id> \
  --type claim-handoff \
  --summary "Implementation complete. Blocked pending review before close." \
  --detail "What changed: AGENTS.md (api+core → backend track), 12 items re-assigned, docs/sprint-workflow.md track references updated. Why: api/core split was artificial, most items touched both. Review focus: does track consolidation make sense? Are there cases where the split was useful? Any other AGENTS.md changes needed? Risks: sprint archive references old track names — may need migration note." \
  --actor claude-session-1

# Block the item to prevent premature closure
sprintctl item status --id <item-id> --status blocked \
  --actor claude-session-1 --claim-id <claim-id> --claim-token <claim-token>

# Release claim — reviewer will claim it
sprintctl claim release \
  --id <claim-id> --claim-token <claim-token> --actor claude-session-1
```

### Step 4: Review

The reviewer reads the item, the notes, and the git diff.

```bash
# Read the item and all notes
sprintctl item show --id <item-id>

# Review the actual changes
git diff HEAD~1 --stat
git diff HEAD~1

# Claim for review
sprintctl claim create \
  --item-id <item-id> \
  --actor reviewer \
  --type review \
  --json
# → new claim_id, claim_token

# Move back to active for review work
sprintctl item status --id <item-id> --status active \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>
```

**If approved:**

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Review: Approved. Track consolidation makes sense. Added migration note to AGENTS.md track taxonomy section for archive references." \
  --actor reviewer

sprintctl item status --id <item-id> --status done \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>

sprintctl claim release \
  --id <review-claim-id> --claim-token <review-claim-token> --actor reviewer
```

**If changes needed:**

```bash
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Review: Changes needed. 'backend' track name is too broad. Suggest 'server' instead. Also: migration note for archive references is missing." \
  --actor reviewer

# Return item to pending for rework
sprintctl item status --id <item-id> --status pending \
  --actor reviewer --claim-id <review-claim-id> --claim-token <review-claim-token>

sprintctl claim release \
  --id <review-claim-id> --claim-token <review-claim-token> --actor reviewer
```

---

## Artifacts produced

- Implementation work product
- Review note on the item (approved or changes needed)
- Done item with review outcome recorded, OR
- Item returned to pending with specific changes required

---

## Example: AGENTS.md change

**Scenario:** An agent wants to add a read-only exploration clause to the claim policy in AGENTS.md.

**Claim and intent:**
```bash
sprintctl claim create \
  --item-id 11 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch docs/claim-policy-update \
  --json
# → claim_id: 5, claim_token: tok_xyz789

sprintctl item status --id 11 --status active \
  --actor claude-session-1 --claim-id 5 --claim-token tok_xyz789

sprintctl item note --id 11 --type decision \
  --summary "Adding read-only exploration clause to claim policy in AGENTS.md. Will flag for review — AGENTS.md changes require review per policy." \
  --actor claude-session-1
```

**Work:** Update AGENTS.md claim policy section to add "Exploration (read-only, no writes) does not require a claim."

**Flag for review:**
```bash
sprintctl item note --id 11 --type claim-handoff \
  --summary "Implementation complete. Flagged for review before close." \
  --detail "Added one bullet to claim policy: optional for read-only exploration (no file writes, no sprintctl mutations). File: AGENTS.md claim policy section ~line 45. Rationale: agents were creating claims for orientation reads, creating noise. Review focus: confirm wording doesn't create an unintended loophole." \
  --actor claude-session-1

sprintctl item status --id 11 --status blocked \
  --actor claude-session-1 --claim-id 5 --claim-token tok_xyz789

sprintctl claim release --id 5 --claim-token tok_xyz789 --actor claude-session-1
```

**Review:**
```bash
sprintctl claim create --item-id 11 --actor reviewer --type review --json
# → claim_id: 6, claim_token: tok_rev001

sprintctl item status --id 11 --status active \
  --actor reviewer --claim-id 6 --claim-token tok_rev001

sprintctl item note --id 11 --type decision \
  --summary "Review: Approved with minor wording change. Changed 'read-only exploration' to 'read-only orientation (no file writes, no sprintctl mutations)' for precision. Applied in place." \
  --actor reviewer

sprintctl item status --id 11 --status done \
  --actor reviewer --claim-id 6 --claim-token tok_rev001

sprintctl claim release --id 6 --claim-token tok_rev001 --actor reviewer
```

---

## When review is recognized mid-work

Sometimes you start as Workflow B and discover mid-way that scope has expanded into review territory.

```bash
# Record that review is now required
sprintctl item note \
  --id <item-id> \
  --type decision \
  --summary "Escalating to review-required: discovered this change affects the sprint rendering path, which is referenced by AGENTS.md artifact section. Broader than originally scoped." \
  --actor claude-session-1
```

Then continue from Step 3 above.

---

## Common mistakes

**Closing without review when review is required:** Bypasses the safety check for high-impact changes. Check AGENTS.md review policy before every close.

**Vague review requests:** "Please review" gives the reviewer nothing to focus on. Specify what changed, why, and what to focus on.

**Reviewer making undocumented changes:** If the reviewer makes changes during review, those changes must appear in the review note.

**Not noting kctl candidates from review outcomes:** Architectural decisions confirmed during review are prime kctl material. Record them as `pattern-noted` event type.
