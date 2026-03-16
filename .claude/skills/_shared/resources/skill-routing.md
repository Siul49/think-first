# 스킬 라우팅 맵

요청 키워드에 따라 적절한 스킬을 선택하는 라우팅 규칙.

---

## 전처리: Thinking Cycle (항상 실행)

모든 라우팅 전에 **thinking-cycle** 스킬이 먼저 로드된다.
도메인 스킬 매칭 여부와 무관하게 TC Phase 0(질문) → Phase 1(결정)을 수행한 후 도메인 스킬로 진입한다.

```text
[사용자 요청] → [thinking-cycle] Phase 0/1 → [도메인 스킬 매칭] → Phase 2 실행 → [thinking-cycle] Phase 3/4
```

---

## 키워드 → 스킬 매핑

| 요청 키워드 | 스킬 | 비고 |
|-------------|------|------|
| API, endpoint, REST, GraphQL, database, migration | **backend** | |
| auth, JWT, login, register, password | **backend** | 인증 UI는 frontend 위임 가능 |
| UI, component, page, form, screen (web) | **frontend** | |
| style, Tailwind, responsive, CSS | **frontend** | |
| mobile, iOS, Android, Flutter, React Native, app | **mobile** | |
| offline, push notification, camera, GPS | **mobile** | |
| bug, error, crash, broken, slow | **debug** | |
| fix, root cause, reproduce, hotfix | **debug** | |
| 감사, 보안, 성능 감사, 접근성 검토 | **qa** | 전체 감사 |
| 리뷰, 코드 검토, diff 확인 | **review** | diff 중심 빠른 리뷰 |
| plan, breakdown, 기획, 스프린트 | **pm** | |
| commit, 커밋, 변경사항 저장 | **commit** | |
| verify, 검증, 구현 확인 | **verify-implementation** | |
| API 스키마, DTO, 라우터 검증 | **verify-api-schema** | verify-implementation에서 자동 호출 |
| 비즈니스 로직, Service, 도메인 검증 | **verify-business-logic** | verify-implementation에서 자동 호출 |
| DB, Repository, 쿼리, 스키마 검증 | **verify-database-layer** | verify-implementation에서 자동 호출 |
| 조사, 리서치, 비교, 어떤 게 좋을까, 방법 찾기 | **research** | 구현 전 선행 조사 |
| 문서화, API 문서, README, 아키텍처 정리, CHANGELOG | **document** | 코드→문서 동기화 |
| 컨텍스트 정리, 프로젝트 요약, 온보딩, CLAUDE.md 갱신 | **context-builder** | AI 세션 간 지식 전달 |
| 스킬 관리, 검증 스킬 설정 | **manage-skills** | |
| 스킬 만들기, 새 스킬, 커맨드 추가 | **skill-creator** | SKILL.md 표준 형식 가이드 |
| MCP 서버, MCP 도구, MCP 연동, Model Context Protocol | **mcp-builder** | MCP 서버/클라이언트 구축 |
| 테스트 작성, E2E 테스트, 통합 테스트, 컴포넌트 테스트 | **webapp-testing** | test-runner 에이전트에서도 참조 |

---

## 복합 요청 라우팅

| 요청 패턴 | 실행 순서 |
|-----------|-----------|
| 풀스택 기능 개발 | pm → (backend + frontend) 병렬 → qa |
| 모바일 앱 개발 | pm → (backend + mobile) 병렬 → qa |
| 버그 수정 후 리뷰 | debug → review → commit |
| 기능 추가 후 테스트 | pm → 해당 스킬 → qa |
| 변경사항 리뷰 후 커밋 | review → commit |
| 새 기술 도입 | research → pm → 구현 → qa |
| 대규모 변경 후 문서화 | 구현 → document → context-builder |

---

## 스킬 간 의존성

### 병렬 실행 가능
- backend + frontend (API 계약이 사전 정의된 경우)
- backend + mobile (API 계약이 사전 정의된 경우)

### 순차 실행 필수
- pm → 모든 구현 스킬 (기획 우선)
- 구현 스킬 → qa/review (구현 완료 후 검수)
- backend → frontend/mobile (API 계약이 미확정인 경우)

### qa/review는 항상 마지막
- 모든 구현 작업 완료 후 실행
- 예외: 사용자가 명시적으로 즉시 리뷰 요청한 경우

---

## 서브에이전트 자동 위임

스킬과 별도로, 다음 상황에서 서브에이전트를 자동 호출한다:

| 트리거 | 서브에이전트 | Worktree | 조건 |
|--------|-------------|----------|------|
| 코드 수정 완료 | `code-reviewer` | YES | diff가 존재할 때 |
| 복합 작업 감지 | `task-planner` | NO | 규모 판단 기준 충족 시 |
| 구현 단계 완료 | `test-runner` | YES | 테스트 파일이 존재할 때 |
| 모든 구현 완료 | `doc-writer` | NO | 문서 갱신이 필요할 때 |
| 인증/보안 코드 변경 | `security-auditor` | YES | auth, token, password, permission 관련 변경 |

### 스킬 → 서브에이전트 연계

| 스킬 완료 후 | 자동 위임 대상 |
|-------------|---------------|
| backend, frontend, mobile | `code-reviewer` → `test-runner` |
| debug | `test-runner` (회귀 검증) |
| pm | `task-planner` (계획서 생성) |
| 구현 전체 완료 | `doc-writer` → `security-auditor` (보안 관련 시) |

---

## 에스컬레이션

| 상황 | 대응 |
|------|------|
| 다른 도메인 버그 발견 | debug 스킬로 위임 |
| CRITICAL 이슈 발견 | 해당 도메인 스킬 재실행 |
| 아키텍처 변경 필요 | pm 스킬로 재기획 |
| API 계약 불일치 | backend 스킬 재실행 |
