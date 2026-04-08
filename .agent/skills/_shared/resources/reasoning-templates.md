---
description: resources 스킬 프로토콜
---

# Reasoning Templates

Use these templates by filling in the blanks when multi-step reasoning is needed.
Complete **each step before moving to the next** to avoid losing direction.

---

## 0. Socratic Questioning (All Agents — Thinking Cycle Phase 0)

Use this template to generate questions before any execution.
Select question patterns based on task type and complexity.

```
=== Socratic Questions for: {task summary} ===

Task complexity: {단순 / 보통 / 복합}
Question count: {1 / 2-3 / 3-5}

Questions:
1. [{category}] {open-ended question}
2. [{category}] {open-ended question} (if applicable)
3. [{category}] {open-ended question} (if applicable)

Categories:
  - [범위] 영향 범위, 파급 효과
  - [이유] 왜 이 접근인지, 대안은 검토했는지
  - [실패] 실패 시나리오, 새로운 문제 가능성
  - [사용자] 사용자/소비자 관점에서의 직관성
  - [장기] 6개월 후 유효성, 유지보수성, 확장성

Rules:
  - Must be open-ended (no Yes/No answers)
  - Must relate directly to the current task
  - Depth scales with complexity (not artificially deep for simple tasks)
```

**Example (단순 — 타이포 수정):**
```
=== Socratic Questions for: README.md 오타 수정 ===

Task complexity: 단순
Question count: 1

Questions:
1. [범위] 이 오타가 다른 문서에도 반복되고 있을 가능성이 있는데, 확인해봤어?
```

**Example (보통 — API 엔드포인트 추가):**
```
=== Socratic Questions for: 사용자 프로필 API 추가 ===

Task complexity: 보통
Question count: 2

Questions:
1. [사용자] 이 API의 주요 소비자가 누구야? 응답 형태가 그 소비자에게 최적인지 생각해봤어?
2. [실패] 프로필 데이터가 없는 사용자에 대해 어떻게 처리할 건지 정했어?
```

**Example (복합 — 인증 시스템 전환):**
```
=== Socratic Questions for: Session → JWT 인증 전환 ===

Task complexity: 복합
Question count: 4

Questions:
1. [이유] Session 기반의 어떤 문제가 이 전환을 촉발했어? JWT가 그 문제를 정말 해결해?
2. [실패] 전환 중 기존 로그인 세션이 무효화되면 사용자 경험에 어떤 영향이 있어?
3. [장기] JWT의 토큰 갱신 전략을 어떻게 설계할 건지 생각해봤어?
4. [범위] 이 전환이 영향을 미치는 서비스/클라이언트가 몇 개야?
```

---

## 1. Debugging Reasoning (Debug Agent, Backend/Frontend/Mobile Agent)

Repeat the loop below when finding the cause of a bug. After 3 iterations without resolution, record `Status: blocked`.

```
=== Hypothesis #{N} ===

Observation: {error message, symptoms, reproduction conditions}
Hypothesis: "{phenomenon} is caused by {suspected cause}"
Verification method: {how to verify — code reading, logs, tests, etc.}
Verification result: {what was actually confirmed}
Verdict: Correct / Incorrect

If correct → Move to fix step
If incorrect → Write new hypothesis #{N+1}
```

**Example:**
```
=== Hypothesis #1 ===
Observation: "Cannot read property 'map' of undefined" in TodoList
Hypothesis: "todos is undefined when .map() is called before API response"
Verification method: Check initial value of todos in TodoList component
Verification result: No initial value in useState() → undefined
Verdict: Correct → Set default value of todos to []
```

---

## 2. Architecture Decision (PM Agent, Backend Agent)

Fill in this matrix when technology selection or design decisions are needed.

```
=== Decision: {what needs to be chosen} ===

Options:
  A: {option A}
  B: {option B}
  C: {option C} (if applicable)

Evaluation criteria and scores (1-5):
| Criterion           | A | B | C | Weight |
|---------------------|---|---|---|--------|
| Performance         |   |   |   | {H/M/L} |
| Implementation complexity |   |   |   | {H/M/L} |
| Team familiarity    |   |   |   | {H/M/L} |
| Scalability         |   |   |   | {H/M/L} |
| Existing code consistency |   |   |   | {H/M/L} |

Conclusion: {selected option}
Reason: {1-2 line rationale}
Trade-off: {why giving up advantages of unchosen options}
```

**Example:**
```
=== Decision: State management library ===

Options:
  A: Zustand
  B: Redux Toolkit
  C: React Context

| Criterion           | A | B | C | Weight |
|---------------------|---|---|---|--------|
| Performance         | 4 | 4 | 3 | M     |
| Implementation complexity | 5 | 3 | 4 | H     |
| Team familiarity    | 3 | 5 | 5 | M     |
| Scalability         | 4 | 5 | 2 | M     |
| Existing code consistency | 2 | 5 | 3 | H |

Conclusion: Redux Toolkit
Reason: Existing codebase uses RTK, highest team familiarity
Trade-off: Giving up Zustand's simplicity for consistency
```

---

## 3. Cause-Effect Chain (Debug Agent)

Use this to trace execution flow step-by-step in complex bugs.

```
=== Execution Flow Trace ===

1. [Entry point]   {file:function} - {input value}
2. [Call]          {file:function} - {passed value}
3. [Processing]    {file:function} - {transformation/logic}
4. [Failure point] {file:function} - {unexpected behavior here}
   - Expected: {expected behavior}
   - Actual: {actual behavior}
   - Cause: {why different}
5. [Result]        {error message or incorrect output}
```

**Example:**
```
1. [Entry point]   pages/todos.tsx:TodoPage - user accesses /todos
2. [Call]          hooks/useTodos.ts:useTodos - fetchTodos() called
3. [Processing]    api/todos.ts:fetchTodos - GET /api/todos request
4. [Failure point] hooks/useTodos.ts:23 - data returned as undefined
   - Expected: data = [] (empty array)
   - Actual: data = undefined (before fetch completes)
   - Cause: useQuery initialData not set
5. [Result]        undefined.map() in TodoList → TypeError
```

---

## 4. Refactoring Judgment (All Implementation Agents)

Use this to decide "fix it or leave it as-is" when modifying code.

```
=== Refactoring Judgment ===

Current code issue: {what is the problem}
Relation to task: Directly related / Indirectly related / Unrelated

Directly related → Fix it
Indirectly related → Record in result, fix only within current task scope
Unrelated → Record in result only (never fix)
```

---

## 5. Performance Bottleneck Analysis (Debug Agent, QA Agent)

Systematically find bottlenecks for "it's slow" reports.

```
=== Performance Bottleneck Analysis ===

Measurements:
  - Total response time: {ms}
  - DB query time: {ms} ({N} queries)
  - Business logic: {ms}
  - Serialization/rendering: {ms}

Bottleneck location: {step taking the most time}
Cause: {N+1 query / heavy computation / large response / missing index / ...}
Solution: {specific fix method}
Expected improvement: {X}ms → {Y}ms
```

---

## Usage Rules

1. **When to use**: Required for Complex difficulty tasks, recommended for Medium
2. **Where to record**: Record reasoning process in `progress-{agent-id}.md`
3. **If blanks cannot be filled**: Gather that information first (Serena, code reading, log checking)
4. **Unresolved after 3 iterations**: `Status: blocked` + include reasoning so far in result
