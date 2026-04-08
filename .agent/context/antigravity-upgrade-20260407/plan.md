# Plan: Antigravity 심화 개조 (Phase 1)

**목표**
1. 불필요한 잔재(Hooks/Agent scripts)의 완전 소거
2. Antigravity와 호환되는 플로우로 문서/설정 전환
3. antigravity 식별자 일괄 클렌징

**마일스톤 (Milestones)**
- [M1] 식별자 클렌징: `.agent` 하위 및 `GEMINI.md`, 스크립트 류의 `antigravity`, `Antigravity` 키워드를 `antigravity`, `gemini` 등으로 대리 치환 및 무결성 검증.
- [M2] Hook 구조 제거 및 대체 안내: `.agent/hooks/` 폴더 제거, `settings.json` 내 후킹 설정 파괴. `GEMINI.md` 에 Git Hooks 권장 내용 추가.
- [M3] Sub-agents 구동체계 개조: `.agent/agents/` 의 백그라운드 쉘 전용 마크다운을 분석해, Antigravity의 `/orchestrate` 워크플로우에 맞게 텍스트 수정 및 불필요 파일 제거.

**성공 기준**
- 프로젝트 내에서 더이상 `antigravity` (불가피한 URL 제외) 문자열과 `.agent/` 관련 경로가 검색되지 않음.
- Antigravity에서 절대 돌아가지 않는 쉘 스크립트 코드나 옵션이 소거됨.
