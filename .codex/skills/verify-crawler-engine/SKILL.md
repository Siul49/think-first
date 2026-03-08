---
name: 크롤러 엔진 검증 (Verify Crawler Engine)
canonical_id: skill.verify.crawler_engine
description: Validate crawler behavior, parsing rules, regex extraction, and scraping reliability.
---

# 크롤러 엔진 검증 (Verify Crawler Engine)

## When to use
- Use this skill when the request matches: crawler, parsing, regex, scraping, graphql.
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

