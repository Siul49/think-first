---
description: resources 스킬 프로토콜
---

# 동적 컨텍스트 로딩 가이드

모든 리소스를 한 번에 읽지 않는다. 작업 유형에 따라 필요한 리소스만 로드하여 컨텍스트를 절약한다.

---

## 로딩 순서 (공통)

### 항상 로드
1. `SKILL.md` — 자동 로드 (Antigravity skills 시스템)

### 작업 시작 시
2. `resources/execution-protocol.md` — 실행 프로토콜

### 난이도별 추가 로드
- **단순**: 추가 로딩 없이 구현 진행
- **중간**: `resources/examples.md` (유사 예시 참고)
- **복합**: `resources/examples.md` + `resources/tech-stack.md` + `resources/snippets.md`

### 실행 중 필요 시
- `resources/checklist.md` — 검증 단계에서 로드
- `resources/error-playbook.md` — 에러 발생 시에만 로드

---

## 작업 유형별 리소스 매핑

### Backend

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| CRUD API 생성 | snippets.md (route, schema, model, test) |
| 인증 구현 | snippets.md (JWT, password) + tech-stack.md |
| DB 마이그레이션 | snippets.md (migration) |
| 성능 최적화 | examples.md (N+1 예시) |
| 기존 코드 수정 | examples.md |

### Frontend

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| 컴포넌트 생성 | snippets.md (component, test) + component-template.tsx |
| 폼 구현 | snippets.md (form + Zod) |
| API 연동 | snippets.md (TanStack Query) |
| 스타일링 | tailwind-rules.md |
| 페이지 레이아웃 | snippets.md (grid) + examples.md |

### Mobile

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| 화면 생성 | snippets.md (screen, provider) + screen-template.dart |
| API 연동 | snippets.md (repository, Dio) |
| 내비게이션 | snippets.md (GoRouter) |
| 오프라인 기능 | examples.md (offline 예시) |
| 상태 관리 | snippets.md (Riverpod) |

### Debug

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| 프론트엔드 버그 | common-patterns.md (Frontend 섹션) |
| 백엔드 버그 | common-patterns.md (Backend 섹션) |
| 모바일 버그 | common-patterns.md (Mobile 섹션) |
| 성능 버그 | common-patterns.md (Performance 섹션) + debugging-checklist.md |

### QA

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| 보안 감사 | checklist.md (Security 섹션) |
| 성능 감사 | checklist.md (Performance 섹션) |
| 접근성 감사 | checklist.md (Accessibility 섹션) |
| 전체 감사 | checklist.md (전체) + self-check.md |

### PM

| 작업 유형 | 필요 리소스 |
|-----------|-------------|
| 새 프로젝트 기획 | examples.md + task-template.json |
| 기능 추가 기획 | examples.md |
| 리팩터링 기획 | 기존 코드베이스 조사 후 판단 |
