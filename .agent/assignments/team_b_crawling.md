# 팀원 2 — DB/인프라 고도화

> 예상 공수: **8~12h** · 확장성과 유지보수성
> 우선순위: Task 1~2 🔴 P0 / Task 3 🟢 P2

---

## Task 1: BE-23 · `crawler_type` 매핑 DB화 (4~5h)

### 왜 배포 전 필수인가?
신규 합주실 추가 시마다 **백엔드 코드 수정 + 서버 재배포**가 필요한 하드코딩 구조입니다.
DB 컬럼 하나만 추가하면 Supabase에서 값만 입력하면 즉시 반영됩니다.

### 현재 문제
```python
# 현재: 코드에 직접 박혀있음
registry.register("groove", GrooveCrawler())   # groove_checker.py
registry.register("naver", NaverCrawler())     # naver_checker.py
registry.register("dream", DreamCrawler())     # dream_checker.py
```

### 변경 후 (DB 기반)
```
DB branch 테이블:
| business_id | name        | crawler_type |
|-------------|-------------|-------------|
| abc123      | 사당 그루브   | groove      |
| def456      | 홍대 ○○합주실 | naver       |
→ 새 지점 추가? → Supabase에서 crawler_type만 입력 → 끝 (재배포 X)
```

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| Supabase | `branch` 테이블에 `crawler_type` 컬럼 추가 |
| `app/services/availability_service.py` | room의 `crawler_type`으로 크롤러 결정 |

### 완료 기준
- [ ] `branch.crawler_type` 컬럼 추가
- [ ] 기존 테스트 통과
- [ ] 새 지점 추가 시 DB만 수정하면 동작

---

## Task 2: BE-31 · 좌표 필터 DB 레벨 위임 (4~5h)

### 왜 배포 전 필수인가?
현재 Python이 **전체 데이터를 메모리로 로드**한 뒤 좌표 계산을 수행합니다.
데이터가 수천 건 이상이면 서버 OOM(메모리 부족) 위험이 있습니다.

### 현재 방식 vs 변경 방식
```
현재: Python → "합주실 전부 다 줘" → 200개 로드 → for문으로 좌표 비교
변경: Python → "서울 강남 근처만 골라줘" → DB가 20개만 반환 (초고속)
```

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| Supabase SQL Editor | RPC 함수 `get_rooms_in_bounds` 생성 |
| `app/utils/room_loader.py` | `.rpc()` 호출로 교체 |

### 구현 가이드
```sql
-- Supabase SQL Editor에서 함수 생성
CREATE FUNCTION get_rooms_in_bounds(p_capacity INT, p_sw_lat FLOAT, p_sw_lng FLOAT, p_ne_lat FLOAT, p_ne_lng FLOAT)
RETURNS TABLE (...) AS $$
  SELECT * FROM room r JOIN branch b ON r.business_id = b.business_id
  WHERE r.max_capacity >= p_capacity
    AND b.lat BETWEEN p_sw_lat AND p_ne_lat
    AND b.lng BETWEEN p_sw_lng AND p_ne_lng
$$ LANGUAGE plpgsql;
```

```python
# room_loader.py
result = supabase.rpc("get_rooms_in_bounds", {
    "p_capacity": 4,
    "p_sw_lat": 37.41, "p_sw_lng": 126.76,
    "p_ne_lat": 37.72, "p_ne_lng": 127.18
}).execute()
```

### 완료 기준
- [ ] RPC 함수 Supabase에 등록
- [ ] `room_loader.py`에서 `.rpc()` 사용
- [ ] 기존 API와 동일한 결과 확인
- [ ] 테스트 통과

---

## Task 3 (시간 여유 시): BE-33 · TTL 캐시 도입 (6~8h)

> 우선순위: 🟢 P2 — 배포 후에도 가능

### 목표
동일 조건 검색 시 크롤링을 매번 수행하지 않고, **1~2분간 결과를 캐싱**합니다.

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| `app/core/` | 신규 `cache.py` (TTLCache 래퍼) |
| `app/services/availability_service.py` | 캐시 조회 → miss 시 크롤링 → 캐시 저장 |

### 핵심 코드
```python
from cachetools import TTLCache
cache = TTLCache(maxsize=256, ttl=120)  # 최대 256개, 2분 TTL
```

### 완료 기준
- [ ] 동일 조건 재조회 시 캐시 히트 (크롤링 스킵)
- [ ] TTL 만료 후 자동 갱신
- [ ] 테스트에서 캐시 동작 검증

---

## ⚠️ 의존성 & 주의사항
- **BE-23 선행 권장** → BE-31은 독립적이므로 병행 가능
- BE-33은 시간 여유 시 진행 (배포 후에도 OK)
- `availability_service.py` 수정 시 다른 팀원과 충돌 주의
