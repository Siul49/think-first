# Skill Routing Map

Routing rules for orchestrator and workflow-guide to assign requests to the right skill.

---

## Keyword -> Skill Mapping

| User Request Keywords | Primary Skill | Notes |
|----------------------|---------------|-------|
| API, endpoint, REST, GraphQL, database, migration | **backend-agent** | |
| auth, JWT, login, register, password | **backend-agent** | Auth UI can be delegated to frontend-agent |
| UI, component, page, form, screen (web) | **frontend-agent** | |
| style, Tailwind, responsive, CSS | **frontend-agent** | |
| mobile, iOS, Android, Flutter, React Native, app | **mobile-agent** | |
| offline, push notification, camera, GPS | **mobile-agent** | |
| debugger, fix error, root cause, reproduce failure, hotfix | **debug-agent** | Focused-debug mode |
| bug, error, crash, broken, slow | **debug-agent** | Full-debug mode |
| reviewer, review request, code review, audit, risk check | **qa-agent** | Focused-review mode |
| review, security, performance | **qa-agent** | Full-qa mode |
| accessibility, WCAG, a11y | **qa-agent** | |
| plan, breakdown, task, sprint | **pm-agent** | |
| verify, validation, compliance, implementation check | **verify-implementation** | Run cross-skill verification after implementation |
| trace id, observability, log masking, middleware chain | **verify-observability** | Validate tracing/logging contracts and middleware wiring |
| room parser, room collection, room pipeline, dto alias | **verify-room-pipeline** | Validate room data pipeline consistency |
| manage-skills, skill maintenance, verification skill setup | **manage-skills** | Maintain and evolve verify skills for this repo |
| preflight, postflight, workflow automation, guardrail, hook migration | **orchestrator** | Uses `_shared/preflight.ps1`, `_shared/verify.ps1`, `_shared/postflight.ps1` |
| automatic, parallel, orchestrate | **orchestrator** | |
| workflow, guide, manual, step-by-step | **workflow-guide** | |
| commit, save changes, conventional commit | **commit** | Commit workflow and message policy |

---

## Complex Request Routing

| Request Pattern | Execution Order |
|----------------|-----------------|
| "Create a fullstack app" | pm -> (backend + frontend) parallel -> qa |
| "Create a mobile app" | pm -> (backend + mobile) parallel -> qa |
| "Fullstack + mobile" | pm -> (backend + frontend + mobile) parallel -> qa |
| "Fix bug and review" | debug -> qa |
| "Review this change set now" | qa (focused-review mode) |
| "Fix this crash now" | debug (focused-debug mode) |
| "Add feature and test" | pm -> relevant agent -> qa |
| "Run verify checks before PR" | verify-implementation |
| "Create/update verification skills" | manage-skills |
| "Do everything automatically" | orchestrator (internally pm -> agents -> qa) |
| "I'll manage manually" | workflow-guide |

---

## Inter-Agent Dependency Rules

### Parallel Execution Possible
- backend + frontend (when API contract is pre-defined)
- backend + mobile (when API contract is pre-defined)
- frontend + mobile (independent of each other)

### Sequential Execution Required
- pm -> all other agents (planning comes first)
- implementation agent -> qa (review after implementation complete)
- implementation agent -> debug (debugging after implementation complete)
- backend -> frontend/mobile (when API contract is not fixed)

### QA Is Always Last
- qa-agent runs after all implementation tasks are complete
- Exception: immediate focused-review for explicit user review requests

---

## Escalation Rules

| Situation | Escalation Target |
|-----------|------------------|
| Agent finds bug in different domain | Create task for debug-agent |
| QA finds CRITICAL issue | Re-run relevant domain agent |
| Architecture change needed | Request re-planning from pm-agent |
| Performance issue found during implementation | Current agent fixes, debug-agent if severe |
| API contract mismatch | Orchestrator re-runs backend-agent |

---

## Turn Limit Guide by Agent

| Agent | Default Turns | Max Turns (including retries) |
|-------|--------------|------------------------------|
| pm-agent | 10 | 15 |
| backend-agent | 20 | 30 |
| frontend-agent | 20 | 30 |
| mobile-agent | 20 | 30 |
| debug-agent | 15 | 25 |
| qa-agent | 15 | 20 |
| orchestrator | 20 | 30 |

---

## Skills

| Skill | Description |
|------|-------------|
| verify-implementation | Run all verification skills and produce an integrated report |
| verify-observability | Validate Trace ID, log masking, and middleware chain contracts |
| verify-room-pipeline | Validate room collection/parsing/DTO mapping consistency |
| commit | Create conventional commits with project rules |
| manage-skills | Maintain skill quality and verify coverage mapping |