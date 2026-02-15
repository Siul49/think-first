---
name: manage-skills
description: Analyze repository changes, detect missing verification coverage, and maintain verify skills plus routing metadata. Use when users ask to add/update/remove skills, especially verify-* skills.
disable-model-invocation: true
argument-hint: "[optional: skill-name or target area]"
---

# Manage Skills

## Purpose

Keep `.agent/skills` consistent and executable.

1. Detect changed areas not covered by existing verify skills.
2. Detect stale references to missing files.
3. Propose update/create/delete actions for skills.
4. Keep `verify-implementation` and `_shared/skill-routing.md` synchronized.

## When to run

- New feature introduces new validation rules.
- Existing verify workflow misses changed files.
- Skill references break after refactor.
- Before PR when agent/verify infrastructure changed.

## Registered verify skills

| Skill | Description | Coverage patterns |
|------|-------------|-------------------|
| `verify-observability` | Validate Trace ID and logging contracts | `app/core/**/*.py`, `app/main.py`, `tests/core/**/*.py` |
| `verify-room-pipeline` | Validate room parsing/collection/DTO pipeline | `app/services/**/*.py`, `app/models/dto.py`, `app/utils/room_loader.py`, `tests/{api,services}/**/*.py`, `scripts/**/*.py` |

## Workflow

### Step 1: Collect changed files

Use git diff and group by top-level area.

```bash
git diff --name-only HEAD
git diff main...HEAD --name-only
```

### Step 2: Map changed files to verify skills

- Compare changed files with each verify skill's Related Files and workflow checks.
- Mark files as `COVERED`, `PARTIAL`, or `UNCOVERED`.

### Step 3: Decide action

- `UPDATE`: Existing verify skill is related but missing checks/files.
- `CREATE`: New repeated validation need across >=3 related files.
- `DELETE`: Skill is obsolete and no longer mapped.

### Step 4: Apply synchronized updates

When creating/updating verify skills, update all three:

1. `.agent/skills/manage-skills/SKILL.md` (registered verify table)
2. `.agent/skills/verify-implementation/SKILL.md` (execution list)
3. `.agent/skills/_shared/skill-routing.md` (skills summary)

### Step 5: Validate links and references

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/manage-skills/scripts/validate-skill-links.ps1
```

### Step 6: Report

Return:

- changed files analyzed
- updated/created/deleted skills
- uncovered files (if any)
- follow-up recommendations

## Related Files

| File | Purpose |
|------|---------|
| `.agent/skills/verify-implementation/SKILL.md` | Verify orchestration skill list |
| `.agent/skills/_shared/skill-routing.md` | Routing/skills registry |
| `.agent/skills/manage-skills/scripts/validate-skill-links.ps1` | Broken reference detector |