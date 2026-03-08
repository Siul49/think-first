---
description: Initial setup workflow — verify CLI installations, check MCP connections, configure language and agent-CLI mapping
---

# MANDATORY RULES — VIOLATION IS FORBIDDEN

- **Response language follows `language` setting in `.codex/config/user-preferences.yaml` if configured.**
- **NEVER skip steps.** Execute from Step 1 in order.
- **Read configuration files BEFORE making changes.**

---

## Step 1: Language Settings

1. Check if `.codex/config/user-preferences.yaml` exists
2. If not:
   - Ask user for preferred language (ko, en, ja, zh, ...)
   - Create default configuration file
3. If exists:
   - Display current language setting
   - Ask if user wants to change

---

## Step 2: CLI Installation Status

Check each CLI installation:

```bash
which gemini && gemini --version
```

Display results:

```
🔍 CLI Installation Status
┌─────────────┬─────────────┬─────────────┐
│ Environment │ Status      │ Version     │
├─────────────┼─────────────┼─────────────┤
│ gemini      │ ✅ Installed │ v2.1.0   │
│ antigravity │ ✅ Native   │ -        │
└─────────────┴─────────────┴─────────────┘
```

Provide installation guide for missing CLIs:

- **gemini**: `npm install -g @google/gemini-cli`

---

## Step 3: MCP Connection Status

1. Check `.codex/mcp.json` existence and configuration
2. Check MCP settings for each CLI:
   - Gemini CLI: `~/.gemini/settings.json`
   - Antigravity IDE: `~/.gemini/antigravity/mcp_config.json`
3. Test Serena MCP connection

Display results:

```
🔗 MCP Connection Status
┌─────────────────┬────────────┬─────────────────────┐
│ Environment     │ MCP Config │ Server              │
├─────────────────┼────────────┼─────────────────────┤
│ gemini CLI      │ ✅ Set     │ serena              │
│ Antigravity IDE │ ⚠️ Check   │ see Step 3.1        │
└─────────────────┴────────────┴─────────────────────┘
```

For missing MCP settings:

- Display configuration instructions
- Offer automatic setup option

---

## Step 3.1: Serena MCP Configuration (Optional)

> **Ask the user**: "Do you use Serena MCP server? (y/n)"
> Skip this step if user answers "no".

### Option A: Command Mode (Simple)

Serena runs as a subprocess for each session. No separate server needed.

**Gemini CLI** (`~/.gemini/settings.json`):

```json
{
  "mcpServers": {
    "serena": {
      "command": "uv",
      "args": ["run", "serena", "--project", "/path/to/your/project"]
    }
  }
}
```

**Antigravity IDE** (`~/.gemini/antigravity/mcp_config.json`):

```json
{
  "mcpServers": {
    "serena": {
      "command": "uv",
      "args": ["run", "serena", "--project", "/path/to/your/project"],
      "disabled": false
    }
  }
}
```

### Option B: SSE Mode (Shared Server)

Serena runs as a shared SSE server. Multiple sessions can share one server instance.

**1. Start Serena server:**

```bash
serena-mcp-server --port 12341
```

**2. Gemini CLI** (`~/.gemini/settings.json`):

```json
{
  "mcpServers": {
    "serena": {
      "url": "http://localhost:12341/sse"
    }
  }
}
```

**3. Antigravity IDE** — requires bridge:

> **Important**: Antigravity IDE doesn't support SSE directly.
> You need the `bridge` command to connect.

**Configure** (`~/.gemini/antigravity/mcp_config.json`):

```json
{
  "mcpServers": {
    "serena": {
      "command": "npx",
      "args": ["-y", "oh-my-ag@latest", "bridge", "http://localhost:12341/sse"],
      "disabled": false
    }
  }
}
```

**Bridge Architecture:**

```
┌─────────────────┐     stdio      ┌──────────────────┐     HTTP/SSE     ┌─────────────────┐
│ Antigravity IDE │ ◄────────────► │  oh-my-ag bridge │ ◄──────────────► │ Serena SSE      │
└─────────────────┘                └──────────────────┘                  └─────────────────┘
                                                                          (localhost:12341)
```

### Comparison

| Mode    | Memory Usage | Setup Complexity | Multiple Sessions |
|---------|--------------|------------------|-------------------|
| Command | Higher       | Simple           | Each has own process |
| SSE     | Lower        | Requires server  | Share one server |

---

## Step 4: Agent-CLI Mapping

1. Display current mapping
2. Ask if user wants to change:

   ```
   Current Agent-CLI Mapping:
   ┌──────────┬─────────┐
   │ Agent    │ CLI     │
   ├──────────┼─────────┤
   │ 🎨 프론트엔드_엔지니어  │ gemini  │
   │ ⚙️ 백엔드_엔지니어   │ gemini  │
   │ 📱 모바일_엔지니어   │ gemini  │
   │ 💡 기획자_PM        │ gemini  │
   │ 🔎 QA_검수자       │ gemini  │
   │ 🐛 디버깅_해결사     │ gemini  │
   └──────────┴─────────┘

   Do you want to change? (e.g., "⚙️ 백엔드_엔지니어 to gemini", "💡 기획자_PM to antigravity")
   ```

3. Update `.codex/config/user-preferences.yaml` if changes requested

---

## Step 5: Setup Complete Summary

```
✅ Setup Complete!

📝 Configuration Summary:
- Response Language: English (en)
- Timezone: UTC
- Installed CLIs: gemini ✅, antigravity ✅
- MCP Status: Configured

📋 Agent-CLI Mapping:
- 🎨 프론트엔드_엔지니어 → gemini
- ⚙️ 백엔드_엔지니어    → gemini
- 📱 모바일_엔지니어    → gemini
- 💡 기획자_PM         → gemini
- 🔎 QA_검수자        → gemini
- 🐛 디버깅_해결사      → gemini

🚀 Get Started:
- /plan: Create project plan
- /orchestrate: Automated multi-agent execution
- /coordinate: Interactive multi-agent coordination
```

If Antigravity IDE with SSE mode:

```
💡 For Antigravity IDE (SSE mode):
- Start Serena server: serena-mcp-server --port 12341
- Restart IDE to apply changes
```
