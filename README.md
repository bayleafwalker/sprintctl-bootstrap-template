# sprintctl-bootstrap-template

> **Template status:** This repository is a bootstrap/reference example. Canonical shared agent workflow and dispatch guidance lives in `/projects/dev/agentops/templates/dispatch/`; adapt these local examples only for project-specific needs.

A reference implementation and bootstrap template for the sprintctl + kctl workflow. This repo demonstrates "what does good look like when starting from nothing?" — a minimal, realistic starting point for a local-first, repo-native sprint workflow with agentic sessions.

## What this is

This is not a documentation cathedral. It is a concrete working example of:

- how to structure a repo for sprintctl + kctl
- how to name sprints, define tracks, and shape backlog items
- how agents enter, claim work, and hand off
- how knowledge gets promoted from sprint events to durable entries
- the full loop: idea → backlog → work → review (optional) → knowledge

**Use it as:**
- a starting point to fork and adapt
- a reference to compare your own repo structure against
- a demo target for understanding the workflow before applying it to a real project

## How to use as a starting point

1. Fork or copy this repo
2. Read `AGENTS.md` — this is what agents read on entry
3. Read `docs/onboarding/sprintctl-bootstrap.md` — the bootstrap prompt for initializing sprintctl on a fresh repo
4. Run the bootstrap prompt in an agent session pointed at your new repo
5. Adapt sprint naming, tracks, and knowledge paths to your project

```
# Quick start
cp -r sprintctl-bootstrap-template my-project
cd my-project
# Edit AGENTS.md to reflect your project's tracks and naming
# Run the bootstrap prompt from docs/onboarding/sprintctl-bootstrap.md
```

## Directory structure

```
.
├── README.md                          # This file
├── AGENTS.md                          # Agent entry guidance (read this first)
├── Makefile                           # Lightweight workflow helpers
├── docs/
│   ├── onboarding/
│   │   └── sprintctl-bootstrap.md     # Bootstrap prompts for fresh repos
│   ├── sprint-naming.md               # Sprint name format and vocabulary
│   ├── sprint-workflow.md             # Core workflow contracts (all 5 stages)
│   ├── knowledge-workflow.md          # How knowledge flows from sprint to kctl
│   ├── workflows/
│   │   ├── A-idea-to-backlog.md       # Concept → shaped sprint items
│   │   ├── B-direct-implementation.md # Agent claims, works, hands off
│   │   ├── C-wider-scope-review.md    # Architectural/risky change + review
│   │   ├── D-knowledge-promotion.md   # Sprint events → durable knowledge
│   │   └── E-fresh-repo-bootstrap.md  # First sprint on a fresh repo
│   ├── examples/
│   │   ├── bootstrap-prompt.md        # Bootstrap prompt in copy-paste form
│   │   ├── backlog-architecture-prompt.md
│   │   ├── minimal-workflow.md        # Shortest possible demo of the pattern
│   │   └── rendered-sprint-current.md # Example sprint snapshot
│   ├── agent-guidance/
│   │   ├── entry-checklist.md         # What to do when entering this repo
│   │   ├── handoff-patterns.md        # Realistic handoff note examples
│   │   └── claim-patterns.md          # When and how to use claims
│   ├── artifacts/
│   │   └── paths.md                   # Where generated artifacts live and why
│   ├── sprint/
│   │   ├── current.md                 # Rendered current sprint (generated)
│   │   └── archive/                   # Past rendered sprints
│   └── knowledge/                     # Published knowledge entries
```

## Operating model

- **sprintctl** — live execution control plane: sprint, track, item, claim management
- **kctl** — reviewed knowledge layer: durable decisions, patterns, accepted risks
- **local-first** — everything lives in the repo, no external project trackers
- **one developer + sparse agent sessions** — no team workflow overhead
- **agents are first-class participants** — claims and handoffs are how continuity works

## Key docs

| Doc | Purpose |
|-----|---------|
| `AGENTS.md` | Agent entry point — read this before doing anything |
| `docs/sprint-workflow.md` | The 5-stage workflow contract |
| `docs/agent-guidance/entry-checklist.md` | Step-by-step agent entry procedure |
| `docs/examples/rendered-sprint-current.md` | What a sprint looks like mid-execution |
| `docs/onboarding/sprintctl-bootstrap.md` | Bootstrap prompts for new repos |
