# Skill-Pack 확장 계획서

## 목표 (What)

Antigravity 공식 생태계에 맞춰 skill-pack을 4가지 영역에서 확장한다:
1. 공식 스킬 3종 추가 (skill-creator, mcp-builder, webapp-testing)
2. Hooks 시스템 확장 (새 이벤트 + 핸들러 타입)
3. 서브에이전트 기능 강화 (memory, skills 필드)
4. 플러그인 형식 패키징

## 성공 기준

- [ ] 3개 새 스킬이 기존 스킬과 동일한 구조(SKILL.md + resources/)로 작성됨
- [ ] Hooks가 5개 → 10개+ 이벤트로 확장, prompt/agent 핸들러 타입 포함
- [ ] 5개 에이전트 모두 memory/skills 필드 적용
- [ ] `.agent-plugin/plugin.json` 기반 플러그인 패키징 완료
- [ ] install.sh가 플러그인 모드도 지원
- [ ] antigravity.md에 새 스킬/훅/에이전트 반영

## 범위

### In Scope
- 새 스킬 3종: skill-creator, mcp-builder, webapp-testing
- Hooks 확장: SubagentStart, TaskCompleted, PostToolUseFailure, InstructionsLoaded, PreCompact + prompt/agent 핸들러
- 에이전트 frontmatter 강화: memory, skills, background 필드
- 플러그인 메타데이터 및 패키징 구조

### Out of Scope
- Agent Teams 지원 (실험 단계, 장기 과제)
- 기존 스킬 내용 수정/리팩토링
- 공식 마켓플레이스 등록
- HTTP 핸들러 타입 (외부 서비스 의존성)

## 마일스톤

| # | 마일스톤 | 산출물 |
|---|----------|--------|
| M1 | 새 스킬 3종 작성 | `skill-creator/`, `mcp-builder/`, `webapp-testing/` |
| M2 | Hooks 확장 | 새 훅 스크립트 + settings.json 업데이트 |
| M3 | 에이전트 강화 | 5개 에이전트 .md 업데이트 |
| M4 | 플러그인 패키징 | `.agent-plugin/plugin.json` + install.sh 업데이트 |
| M5 | antigravity.md 갱신 | 문서 동기화 |
