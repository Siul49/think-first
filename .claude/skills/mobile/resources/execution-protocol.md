# Mobile Agent - Execution Protocol

## Step -1: Thinking Cycle (이해도 점검 + 질문 + 결정)
1. **이해도 사전 점검** — 코드 수정 시 `../code-reading/SKILL.md` 사전 점검 수행
   - 사용자가 수정 대상 코드를 이해하고 있는지 확인
   - 이해 부족 시 설명 요구 → 설명 후 진행
2. **질문** — `../_shared/resources/thinking-cycle.md` Phase 0 수행
   - 작업 복잡도에 맞는 소크라테스 질문 선정
   - 사용자 답변 대기 (답변 전 진행 금지)
3. **결정** — 트레이드오프 존재 시 Phase 1 수행
   - 선택지 제시 + 근거 요구
   - 근거 없는 선택은 재질문

## Step 0: Prepare
1. **Assess difficulty** — see `../_shared/difficulty-guide.md`
   - **Simple**: Skip to Step 3 | **Medium**: All 4 steps | **Complex**: All steps + checkpoints
2. **Check lessons** — read your domain section in `../_shared/lessons-learned.md`
3. **Clarify requirements** — follow `../_shared/clarification-protocol.md`
   - Check **Uncertainty Triggers**: business logic, security/auth, existing code conflicts?
   - Determine level: LOW → proceed | MEDIUM → present options | HIGH → ask immediately
4. **Budget context** — follow `../_shared/context-budget.md` (read symbols, not whole files)

**⚠️ Intelligent Escalation**: When uncertain, escalate early. Don't blindly proceed.

Follow these steps in order (adjust depth by difficulty).

## Step 1: Analyze
- Read the task requirements carefully
- Identify which screens, widgets, and providers are needed
- Check existing code with Serena: `get_symbols_overview("lib/features")`, `find_symbol("ScreenName")`
- Determine platform-specific requirements (iOS vs Android)
- List assumptions; ask if unclear

## Step 2: Plan
- Decide on feature structure using Clean Architecture
- Define entities (domain) and repository interfaces
- Plan state management (Riverpod providers)
- Identify navigation routes (GoRouter)
- Plan offline-first strategy if required
- Note platform differences (Material Design 3 vs iOS HIG)

## Step 3: Implement
- Create/modify files in this order:
  1. Domain: entities and repository interfaces
  2. Data: models, API clients (Dio), repository implementations
  3. Presentation: providers (Riverpod), screens, widgets
  4. Navigation: GoRouter routes
  5. Tests: unit + widget tests
- Use `resources/screen-template.dart` as reference
- Follow Clean Architecture layers strictly

## Step 4: Verify
- Run `resources/checklist.md` items
- Run `../_shared/common-checklist.md` items
- Test on both iOS and Android (or emulators)
- Verify 60fps performance (no jank)
- Check dark mode support

## Pre-Final Step: 코드 리딩 (Thinking Cycle Phase 3)
1. `../code-reading/SKILL.md` 사후 점검 수행
2. 변경된 코드에 대해 레벨 C(기본) 질문 → 사용자 답변 평가
3. 코드 변경이 없는 작업은 생략

## Final Step: 회고 (Thinking Cycle Phase 4)
1. `../_shared/resources/thinking-cycle.md` Phase 4 수행
2. 회고 질문 제시 → 사용자 답변을 `.claude/reflections/YYYY-MM-DD.md`에 기록
3. 회고 없이 작업 종료 금지

## On Error
See `resources/error-playbook.md` for recovery steps.
