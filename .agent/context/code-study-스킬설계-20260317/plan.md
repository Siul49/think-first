# code-study 스킬 설계 계획

## 목표
code-reading을 대체하는 code-study 스킬을 만들어 TC Phase 3를 완전히 대체한다.

## 핵심 문제 (code-reading의 한계)
1. 질문이 집요하지 않음 — 대충 답해도 "맞습니다" 하고 넘어감
2. 기반 개념을 안 다룸 — 코드 흐름만 묻고, 도구(exit code, pipefail, 정규식 등) 스킵
3. 미흡한 답변 후 설명만 하고 끝 — 다시 확인 없이 회고로 직행

## 성공 기준
- [ ] code-study SKILL.md + execution-protocol.md 작성 완료
- [ ] TC Phase 3에서 code-reading → code-study로 교체
- [ ] antigravity.md 스킬 테이블 갱신
- [ ] code-reading 스킬 폐기 (디렉토리 삭제)
- [ ] skill-routing.md 갱신

## 범위
- **In**: code-study 스킬 생성, TC 연동, antigravity.md 갱신, code-reading 폐기
- **Out**: 다른 스킬 수정, 훅 변경, verify 스킬 추가

## code-study vs code-reading 핵심 차이

| 측면 | code-reading (폐기) | code-study (신규) |
|------|-------------------|------------------|
| 깊이 | What → Why → 응용 (3단계) | What → Why → 개념 → 연결 → 응용 (5단계) |
| 기반 개념 | 안 다룸 | 코드가 사용하는 개념/도구를 별도로 다룸 |
| 답변 평가 | 설명 후 넘어감 | 설명 후 재확인 질문 (이해 검증 루프) |
| 집요함 | 1회 질문 | 이해될 때까지 반복 (최대 3회 힌트 후 설명) |
| 스킵 | "바빠"→B, "급해"→A | "바로 넘어가자"로 스킵 가능하되, 최소 1개 개념은 확인 |
