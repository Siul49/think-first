---
description: resources 스킬 프로토콜
---

# Clarification Protocol

When requirements are ambiguous, "assuming and proceeding" usually leads in the wrong direction.
Follow this protocol to secure clear requirements before execution.

> **Core Principle**: AI는 실행자가 아니라 사고 파트너다. 답을 주기 전에 질문하고, 결정을 대신하지 않는다.

---

## Thinking Cycle 연동 (필수)

이 프로토콜은 `thinking-cycle.md`와 함께 작동한다.

**불확실성 레벨과 무관하게, 모든 작업에 최소 1개 질문은 필수.**

| 상황 | 기존 동작 | 변경된 동작 |
|------|-----------|------------|
| LOW 불확실성 | 기본값 적용 후 진행 | **최소 1개 질문** 후 진행 |
| MEDIUM 불확실성 | 옵션 제시 후 선택 요청 | 옵션 제시 + **근거 요구** |
| HIGH 불확실성 | 차단, 질문 목록 제시 | 차단, 질문 목록 제시 (동일) |

### 스킵 방지 정책

- 사용자가 "그냥 해줘", "알아서 해"라고 요청해도 **최소 1개 질문에 답해야 진행**
- 질문 없이 실행을 시작하는 것은 **금지**
- 스킵 요청 시 대응:

```
이해합니다, 하지만 최소 1개 질문에는 답이 필요합니다.
가장 핵심적인 질문 하나만 드릴게요:

→ {가장 중요한 질문 1개}
```

---

## Uncertainty Level Definitions

| Level | State | Action | Example |
|-------|-------|--------|---------|
| **LOW** | Clear | **최소 1개 질문** + defaults 적용 후 진행 | "Create a TODO app" |
| **MEDIUM** | Partially ambiguous | Present 2-3 options + **근거 있는 선택** 요구 | "Create a user management system" |
| **HIGH** | Very ambiguous | **Cannot proceed**, must ask questions | "Create a good app" |

---

## Uncertainty Triggers

Automatically classify as MEDIUM/HIGH level in the following situations:

### HIGH (Must Ask)
- [ ] Business logic decisions needed (pricing policy, approval workflow, etc.)
- [ ] Security/authentication decisions (OAuth provider, permission model, etc.)
- [ ] Possible conflict with existing code
- [ ] Requirements are subjective ("good", "fast", "pretty")
- [ ] Scope feels unlimited

### MEDIUM (Present Options)
- [ ] 2+ technology stack choices possible
- [ ] Trade-offs exist for implementation approach
- [ ] Multiple features with unclear priority
- [ ] External API/service selection needed

---

## Escalation Templates

### LOW → 질문 1개 + Proceed (Assumed)
```
🤔 진행 전에 하나만:
→ {작업 범위/영향에 관한 질문 1개}

⚠️ 답변 확인 후 아래 기본값으로 진행합니다:
- JWT authentication included
- PostgreSQL database
- REST API
- MVP scope (CRUD only)
```

### MEDIUM → Request Selection + 근거 요구 (Options)
```
⚖️ 선택이 필요합니다: {specific issue}

Option A: {approach}
  → 장점: {benefits}
  → 단점: {drawbacks}
  → 비용: {low/medium/high}

Option B: {approach}
  → 장점: {benefits}
  → 단점: {drawbacks}
  → 비용: {low/medium/high}

Option C: {approach}
  → 장점: {benefits}
  → 단점: {drawbacks}
  → 비용: {low/medium/high}

어떤 걸 선택하시겠어요? **이유도 함께** 알려주세요.
```

> 근거 없이 "A"만 답하면 → "왜 A인지 한 줄만 더 알려주세요."

### HIGH → Blocked
```
❌ Cannot proceed: Requirements too ambiguous

Specific uncertainty: {what is unclear}

Questions needed:
1. {specific question}
2. {specific question}
3. {specific question}

Impact of proceeding blindly: {what could go wrong}

Status: BLOCKED (awaiting clarification)
```

---

## Required Verification Items

If any of the items below are unclear, **do not assume** — explicitly record them.

### Common to All Agents
| Item | Verification Question | Default (if assumed) | Uncertainty |
|------|----------------------|---------------------|-------------|
| Target users | Who will use this service? | General web users | LOW |
| Core features | What are the 3 must-have features? | Infer from task description | MEDIUM |
| Tech stack | Are there specific framework constraints? | Project default stack | LOW |
| Authentication | Is login required? | JWT authentication included | MEDIUM |
| Scope | MVP or full-featured? | MVP | LOW |

### Backend Agent Additional Verification
| Item | Verification Question | Default | Uncertainty |
|------|----------------------|---------|-------------|
| DB selection | PostgreSQL? MongoDB? SQLite? | PostgreSQL | MEDIUM |
| API style | REST? GraphQL? gRPC? | REST | MEDIUM |
| Auth method | JWT? Session? OAuth? | JWT (access + refresh) | HIGH |
| File upload | Needed? Size limit? | Not needed | LOW |
| Deployment environment | Serverless? Container? VM? | Container | MEDIUM |

### Frontend Agent Additional Verification
| Item | Verification Question | Default | Uncertainty |
|------|----------------------|---------|-------------|
| SSR/CSR | Server-side rendering needed? | Next.js App Router (SSR) | MEDIUM |
| Dark mode | Support needed? | Supported | LOW |
| Internationalization | Multi-language support? | Not needed | LOW |
| Existing design system | UI library to use? | shadcn/ui | MEDIUM |
| State management | Context? Redux? Zustand? | Zustand | MEDIUM |

### Mobile Agent Additional Verification
| Item | Verification Question | Default | Uncertainty |
|------|----------------------|---------|-------------|
| Platform | iOS only? Android only? Both? | Both | MEDIUM |
| Offline | Offline support needed? | Not needed | LOW |
| Push notifications | Needed? | Not needed | LOW |
| Minimum OS | iOS/Android minimum versions? | iOS 14+, Android API 24+ | LOW |
| Architecture | MVC? MVVM? Clean? | MVVM | MEDIUM |

---

## Detailed Response by Ambiguity Level

### Level 1 (LOW): Slightly ambiguous (core is clear, details lacking)
Example: "Create a TODO app"

**Response**: Apply defaults and record assumption list in result
```
⚠️ Assumptions:
- JWT authentication included
- PostgreSQL database
- REST API
- MVP scope (CRUD only)
```

### Level 2 (MEDIUM): Considerably ambiguous (core features unclear)
Example: "Create a user management system"

**Response**: Narrow scope to 3 core features, specify and proceed
```
⚠️ Interpreted scope (3 core features):
1. User registration + login (JWT)
2. Profile management (view/edit)
3. Admin user list (admin role only)

NOT included (would need separate task):
- Role-based access control (beyond admin/user)
- Social login (OAuth)
- Email verification
```

### Level 3 (HIGH): Very ambiguous (direction itself unclear)
Example: "Create a good app", "Improve this"

**Response**: Do not proceed, record clarification request in result
```
❌ Cannot proceed: Requirements too ambiguous

Questions needed:
1. What is the app's primary purpose?
2. Who are the target users?
3. What are the 3 must-have features?
4. Are there existing designs or wireframes?

Status: blocked (awaiting clarification)
```

---

## PM Agent Only: Requirements Specification Framework

PM Agent uses the framework below to specify ambiguous requests:

```
=== Requirements Specification ===

Original request: "{user's original text}"

1. Core goal: {define in one sentence}
2. User stories:
   - "As a {user}, I want to {action} so that {benefit}"
   - (minimum 3)
3. Feature scope:
   - Must-have: {list}
   - Nice-to-have: {list}
   - Out-of-scope: {list}
4. Technical constraints:
   - {existing code / stack / compatibility}
5. Success criteria:
   - {measurable conditions}
```

---

## Application in Subagent Mode

CLI subagents cannot ask users directly.
Therefore:

1. **Level 1**: Apply defaults + record assumptions → Proceed
2. **Level 2**: Narrow and interpret scope + specify → Proceed
3. **Level 3**: `Status: blocked` + question list → Do not proceed

When Orchestrator receives Level 3 result, it relays questions to user
and re-runs that agent after receiving answers.
