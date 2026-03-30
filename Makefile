.PHONY: help sprint-current knowledge-status agent-entry validate-docs

# Default target
help:
	@echo ""
	@echo "sprintctl-bootstrap-template — workflow helpers"
	@echo ""
	@echo "Targets:"
	@echo "  help              Show this message"
	@echo "  sprint-current    Show instructions for rendering current sprint"
	@echo "  knowledge-status  Show instructions for checking knowledge status"
	@echo "  agent-entry       Print agent entry checklist reminder"
	@echo "  validate-docs     Check that expected doc files exist"
	@echo ""
	@echo "Note: Actual sprint/knowledge operations require sprintctl and kctl."
	@echo "These targets are reminders and helpers, not full automation."
	@echo ""

sprint-current:
	@echo ""
	@echo "To render the current sprint snapshot:"
	@echo ""
	@echo "  sprintctl sprint render --sprint current --output docs/sprint/current.md"
	@echo ""
	@echo "To view current sprint state in terminal:"
	@echo ""
	@echo "  sprintctl sprint current"
	@echo "  sprintctl item list --sprint current"
	@echo ""
	@if [ -f docs/sprint/current.md ]; then \
		echo "Last render: docs/sprint/current.md exists."; \
		echo "  Head:"; \
		head -5 docs/sprint/current.md | sed 's/^/    /'; \
	else \
		echo "docs/sprint/current.md does not exist yet. Run the render command above."; \
	fi
	@echo ""

knowledge-status:
	@echo ""
	@echo "To check knowledge status:"
	@echo ""
	@echo "  kctl list                           # All entries"
	@echo "  kctl list --state candidate         # Pending promotion"
	@echo "  kctl list --state reviewed          # Ready to publish"
	@echo "  kctl list --state published         # Published entries"
	@echo ""
	@echo "To check sprint items tagged for knowledge promotion:"
	@echo ""
	@echo "  sprintctl item list --tag kctl-candidate"
	@echo ""
	@echo "Published knowledge entries in this repo:"
	@if [ -d docs/knowledge ] && [ "$$(ls -A docs/knowledge 2>/dev/null)" ]; then \
		ls docs/knowledge/*.md 2>/dev/null | sed 's|docs/knowledge/||' | sed 's/^/  - /'; \
	else \
		echo "  (none published yet)"; \
	fi
	@echo ""

agent-entry:
	@echo ""
	@echo "Agent entry checklist (quick reference):"
	@echo ""
	@echo "  1. cat AGENTS.md"
	@echo "  2. sprintctl sprint current"
	@echo "  3. sprintctl item list --sprint current"
	@echo "  4. sprintctl claim list"
	@echo "  5. Read handoff notes on items you're picking up:"
	@echo "       sprintctl item show <item-id>"
	@echo "  6. sprintctl item list --sprint current --state blocked"
	@echo "  7. Identify your track for this session"
	@echo "  8. Claim before starting: sprintctl claim create --item <id> --context '...'"
	@echo ""
	@echo "Full checklist: docs/agent-guidance/entry-checklist.md"
	@echo ""

validate-docs:
	@echo ""
	@echo "Validating expected documentation files..."
	@echo ""
	@MISSING=0; \
	for f in \
		README.md \
		AGENTS.md \
		Makefile \
		docs/onboarding/sprintctl-bootstrap.md \
		docs/sprint-naming.md \
		docs/sprint-workflow.md \
		docs/knowledge-workflow.md \
		docs/workflows/A-idea-to-backlog.md \
		docs/workflows/B-direct-implementation.md \
		docs/workflows/C-wider-scope-review.md \
		docs/workflows/D-knowledge-promotion.md \
		docs/workflows/E-fresh-repo-bootstrap.md \
		docs/examples/bootstrap-prompt.md \
		docs/examples/backlog-architecture-prompt.md \
		docs/examples/minimal-workflow.md \
		docs/examples/rendered-sprint-current.md \
		docs/agent-guidance/entry-checklist.md \
		docs/agent-guidance/handoff-patterns.md \
		docs/agent-guidance/claim-patterns.md \
		docs/artifacts/paths.md \
	; do \
		if [ -f "$$f" ]; then \
			echo "  [ok] $$f"; \
		else \
			echo "  [MISSING] $$f"; \
			MISSING=$$((MISSING + 1)); \
		fi; \
	done; \
	echo ""; \
	if [ $$MISSING -eq 0 ]; then \
		echo "All expected files present."; \
	else \
		echo "$$MISSING file(s) missing."; \
		exit 1; \
	fi
	@echo ""
