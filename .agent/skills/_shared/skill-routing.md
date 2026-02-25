# Skill Routing Map

Routing rules for orchestrator and workflow-guide to assign requests to the right skill.

---

## Mandatory Turn-Start Rule

Before any execution, resolve and announce relevant skills for the current user request.

1. Check explicitly named skills first.
2. Then match keywords in this routing map.
3. If no direct match exists, choose the best fallback skill and state why.
4. Apply this on every user turn.

---

## Keyword -> Skill Mapping

| User Request Keywords | Primary Skill | Notes |
|----------------------|---------------|-------|
| API, endpoint, REST, GraphQL, database, migration | **⚙️ 백엔드_엔지니어** | |
| auth, JWT, login, register, password | **⚙️ 백엔드_엔지니어** | Auth UI can be delegated to 🎨 프론트엔드_엔지니어 |
| UI, component, page, form, screen (web) | **🎨 프론트엔드_엔지니어** | |
| style, Tailwind, responsive, CSS | **🎨 프론트엔드_엔지니어** | |
| mobile, iOS, Android, Flutter, React Native, app | **📱 모바일_엔지니어** | |
| offline, push notification, camera, GPS | **📱 모바일_엔지니어** | |
| debugger, fix error, root cause, reproduce failure, hotfix | **🐛 디버깅_해결사** | Focused-debug mode |
| bug, error, crash, broken, slow | **🐛 디버깅_해결사** | Full-debug mode |
| reviewer, review request, code review, audit, risk check | **🔎 QA_검수자** | Focused-review mode |
| review, security, performance | **🔎 QA_검수자** | Full-qa mode |
| accessibility, WCAG, a11y | **🔎 QA_검수자** | |
| plan, breakdown, task, sprint | **💡 기획자_PM** | |
| verify, validation, compliance, implementation check | **✅ 검증_파이프라인_구현** | Run cross-skill verification after implementation |
| trace id, observability, log masking, middleware chain | **✅ 검증_파이프라인_관측성** | Validate tracing/logging contracts and middleware wiring |
| room parser, room collection, room pipeline, dto alias | **✅ 검증_파이프라인_데이터** | Validate room data pipeline consistency |
| manage-skills, skill maintenance, verification skill setup | **🗂️ 스킬_관리자** | Maintain and evolve verify skills for this repo |
| project customization, customize verify skill, skill bootstrap, 스킬 커스터마이징 | **🚀 프로젝트_커스터마이저** | Generate project-fit verify skills from config |
| project fit orchestrator, 병렬 스킬 실행, one-skill parallel, project fit runner | **🎶 맞춤형_총괄_조율자** | One entrypoint to run project-fit verify skills in parallel |
| preflight, postflight, workflow automation, guardrail, hook migration | **🎼 총괄_조율자** | Uses `_shared/preflight.ps1`, `_shared/verify.ps1`, `_shared/postflight.ps1` |
| automatic, parallel, orchestrate | **🎼 총괄_조율자** | |
| workflow, guide, manual, step-by-step | **📖 워크플로우_가이드** | |
| commit, save changes, conventional commit | **📦 커밋_담당자** | Commit workflow and message policy |

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
| project-customizer | Bootstrap project-specific verify skill generation workflow |
| project-fit-orchestrator | Run project-fit customization and parallel verify execution with one command |
| commit | Create conventional commits with project rules |
| manage-skills | Maintain skill quality and verify coverage mapping |
