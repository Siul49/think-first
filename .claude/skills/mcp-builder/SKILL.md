---
name: mcp-builder
description: MCP 서버 개발, MCP 도구 통합, MCP 설정 작업 시 자동 활성화됩니다. Model Context Protocol 표준에 맞는 서버/클라이언트를 구축합니다. "MCP 서버", "MCP 도구", "MCP 연동" 요청에 반응합니다.
---

# MCP 빌더

## 활성화 조건

- "MCP 서버 만들어줘", "MCP 도구 추가", "MCP 연동" 요청
- `@modelcontextprotocol/sdk` 임포트가 감지된 경우
- `.mcp.json` 또는 MCP 설정 파일 수정 시
- "도구 서버", "tool server" 관련 요청

## 다른 스킬과의 차이

- **mcp-builder**: MCP 프로토콜 준수 서버/도구 구현. 프로토콜 스펙 전문.
- **backend**: 일반 API/서버 로직. MCP 프로토콜 전문 지식 없음.
- **skill-creator**: Claude Code 스킬 작성. mcp-builder는 MCP 서버 구축.

## 실행 절차

### Step 1: MCP 서버 유형 결정

| 유형 | 설명 | 예시 |
|------|------|------|
| Tool Server | 도구(함수) 제공 | DB 쿼리, API 호출, 파일 처리 |
| Resource Server | 데이터 리소스 제공 | 문서, 설정, 상태 정보 |
| Prompt Server | 프롬프트 템플릿 제공 | 분석 프롬프트, 변환 프롬프트 |
| 복합 | 위 조합 | 도구 + 리소스 |

### Step 2: 프로젝트 초기화

```bash
# TypeScript MCP 서버 초기화
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript @types/node
```

### Step 3: 서버 구현

MCP 서버 기본 구조:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-server",
  version: "1.0.0",
});

// 도구 등록
server.tool("tool-name", "도구 설명", {
  param: z.string().describe("파라미터 설명"),
}, async ({ param }) => {
  return { content: [{ type: "text", text: "결과" }] };
});

// 리소스 등록 (선택)
server.resource("resource://path", "리소스 설명", async (uri) => {
  return { contents: [{ uri: uri.href, text: "내용", mimeType: "text/plain" }] };
});

// 서버 시작
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Step 4: Claude Code 연동 설정

`.mcp.json` 파일 작성:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {}
    }
  }
}
```

### Step 5: 테스트 및 검증

1. MCP Inspector로 도구/리소스 검증
2. Claude Code에서 도구 호출 테스트
3. 에러 핸들링 및 타임아웃 처리 확인

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 스터디**: 변경 코드 이해도 점검 (레벨 S 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 핵심 규칙

1. **MCP 스펙 준수**: `@modelcontextprotocol/sdk` 최신 버전 사용
2. **Zod 스키마 필수**: 모든 도구 파라미터에 Zod 스키마 + `.describe()` 적용
3. **에러 핸들링**: `isError: true`로 에러 응답 반환, throw 금지
4. **Stdio 우선**: 로컬 서버는 Stdio 전송, 원격은 HTTP Streamable 전송
5. **도구 설명 충실**: 도구명과 description이 LLM이 이해할 수 있도록 명확해야 함
6. **입력 검증**: 모든 외부 입력에 Zod 유효성 검증 적용

## MCP 서버 체크리스트

```
- [ ] package.json에 @modelcontextprotocol/sdk 의존성
- [ ] 모든 도구에 Zod 스키마 + describe
- [ ] 에러 응답이 isError: true로 반환
- [ ] .mcp.json 설정 파일 작성
- [ ] stdio 또는 HTTP 전송 설정
- [ ] README에 설치/사용법 문서화
```

## 보고 형식

```
## MCP 서버 구축 완료

### 서버 정보
- 이름: {server-name}
- 유형: {Tool/Resource/Prompt}
- 전송: {stdio/HTTP}

### 등록된 도구/리소스
| 이름 | 유형 | 설명 |
|------|------|------|

### 연동 설정
- .mcp.json 경로: {path}

### 테스트 결과
- {검증 결과}
```

## 참조 리소스

`resources/` 참조:
- 실행 프로토콜: `execution-protocol.md`
- 서버 템플릿: `server-template.md`
- 에러 대응: `error-playbook.md`
