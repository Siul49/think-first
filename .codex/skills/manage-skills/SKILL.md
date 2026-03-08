---
name: 스킬 관리 (Manage Skills)
canonical_id: skill.governance.manage_skills
description: Maintain skill coverage, registries, routing maps, and validation scripts.
---

# 스킬 관리 (Manage Skills)

## When to use
- Use this skill when the request matches: manage skills, skill maintenance, registry, routing, verify coverage.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- `scripts/scripts`
- `scripts/validate-skill-links.ps1`
- `scripts/validate-verify-registry.ps1`

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

