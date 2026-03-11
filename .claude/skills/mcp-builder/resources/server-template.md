# MCP 서버 템플릿

## 최소 구현 (Stdio + Tool)

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "{server-name}",
  version: "1.0.0",
});

server.tool(
  "{tool-name}",
  "{도구 설명 - LLM이 이해할 수 있게 명확하게}",
  {
    param1: z.string().describe("{파라미터 설명}"),
    param2: z.number().optional().describe("{선택 파라미터 설명}"),
  },
  async ({ param1, param2 }) => {
    try {
      // 도구 로직
      const result = `처리 결과: ${param1}`;
      return { content: [{ type: "text", text: result }] };
    } catch (error) {
      return {
        content: [{ type: "text", text: `오류: ${error.message}` }],
        isError: true,
      };
    }
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

## .mcp.json 설정

```json
{
  "mcpServers": {
    "{server-name}": {
      "command": "node",
      "args": ["{path/to/dist/index.js}"],
      "env": {
        "API_KEY": "{필요시 환경변수}"
      }
    }
  }
}
```

## package.json 필수 의존성

```json
{
  "type": "module",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/node": "^22.0.0"
  }
}
```
