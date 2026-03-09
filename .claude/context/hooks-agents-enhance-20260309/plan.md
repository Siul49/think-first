# Hooks & Subagents 고도화

Task ID: hooks-agents-enhance-20260309

## 목표

Hooks와 Subagents를 고도화하여 자동화 수준을 높이고, worktree 격리로 안전한 병렬 실행을 보장한다.

## 성공 기준

1. Hook 5개 이벤트 활용 (SessionStart, PreToolUse, PostToolUse, Stop, SubagentStop)
2. Subagent 5개, frontmatter 확장 (isolation, maxTurns, skills)
3. Worktree 격리 전략 적용 (읽기 전용 에이전트)
4. CLAUDE.md에 자동 위임 규칙 추가
5. install.sh 호환성 유지

## 범위

### In
- 새 Hook 스크립트 3개 (auto-format, session-context-loader, subagent-post-process)
- 기존 Hook 스크립트 2개 업그레이드 (jq 지원, 패턴 추가)
- Subagent frontmatter 확장 (4개 기존 + 1개 신규)
- settings.json 업데이트
- CLAUDE.md 자동 위임 규칙
- README.md 업데이트

### Out
- pre-commit-check.sh (프로젝트별 린터 의존성 높아 범용성 낮음)
- install.sh merge 로직 (별도 작업으로 분리)
