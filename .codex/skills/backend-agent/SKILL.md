---
name: 백엔드 엔지니어 (Backend)
canonical_id: skill.agent.backend
description: APIs, repositories, authentication, database access, and server-side business logic.
---

# 백엔드 엔지니어 (Backend)

## When to use
- Use this skill when the request matches: api, endpoint, backend, database, repository, auth, supabase.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `resources/api-template.py`
- `resources/checklist.md`
- `resources/error-playbook.md`
- `resources/examples.md`
- `resources/execution-protocol.md`
- `resources/snippets.md`
- `resources/tech-stack.md`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

