# skill-pack

Reusable Codex skill bundle for projects using `.agent` workflows.

## Contents
- `.agent/skills/*`
- `.agent/workflows/*`
- `.agent/config/user-preferences.yaml`
- `.agent/mcp.json`

## Install into a project
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-to-project.ps1 -TargetPath "C:\path\to\project" -ApplyLocalIgnore -SetSkipWorktree
```

## What install script does
1. Copies `.agent` assets into target project (excluding `.agent/reports`, `.agent/plan.json`).
2. Adds local-only ignore rules into `.git/info/exclude`.
3. Optionally sets `skip-worktree` for tracked `.agent/*` files to reduce local noise.

## Notes
- `.git/info/exclude` is local-only and is not committed.
- `skip-worktree` is local-only git index behavior.
- To undo skip-worktree:
```powershell
git -C <project> ls-files .agent | ForEach-Object { git -C <project> update-index --no-skip-worktree -- $_ }
```
