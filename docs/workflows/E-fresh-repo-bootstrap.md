# Workflow E: Fresh Repo Bootstrap

**Purpose:** A fresh repository gets its first sprint, tracks, render paths, and example items. This is a walkthrough of bootstrapping sprintctl + kctl from zero.

---

## Scenario

You have a new repository. It may have a README and some code, or it may be completely empty. You want to set up the sprintctl + kctl workflow and have a first sprint ready to execute within one agent session.

---

## Prerequisites

- `sprintctl` installed and accessible in PATH
- `kctl` installed and accessible in PATH
- Git repository initialized

```bash
# Verify tools
sprintctl --version
kctl --version
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

For this walkthrough, we're setting up `my-app` — a small Python web service. The repo has a `src/` directory and a `README.md` but no workflow tooling.

### 2. Initialize sprintctl

```bash
sprintctl init
```

When prompted:
- **Repo name:** `my-app`
- **Sprint naming convention:** `YYYY-SNN-<anchor>-<focus>-<phase>` (accept default)
- **Default sprint length:** `14` (days)
- **Sprint render path:** `docs/sprint/`
- **Knowledge path:** `docs/knowledge/`

This creates `.sprintctl/config.yaml` and the necessary directory structure.

```bash
# Verify initialization
cat .sprintctl/config.yaml
```

### 3. Initialize kctl

```bash
kctl init
```

When prompted:
- **Knowledge path:** `docs/knowledge/` (match sprintctl config)
- **Candidate tag:** `kctl-candidate`
- **Review before publish:** `yes`

This creates `.kctl/config.yaml`.

### 4. Create the directory structure

```bash
mkdir -p docs/sprint/archive docs/knowledge docs/agent-guidance
```

### 5. Choose and create the first sprint

The first sprint should be `overture` phase. Look at the repo and decide what the first sprint is actually doing.

For `my-app`:
- It's a new service with nothing implemented yet
- First sprint will set up schema, config, and basic API scaffolding
- Anchor: `forge` (heavy construction from scratch)
- Focus: `schema` (data modeling and config structure first)
- Phase: `overture` (first sprint)

```bash
sprintctl sprint create \
  --name 2026-S01-forge-schema-overture \
  --start 2026-03-30 \
  --end 2026-04-12
```

### 6. Create tracks

For a Python web service, 4-5 tracks makes sense:

```bash
sprintctl track create --sprint 2026-S01-forge-schema-overture --name core
sprintctl track create --sprint 2026-S01-forge-schema-overture --name api
sprintctl track create --sprint 2026-S01-forge-schema-overture --name infra
sprintctl track create --sprint 2026-S01-forge-schema-overture --name docs
```

Verify:

```bash
sprintctl track list --sprint 2026-S01-forge-schema-overture
```

### 7. Create initial items

Create 8-12 specific, shaped items. Not placeholders.

```bash
# Core track items
sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track core \
  --title "Define data models: User, Session, Event" \
  --priority high \
  --description "Create src/models.py with SQLAlchemy models. User needs: id, email, created_at. Session: id, user_id, token, expires_at. Event: id, user_id, type, payload, created_at."

sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track core \
  --title "Set up database migration framework with Alembic" \
  --priority high \
  --description "Initialize Alembic, create first migration from models.py. Target: SQLite for dev, PostgreSQL config ready for prod."

sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track core \
  --title "Write config loader with environment variable support" \
  --priority high \
  --description "src/config.py: load from .env or environment. Required: DATABASE_URL, SECRET_KEY. Optional with defaults: PORT=8000, LOG_LEVEL=info."

# API track items
sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track api \
  --title "Scaffold FastAPI app with health check endpoint" \
  --priority high \
  --description "src/app.py: FastAPI instance, GET /health returns {status: ok, version: <version>}. Wire config loader."

sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track api \
  --title "Implement POST /auth/register and POST /auth/login" \
  --priority medium \
  --description "Register: create user, return token. Login: validate credentials, return token. Use JWT. Reference: core User and Session models."

# Infra track items
sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track infra \
  --title "Create Dockerfile for development" \
  --priority medium \
  --description "Python 3.12 slim base. Install deps, copy src. Dev: mount src as volume. Expose 8000."

sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track infra \
  --title "Add docker-compose.yml with app + postgres services" \
  --priority medium \
  --description "Services: app (build from Dockerfile), db (postgres:16). App depends_on: db. Wire DATABASE_URL."

# Docs track items
sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track docs \
  --title "Create AGENTS.md for my-app" \
  --priority high \
  --description "Cover: repo purpose, track taxonomy, claim policy, review policy (schema changes require review). Use sprintctl-bootstrap-template/AGENTS.md as template."

sprintctl item create \
  --sprint 2026-S01-forge-schema-overture \
  --track docs \
  --title "Update README with setup instructions and workflow pointer" \
  --priority low \
  --description "Add: quick start (docker-compose up), dev setup, pointer to AGENTS.md and docs/onboarding/."
```

Verify items:

```bash
sprintctl item list --sprint 2026-S01-forge-schema-overture
```

### 8. Create AGENTS.md

Create `AGENTS.md` with content specific to this repo. Don't copy verbatim from the template — adapt it.

Key sections to customize:
- Repo classification and purpose (this is `my-app`, a Python web service)
- Track taxonomy (core, api, infra, docs)
- Review policy (schema changes require review; API changes require review if public-facing)
- Sprint naming in use

### 9. Render the current sprint

```bash
sprintctl sprint render --sprint current --output docs/sprint/current.md
```

This creates `docs/sprint/current.md` showing the sprint state.

### 10. Verify everything works

```bash
# Sprint state
sprintctl sprint current

# Items
sprintctl item list --sprint current

# Claims (should be empty)
sprintctl claim list

# kctl
kctl list
```

Expected state:
- One active sprint with correct dates
- 8-10 shaped items across 4 tracks
- No stale claims
- AGENTS.md exists
- `docs/sprint/current.md` exists

### 11. Start working

Pick the highest priority item and claim it.

```bash
sprintctl item list --sprint current --state open --priority high

sprintctl claim create \
  --item CORE-001 \
  --context "Creating src/models.py with SQLAlchemy models. Will define User, Session, Event as described. Using declarative base with type annotations."
```

Bootstrap complete.

---

## What you produced

```
.sprintctl/config.yaml
.kctl/config.yaml
AGENTS.md
docs/sprint/current.md
docs/sprint/archive/         (empty, ready for archiving)
docs/knowledge/              (empty, ready for promotion)
```

Plus 8-10 sprintctl items and 1 active sprint.

---

## Common bootstrap mistakes

**Creating too many tracks** — 3-5 is right. 8 tracks is over-engineering.

**Creating vague items** — "Set up auth" is not a sprint item. "Implement POST /auth/register with JWT token return" is.

**Not creating AGENTS.md** — Agents entering this repo cold will have no orientation. AGENTS.md is not optional.

**Using placeholder names** — `2026-S01-sprint-one` is not a valid sprint name. Follow the naming convention.

**Forgetting to verify** — Always run the verification commands before considering bootstrap done.
