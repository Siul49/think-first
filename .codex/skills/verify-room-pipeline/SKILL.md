---
name: 룸 파이프라인 검증 (Verify Room Pipeline)
canonical_id: skill.verify.room_pipeline
description: Validate room collection, parsing, DTO aliases, and pipeline consistency.
---

# 룸 파이프라인 검증 (Verify Room Pipeline)

## When to use
- Use this skill when the request matches: room pipeline, room parser, dto alias, room collection.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use as the primary implementation skill for new features.
- Avoid docs-only tasks that do not need runtime verification.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- Use sibling shared assets from `../_shared/` when needed.

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

