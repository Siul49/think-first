# Memory Protocol

Use MCP memory tools consistently:

1. `write_memory` to create session/task artifacts.
2. `read_memory` before decisions to avoid state drift.
3. `edit_memory` only for incremental status updates.
4. Keep one owner per memory file when possible.