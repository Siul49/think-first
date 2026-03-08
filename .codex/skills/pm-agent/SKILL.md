---
name: 기획 관리자 (PM)
canonical_id: skill.agent.pm
description: Planning, scoping, task breakdown, and coordination guidance.
---

# 기획 관리자 (PM)

## When to use
- Use this skill when the request matches: plan, scope, breakdown, task, sprint, roadmap.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/error-playbook.md`
- `resources/examples.md`
- `resources/execution-protocol.md`
- `resources/task-template.json`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

