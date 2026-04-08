---
name: verify-implementation
description: 프로젝트의 모든 verify 스킬을 순차 실행하여 통합 검증 보고서를 생성합니다. 기능 구현 후, PR 전, 코드 리뷰 시 사용.
disable-model-invocation: true
argument-hint: "[선택사항: 특정 verify 스킬 이름]"
---

# 검증 파이프라인

## 목적

등록된 `verify-*` 스킬을 순차 실행하고, 통합 검증 보고서를 생성한다.

## 사용 시점

- 새 기능 구현 후
- PR 생성 전
- 릴리스 준비 리뷰
- 대규모 리팩터링 후

## 등록된 검증 스킬

<!-- manage-skills가 이 테이블을 자동 관리합니다 -->

| # | 스킬 | 설명 |
|---|------|------|
| 1 | verify-api-schema | API 라우터, DTO, request/response 모델, API 계약 정합성 검증 |
| 2 | verify-business-logic | Service 레이어 규칙, 스케줄러, 배치, 도메인 로직 정합성 검증 |
| 3 | verify-database-layer | Repository, CRUD 경로, 스키마 가정, 쿼리 안전성 검증 |

## 실행 절차

### Step 1: 소개
등록된 검증 스킬 목록을 사용자에게 보여준다.

### Step 2: 순차 실행
각 스킬에 대해:
1. 해당 스킬의 `SKILL.md`를 읽고 워크플로우 파악
2. 워크플로우에 정의된 검사를 순서대로 실행
3. 각 스킬의 예외 조건을 적용
4. PASS/FAIL 및 증거(`file:line`)를 기록

### Step 3: 통합 보고서

| 스킬 | 상태 | 발견 건수 | 주요 증거 |
|------|------|-----------|-----------|
| verify-xxx | PASS/FAIL | N | `path:line` |

### Step 4: 사용자 조치 확인
실패한 스킬이 있으면 사용자에게 확인:
1. 모든 권장 수정 적용
2. 개별 선택하여 수정
3. 건너뛰기

### Step 5: 수정 적용
사용자 선택에 따라 수정을 적용한다.

### Step 6: 재검증
수정이 적용된 스킬만 재실행하고, 이전/이후 비교를 보여준다.

## 예외

- 빈 프로젝트 (등록된 스킬 없음): 보고 후 중단
- 각 스킬 자체의 예외 조건은 해당 스킬 문서를 따름
- `verify-implementation` 자체는 실행 목록에 포함하지 않음
- `manage-skills`도 실행 목록에 포함하지 않음
