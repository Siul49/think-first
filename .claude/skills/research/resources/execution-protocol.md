# Research 실행 프로토콜

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

## 1단계: 범위 확정 (필수)

```
질문 체크리스트:
□ 조사 목적이 명확한가? (기술 선택 / 패턴 탐색 / 문제 해결)
□ 깊이가 결정되었는가? (quick-scan / deep-dive)
□ 제약 조건이 파악되었는가? (기존 스택, 성능, 팀 규모)
□ 결과물 형태가 합의되었는가? (비교표 / 추천안 / 보고서)
```

불명확한 경우 → `_shared/resources/clarification-protocol.md` 참조.

## 2단계: 정보 수집

### quick-scan 모드
1. 코드베이스 분석 (기존 스택/패턴 파악)
2. 웹 검색 (최신 정보 1-2회)
3. 핵심 선택지 2-3개 도출
4. 간단 비교표 작성

### deep-dive 모드
1. 코드베이스 심층 분석
2. 공식 문서 확인
3. GitHub 이슈/디스커션 확인
4. 벤치마크/성능 데이터 수집
5. 유사 프로젝트 사례 조사
6. 상세 비교 매트릭스 작성

## 3단계: 분석 및 추천

1. 수집 정보를 기준별로 정리
2. 프로젝트 컨텍스트에 맞게 가중치 부여
3. 명확한 추천안 도출 (1순위 + 대안)
4. 리스크/트레이드오프 명시

## 4단계: 보고

`research-templates.md`의 보고서 형식 사용.
모든 추천에 근거 출처 포함.

## Pre-Final Step: 코드 리딩 (Thinking Cycle Phase 3)
1. `../code-reading/SKILL.md` 사후 점검 수행
2. 변경된 코드에 대해 레벨 C(기본) 질문 → 사용자 답변 평가
3. 코드 변경이 없는 작업은 생략

## Final Step: 회고 (Thinking Cycle Phase 4)
1. `../_shared/resources/thinking-cycle.md` Phase 4 수행
2. 회고 질문 제시 → 사용자 답변을 `.claude/reflections/YYYY-MM-DD.md`에 기록
3. 회고 없이 작업 종료 금지
