# MCP 빌더 에러 대응

## 서버 기동 실패

| 증상 | 원인 | 해결 |
|------|------|------|
| `MODULE_NOT_FOUND` | SDK 미설치 또는 경로 오류 | `npm install @modelcontextprotocol/sdk` |
| `ERR_REQUIRE_ESM` | CommonJS에서 ESM 모듈 로드 | package.json에 `"type": "module"` 추가 |
| Stdio 연결 끊김 | stdout에 디버그 출력 | `console.log` → `console.error`로 변경 |

## 도구 호출 실패

| 증상 | 원인 | 해결 |
|------|------|------|
| 스키마 검증 오류 | Zod 타입 불일치 | `.describe()`로 파라미터 힌트 추가 |
| 타임아웃 | 느린 외부 API | AbortSignal 타임아웃 설정 |
| 빈 응답 | content 배열이 비어있음 | 최소 하나의 텍스트 content 반환 |

## Claude Code 연동 실패

| 증상 | 원인 | 해결 |
|------|------|------|
| 도구 목록에 안 보임 | .mcp.json 경로 오류 | 절대 경로 사용 또는 프로젝트 루트 기준 확인 |
| 권한 거부 | 실행 권한 없음 | `chmod +x` 또는 node 경로 확인 |
| 환경변수 미전달 | env 설정 누락 | .mcp.json의 env 섹션에 추가 |
