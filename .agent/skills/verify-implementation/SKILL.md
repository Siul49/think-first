---
name: verify-implementation
description: Run all registered verify skills in sequence and produce a consolidated validation report. Use after feature implementation, before PR, or during final review.
disable-model-invocation: true
argument-hint: "[optional: verify-skill-name]"
---

# Verify Implementation

## Purpose

Execute `verify-*` skills consistently and summarize pass/fail status with actionable findings.

## When to run

- After implementing new features
- Before opening a PR
- During release readiness review
- After major refactoring

## Execution list

| # | Skill | Description |
|---|------|-------------|
| 1 | `verify-observability` | Validate Trace ID and logging contracts |
| 2 | `verify-room-pipeline` | Validate room parser/collector/DTO consistency |

## Workflow

### Step 1: Select scope

- If an argument is provided, run only that verify skill.
- Otherwise run all skills in the execution list.

### Step 2: Execute each verify skill

For each selected skill:

1. Read skill workflow and related files.
2. Run checks in order.
3. Capture PASS/FAIL and evidence.
4. Capture remediation guidance for failures.

### Step 3: Build consolidated report

Return one table:

| Skill | Status | Findings | Key evidence |
|------|--------|----------|--------------|
| verify-xxx | PASS/FAIL | N | `path:line` |

### Step 4: Remediation loop (optional)

If failures exist, ask whether to:

1. Apply all recommended fixes
2. Apply selected fixes only
3. Skip fixes

After fixes, re-run only failed verify skills.

## Exceptions

- If no verify skills are registered, report and stop.
- `verify-implementation` must never include itself in the execution list.

## Related Files

| File | Purpose |
|------|---------|
| `.agent/skills/manage-skills/SKILL.md` | Verify skill registry maintenance |
| `.agent/skills/_shared/skill-routing.md` | Routing and skills summary |