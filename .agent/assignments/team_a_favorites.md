# 팀원 1 — 즐겨찾기 보강 & 헬스체크

> 예상 공수: **4~6h** · 배포 안정성 직결
> 우선순위: 🔴 P0

---

## Task 1: BE-12 · 찜 목록 20개 상한 (2~3h)

### 왜 배포 전 필수인가?
상한이 없으면 악의적 스크립트 또는 자동화 도구로 찜하기를 무한정 호출하여 **Supabase DB 용량 고갈** 및 성능 저하를 유발할 수 있습니다.

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| `app/repositories/base.py` | `count_by_device(device_id)` 인터페이스 추가 |
| `app/repositories/supabase_repository.py` | `count_by_device` 구현 |
| `app/api/favorites.py` | `add_favorite`에서 상한 체크 로직 추가 |
| `app/exception/` | `FavoriteLimitExceeded` 커스텀 예외 생성 |

### 구현 가이드
```python
# supabase_repository.py
def count_by_device(self, device_id: str) -> int:
    response = self.supabase.table(self.table_name).select(
        "", count="exact", head=True
    ).eq("device_id", device_id).execute()
    return response.count

# favorites.py - add_favorite 내부
count = repo.count_by_device(device_id=x_device_id)
if count >= 20:
    raise FavoriteLimitExceeded("즐겨찾기는 최대 20개까지 저장할 수 있습니다.")
```

### 완료 기준
- [ ] 21번째 추가 시 400 에러 + 명확한 에러 메시지
- [ ] 기존 20개 이하 추가는 정상 동작
- [ ] 테스트 통과

---

## Task 2: BE-34 · `/health` 엔드포인트 (2~3h)

### 왜 배포 전 필수인가?
현재 `/ping`은 서버 프로세스 생존만 확인합니다. **크롤링이 전부 실패해도 "서버 정상"**으로 표시되어 장애를 감지할 수 없습니다.

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| `app/api/` | 신규 `health.py` 라우터 생성 |
| `app/main.py` | health 라우터 등록 |

### 구현 가이드
```python
# app/api/health.py
from fastapi import APIRouter
from app.core.supabase_client import get_supabase_client

router = APIRouter(tags=["Health"])

@router.get("/health")
async def health_check():
    checks = {}
    
    # 1. DB 연결 확인
    try:
        supabase = get_supabase_client()
        supabase.table("branch").select("business_id").limit(1).execute()
        checks["database"] = "connected"
    except Exception:
        checks["database"] = "disconnected"
    
    # 2. 전체 상태 판단
    all_ok = all(v != "disconnected" for v in checks.values())
    
    return {
        "status": "healthy" if all_ok else "degraded",
        "checks": checks
    }
```

### 완료 기준
- [ ] `GET /health` 엔드포인트 동작
- [ ] DB 연결 상태 확인 포함
- [ ] 정상/비정상 시 응답이 다르게 나옴

---

## ⚠️ 의존성 & 주의사항
- BE-12 → BE-34 순서 (BE-34는 독립적이라 병행도 가능)
- `favorites.py`, `supabase_repository.py`는 이 팀원만 수정 (충돌 없음)
