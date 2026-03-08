---
name: 프로젝트 맞춤 조율자 (Project Fit)
canonical_id: skill.workflow.project_fit_orchestrator
description: Run project-fit customization and verification in one coordinated flow.
---

# 프로젝트 맞춤 조율자 (Project Fit)

## When to use
- Use this skill when the request matches: project fit, parallel verify, customizer, one-skill parallel.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/project-fit-orchestrator.example.json`
- `scripts/run-project-fit.ps1`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

