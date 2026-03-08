---
name: 한글 주석 검증 (Verify Korean Comments)
canonical_id: skill.verify.korean_comments
description: Validate Korean rationale and usage comments on new definitions.
---

# 한글 주석 검증 (Verify Korean Comments)

## When to use
- Use this skill when the request matches: korean comment, 한국어 주석, comment quality, why comment.
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

