---
name: 커밋 담당자 (Commit)
canonical_id: skill.workflow.commit
description: Conventional commit guidance and commit hygiene.
---

# 커밋 담당자 (Commit)

## When to use
- Use this skill when the request matches: commit, conventional commit, commit message, save changes.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/conventional-commits.md`
- `config/commit-config.yaml`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

