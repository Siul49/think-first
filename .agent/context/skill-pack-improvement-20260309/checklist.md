# 실행 체크리스트

Task ID: skill-pack-improvement-20260309

## Phase 1: resources/ 마이그레이션

- [x] 확인 완료 — 이미 `.agent/skills/*/resources/`에 존재 (commit, review는 원래 없음)

## Phase 2: context 경로 통일

- [x] antigravity.md: `.agent/context/`로 통일 완료
- [x] install.sh: `.agent/context/` gitignore 경로 정합
- [x] 프로젝트 구조 섹션 업데이트 완료

## Phase 3: qa/review 역할 분리

- [x] review: diff 중심 빠른 리뷰로 재정의 완료
- [x] qa: 전체 감사 전용으로 명확화 완료
- [x] antigravity.md 스킬 테이블 설명 업데이트

## Phase 4: _shared/resources/ 보강

- [x] context-loading.md 추가 (한국어 + Codex 참조 제거)
- [x] context-budget.md 추가 (한국어)
- [x] skill-routing.md 추가 (한국어 + 역할 분리 반영)

## Phase 5: install.sh 업데이트

- [x] context 디렉토리 초기화 로직 추가
- [x] 설치 후 안내 메시지 업데이트 (context 안내 추가)
