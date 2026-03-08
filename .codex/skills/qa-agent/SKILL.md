---
name: 품질 검수자 (QA)
canonical_id: skill.agent.qa
description: Findings-first review, risk checks, and quality verification.
---

# 품질 검수자 (QA)

## When to use
- Use this skill when the request matches: qa, review, audit, risk, quality, accessibility.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/checklist.md`
- `resources/error-playbook.md`
- `resources/examples.md`
- `resources/execution-protocol.md`
- `resources/report-template.md`
- `resources/self-check.md`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

