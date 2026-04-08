# Checklist (Antigravity Upgrade)

- [ ] [M1] python/쉘 스크립트 등을 이용한 `antigravity`, `Antigravity` 대소문자 무관 일괄 치환 파일 탐색
- [ ] [M1] 확인된 파일 안의 잔재 식별자를 `gemini` 또는 `antigravity` 로 일괄 변경
- [ ] [M2] `.agent/hooks/` 디렉토리 전체 강제 삭제
- [ ] [M2] `.agent/settings.json` 내의 hook 관련 속성 삭제 (settings.local.json 포함)
- [ ] [M3] `.agent/agents/` (서브에이전트 스폰 관련) 내용물 점검 후 폐기 또는 워크플로우 안내문구로 프롬프트 치환
- [ ] [공통] `GEMINI.md` 의 '구성 요소' 테이블 등에서 훅 관련 설명을 지우고 Git Hook 등 대체 방안으로 수정 반영
- [ ] 작업 파일 영향도 및 정상 변환 상태 최종 모니터링
