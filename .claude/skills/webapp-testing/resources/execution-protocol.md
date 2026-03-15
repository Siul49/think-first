# 웹앱 테스트 실행 프로토콜

## Step -1: Thinking Cycle (이해도 점검 + 질문 + 결정)
1. **이해도 사전 점검** — 코드 수정 시 `../code-reading/SKILL.md` 사전 점검 수행
   - 사용자가 수정 대상 코드를 이해하고 있는지 확인
   - 이해 부족 시 설명 요구 → 설명 후 진행
2. **질문** — `../_shared/resources/thinking-cycle.md` Phase 0 수행
   - 작업 복잡도에 맞는 소크라테스 질문 선정
   - 사용자 답변 대기 (답변 전 진행 금지)
3. **결정** — 트레이드오프 존재 시 Phase 1 수행
   - 선택지 제시 + 근거 요구
   - 근거 없는 선택은 재질문

## Phase 1: 테스트 환경 파악

1. 프로젝트 테스트 프레임워크 확인
   - `package.json` devDependencies 스캔
   - 기존 테스트 파일 패턴 확인 (`*.test.*`, `*.spec.*`)
   - 테스트 설정 파일 확인 (`vitest.config.*`, `jest.config.*`, `playwright.config.*`)
2. 테스트 스크립트 확인 (`npm test`, `npm run test:e2e`)
3. 기존 테스트 커버리지 수준 파악

## Phase 2: 테스트 대상 식별

1. 변경/신규 코드에서 테스트 대상 추출
2. 우선순위 분류:
   - P0: 핵심 비즈니스 로직, 인증/결제 등 크리티컬 패스
   - P1: 사용자 인터랙션, 폼 검증, 상태 관리
   - P2: 유틸리티 함수, 헬퍼, 포맷터
3. 테스트 유형별 배분 결정

## Phase 3: 테스트 작성

### Unit 테스트

```typescript
// {target}.test.ts
import { describe, it, expect } from "vitest";
import { targetFunction } from "./{target}";

describe("{targetFunction}", () => {
  it("{정상 케이스 설명}", () => {
    expect(targetFunction(input)).toBe(expected);
  });

  it("{엣지 케이스 설명}", () => {
    expect(() => targetFunction(invalidInput)).toThrow();
  });
});
```

### Component 테스트

```typescript
// {Component}.test.tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Component } from "./{Component}";

describe("{Component}", () => {
  it("{렌더링 검증}", () => {
    render(<Component prop={value} />);
    expect(screen.getByText("expected")).toBeInTheDocument();
  });

  it("{인터랙션 검증}", async () => {
    const user = userEvent.setup();
    render(<Component onAction={mockFn} />);
    await user.click(screen.getByRole("button"));
    expect(mockFn).toHaveBeenCalledWith(expected);
  });
});
```

### E2E 테스트

```typescript
// e2e/{scenario}.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{시나리오}", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("{사용자 플로우}", async ({ page }) => {
    // 사용자 행동 시뮬레이션
    await page.getByLabel("이메일").fill("test@example.com");
    await page.getByRole("button", { name: "제출" }).click();
    await expect(page.getByText("성공")).toBeVisible();
  });
});
```

## Phase 4: 실행 및 검증

1. 단위 테스트 실행 → 통과 확인
2. E2E 테스트 실행 → 통과 확인
3. 실패 시 원인 분석 후 수정
4. 불안정(flaky) 테스트 여부 확인 (3회 반복 실행)

## 안티패턴

- 구현 디테일 테스트 → 동작(behavior) 테스트
- `sleep`/`setTimeout` 사용 → `waitFor`/`expect.poll` 사용
- 하드코딩된 셀렉터 (`#id`, `.class`) → 시맨틱 쿼리 (`getByRole`, `getByLabel`)
- 하나의 테스트에 여러 시나리오 → 테스트당 하나의 시나리오
- 모킹 과다 → 실제 동작 우선, 외부 의존성만 모킹

## Pre-Final Step: 코드 리딩 (Thinking Cycle Phase 3)
1. `../code-reading/SKILL.md` 사후 점검 수행
2. 변경된 코드에 대해 레벨 C(기본) 질문 → 사용자 답변 평가
3. 코드 변경이 없는 작업은 생략

## Final Step: 회고 (Thinking Cycle Phase 4)
1. `../_shared/resources/thinking-cycle.md` Phase 4 수행
2. 회고 질문 제시 → 사용자 답변을 `.claude/reflections/YYYY-MM-DD.md`에 기록
3. 회고 없이 작업 종료 금지
