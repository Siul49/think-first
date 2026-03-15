---
name: webapp-testing
description: 웹 애플리케이션 E2E 테스트, 통합 테스트, 컴포넌트 테스트 작성 시 자동 활성화됩니다. 테스트 전략 수립부터 테스트 코드 작성까지 가이드합니다. "테스트 작성", "E2E 테스트", "테스트 추가" 요청에 반응합니다.
---

# 웹앱 테스터

## 활성화 조건

- "테스트 작성해줘", "E2E 테스트", "테스트 추가" 요청
- 테스트 파일 (`.test.ts`, `.spec.ts`, `.test.tsx`) 작업 시
- "테스트 커버리지", "테스트 전략", "테스트 계획" 요청
- Playwright, Vitest, Jest, Cypress 관련 작업

## 다른 스킬과의 차이

- **webapp-testing**: 테스트 전략 + 테스트 코드 작성 전문.
- **qa**: 프로젝트 전체 감사 (보안/성능/접근성). 테스트 코드 작성 아님.
- **debug**: 기존 버그 진단. webapp-testing은 사전 예방 테스트.

## 실행 절차

### Step 1: 테스트 전략 결정

| 테스트 유형 | 도구 | 대상 |
|-------------|------|------|
| Unit | Vitest / Jest | 함수, 유틸리티, 훅 |
| Component | Vitest + Testing Library | React/Vue 컴포넌트 |
| Integration | Vitest / Supertest | API 엔드포인트, 서비스 계층 |
| E2E | Playwright | 사용자 시나리오, 페이지 플로우 |

프로젝트의 기존 테스트 스택 확인:
```
!`ls package.json 2>/dev/null && cat package.json | grep -E "vitest|jest|playwright|cypress|testing-library" || echo "(테스트 도구 미감지)"`
```

### Step 2: 테스트 대상 분석

1. 변경된 코드 또는 새로 작성된 코드 확인
2. 핵심 비즈니스 로직 식별
3. 엣지 케이스와 에러 시나리오 도출
4. 테스트 우선순위 결정 (Critical Path 먼저)

### Step 3: 테스트 코드 작성

**파일 네이밍 규칙**:
- Unit/Component: `{파일명}.test.ts(x)` (같은 디렉토리)
- Integration: `__tests__/{모듈}.integration.test.ts`
- E2E: `e2e/{시나리오}.spec.ts`

**테스트 구조** (AAA 패턴):
```typescript
describe("{테스트 대상}", () => {
  it("{기대 동작을 한국어로}", async () => {
    // Arrange - 준비
    // Act - 실행
    // Assert - 검증
  });
});
```

### Step 4: 테스트 실행 및 검증

1. 전체 테스트 실행: `npm test` 또는 `npx vitest run`
2. 실패 테스트 분석 및 수정
3. 커버리지 확인 (설정된 경우)

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 리딩**: 변경 코드 이해도 점검 (레벨 C 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 핵심 규칙

1. **기존 스택 존중**: 프로젝트에 이미 있는 테스트 프레임워크 사용
2. **AAA 패턴**: Arrange → Act → Assert 구조 준수
3. **테스트 격리**: 테스트 간 상태 공유 금지, 각 테스트 독립 실행
4. **의미 있는 테스트명**: `it("사용자가 로그인하면 대시보드로 이동한다")` 스타일
5. **과도한 모킹 금지**: 실제 동작 테스트 우선, 외부 의존성만 모킹
6. **Happy Path + Edge Case**: 정상 시나리오 + 에러 시나리오 모두 커버
7. **플레이키 테스트 금지**: 타이밍 의존, 순서 의존 테스트 작성 금지

## E2E 테스트 패턴 (Playwright)

```typescript
import { test, expect } from "@playwright/test";

test.describe("{페이지/기능}", () => {
  test("{사용자 시나리오}", async ({ page }) => {
    await page.goto("/path");
    await page.getByRole("button", { name: "버튼명" }).click();
    await expect(page.getByText("기대 결과")).toBeVisible();
  });
});
```

## 보고 형식

```
## 테스트 작성 완료

### 테스트 요약
| 유형 | 파일 | 테스트 수 |
|------|------|-----------|

### 커버리지
- 핵심 로직: {범위}
- 엣지 케이스: {범위}

### 테스트 실행 결과
- 통과: N건
- 실패: N건 (있다면 원인 포함)

### 다음 단계
- [추가 테스트가 필요한 영역]
```

## 참조 리소스

`resources/` 참조:
- 실행 프로토콜: `execution-protocol.md`
- 테스트 패턴: `test-patterns.md`
- 에러 대응: `error-playbook.md`
