# Subagent Template System

This directory defines reusable subagent execution templates for `run-task.ps1`.

## Files

- `template-manifest.json`: template catalog, matching keywords, skill chains, and token/context budgets.

## Behavior

1. `run-task.ps1` selects a template by keyword match.
2. If no match is found, default template is used.
3. Selected template writes token/context/report schema metadata into `skill-lock.json`.
4. Context pack is generated for compressed worker input.

## Notes

- Internal skill IDs remain stable.
- Karpathy guardrails are auto-injected for code-oriented chains unless explicitly disabled.
