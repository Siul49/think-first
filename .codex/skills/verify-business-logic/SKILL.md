---
name: 비즈니스 로직 검증 (Verify Business Logic)
canonical_id: skill.verify.business_logic
description: Validate service-layer rules, scheduling, exceptions, and domain behaviors.
---

# 비즈니스 로직 검증 (Verify Business Logic)

## When to use
- Use this skill when the request matches: business logic, scheduler, batch, domain service, exception.
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

