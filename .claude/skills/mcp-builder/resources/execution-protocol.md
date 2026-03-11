# MCP 빌더 실행 프로토콜

## Phase 1: 요구사항 분석

1. MCP 서버 용도 파악 (어떤 도구/리소스를 제공할 것인지)
2. 전송 방식 결정 (stdio vs HTTP Streamable)
3. 기존 MCP 서버와 중복 여부 확인
4. 인증 필요 여부 확인

## Phase 2: 프로젝트 구조

```
my-mcp-server/
├── src/
│   ├── index.ts          # 서버 진입점
│   ├── tools/            # 도구 정의
│   │   └── {tool-name}.ts
│   ├── resources/        # 리소스 정의 (선택)
│   │   └── {resource}.ts
│   └── utils/            # 유틸리티
├── package.json
├── tsconfig.json
├── .mcp.json             # Claude Code 연동 설정
└── README.md
```

## Phase 3: 구현 패턴

### 도구 정의 패턴

```typescript
// tools/my-tool.ts
import { z } from "zod";

export const myToolSchema = {
  input: z.string().describe("입력 설명"),
  options: z.object({
    flag: z.boolean().optional().describe("옵션 설명"),
  }).optional(),
};

export async function myTool({ input, options }: z.infer<typeof myToolSchema>) {
  try {
    const result = await doSomething(input);
    return { content: [{ type: "text" as const, text: JSON.stringify(result) }] };
  } catch (error) {
    return {
      content: [{ type: "text" as const, text: `오류: ${error.message}` }],
      isError: true,
    };
  }
}
```

### 리소스 정의 패턴

```typescript
// resources/my-resource.ts
export async function getMyResource(uri: URL) {
  const data = await fetchData(uri.pathname);
  return {
    contents: [{
      uri: uri.href,
      text: JSON.stringify(data),
      mimeType: "application/json",
    }],
  };
}
```

## Phase 4: 연동 검증

1. `npx tsc --noEmit` — 타입 검사
2. `node dist/index.js` — 서버 기동 확인
3. Claude Code에서 도구 목록 확인
4. 실제 도구 호출 테스트

## 안티패턴

- throw로 에러 전파 → `isError: true` 응답으로 반환
- Zod 스키마 없이 any 타입 → 모든 파라미터에 스키마 필수
- console.log로 디버그 출력 → Stdio 전송 시 stdout 오염됨, stderr 사용
- 거대한 응답 반환 → 컨텍스트 윈도우 고려, 요약/페이징 적용
