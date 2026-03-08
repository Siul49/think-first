# skill-pack

Reusable Codex bundle for projects that want a project-local `.codex` runtime pack.

## Branch Intent

- `main`: legacy `.agent`-first bundle history
- `codex/portable-bundle`: Codex-native portable bundle centered on `.codex`

## Contents

- `.codex/skills/*`
- `.codex/workflows/*`
- `.codex/config/user-preferences.yaml`
- `.codex/mcp.json`
- `.codex/skill-pack/*`
- `AGENTS.md`

## Included Packs

- `project-customizer`: generate project-specific Codex assets and sync local registries.
- `project-fit-orchestrator`: run customization and verification in one coordinated flow.
- `ensure-big-task-docs`: enforce plan/context/checklist discipline for larger tasks.
- `manage-skills`: maintain routing, registries, and validation scripts.

## Install Into a Project

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-to-project.ps1 -TargetPath "C:\path\to\project" -ApplyLocalIgnore -SetSkipWorktree
```

## One-Line Update

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync-project.ps1 -TargetPath "C:\path\to\project" -ApplyLocalIgnore -SetSkipWorktree
```

## What the Install Script Does

1. Copies the portable `.codex` bundle into the target project, excluding runtime-only `context` and `reports` contents.
2. Seeds `AGENTS.md` and `.codex/config/user-preferences.yaml` from the bundled templates when they are missing.
3. Adds local-only ignore rules into `.git/info/exclude` so the installed `.codex` bundle can stay untracked in the target repository.
4. Optionally sets `skip-worktree` for tracked `.codex/*` files when the target already versions them.

## Notes

- `.git/info/exclude` is local-only and is not committed.
- `skip-worktree` is local-only git index behavior.
- Runtime outputs are expected under `.codex/context/` and `.codex/reports/`; this repo tracks only placeholder files for those directories.
- To undo `skip-worktree`:

```powershell
git -C <project> ls-files .codex | ForEach-Object { git -C <project> update-index --no-skip-worktree -- $_ }
```
