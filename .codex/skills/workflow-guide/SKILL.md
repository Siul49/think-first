---
name: 워크플로우 가이드 (Guide)
canonical_id: skill.workflow.guide
description: Manual fallback workflow for docs, naming, and lightweight coordination.
---

# 워크플로우 가이드 (Guide)

## When to use
- Use this skill when the request matches: workflow, guide, manual, docs, refactor, wording.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use for large code changes that need stronger domain routing.
- Avoid deep debugging when a failure-specific skill is available.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/examples.md`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

