---
name: frontend
description: UI, 컴포넌트, 스타일링, 폼, 반응형 디자인 작업 시 자동 활성화됩니다. FSD-lite 아키텍처, shadcn/ui, TailwindCSS v4를 적용합니다.
---

# 프론트엔드 엔지니어

## 활성화 조건

- 사용자 인터페이스 및 컴포넌트 구축
- 클라이언트 사이드 로직 및 상태 관리
- 스타일링 및 반응형 디자인
- 폼 검증 및 사용자 인터랙션
- 백엔드 API 통합

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 리딩**: 변경 코드 이해도 점검 (레벨 C 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 핵심 규칙

1. **컴포넌트 재사용**: `shadcn/ui` 우선. `cva` 변형 또는 합성으로 확장. 커스텀 CSS 지양.
2. **디자인 정합**: 코드는 디자인 토큰과 1:1 매핑. 불일치 시 구현 전 해결.
3. **렌더링 전략**: Server Components 기본. Client Components는 인터랙티브 요소에만.
4. **접근성**: 시맨틱 HTML, ARIA 레이블, 키보드 내비게이션, 스크린 리더 호환 필수.
5. **도구 우선**: 코딩 전에 기존 솔루션/도구 확인.

## 아키텍처 (FSD-lite)

- **Root (`src/`)**: 공유 로직 (components, lib, types)
- **Feature (`src/features/*/`)**: 기능별 로직. 크로스 피처 임포트 금지.

```
src/features/[feature]/
├── components/           # 기능별 UI 컴포넌트
│   └── skeleton/         # 로딩 스켈레톤
├── types/                # 기능별 타입 정의
└── utils/                # 기능별 유틸리티 (커스텀 로직은 >90% 테스트 커버리지 필수)
```

## 라이브러리

| 카테고리 | 라이브러리 |
|----------|---------|
| Date | `luxon` |
| Styling | `TailwindCSS v4` + `shadcn/ui` |
| Hooks | `ahooks` |
| Utils | `es-toolkit` |
| State (URL) | `jotai-location` |
| State (Server) | `TanStack Query` |
| State (Client) | `Jotai` (최소화) |
| Forms | `@tanstack/react-form` + `zod` |

## 성능 및 네이밍

- FCP < 1s, `next/dynamic` / `next/image` 활용
- 반응형: 320px, 768px, 1024px, 1440px
- 파일: `kebab-case.tsx` / 컴포넌트: `PascalCase` / 함수: `camelCase` / 상수: `SCREAMING_SNAKE_CASE`

## UI 구현 (shadcn/ui)

- `components/ui/*`는 읽기 전용. 커스터마이징은 래퍼 또는 `cva` 합성.
- 반응형: `Drawer` (모바일) vs `Dialog` (데스크탑)

## 리뷰 체크리스트

- [ ] 인터랙티브 요소에 `aria-label`. 시맨틱 헤딩.
- [ ] 모바일 뷰포트 기능 검증.
- [ ] CLS 없음, 빠른 로드.
- [ ] Error Boundaries와 Loading Skeletons.
- [ ] 복잡한 로직에 Vitest 테스트.
- [ ] 타입체크와 Lint 통과.

## 참조 리소스

`resources/` 참조:
- 실행 프로토콜: `execution-protocol.md`
- 코드 예시: `examples.md`, `snippets.md`
- 체크리스트: `checklist.md`
- 에러 대응: `error-playbook.md`
- 기술 스택: `tech-stack.md`
- 컴포넌트 템플릿: `component-template.tsx`
- Tailwind 규칙: `tailwind-rules.md`
