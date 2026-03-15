# PM Agent - Execution Protocol

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
   - **Simple**: Lightweight plan, 3-5 tasks | **Medium**: Full 4 steps | **Complex**: Full + API contracts
2. **Clarify requirements** — follow `../_shared/clarification-protocol.md` (critical for PM)
   - Check **Uncertainty Triggers**: business logic, security/auth, existing code conflicts?
   - Determine level: LOW → proceed | MEDIUM → present options | HIGH → ask immediately
3. **Use reasoning templates** — for architecture decisions, use `../_shared/reasoning-templates.md` (decision matrix)
4. **Check lessons** — read cross-domain section in `../_shared/lessons-learned.md`

**⚠️ Intelligent Escalation**: When uncertain, escalate early. Don't blindly proceed.

Follow these steps in order (adjust depth by difficulty).

## Step 1: Analyze Requirements
- Parse user request into concrete requirements
- Identify explicit and implicit features
- List edge cases and assumptions
- Ask clarifying questions if ambiguous
- Use Serena (if existing codebase): `get_symbols_overview` to understand current architecture

## Step 2: Design Architecture
- Select tech stack (frontend, backend, mobile, database, infra)
- Define API contracts (method, path, request/response schema)
- Design data models (tables, relationships, indexes)
- Identify security requirements (auth, validation, encryption)
- Plan infrastructure (hosting, caching, CDN, monitoring)

## Step 3: Decompose Tasks
- Break into tasks completable by a single agent
- Each task has: agent, title, description, acceptance criteria, priority, dependencies
- Minimize dependencies for maximum parallel execution
- Priority tiers: 1 = independent (run first), 2 = depends on tier 1, etc.
- Complexity: Low / Medium / High / Very High
- Save to `.agent/plan.json` and `.gemini/antigravity/brain/current-plan.md`

## Step 4: Validate Plan
- Check: Can each task be done independently given its dependencies?
- Check: Are acceptance criteria measurable and testable?
- Check: Is security considered from the start (not deferred)?
- Check: Are API contracts defined before frontend/mobile tasks?
- Output task-board.md format for orchestrator compatibility

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
