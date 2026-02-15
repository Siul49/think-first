---
name: workflow-guide
description: Guide for coordinating PM, Frontend, Backend, Mobile, and QA agents on complex projects via CLI
---

# Multi-Agent Workflow Guide

## When to use
- Complex feature spanning multiple domains
- Coordination needed between frontend/backend/mobile/QA
- User wants manual step-by-step execution

## When NOT to use
- Simple single-domain tasks
- Fully automated execution (use orchestrator)

## Core Rules
1. Start with PM planning
2. Run same-priority tasks in parallel when dependencies allow
3. Final QA is mandatory
4. Keep API contracts explicit before parallel UI/mobile work

## Workflow

### Step 1: Plan with PM Agent
Create task breakdown with priorities and dependencies.

### Step 2: Spawn by priority tier
Run same-priority tasks in parallel.

### Step 3: Monitor and coordinate
Track progress and resolve dependency mismatches.

### Step 4: QA review
Run QA after implementation completion.

## Automated Alternative
For automatic orchestration with pre/verify/post gates, use `orchestrator`.

## References
- Workflow examples: `resources/examples.md`