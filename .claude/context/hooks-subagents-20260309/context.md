# 작업 배경

Task ID: hooks-subagents-20260309

## 배경

skill-pack은 현재 Skills만 사용 중. Claude Code가 제공하는 Hooks(자동화)와 Subagents(작업 위임)를 도입하여 워크플로우를 강화한다.

## 제약

- 기존 스킬은 삭제하지 않음 (에이전트와 공존)
- Hook 스크립트는 bash 기반 (크로스 플랫폼)
- settings.json은 설치 시 덮어쓰기 방지 필요

## 결정사항

- Hook은 `.claude/settings.json`에 정의 (팀 공유)
- 포매터 hook은 주석으로 커스터마이징 안내 (프로젝트마다 다르므로)
- Subagent는 4개로 시작: code-reviewer, task-planner, test-runner, doc-writer
- 스킬 = 행동 규칙, 에이전트 = 독립 실행 위임으로 역할 분담

## 리스크

- Hook 스크립트가 Windows에서 동작하지 않을 수 있음 → Git Bash 기준으로 작성
- settings.json 충돌 시 사용자 설정 덮어쓸 수 있음 → 머지 로직 또는 템플릿 제공
