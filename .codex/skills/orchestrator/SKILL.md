---
name: 워크플로우 오케스트레이터 (Orchestrator)
canonical_id: skill.workflow.orchestrator
description: Create task locks, choose templates, and coordinate multi-skill execution.
---

# 워크플로우 오케스트레이터 (Orchestrator)

## When to use
- Use this skill when the request matches: orchestrate, run-task, skill-lock, guardrail, automation.
- Prefer bundled resources and existing repository patterns before adding new structure.

## When NOT to use
- Do not use this as a catch-all skill when a more specific domain skill fits better.
- Avoid unrelated refactors outside the current request scope.

## Execution Rules
- Work only within the current request scope.
- Keep diffs surgical and explain assumptions before risky changes.
- Load `../_shared/` only when the local resources are insufficient.

## Available References
- Use sibling shared assets from `../_shared/` when needed.

## Reporting
- Summarize changed files, verification steps, risks, and decisions when the work is substantial.

