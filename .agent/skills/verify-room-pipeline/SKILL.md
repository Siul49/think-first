---
name: verify-room-pipeline
description: Validate room parsing, collection persistence, DTO mapping, and availability integration for the room data pipeline. Use when room-domain code changes.
---

# Verify Room Pipeline

## Purpose

1. Validate parser strategy and fallback behavior.
2. Validate collection persistence and unresolved-item handling.
3. Validate DTO alias/nullability and loader mapping.
4. Validate API/service integration and test coverage.

## When to run

- `app/services/room_parser_service.py` changed
- `app/services/room_collection_service.py` changed
- `app/models/dto.py` or `app/utils/room_loader.py` changed
- `app/services/availability_service.py` changed
- `tests/services/test_room_parser_service.py` or `tests/api/test_available_room.py` changed
- room pipeline support scripts changed (`scripts/check_db.py`, `scripts/test_parsing.py`)

## Related Files

| File | Purpose |
|------|---------|
| `app/services/room_parser_service.py` | Parser and fallback logic |
| `app/services/room_collection_service.py` | Collection persistence/unresolved export |
| `app/models/dto.py` | DTO alias and validation rules |
| `app/utils/room_loader.py` | DB result mapping to DTO |
| `app/services/availability_service.py` | Availability response composition |
| `tests/services/test_room_parser_service.py` | Parser pipeline tests |
| `tests/api/test_available_room.py` | API-level room availability tests |
| `scripts/check_db.py` | DB-level sanity checks |
| `scripts/test_parsing.py` | Parser scenario checks |

## Workflow

### Step 1: Verify parser stages

```bash
rg -n "KEYWORD|regex|fallback|parse_room_desc|validate" app/services/room_parser_service.py
```

PASS if keyword/regex/fallback validation stages are present.

### Step 2: Verify collection persistence

```bash
rg -n "upsert|existing|unresolved|MANUAL_REVIEW|export" app/services/room_collection_service.py
```

PASS if upsert, unresolved handling, and safe-write/export behavior exist.

### Step 3: Verify DTO/loader consistency

```bash
rg -n "alias=|model_validate|handle_null|join|branch" app/models/dto.py app/utils/room_loader.py
```

PASS if DTO aliases/null handling and loader mappings are consistent.

### Step 4: Verify service/API/test linkage

```bash
rg -n "check_availability|get_rooms_by_criteria|room" app/services/availability_service.py tests/services/test_room_parser_service.py tests/api/test_available_room.py
```

PASS if service integration and critical tests exist.

## Output Format

| Check | Status | Evidence | Action |
|------|--------|----------|--------|
| Parser stages | PASS/FAIL | `path:line` | fix if needed |
| Collection persistence | PASS/FAIL | `path:line` | fix if needed |
| DTO/loader consistency | PASS/FAIL | `path:line` | fix if needed |
| Service/API/tests | PASS/FAIL | `path:line` | fix if needed |

## Exceptions

1. Optional external parser engine unavailability can be tolerated if fallback path is covered.
2. Generated sample data files are not pipeline failures by themselves.
3. Optional coordinate filters are acceptable when API contract allows nullable fields.