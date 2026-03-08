---
name: 카파시 가이드라인 (Karpathy)
canonical_id: skill.governance.karpathy_guidelines
description: Keep solutions simple, surgical, and goal-driven.
---

# 카파시 가이드라인 (Karpathy)

## When to use
- Use this skill when the request matches: karpathy, simplicity, minimal diff, goal-driven, surgical.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/karpathy-guidelines.md`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

