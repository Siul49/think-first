# Thinking Mode — 체크리스트

## M1: 핵심 프레임워크

- [x] `.agent/skills/_shared/thinking-cycle.md` 생성
  - [x] 4단계 사이클 정의 (질문 → 결정 → 실행 → 회고)
  - [x] 질문 깊이 자연 조절 가이드 (작업 복잡도에 비례)
  - [x] 스킵 불가 정책 명시
  - [x] 스킬별 적용 예시
- [x] antigravity.md 핵심 철학 섹션 추가/변경
  - [x] 프로젝트 정체성 재정의 ("사고 강제 에이전트 스킬 번들")
  - [x] Thinking Cycle을 작업 실행 프로토콜에 통합
  - [x] 기존 "작업 실행 프로토콜"에 Phase 0(질문) 추가

## M2: 회고 시스템

- [x] `.agent/reflections/` 디렉토리 구조 설계
- [x] 회고 템플릿 생성 (`.agent/skills/_shared/reflection-template.md`)
  - [x] 필수 항목: 뭘 배웠나, 다음에 다르게 할 건 뭔가, 어떤 가정이 맞았/틀렸나
  - [x] 날짜별 파일 형식 (`YYYY-MM-DD.md`)
  - [x] 하루에 여러 작업 시 append 방식
- [x] 회고 강제 메커니즘 (antigravity.md Phase 5 + thinking-cycle.md Phase 3에 명시)

## M3: 스킬 적용

- [x] 각 스킬 SKILL.md에 Thinking Cycle 참조 추가
  - [x] backend
  - [x] frontend
  - [x] mobile
  - [x] debug
  - [x] qa
  - [x] pm
  - [x] commit
  - [x] review
  - [x] research
  - [x] document
  - [x] context-builder
  - [x] skill-creator
  - [x] mcp-builder
  - [x] webapp-testing
- [x] 각 스킬의 execution-protocol.md에 Phase 0(질문) 단계 삽입 (12개 + commit/review는 SKILL.md만)

## M4: 보호 장치

- [x] clarification-protocol.md 강화
  - [x] 모든 불확실성 레벨에서 최소 1개 질문 필수
  - [x] "그냥 해줘" 대응 정책 명시
  - [x] 질문 없이 실행 시작하는 것을 금지하는 규칙
- [x] reasoning-templates.md에 소크라테스 질문 패턴 추가

## M5: 배포 통합

- [x] install.sh에 reflections 디렉토리 생성 추가
- [x] plugin.json description 업데이트
- [x] .gitignore — reflections는 커밋 포함 (성장 기록이므로 제외하지 않음)
