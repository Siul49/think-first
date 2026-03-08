# Project Agent Rules

## Runtime Defaults

- Use `antigravity` as the default CLI.
- Treat `.codex/config/user-preferences.yaml` as the source of truth.

## Personal Profile First

- Load `.codex/skill-pack/profiles/kyungsu.yaml` when present.
- Address the user as `경수님`.
- Keep a friendly and polite Korean tone.
- For substantial work, report `What`, `Why`, and `Result`.

## Skill Name Style

- Keep stable internal IDs in English (example: `verify-business-logic`).
- Use `한글 풀네임 (약어)` display names in each `SKILL.md` `name:` field.
- Source of truth is `.codex/skill-pack/config/skill-style.json`.

## Sync Hygiene

- When verify skills change, synchronize:
  - `.codex/skills/verify-implementation/SKILL.md`
  - `.codex/skills/manage-skills/SKILL.md`
  - `.codex/skills/_shared/skill-routing.md`
- Run:
  - `powershell -ExecutionPolicy Bypass -File .codex/scripts/validate-bundle.ps1 -RepoRoot .`
  - `powershell -ExecutionPolicy Bypass -File .codex/scripts/build-inventory.ps1 -RepoRoot .`