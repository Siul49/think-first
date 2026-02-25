# Big Task Context

Task ID: translate-comments-ko
Last Reviewed: 2026-02-23T06:23:09Z

## Background
- Why this task exists.

## Constraints
- Technical constraints:
- `app/` 범위 내 주석 및 docstring 중심으로 정리
- 코드 로직 변경 없이 텍스트 정리 우선
- Product constraints:
- 한자 사용 금지
- 깨진 `?` 형태 기호 사용 금지

## Decisions
- Decision:
  - Reason:
- `availability_service.py`, `room_collection_service.py`의 깨진 텍스트를 수동 재작성
  - 자동 번역 타임아웃 이후 텍스트 손상이 집중된 파일을 우선 복구하는 것이 안전함

## Risks
- Risk:
  - Mitigation:





