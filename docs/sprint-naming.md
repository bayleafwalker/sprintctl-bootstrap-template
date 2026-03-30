# Sprint Naming Conventions

## Format

```
YYYY-SNN-<anchor>-<focus>-<phase>
```

| Component | Description | Example |
|-----------|-------------|---------|
| `YYYY` | Calendar year | `2026` |
| `SNN` | Sprint number within year, zero-padded | `S01`, `S12` |
| `anchor` | Grounding metaphor — what does this sprint feel like? | `hearth` |
| `focus` | What the sprint is actually doing | `workflow` |
| `phase` | Lifecycle stage | `overture` |

Full example: `2026-S01-hearth-workflow-overture`

The name should be readable as a phrase. "hearth-workflow-overture" suggests a warm, foundational beginning for workflow work. The metaphor doesn't need to be perfect, but it should be evocative and memorable.

---

## Anchor vocabulary

Anchor words ground the sprint with a sense of place or character. Choose one that fits the sprint's energy.

| Anchor | When to use |
|--------|-------------|
| `hearth` | Foundation work, initial setup, creating home base |
| `forge` | Heavy construction, schema work, building core structures |
| `harbor` | Stabilization, consolidation, making things safe to use |
| `ridge` | Elevation work, raising quality, improvement over existing |
| `cairn` | Marking progress, checkpointing, milestone-oriented |
| `delta` | Change-heavy sprint, migrations, significant transitions |
| `canopy` | Broad coverage work, documentation passes, cross-cutting |
| `hollow` | Cleanup, refactoring, removing debt and dead weight |
| `shore` | Boundary definition, API work, interface design |
| `summit` | Delivery sprint, final push, major milestone completion |

---

## Focus vocabulary

Focus words describe the primary activity of the sprint.

| Focus | When to use |
|-------|-------------|
| `workflow` | Process design, workflow contracts, flow definition |
| `schema` | Data modeling, config structure, type system work |
| `docs` | Documentation, reference material, onboarding content |
| `api` | Interface design, endpoint work, contract definition |
| `infra` | Infrastructure, deployment, environment setup |
| `core` | Core business logic, fundamental functionality |
| `ui` | Frontend, visual layer, user-facing components |
| `knowledge` | Knowledge base work, kctl entries, lesson capture |
| `tooling` | Developer tooling, scripts, automation, Makefile |
| `test` | Test coverage, test infrastructure, quality validation |

---

## Phase vocabulary

Phase words describe where in the lifecycle this sprint sits.

| Phase | When to use |
|-------|-------------|
| `overture` | First sprint on a project, setup, initialization |
| `build` | Active construction, primary implementation sprint |
| `weave` | Integration work, connecting pieces that exist separately |
| `survey` | Exploration, audit, assessment, understanding existing state |
| `harden` | Security, validation, error handling, edge cases |
| `polish` | UX, clarity, finishing touches before delivery |
| `migrate` | Moving from old to new, transitions, breaking changes |
| `repair` | Bug fixing sprint, regression work, fire-fighting |
| `archive` | Wrapping up, final cleanup, closing out a phase |
| `pivot` | Significant direction change, replanning sprint |

---

## Naming rules for agents

1. **Read the backlog before naming.** The name should reflect what's actually in the sprint, not just what sounds good.

2. **Anchor first.** Pick the anchor that feels right for the sprint's energy, then choose focus and phase to be descriptive.

3. **Don't over-literal.** "forge-schema-build" is fine. "ridge-database-migration-schema-harden" is too much — that's what the items are for.

4. **Keep it pronounceable.** You should be able to say the sprint name in a conversation without stumbling.

5. **Don't encode dates in the name.** The `YYYY-SNN` prefix handles timing. The name should be timeless within context.

6. **Don't encode team names or developer initials.** This is a single-developer workflow — names don't need attribution.

7. **When in doubt, be conservative.** `2026-S03-harbor-docs-survey` is better than `2026-S03-twilight-textual-illumination-survey`. Poetic is fine; cryptic is not.

---

## What NOT to encode in the name

- **Specific feature names** — features belong in items, not sprint names
- **Ticket/issue numbers** — no external tracker coupling
- **Developer names or initials** — single-developer, no attribution needed
- **Version numbers** — versions are for releases, not sprints
- **Urgency indicators** — "hotfix-emergency" is a vibe, not a sprint name
- **Dates beyond year/sprint-number** — already in the `YYYY-SNN` prefix

---

## 12 Example sprint names with rationale

| Sprint name | Rationale |
|-------------|-----------|
| `2026-S01-hearth-workflow-overture` | First sprint on this bootstrap template — setting up the home base for workflow work |
| `2026-S02-forge-schema-weave` | Second sprint integrating sprintctl schema with kctl schema, heavy connection work |
| `2026-S03-harbor-docs-survey` | Documentation pass, stabilizing reference content, auditing coverage |
| `2026-S04-ridge-tooling-build` | Elevating the Makefile and helper scripts, primary build sprint |
| `2026-S05-cairn-knowledge-archive` | Milestone sprint to promote accumulated knowledge candidates to published entries |
| `2026-S06-delta-api-migrate` | Breaking API changes, migration sprint for interface contracts |
| `2026-S07-canopy-test-build` | Broad test coverage sprint, touching all tracks |
| `2026-S08-hollow-core-repair` | Cleanup and bug-fixing sprint after a heavy build phase |
| `2026-S09-shore-api-harden` | Hardening API boundaries, validation, error handling |
| `2026-S10-summit-core-polish` | Final sprint before a significant delivery — polish and finishing |
| `2026-S11-delta-infra-migrate` | Infrastructure migration sprint, moving from old deployment model |
| `2026-S12-hearth-knowledge-overture` | Starting a new knowledge management phase, fresh initialization |

---

## Sprint numbers reset each year

`S01` means the first sprint of the calendar year, not the first sprint of the project. A project starting in October would begin at `S01` the following January or continue numbering from where it left off.

Recommendation: reset to `S01` each January. This keeps sprint numbers small and makes year boundaries explicit.
