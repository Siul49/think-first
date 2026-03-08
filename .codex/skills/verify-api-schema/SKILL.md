---
name: API 스키마 검증 (Verify API Schema)
canonical_id: skill.verify.api_schema
description: Validate routers, DTOs, request/response models, and API contract integrity.
---

# API 스키마 검증 (Verify API Schema)

## When to use
- Use this skill when the request matches: api schema, dto, router, swagger, api contract.
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

