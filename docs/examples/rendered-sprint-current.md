# Sprint: 2026-S01-hearth-workflow-overture

**Status:** active
**Start:** 2026-03-30
**End:** 2026-04-12
**Day:** 1 of 14
**Progress:** 3 done / 2 in-progress / 4 open / 1 blocked — 10 items total

---

## Track: workflow

### WF-001 — Define track taxonomy and write AGENTS.md skeleton
**State:** done
**Priority:** high
**Closed:** 2026-03-30

> Done. Created AGENTS.md with track taxonomy (workflow, docs, knowledge, tooling), claim policy, review policy, artifact paths, and sprint naming reference. 118 lines.

---

### WF-002 — Write docs/sprint-workflow.md covering all 5 stages
**State:** done
**Priority:** high
**Closed:** 2026-03-30

> Done. docs/sprint-workflow.md created with entry conditions, artifacts, expected actions, and success criteria for all 5 stages. 210 lines.

---

### WF-003 — Write docs/sprint-naming.md with anchor/focus/phase vocabulary
**State:** done
**Priority:** high
**Closed:** 2026-03-30

> Done. docs/sprint-naming.md created with full vocabulary tables (10 anchors, 10 focus, 10 phase), naming rules, 12 examples with rationale, and what-not-to-encode section.
> kctl-candidate tagged: sprint-naming-anchor-first

---

### WF-004 — Write docs/knowledge-workflow.md
**State:** in-progress
**Priority:** high
**Claimed by:** agent-session-2026-03-30-b
**Claim context:** Writing knowledge-workflow.md. Covering: promotion qualifications, non-qualifications, the candidate→reviewed→published path, example candidate, example published entry, referencing pattern.

> Last updated: 2026-03-30 14:22

---

### WF-005 — Write Makefile with help, sprint-current, knowledge-status, agent-entry, validate-docs targets
**State:** open
**Priority:** medium

---

## Track: docs

### DOC-001 — Write docs/workflows/ series (A through E)
**State:** in-progress
**Priority:** high
**Claimed by:** agent-session-2026-03-30-a
**Claim context:** Writing all 5 workflow docs. Working through A→E in order. A (idea-to-backlog) and B (direct-implementation) complete. On C now.

**Handoff note (2026-03-30 13:45):**
```
Status: A and B complete. C (wider-scope-review) drafted but needs review section
  expanded — the "when review is required" table is thin.
Next: Expand C review section, then write D and E.
Files: docs/workflows/A-idea-to-backlog.md (done), B-direct-implementation.md (done),
  C-wider-scope-review.md (draft, needs expansion).
Blockers: none.
```

---

### DOC-002 — Write docs/agent-guidance/ (entry-checklist, handoff-patterns, claim-patterns)
**State:** open
**Priority:** high

---

### DOC-003 — Write docs/examples/ (bootstrap-prompt, backlog-architecture-prompt, minimal-workflow, rendered-sprint-current)
**State:** open
**Priority:** medium

---

### DOC-004 — Write README.md with structure overview and pointers
**State:** open
**Priority:** medium

---

## Track: knowledge

### KN-001 — Review kctl-candidate from WF-003 and publish sprint-naming-anchor-first
**State:** blocked
**Priority:** low
**Blocked reason:** Waiting for WF-003 to be through one sprint before promoting — need to validate the pattern holds before publishing. Unblock condition: end of sprint 2026-S01.

---

## Track: tooling

*(No items yet — tooling track created for Makefile and helper scripts work in later sprint days)*

---

## Sprint summary

**Velocity so far:** 3 items done in day 1 (high-priority workflow foundation items)
**In-flight:** 2 items claimed (WF-004, DOC-001)
**Upcoming:** DOC-002, DOC-003, DOC-004, WF-005

**Health:** On track. Foundation items completed. Documentation work in progress with active claims and a clean handoff note on DOC-001. One item deliberately blocked pending validation (KN-001).

**kctl candidates this sprint:**
- `sprint-naming-anchor-first` (tagged on WF-003, blocked until end-of-sprint)

**Next recommended action for an incoming agent:**
- Check claims on WF-004 and DOC-001 — are they still active or stale?
- If DOC-001 claim is stale, pick up from the handoff note (continue from C)
- Otherwise, claim DOC-002 (next highest priority unclaimed item)

---

*Rendered: 2026-03-30 15:00*
*Render command: `sprintctl sprint render --sprint current --output docs/sprint/current.md`*
