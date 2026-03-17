---
name: backend
description: API, 데이터베이스, 인증, 서버 사이드 비즈니스 로직 작업 시 자동 활성화됩니다. Clean Architecture(Router→Service→Repository) 패턴을 적용합니다.
---

# 백엔드 엔지니어

## 활성화 조건

- REST API 또는 GraphQL 엔드포인트 구축
- 데이터베이스 설계 및 마이그레이션
- 인증/인가 구현
- 서버 사이드 비즈니스 로직
- 백그라운드 작업 및 큐

## 아키텍처 패턴

```
Router (HTTP) → Service (Business Logic) → Repository (Data Access) → Models
```

### Repository 레이어
- 파일: `src/[domain]/repository.py`
- 역할: DB CRUD 및 쿼리 로직 캡슐화
- 원칙: 비즈니스 로직 금지, SQLAlchemy 모델 반환

### Service 레이어
- 파일: `src/[domain]/service.py`
- 역할: 비즈니스 로직, Repository 조합, 외부 API 호출
- 원칙: 비즈니스 의사결정은 여기서만

### Router 레이어
- 파일: `src/[domain]/router.py`
- 역할: HTTP 요청 수신, 입력 검증, Service 호출, 응답 반환
- 원칙: 비즈니스 로직 금지, DI를 통해 Service 주입

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 스터디**: 변경 코드 이해도 점검 (레벨 S 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 핵심 규칙

1. Clean architecture: router → service → repository → models
2. 라우트 핸들러에 비즈니스 로직 금지
3. 모든 입력은 Pydantic으로 검증
4. 파라미터화된 쿼리만 사용 (문자열 보간 금지)
5. 인증은 JWT + bcrypt; 인증 엔드포인트에 rate limit 적용
6. async/await 일관 사용; 모든 시그니처에 타입 힌트
7. 커스텀 예외는 `src/lib/exceptions.py` 사용 (raw HTTPException 금지)

## 코드 품질

- Python 3.12+: 엄격한 타입 힌트 (mypy)
- Async/Await: I/O 바운드 작업 필수
- Ruff: 린팅/포매팅 (Double Quotes, Line Length 100)

## 실행 절차

1. 요구사항 분석 및 영향 범위 파악
2. API 계약 정의 (엔드포인트, 요청/응답 스키마)
3. 모델/마이그레이션 구현
4. Repository → Service → Router 순서로 구현
5. 테스트 작성 및 검증
6. 체크리스트 확인 후 완료 보고

## 참조 리소스

상세 리소스는 `resources/`에서 참조:
- 실행 프로토콜: `execution-protocol.md`
- 코드 예시: `examples.md`, `snippets.md`
- 체크리스트: `checklist.md`
- 에러 대응: `error-playbook.md`
- 기술 스택: `tech-stack.md`
- API 템플릿: `api-template.py`
