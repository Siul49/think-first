---
name: verify-api-schema
description: API 라우터, DTO, request/response 모델, API 계약의 정합성을 검증합니다.
---

# API 스키마 검증

## 활성화 조건

- `verify-implementation` 파이프라인에서 자동 호출
- `manage-skills`가 API 관련 변경 감지 시 등록

## 검증 대상 파일 패턴

- `**/routes/**`, `**/routers/**`, `**/controllers/**`
- `**/dto/**`, `**/schemas/**`, `**/models/**`
- `**/types/**` (API request/response 관련)
- `**/openapi.*`, `**/swagger.*`

## 워크플로우

### Step 1: 변경된 API 엔드포인트 수집

라우터/컨트롤러 파일에서 변경된 엔드포인트를 식별한다.

### Step 2: DTO-라우터 일관성 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| Request DTO 존재 | POST/PUT/PATCH 엔드포인트에 Request DTO 정의됨 | body를 `any`/raw로 받음 |
| Response DTO 존재 | 모든 엔드포인트에 Response 타입 정의됨 | 반환 타입이 `any`이거나 미정의 |
| DTO 필드-DB 모델 매핑 | DTO 필드가 실제 모델 필드와 일치 | 존재하지 않는 필드 참조 |
| 필수/선택 필드 일관성 | validation 데코레이터와 타입이 일치 | `required`인데 `optional` 타입 등 |

### Step 3: HTTP 규약 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| HTTP 메서드 적합성 | CRUD에 맞는 메서드 사용 | 데이터 변경에 GET 사용 등 |
| 상태 코드 일관성 | 201(생성), 204(삭제) 등 규약 준수 | 모든 응답이 200 |
| 에러 응답 형식 | 일관된 에러 응답 구조 | 엔드포인트마다 에러 형식 다름 |
| URL 네이밍 | RESTful 규칙 준수 (복수형, kebab-case) | 동사 사용, camelCase 등 |

### Step 4: 계약 정합성 검사

| 검사 항목 | PASS 기준 | FAIL 기준 |
|-----------|-----------|-----------|
| API 문서와 실제 구현 일치 | OpenAPI/Swagger 스펙과 코드 일치 | 스펙에 없는 엔드포인트 존재 |
| 버전 호환성 | 기존 필드 삭제 없이 확장 | Breaking change 무경고 |

### Step 5: 결과 보고

```
## API 스키마 검증 결과

| # | 상태 | 검사 항목 | 파일:라인 | 설명 |
|---|------|-----------|-----------|------|
| 1 | PASS/FAIL | 항목 | `path:line` | 상세 |

### 요약: PASS N건 / FAIL N건
```

## 예외

- 내부 전용 유틸리티 엔드포인트 (health check, metrics)
- protobuf/gRPC 스키마 (별도 검증 체계)
- 테스트 전용 mock 라우터
