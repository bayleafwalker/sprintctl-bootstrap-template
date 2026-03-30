# Workflow E: Fresh Repo Bootstrap

**Purpose:** A fresh repository gets its first sprint, tracks, render paths, and example items. This is a walkthrough of bootstrapping sprintctl + kctl from zero.

---

## Scenario

You have a new repository. It may have a README and some code, or it may be empty. You want to set up the sprintctl + kctl workflow and have a first sprint ready to execute within one agent session.

---

## Prerequisites

- `sprintctl` installed (`pipx install git+https://github.com/bayleafwalker/sprintctl.git`)
- Git repository initialized
- direnv available (optional but recommended for per-project DB scope)

```bash
# Verify
sprintctl --version
git status
```

---

## Walkthrough

### 1. Assess the repo

Before doing anything, understand what exists.

```bash
ls -la
cat README.md 2>/dev/null || echo "(no README)"
```

For this walkthrough: `my-app` — a small Python web service. Has `src/` and a `README.md`, no workflow tooling.

### 2. Set up the database scope

sprintctl defaults to `~/.sprintctl/sprintctl.db`. For per-project isolation, use an `.envrc`:

```bash
cat > .envrc << 'EOF'
export SPRINTCTL_DB="${PWD}/.sprintctl/sprintctl.db"
EOF

# If using direnv
direnv allow

# Or source manually
source .envrc
```

Add to `.gitignore`:

```
.sprintctl/
handoff-*.json
sprint-*.json
```

The database is created automatically on first use — no `init` command needed.

### 3. Create the directory structure

```bash
mkdir -p docs/sprint/archive docs/knowledge docs/agent-guidance docs/onboarding
```

### 4. Create the first sprint

The first sprint should use `overture` phase. Look at the repo and decide what the sprint is actually doing.

For `my-app`:
- New service, nothing implemented yet
- First sprint: schema, config, and basic API scaffolding
- Anchor: `forge` (construction from scratch)
- Focus: `schema` (data modeling first)
- Phase: `overture` (first sprint)

```bash
sprintctl sprint create \
  --name 2026-S01-forge-schema-overture \
  --status active \
  --start 2026-03-30 \
  --end 2026-04-12

# Note the sprint ID from the output
sprintctl sprint show
```

### 5. Create tracks

Tracks are created implicitly when you add items to them. For `my-app`, you'll use:
`core`, `api`, `infra`, `docs`

No separate track creation step is needed — just use `--track <name>` when adding items.

```bash
# Verify track creation is implicit
SPRINT_ID=1  # use the actual sprint ID from step 4
```

### 6. Create initial items

Create 8-10 specific, shaped items. Not placeholders.

```bash
SPRINT_ID=1  # replace with actual sprint ID

# Core track items
sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track core \
  --title "Define data models: User, Session, Event"

sprintctl item note --id 1 --type decision \
  --summary "Create src/models.py with SQLAlchemy models. User: id, email, created_at. Session: id, user_id, token, expires_at. Event: id, user_id, type, payload, created_at." \
  --actor setup

sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track core \
  --title "Set up database migration framework with Alembic"

sprintctl item note --id 2 --type decision \
  --summary "Initialize Alembic, create first migration from models.py. SQLite for dev, PostgreSQL config ready for prod." \
  --actor setup

sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track core \
  --title "Write config loader with environment variable support"

sprintctl item note --id 3 --type decision \
  --summary "src/config.py: load from .env or environment. Required: DATABASE_URL, SECRET_KEY. Optional with defaults: PORT=8000, LOG_LEVEL=info." \
  --actor setup

# API track items
sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track api \
  --title "Scaffold FastAPI app with health check endpoint"

sprintctl item note --id 4 --type decision \
  --summary "src/app.py: FastAPI instance, GET /health returns {status: ok, version: <version>}. Wire config loader." \
  --actor setup

sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track api \
  --title "Implement POST /auth/register and POST /auth/login"

sprintctl item note --id 5 --type decision \
  --summary "Register: create user, return JWT. Login: validate credentials, return JWT. Reference User and Session models." \
  --actor setup

# Infra track items
sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track infra \
  --title "Create Dockerfile for development"

sprintctl item note --id 6 --type decision \
  --summary "Python 3.12-slim base. Install deps, copy src. Dev: mount src as volume. Expose 8000." \
  --actor setup

sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track infra \
  --title "Add docker-compose.yml with app + postgres services"

sprintctl item note --id 7 --type decision \
  --summary "Services: app (build from Dockerfile), db (postgres:16). app depends_on: db. Wire DATABASE_URL." \
  --actor setup

# Docs track items
sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track docs \
  --title "Create AGENTS.md for my-app"

sprintctl item note --id 8 --type decision \
  --summary "Cover: repo purpose, track taxonomy (core/api/infra/docs), claim policy, review policy (schema changes require review). Use sprintctl-bootstrap-template/AGENTS.md as template." \
  --actor setup

sprintctl item add \
  --sprint-id $SPRINT_ID \
  --track docs \
  --title "Update README with setup instructions and workflow pointer"

sprintctl item note --id 9 --type decision \
  --summary "Add: quick start (docker-compose up), dev setup, pointer to AGENTS.md and docs/onboarding/." \
  --actor setup
```

Verify items:

```bash
sprintctl sprint show --detail
sprintctl item list --sprint-id $SPRINT_ID
```

### 7. Create AGENTS.md

Create `AGENTS.md` specific to this repo. Don't copy verbatim from the template — adapt it.

Key sections:
- Repo classification and purpose
- Track taxonomy (core/api/infra/docs for `my-app`)
- Claim policy
- Review policy (schema changes, API changes, AGENTS.md changes require review)
- Sprint naming convention in use
- Source-of-truth order

### 8. Render the current sprint

```bash
sprintctl render > docs/sprint/current.md
```

This creates a plain-text snapshot of the sprint. Commit this file — it's the repo-visible sprint state.

### 9. Verify everything works

```bash
# Sprint state
sprintctl sprint show

# Items by track
sprintctl item list --sprint-id $SPRINT_ID

# Claims (should be empty at bootstrap)
sprintctl claim list-sprint --sprint-id $SPRINT_ID

# Maintenance check
sprintctl maintain check --sprint-id $SPRINT_ID
```

Expected state:
- One active sprint with correct dates
- 8-10 pending items across 4 tracks
- No stale claims
- AGENTS.md exists
- `docs/sprint/current.md` exists and is committed

### 10. Start working

Pick the highest priority item (or the logical first one) and claim it.

```bash
# Identify what to work on
sprintctl item list --sprint-id $SPRINT_ID --status pending

# Claim the first item
sprintctl claim create \
  --item-id 8 \
  --actor claude-session-1 \
  --runtime-session-id "${CODEX_THREAD_ID:-session-1}" \
  --branch docs/agents-md \
  --json
# Save claim_id and claim_token from output

# Move to active
sprintctl item status --id 8 --status active \
  --actor claude-session-1 --claim-id <claim-id> --claim-token <claim-token>
```

Bootstrap complete.

---

## What you produced

```
.envrc                         (DB path scoping)
.gitignore                     (ignores .sprintctl/, handoff files)
AGENTS.md                      (repo workflow contract)
docs/sprint/current.md         (rendered sprint snapshot, committed)
docs/sprint/archive/           (ready for future archiving)
docs/knowledge/                (ready for knowledge entries)
docs/agent-guidance/           (ready for guidance docs)
```

Plus 8-10 pending sprintctl items and 1 active sprint.

---

## Common bootstrap mistakes

**Creating too many tracks** — 3-5 is right. 8 tracks is over-engineering for one developer.

**Creating vague items** — "Set up auth" is not a sprint item. "Implement POST /auth/register with JWT token return" is.

**Not creating AGENTS.md** — Agents entering this repo cold will have no orientation. AGENTS.md is not optional.

**Using placeholder sprint names** — `2026-S01-sprint-one` is not a valid sprint name. Follow the naming convention.

**Forgetting to render** — Run `sprintctl render > docs/sprint/current.md` and commit it. This is the repo-visible state.

**Not verifying** — Run the verification commands before considering bootstrap done.
