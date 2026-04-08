# Thinking Cycle 독립 스킬화

## 목표

Thinking Cycle을 독립 스킬로 분리하여, 스킬 매칭 여부와 무관하게 **모든 인터랙션**에서 TC가 발동되도록 구조 변경.

## 성공 기준

1. 코드 작업 요청 → TC 발동 (기존과 동일)
2. 학습/이해 질문 ("이게 뭐야?") → TC 발동 (현재 누락 가능)
3. 상태 확인/설정 질문 → TC 발동 (현재 누락)
4. 도메인 스킬 매칭 시 → TC + 도메인 스킬 병행 로드
5. SessionStart 훅으로 TC 스킬 로드 구조적 강제

## 범위

### In
- thinking-cycle 독립 스킬 생성 (SKILL.md)
- SessionStart 훅 확장 (TC 강제 로드 지시 주입)
- antigravity.md Thinking Cycle 섹션 강화
- skill-routing.md에 TC 전처리 레이어 추가
- 12개 도메인 스킬 execution-protocol.md에서 Step -1 / Pre-Final / Final 제거

### Out
- thinking-cycle.md 내용 변경 (기존 프로토콜은 유지)
- 도메인 스킬의 Step 0~N 변경 없음
- verify-*, manage-skills 스킬은 대상 아님 (TC 미적용)

## 마일스톤

| # | 단계 | 산출물 |
|---|------|--------|
| 1 | thinking-cycle 스킬 생성 | `.agent/skills/thinking-cycle/SKILL.md` |
| 2 | SessionStart 훅 확장 | `session-context-loader.sh` 수정 |
| 3 | antigravity.md 강화 | Thinking Cycle 섹션 재작성 |
| 4 | skill-routing.md 업데이트 | TC 전처리 레이어 추가 |
| 5 | 기존 12개 스킬 정리 | execution-protocol.md Step -1/Pre-Final/Final 제거 |

## 아키텍처 변경

### Before
```
[요청] → [스킬 매칭?] → 매칭 O → Step -1 (TC) → Step 0~N → Pre-Final → Final
                        매칭 X → antigravity.md 텍스트 의존 → TC 누락 가능
```

### After
```
[요청] → [SessionStart 훅: TC 강제] → [thinking-cycle 스킬 항상 로드]
              ↓                              ↓
         TC Phase 0/1 수행           [도메인 스킬 병행 로드 (있으면)]
              ↓                              ↓
         TC Phase 2 (실행)  ←────── 도메인 스킬 프로토콜 수행
              ↓
         TC Phase 3 (코드 리딩, 코드 변경 시만)
              ↓
         TC Phase 4 (회고)
```
