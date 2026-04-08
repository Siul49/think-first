---
name: verify-business-logic
description: Service 레이어 규칙, 스케줄러, 배치, 도메인 로직의 정합성을 검증합니다.
---

# 비즈니스 로직 검증

## 활성화 조건

- `verify-implementation` 파이프라인에서 자동 호출
- `manage-skills`가 Service/Domain 레이어 변경 감지 시 등록

## 검증 대상 파일 패턴

- `**/services/**`, `**/usecases/**`
- `**/domain/**`, `**/entities/**`
- `**/jobs/**`, `**/schedulers/**`, `**/batch/**`
- `**/middleware/**` (비즈니스 로직 포함 시)

## 워크플로우

### Step 1: 변경된 Service/Domain 파일 수집

비즈니스 로직이 포함된 변경 파일을 식별한다.

### Step 2: 레이어 위반 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| Service → Repository 방향 | Service가 Repository를 호출 | Service가 DB를 직접 조작 |
| Controller → Service 방향 | Controller가 Service를 호출 | Controller에 비즈니스 로직 직접 구현 |
| 순환 의존 없음 | 단방향 의존 관계 | ServiceA ↔ ServiceB 상호 호출 |
| Domain 순수성 | Domain 객체가 외부 의존 없음 | Domain에서 HTTP/DB 직접 참조 |

### Step 3: 비즈니스 규칙 일관성 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| 동일 규칙 중복 구현 없음 | 비즈니스 규칙이 한 곳에서만 정의 | 같은 검증 로직이 여러 곳에 산재 |
| 예외 처리 일관성 | 커스텀 예외로 도메인 에러 표현 | 일반 Error/throw로 비즈니스 에러 처리 |
| 트랜잭션 경계 명확 | 트랜잭션이 Service 레이어에서 관리 | Repository나 Controller에서 트랜잭션 시작 |
| 상태 전이 검증 | 허용된 상태 전이만 가능 | 잘못된 상태 전이 방지 로직 없음 |

### Step 4: 스케줄러/배치 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| 멱등성 | 동일 입력에 동일 결과 | 재실행 시 중복 데이터 생성 |
| 실패 복구 | 실패 시 재시도/보상 로직 존재 | 실패 시 무시 또는 무한 루프 |
| 동시 실행 방지 | 중복 실행 방지 장치 존재 | Lock 없이 병렬 실행 가능 |

### Step 5: 결과 보고

```
## 비즈니스 로직 검증 결과

| # | 상태 | 검사 항목 | 파일:라인 | 설명 |
|---|------|-----------|-----------|------|
| 1 | PASS/FAIL | 항목 | `path:line` | 상세 |

### 요약: PASS N건 / FAIL N건
```

## 예외

- 단순 CRUD만 수행하는 pass-through Service (별도 로직 없음)
- 외부 SDK 래퍼 (비즈니스 로직이 아닌 통합 레이어)
- 마이그레이션/시드 스크립트
