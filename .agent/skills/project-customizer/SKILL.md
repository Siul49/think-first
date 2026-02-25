---
name: 🚀 프로젝트_커스터마이저
description: Create or update project-specific verify skills from a JSON config, then synchronize verify-implementation, manage-skills registry, and skill-routing in one run. Use when the user wants "customize skill and just run it".
---

# Project Customizer

## Purpose

Generate project-fit `verify-*` skills and keep routing/registry files synchronized with one command.

## Quick Start

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/project-customizer/scripts/apply-project-customization.ps1 -ConfigPath .agent/project-customization.json -Init
```

Fill `.agent/project-customization.json`, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/project-customizer/scripts/apply-project-customization.ps1 -ConfigPath .agent/project-customization.json -RunValidation
```

## What It Updates

1. `.agent/skills/<verify-skill>/SKILL.md` (create or overwrite)
2. `.agent/skills/verify-implementation/SKILL.md` execution table
3. `.agent/skills/manage-skills/SKILL.md` registered verify table
4. `.agent/skills/_shared/skill-routing.md`
   - keyword mapping row
   - skills summary row

## Config Reference

Use template:

- `resources/customization-config.example.json`

Required keys:

- `verify_skill_name`
- `verify_skill_description`
- `execution_description`
- `routing_keywords` (array)
- `coverage_patterns` (array)
- `related_files` (array of `{file,purpose}`)
- `checks` (array of `{name,command,pass_criteria}`)
- `exceptions` (array)

## Notes

- `verify_skill_name` must start with `verify-`.
- Re-running with same skill name updates the same skill and skips duplicate table rows.
