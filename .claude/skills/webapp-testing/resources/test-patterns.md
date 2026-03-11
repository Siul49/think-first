# 테스트 패턴 레퍼런스

## 1. API 엔드포인트 테스트

```typescript
import { describe, it, expect } from "vitest";
import request from "supertest";
import { app } from "../app";

describe("POST /api/users", () => {
  it("유효한 데이터로 사용자를 생성한다", async () => {
    const res = await request(app)
      .post("/api/users")
      .send({ email: "test@example.com", name: "테스트" });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("id");
  });

  it("이메일 누락 시 400을 반환한다", async () => {
    const res = await request(app)
      .post("/api/users")
      .send({ name: "테스트" });

    expect(res.status).toBe(400);
  });
});
```

## 2. 커스텀 훅 테스트

```typescript
import { renderHook, act } from "@testing-library/react";
import { useCounter } from "./useCounter";

describe("useCounter", () => {
  it("초기값으로 시작한다", () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it("increment로 값이 증가한다", () => {
    const { result } = renderHook(() => useCounter(0));
    act(() => result.current.increment());
    expect(result.current.count).toBe(1);
  });
});
```

## 3. 비동기 상태 테스트

```typescript
import { render, screen, waitFor } from "@testing-library/react";
import { DataList } from "./DataList";
import { server } from "../mocks/server"; // MSW

describe("DataList", () => {
  it("데이터를 로딩하고 표시한다", async () => {
    render(<DataList />);

    expect(screen.getByText("로딩 중...")).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText("항목 1")).toBeInTheDocument();
    });
  });
});
```

## 4. 폼 유효성 검증 테스트

```typescript
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { LoginForm } from "./LoginForm";

describe("LoginForm", () => {
  it("빈 이메일로 제출 시 에러를 표시한다", async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await user.click(screen.getByRole("button", { name: "로그인" }));
    expect(screen.getByText("이메일을 입력해주세요")).toBeVisible();
  });
});
```

## 5. Playwright 인증 플로우

```typescript
import { test, expect } from "@playwright/test";

test.describe("인증 플로우", () => {
  test("로그인 → 대시보드 이동", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("이메일").fill("user@example.com");
    await page.getByLabel("비밀번호").fill("password123");
    await page.getByRole("button", { name: "로그인" }).click();

    await expect(page).toHaveURL("/dashboard");
    await expect(page.getByText("환영합니다")).toBeVisible();
  });

  test("잘못된 비밀번호로 에러 표시", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("이메일").fill("user@example.com");
    await page.getByLabel("비밀번호").fill("wrong");
    await page.getByRole("button", { name: "로그인" }).click();

    await expect(page.getByText("비밀번호가 올바르지 않습니다")).toBeVisible();
  });
});
```
