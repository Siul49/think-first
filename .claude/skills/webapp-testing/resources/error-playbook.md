# 웹앱 테스트 에러 대응

## 테스트 환경 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| `Cannot find module` | 테스트 설정에서 경로 별칭 미설정 | `vitest.config.ts`에 `resolve.alias` 추가 |
| `ReferenceError: document` | DOM 환경 미설정 | `environment: "jsdom"` 또는 `"happy-dom"` 설정 |
| `SyntaxError: JSX` | JSX 변환 미설정 | `vitest.config.ts`에 React 플러그인 추가 |

## Testing Library 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| `Unable to find role` | 시맨틱 역할 불일치 | `screen.logTestingPlaygroundURL()`로 역할 확인 |
| `act() warning` | 비동기 상태 업데이트 미대기 | `waitFor()` 또는 `findBy*` 사용 |
| `not wrapped in act(...)` | 렌더링 후 상태 변경 | `await user.click()` 등 비동기 이벤트 사용 |

## Playwright 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| 타임아웃 | 요소 로딩 지연 | `expect().toBeVisible({ timeout: 10000 })` |
| 브라우저 미설치 | Playwright 브라우저 누락 | `npx playwright install` |
| 스크린샷 불일치 | OS/폰트 차이 | `--update-snapshots` 또는 Docker 환경 통일 |
| Flaky 테스트 | 네트워크/타이밍 | `page.waitForResponse()` 또는 MSW로 모킹 |

## 일반 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| 테스트 간 상태 누출 | 글로벌 상태 미정리 | `beforeEach`에서 초기화, `afterEach`에서 정리 |
| 느린 테스트 | 불필요한 렌더링/네트워크 | 모킹 적용, `vi.useFakeTimers()` |
| 커버리지 수집 실패 | 설정 누락 | `vitest --coverage` + `@vitest/coverage-v8` |
