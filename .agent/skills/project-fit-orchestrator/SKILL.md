---
name: 🎶 맞춤형_총괄_조율자
description: Run project-fit customization and execute multiple verify skills in parallel from one entrypoint. Use when the user wants one skill execution that fans out into parallel validation tasks and returns an integrated report.
---

# Project Fit Orchestrator

## Purpose

Provide a one-command entrypoint that:

1. Applies project customization rules (optional).
2. Executes selected `verify-*` skills in parallel.
3. Writes one integrated report.

## Quick Start

Initialize config:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/project-fit-orchestrator/scripts/run-project-fit.ps1 -ConfigPath .agent/project-fit-orchestrator.json -Init
```

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/project-fit-orchestrator/scripts/run-project-fit.ps1 -ConfigPath .agent/project-fit-orchestrator.json
```

## Config

Template:

- `resources/project-fit-orchestrator.example.json`

Key options:

- `run_customizer_first`: apply project-customizer before parallel run
- `customization_config_paths`: one or more customizer config files
- `verify_skill_names`: verify skills to run (empty means auto-discover all)
- `report_path`: markdown output path

## Output

`report_path` markdown table:

| Skill | Status | Command Count | Failures |
|------|--------|---------------|----------|
