# Portable Codex Bundle

This directory is the reusable project-local Codex bundle published by `skill-pack`. It packages skills, workflows, hooks, templates, and validation helpers under one portable `.codex` directory.

## Design Goals

- Keep all Codex runtime assets inside one portable `.codex` directory.
- Keep `SKILL.md` files concise to reduce context cost.
- Preserve bundled resources, workflows, hooks, and templates without relying on global state.
- Make installation repeatable through bundled scripts and templates.

## Layout

- `config/`: local user preferences for Codex behavior
- `context/`: task locks and compressed context packs (runtime output, not versioned beyond placeholders)
- `mcp.json`: project-local MCP reference
- `registry/`: bundle catalog and migration map
- `reports/`: generated inventory and validation output (runtime output, not versioned beyond placeholders)
- `skill-pack/`: profile, templates, and installer-like scripts
- `skills/`: local skills plus `_shared` runtime scripts
- `subagent/`: template manifest for skill-lock orchestration
- `scripts/`: bundle-level sync, validate, and inventory helpers
- `workflows/`: human-readable workflow playbooks
