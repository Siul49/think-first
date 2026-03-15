# QA Agent - Execution Protocol

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
   - **Simple**: Quick security + quality check | **Medium**: Full 4 steps | **Complex**: Full + prioritized scope
2. **Check lessons** — read QA section in `../_shared/lessons-learned.md`
3. **Clarify requirements** — follow `../_shared/clarification-protocol.md`
   - Check **Uncertainty Triggers**: security/auth concerns, existing code conflict potential?
   - Determine level: LOW → proceed | MEDIUM → present options | HIGH → ask immediately
4. **Budget context** — follow `../_shared/context-budget.md` (prioritize high-risk files)
5. **After review**: add recurring issues to `../_shared/lessons-learned.md`

**⚠️ Intelligent Escalation**: When uncertain, escalate early. Don't blindly proceed.

Follow these steps in order (adjust depth by difficulty).

## Step 1: Scope
- Identify what to review: new feature, full audit, or specific concern
- List all files/modules to inspect
- Determine review depth: quick check vs. comprehensive audit
- Use Serena to map the codebase:
  - `get_symbols_overview("src/")`: Understand structure
  - `search_for_pattern("password.*=.*[\"']")`: Find hardcoded secrets
  - `search_for_pattern("execute.*\\$\\{")`: Find SQL injection
  - `search_for_pattern("innerHTML")`: Find XSS vulnerabilities

## Step 2: Audit
Review in this priority order:
1. **Security** (CRITICAL): OWASP Top 10, auth, injection, data protection
2. **Performance**: API latency, N+1 queries, bundle size, Core Web Vitals
3. **Accessibility**: WCAG 2.1 AA, keyboard nav, screen reader, contrast
4. **Code Quality**: test coverage, complexity, architecture adherence

Use `resources/checklist.md` (renamed qa-checklist) as the comprehensive review guide.

## Step 3: Report
Generate structured report with:
- Overall status: PASS / WARNING / FAIL
- Findings grouped by severity (CRITICAL > HIGH > MEDIUM > LOW)
- Each finding: file:line, description, remediation code
- Performance metrics vs. targets

## Step 4: Verify
- Run `resources/self-check.md` to verify your own review quality
- Ensure no false positives (each finding is real and reproducible)
- Confirm remediation suggestions are correct and complete
- Run `../_shared/common-checklist.md` for general quality

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
