---
name: ✅ 검증_파이프라인_관측성
description: Validate Trace ID propagation, sensitive log masking, middleware wiring, and observability test coverage. Use when observability-related files change.
---

# Verify Observability

## Purpose

1. Confirm request Trace ID is generated/propagated and returned in response headers.
2. Confirm sensitive data masking is applied in logging pipeline.
3. Confirm middleware and logging setup are wired in application startup.
4. Confirm observability tests cover critical behavior.

## When to run

- `app/core/logging_config.py` changed
- `app/core/middleware.py` or `app/core/context.py` changed
- `app/main.py` middleware/log setup changed
- `tests/core/test_logging_config.py` or `tests/core/test_middleware.py` changed

## Related Files

| File | Purpose |
|------|---------|
| `app/core/context.py` | Trace ID context storage |
| `app/core/middleware.py` | Trace ID and HTTP middleware chain |
| `app/core/logging_config.py` | JSON logging and sensitive masking |
| `app/main.py` | Middleware registration and logging setup |
| `tests/core/test_logging_config.py` | Logging/masking tests |
| `tests/core/test_middleware.py` | Middleware behavior tests |

## Workflow

### Step 1: Verify Trace ID propagation

```bash
rg -n "X-Trace-ID|set_trace_id|request.state.trace_id|UUID_PATTERN" app/core/middleware.py app/core/context.py
```

PASS if trace ID generation, state propagation, and response header write are all present.

### Step 2: Verify sensitive masking

```bash
rg -n "SENSITIVE_KEYS|SENSITIVE_HEADERS|mask_dict\(|mask_string\(|SensitiveDataFilter|addFilter\(" app/core/logging_config.py
```

PASS if masking utilities and logger filter wiring are present.

### Step 3: Verify app wiring

```bash
rg -n "setup_logging\(|add_middleware\(" app/main.py
```

PASS if logging setup and required middleware registration exist.

### Step 4: Verify tests

```bash
rg -n "trace|mask|middleware|cache-control" tests/core/test_logging_config.py tests/core/test_middleware.py
```

PASS if critical observability behaviors are tested.

## Output Format

| Check | Status | Evidence | Action |
|------|--------|----------|--------|
| Trace ID propagation | PASS/FAIL | `path:line` | fix if needed |
| Sensitive masking | PASS/FAIL | `path:line` | fix if needed |
| App wiring | PASS/FAIL | `path:line` | fix if needed |
| Test coverage | PASS/FAIL | `path:line` | add tests if needed |

## Exceptions

1. Health-check endpoint specific middleware bypass is not a failure if documented.
2. Fresh environment without generated log file is not a failure.
3. Trace ID fallback generation (when request header missing) is valid behavior.