# Debug Agent - Execution Protocol

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
   - Check **Uncertainty Triggers**: security/auth related bugs, existing code conflict potential?
   - Determine level: LOW → proceed | MEDIUM → present options | HIGH → ask immediately
4. **Use reasoning templates** — for Complex bugs, use `../_shared/reasoning-templates.md` (hypothesis loop, execution trace)
5. **Budget context** — follow `../_shared/context-budget.md` (use find_symbol, not read_file)

**⚠️ Intelligent Escalation**: When uncertain, escalate early. Don't blindly proceed.

Follow these steps in order (adjust depth by difficulty).

## Step 1: Understand
- Gather: What happened? What was expected? Error messages? Steps to reproduce?
- Read relevant code using Serena:
  - `find_symbol("functionName")`: Locate the failing function
  - `find_referencing_symbols("Component")`: Find all callers
  - `search_for_pattern("error pattern")`: Find similar issues
- Classify: logic bug, runtime error, performance issue, security flaw, or integration failure

## Step 2: Reproduce & Diagnose
- Trace execution flow from entry point to failure
- Identify the exact line and condition that causes the bug
- Determine root cause (not just symptom):
  - Null/undefined access?
  - Race condition?
  - Missing validation?
  - Wrong assumption about data shape?
- Check `resources/common-patterns.md` for known patterns

## Step 3: Fix & Test
- Apply minimal fix that addresses the root cause
- Write a regression test that:
  - Fails without the fix
  - Passes with the fix
  - Covers the specific edge case
- Check for similar patterns elsewhere: `search_for_pattern("same_bug_pattern")`
- If found, fix proactively or report them

## Step 4: Document & Verify
- Run `resources/checklist.md` items
- Save bug report to `.gemini/antigravity/brain/bugs/` using `resources/bug-report-template.md`
- Include: root cause, fix, prevention advice
- Verify no regressions in related functionality

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
