---
description: Coordinate multiple agents for a complex multi-domain project using PM planning, parallel agent spawning, and QA review
---

# MANDATORY RULES — VIOLATION IS FORBIDDEN

- **Response language follows `language` setting in `.agent/config/user-preferences.yaml` if configured.**
- **NEVER skip steps.** Execute from Step 0 in order. Explicitly report completion of each step to the user before proceeding to the next.
- **You MUST use MCP tools throughout the entire workflow.** This is NOT optional.
  - Use code analysis tools (`get_symbols_overview`, `find_symbol`, `find_referencing_symbols`, `search_for_pattern`) for code exploration.
  - Use memory tools (read/write/edit) for progress tracking.
  - Memory path: configurable via `memoryConfig.basePath` (default: `.serena/memories`)
  - Tool names: configurable via `memoryConfig.tools` in `mcp.json`
  - Do NOT use raw file reads or grep as substitutes. MCP tools are the primary interface for code and memory operations.
- **Read the workflow-guide BEFORE starting.** Read `.agent/skills/workflow-guide/SKILL.md` and follow its Core Rules.
- **Follow the context-loading guide.** Read `.agent/skills/_shared/context-loading.md` and load only task-relevant resources.

---

## Step 0: Preparation (DO NOT SKIP)

1. Read `.agent/skills/workflow-guide/SKILL.md` and confirm Core Rules.
2. Read `.agent/skills/_shared/context-loading.md` for resource loading strategy.
3. Read `.agent/skills/_shared/memory-protocol.md` for memory protocol.
4. Record session start using memory write tool:
   - Create `session-coordinate.md` in the memory base path
   - Include: session start time, user request summary.
5. Initialize big-task docs pack (plan/context/checklist):

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/_shared/ensure-big-task-docs.ps1 -Workspace . -Mode Init -TaskId <task-id>
```

---

## Step 1: Analyze Requirements

Analyze the user's request and identify involved domains (🎨 프론트엔드_엔지니어, ⚙️ 백엔드_엔지니어, 📱 모바일_엔지니어, 🔎 QA_검수자).

- Single domain: suggest using the specific agent directly.
- Multiple domains: proceed to Step 2.
- Use MCP code analysis tools (`get_symbols_overview` or `search_for_pattern`) to understand the existing codebase structure relevant to the request.
- Report analysis results to the user.

---

## Step 2: Run 💡 기획자_PM for Task Decomposition

// turbo
Activate 💡 기획자_PM to:

1. Analyze requirements.
2. Define API contracts.
3. Create a prioritized task breakdown.
4. Save plan to `.agent/plan.json`.
5. Use memory write tool to record plan completion.

---

## Step 3: Review Plan with User

Present the 💡 기획자_PM's task breakdown to the user:

- Priorities (P0, P1, P2)
- Agent assignments
- Dependencies
- **You MUST get user confirmation before proceeding to Step 4.** Do NOT proceed without confirmation.

---

## Step 4: Spawn Agents by Priority Tier

// turbo
Spawn agents using CLI for each task:

```bash
# Example: spawn backend and frontend in parallel
oh-my-ag agent:spawn "⚙️ 백엔드_엔지니어" "task description" session-id ./backend &
oh-my-ag agent:spawn "🎨 프론트엔드_엔지니어" "task description" session-id ./frontend &
wait
```

1. Use spawn-agent.sh for each task (respects agent_cli_mapping from user-preferences.yaml)
2. Spawn all same-priority tasks in parallel using background processes
3. Assign separate workspaces to avoid file conflicts
4. Before each subtask spawn, record review checkpoint:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/_shared/ensure-big-task-docs.ps1 -Workspace . -Mode Review -TaskId <task-id> -SubtaskNote "<agent>/<task>"
```

---

## Step 5: Monitor Agent Progress

- Use memory read tool to poll `progress-{agent}.md` files
- Use MCP code analysis tools (`find_symbol` and `search_for_pattern`) to verify API contract alignment between agents
- Use memory edit tool to record monitoring results

---

## Step 6: Run 🔎 QA_검수자 Review

After all implementation agents complete, spawn 🔎 QA_검수자 to review all deliverables:

- Security (OWASP Top 10)
- Performance
- Accessibility (WCAG 2.1 AA)
- Code quality

---

## Step 7: Address Issues and Iterate

If 🔎 QA_검수자 finds CRITICAL or HIGH issues:

1. Re-spawn the responsible agent with 🔎 QA_검수자 findings.
2. Repeat Steps 5-7.
3. Continue until all critical issues are resolved.
4. Use memory write tool to record final results.
