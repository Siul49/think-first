# 실행 체크리스트

Task ID: think-first-improvement-20260309

## Phase 1: resources/ 마이그레이션

- [x] 확인 완료 — 이미 `.claude/skills/*/resources/`에 존재 (commit, review는 원래 없음)

## Phase 2: context 경로 통일

- [ ] CLAUDE.md: `.agent/context/` → `.claude/context/`
- [ ] install.sh: gitignore 경로 확인 (이미 `.claude/context/`)
- [ ] 프로젝트 구조 섹션 업데이트

## Phase 3: qa/review 역할 분리

- [ ] review: diff 중심 빠른 리뷰로 재정의
- [ ] qa: 전체 감사(보안/성능/접근성) 전용으로 명확화

## Phase 4: _shared/resources/ 보강

- [ ] context-loading.md 추가
- [ ] context-budget.md 추가
- [ ] skill-routing.md 추가

## Phase 5: install.sh 업데이트

- [ ] context 디렉토리 초기화 로직 추가
- [ ] 설치 후 안내 메시지 업데이트
