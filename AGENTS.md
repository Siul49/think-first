# Project Agent Rules

## Codex Bundle First

- Use the project-local `.codex` bundle as the source of truth for Codex runtime assets.
- Treat `.codex/config/user-preferences.yaml` as the source of truth for CLI priority and per-agent mapping.
- Keep Serena MCP context aligned with `.codex/mcp.json` (`--context antigravity`).

## Personal Profile First

- Load `.codex/skill-pack/profiles/kyungsu.yaml` first when present.
- Address the user as `경수님`.
- Keep a friendly but polite Korean tone.
- For substantial work reports, include `What`, `Why`, and `Result`.

## Karpathy Guardrails

- Prefer simple, request-scoped implementation over speculative abstractions.
- Make surgical diffs and avoid unrelated refactors.
- Surface assumptions and tradeoffs before coding when ambiguous.
- Define success checks first, then implement and verify.

## Skillset Scope

- Prefer project-local skills in `.codex/skills` over global skill catalogs unless the user explicitly requests a global skill.
- Default entry skills for routine work:
  - `project-fit-orchestrator`
  - `verify-implementation`
  - `manage-skills`
  - `workflow-guide`

## Sync Hygiene

- When verify skills change, keep these synchronized:
  - `.codex/skills/verify-implementation/SKILL.md`
  - `.codex/skills/manage-skills/SKILL.md`
  - `.codex/skills/_shared/skill-routing.md`
- Run:
  - `powershell -ExecutionPolicy Bypass -File .codex/scripts/validate-bundle.ps1 -RepoRoot .`
  - `powershell -ExecutionPolicy Bypass -File .codex/scripts/build-inventory.ps1 -RepoRoot .`

## Skill-Lock Guardrail

- Do not start implementation directly.
- Always create task lock first:
  - `powershell -ExecutionPolicy Bypass -File .codex/skills/_shared/run-task.ps1 -TaskText "<user-request>" -Workspace . -AgentType orchestrator`
- If no matching skill keyword is found, `run-task.ps1` automatically falls back to `workflow-guide`.
- For truly skill-free work, use explicit exception:
  - `powershell -ExecutionPolicy Bypass -File .codex/skills/_shared/run-task.ps1 -TaskText "<user-request>" -Workspace . -AgentType orchestrator -NoSkill -NoSkillReason "<why no skill is needed>"`
- `preflight.ps1` enforces lock validation and blocks execution when lock is missing or mismatched.

## Subagent Template Engine

- `run-task.ps1` selects subagent template from `.codex/subagent/template-manifest.json`.
- Selected template writes `token_budget`, `context_budget`, `report_schema`, and `context_pack_path` into the skill-lock.
- Context compression is mandatory for code tasks via `.codex/skills/_shared/build-context-pack.ps1`.
- Code-oriented chains automatically include `karpathy-guidelines` unless `-DisableKarpathy` is explicitly set.
