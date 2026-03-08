---
name: 디버깅 해결사 (Debug)
canonical_id: skill.agent.debug
description: Root-cause analysis, failure reproduction, and surgical fixes.
---

# 디버깅 해결사 (Debug)

## When to use
- Use this skill when the request matches: debug, bug, error, crash, hotfix, root cause.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/bug-report-template.md`
- `resources/checklist.md`
- `resources/common-patterns.md`
- `resources/debugging-checklist.md`
- `resources/error-playbook.md`
- `resources/examples.md`
- `resources/execution-protocol.md`
- `resources/report-template.md`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

