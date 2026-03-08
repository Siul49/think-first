---
name: 프로젝트 커스터마이저 (Customizer)
canonical_id: skill.workflow.project_customizer
description: Customize local skill packs and project-specific Codex assets.
---

# 프로젝트 커스터마이저 (Customizer)

## When to use
- Use this skill when the request matches: customize, skill bootstrap, project customization, verify skill.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/customization-config.example.json`
- `scripts/apply-project-customization.ps1`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

