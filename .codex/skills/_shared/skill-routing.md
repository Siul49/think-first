# Skill Routing Map

Routing rules for local Codex orchestration.

1. Check explicitly named skills first.
2. Match keywords in the routing table below.
3. Fall back to `skill.workflow.guide` for low-risk/manual work.

## Antigravity-First Profile

- Default CLI is managed in `.codex/config/user-preferences.yaml`.
- Preferred entry skills: `skill.workflow.project_fit_orchestrator`, `skill.verify.implementation`, `skill.governance.manage_skills`, `skill.workflow.guide`.

## Skill Display Style

| Skill ID | Display Name |
|----------|--------------|
| skill.agent.backend | 백엔드 엔지니어 (Backend) |
| skill.agent.frontend | 프론트엔드 엔지니어 (Frontend) |
| skill.agent.mobile | 모바일 엔지니어 (Mobile) |
| skill.agent.debug | 디버깅 해결사 (Debug) |
| skill.agent.qa | 품질 검수자 (QA) |
| skill.agent.pm | 기획 관리자 (PM) |
| skill.workflow.orchestrator | 워크플로우 오케스트레이터 (Orchestrator) |
| skill.workflow.guide | 워크플로우 가이드 (Guide) |
| skill.workflow.commit | 커밋 담당자 (Commit) |
| skill.workflow.project_customizer | 프로젝트 커스터마이저 (Customizer) |
| skill.workflow.project_fit_orchestrator | 프로젝트 맞춤 조율자 (Project Fit) |
| skill.governance.manage_skills | 스킬 관리 (Manage Skills) |
| skill.verify.implementation | 구현 검증 파이프라인 (Verify Implementation) |
| skill.verify.observability | 관측성 검증 (Verify Observability) |
| skill.verify.room_pipeline | 룸 파이프라인 검증 (Verify Room Pipeline) |
| skill.verify.api_schema | API 스키마 검증 (Verify API Schema) |
| skill.verify.database_layer | 데이터베이스 레이어 검증 (Verify Database Layer) |
| skill.verify.crawler_engine | 크롤러 엔진 검증 (Verify Crawler Engine) |
| skill.verify.business_logic | 비즈니스 로직 검증 (Verify Business Logic) |
| skill.verify.korean_comments | 한글 주석 검증 (Verify Korean Comments) |
| skill.governance.karpathy_guidelines | 카파시 가이드라인 (Karpathy) |

## Keyword -> Skill Mapping

| User Request Keywords | Primary Skill | Notes |
|----------------------|---------------|-------|
| api, endpoint, backend, database, repository, auth, supabase | **skill.agent.backend** | APIs, repositories, authentication, database access, and server-side business logic. |
| ui, frontend, component, page, form, tailwind, css | **skill.agent.frontend** | Web UI, forms, components, styling, and browser-side integration. |
| mobile, ios, android, flutter, react native, app | **skill.agent.mobile** | Mobile screens, device capabilities, and mobile-first integration patterns. |
| debug, bug, error, crash, hotfix, root cause | **skill.agent.debug** | Root-cause analysis, failure reproduction, and surgical fixes. |
| qa, review, audit, risk, quality, accessibility | **skill.agent.qa** | Findings-first review, risk checks, and quality verification. |
| plan, scope, breakdown, task, sprint, roadmap | **skill.agent.pm** | Planning, scoping, task breakdown, and coordination guidance. |
| orchestrate, run-task, skill-lock, guardrail, automation | **skill.workflow.orchestrator** | Create task locks, choose templates, and coordinate multi-skill execution. |
| workflow, guide, manual, docs, refactor, wording | **skill.workflow.guide** | Manual fallback workflow for docs, naming, and lightweight coordination. |
| commit, conventional commit, commit message, save changes | **skill.workflow.commit** | Conventional commit guidance and commit hygiene. |
| customize, skill bootstrap, project customization, verify skill | **skill.workflow.project_customizer** | Customize local skill packs and project-specific Codex assets. |
| project fit, parallel verify, customizer, one-skill parallel | **skill.workflow.project_fit_orchestrator** | Run project-fit customization and verification in one coordinated flow. |
| manage skills, skill maintenance, registry, routing, verify coverage | **skill.governance.manage_skills** | Maintain skill coverage, registries, routing maps, and validation scripts. |
| verify, validation, implementation check, pre-pr, compliance | **skill.verify.implementation** | Run all project verify skills and consolidate the results. |
| observability, trace id, log masking, middleware | **skill.verify.observability** | Validate trace IDs, log masking, and middleware observability guardrails. |
| room pipeline, room parser, dto alias, room collection | **skill.verify.room_pipeline** | Validate room collection, parsing, DTO aliases, and pipeline consistency. |
| api schema, dto, router, swagger, api contract | **skill.verify.api_schema** | Validate routers, DTOs, request/response models, and API contract integrity. |
| database, repository, crud, sql, db schema | **skill.verify.database_layer** | Validate repositories, CRUD paths, schema assumptions, and query safety. |
| crawler, parsing, regex, scraping, graphql | **skill.verify.crawler_engine** | Validate crawler behavior, parsing rules, regex extraction, and scraping reliability. |
| business logic, scheduler, batch, domain service, exception | **skill.verify.business_logic** | Validate service-layer rules, scheduling, exceptions, and domain behaviors. |
| korean comment, 한국어 주석, comment quality, why comment | **skill.verify.korean_comments** | Validate Korean rationale and usage comments on new definitions. |
| karpathy, simplicity, minimal diff, goal-driven, surgical | **skill.governance.karpathy_guidelines** | Keep solutions simple, surgical, and goal-driven. |

## Verify Summary

| Skill | Purpose |
|------|---------|
| skill.verify.implementation | Run all project verify skills and summarize the result. |
| skill.verify.api_schema | Validate routers, DTOs, and API contracts. |
| skill.verify.database_layer | Validate repository/database consistency. |
| skill.verify.crawler_engine | Validate crawler/parsing engine behavior. |
| skill.verify.business_logic | Validate service-layer rules and exceptions. |
| skill.verify.room_pipeline | Validate room collection/parsing/DTO mapping. |
| skill.verify.observability | Validate trace/logging guardrails. |
| skill.verify.korean_comments | Validate rationale/usage comments for new definitions. |

