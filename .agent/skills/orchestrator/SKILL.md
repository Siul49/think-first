---
name: orchestrator
description: Automated multi-agent orchestrator that coordinates planning, parallel execution, verification, and reporting with shared memory
---

# Orchestrator - Automated Multi-Agent Coordinator

## When to use
- Complex feature requires multiple specialized agents working in parallel
- User wants automated execution without manually spawning agents
- Full-stack implementation spanning backend, frontend, mobile, and QA
- User asks for preflight/postflight automation and verification gates

## When NOT to use
- Simple single-domain task -> use the specific agent directly
- User wants step-by-step manual control -> use workflow-guide
- Quick bug fixes or minor changes

## Important
This skill orchestrates CLI subagents and tracks shared state through MCP memory tools.

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| MAX_PARALLEL | 3 | Max concurrent subagents |
| MAX_RETRIES | 2 | Retry attempts per failed task |
| POLL_INTERVAL | 30s | Status check interval |
| MAX_TURNS (impl) | 20 | Turn limit for backend/frontend/mobile |
| MAX_TURNS (review) | 15 | Turn limit for qa/debug |
| MAX_TURNS (plan) | 10 | Turn limit for pm |

## Memory Configuration

Memory provider and tool names are configurable via `mcp.json`.

## Workflow Phases

**PHASE 0.5 - Preflight**: Run `../_shared/preflight.ps1 -Workspace {workspace} -AgentType orchestrator` before spawning agents.
**PHASE 1 - Plan**: Analyze request -> decompose tasks -> generate session ID.
**PHASE 2 - Setup**: Create `orchestrator-session.md` and `task-board.md` in memory.
**PHASE 3 - Execute**: Spawn agents by priority tier (never exceed MAX_PARALLEL).
**PHASE 4 - Monitor**: Poll by `POLL_INTERVAL`; handle completed/failed/crashed agents.
**PHASE 4.5 - Verify**: Run `../_shared/verify.ps1 -AgentType {agent-type} -Workspace {workspace}` per completed agent.
**PHASE 5 - Collect**: Read all `result-{agent}.md`, compile summary, cleanup progress files.
**PHASE 5.5 - Postflight**: Run `../_shared/postflight.ps1 -Workspace {workspace} -AgentType orchestrator` after collection.

## Verification Gate (PHASE 4.5)

After each agent completes, run automated verification before accepting the result:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/_shared/verify.ps1 -AgentType {agent-type} -Workspace {workspace}
```

- **PASS (exit 0)**: Accept result and move to next task
- **FAIL (exit 1)**: Treat as failure and retry with verify output context
- Never skip verification even if the agent reports success

## Automation Gate

```powershell
powershell -ExecutionPolicy Bypass -File .agent/skills/_shared/preflight.ps1 -Workspace {workspace} -AgentType orchestrator
powershell -ExecutionPolicy Bypass -File .agent/skills/_shared/postflight.ps1 -Workspace {workspace} -AgentType orchestrator
```

## Retry Logic
- 1st retry: Wait 30s, re-spawn with error context
- 2nd retry: Wait 60s, add "Try a different approach"
- Final failure: Report to user and ask whether to continue or abort

## References
- Skill routing: `../_shared/skill-routing.md`
- Verification scripts: `../_shared/preflight.ps1`, `../_shared/verify.ps1`, `../_shared/postflight.ps1`
- Workflow guide: `../workflow-guide/SKILL.md`
- Shared context strategy: `../_shared/context-loading.md`
