# 시험 일정 캐싱 Design

## Goal

등록 시험 정보(`fetchAppliedExams`)를 Home 재진입마다 재조회하는 현재 구조를, 캐시 우선 표시 + 쓰기 이벤트 기반 갱신으로 바꾼다. 등록 시험 정보는 이 앱 안에서, 사용자가 직접 등록·변경할 때만 바뀐다는 전제 위에서 타이머·TTL 없이 설계한다.

## 배경 — 왜 바꾸는가

`HomeCoordinatorImpl`에서 `reloadExamSchedule()` / `needsRefresh` 플래그를 통해 재조회가 걸리는 지점을 감사한 결과, 8곳 중 등록 정보가 실제로 바뀌는 경우는 2곳뿐이다.

| 트리거 | 위치 | 등록 정보가 바뀌었나 | 현재 동작 |
|---|---|---|---|
| 등록·변경 직후 (선택 시트) | `HomeCoordinatorImpl.swift:244` (`ExamSelectionDelegate.didUpdateExamSchedule`) | 그렇다 | `reloadExamSchedule()` → exam·daily·weekly 3개 API 재조회 |
| 등록·변경 직후 (다른 탭) | `HomeCoordinatorImpl.swift:113` (`handleExamScheduleUpdate`) | 그렇다 | 즉시 재조회 또는 `needsRefresh` |
| 일일 플랜 초기화 완료 | `HomeCoordinatorImpl.swift:225` | 아니다 | `reloadExamSchedule()` |
| 일일 플랜 리셋 | `HomeCoordinatorImpl.swift:231` | 아니다 | `reloadExamSchedule()` |
| 온보딩 종료 | `HomeCoordinatorImpl.swift:255` | 아니다 | `reloadExamSchedule()` |
| 모의고사 응시 종료 | `HomeCoordinatorImpl.swift:264` | 아니다 | `needsRefresh` |
| 모의고사 → 개념서 이동 | `HomeCoordinatorImpl.swift:270` | 아니다 | `needsRefresh` |
| 데일리 학습 종료 / 이동 | `HomeCoordinatorImpl.swift:285`, `:291` | 아니다 | `needsRefresh` |

나머지 6곳은 시험 등록 상태와 무관한데도 전체 재조회(`loadAllData()`: exam + daily + weekly)를 유발한다. 등록·변경 2곳조차 이미 응답에 최신값이 있는데 다시 3개 API를 부른다.

## 핵심 원칙

1. **캐시가 있으면 타이머·TTL 없이 그대로 쓴다.** 백그라운드 재검증을 하지 않는다.
2. **갱신은 쓰기(등록·변경) 성공 시에만** — 재조회가 아니라 응답으로 캐시를 직접 덮어쓴다. 단, 등록/변경 응답에는 `userApplyId`가 없으므로 그 값을 채우기 위해 목록을 1회만 재조회한다.
3. **fetch는 캐시가 없을 때만** — 최초 설치, 로그인 직후, 로그아웃 후 재로그인.
4. **시험일이 지났는지는 클라이언트 계산.** 저장된 `examDate` 문자열과 오늘 날짜를 비교(`String.dDay`)하며, API가 필요 없다.
5. **저장소는 UserDefaults.** Codable → JSON Data, `userId`로 스코프. 프로토콜(`ExamScheduleCacheStore`)로 감싸 테스트 시 in-memory fake로 교체한다. SwiftData는 iOS 17+ 환경이라 기술적으로 가능하지만, 레코드 1건·쿼리 없음이라는 이 데이터 형태엔 과설계로 판단해 보류한다.
6. **캐시를 지우는 경우**: 로그아웃 · 세션 만료 · 회원 탈퇴.
7. **회차 목록(`ExamScheduleListRequest`)은 캐시하지 않는다.** 관리자가 올리는 데이터이고, 선택 시트를 여는 행위 자체가 최신값이 필요하다는 신호이므로 지금처럼 열 때마다 받는다.

## 상태 전이

| 캐시 상태 | 무슨 일 | 다음 상태 |
|---|---|---|
| 없음 | fetch 성공 | 캐시 저장 + 표시 |
| 없음 | fetch 실패 | 전체 오류 + 재시도 |
| 있음 | (그 무엇이 와도) | 재검증 없이 그대로 표시 |
| 있음 | 쓰기 성공 | 응답으로 캐시 교체 |

## 쓰기 경로 — 등록 · 변경

사용자당 연간 몇 번뿐인 작업이므로 영속 outbox·멱등 키·자동 재시도는 두지 않는다. 낙관적 반영 하나만 둔다.

```
stable --탭--> pending(낙관적 반영) --전송--> sending
  sending --성공 응답--> confirmed (캐시 직접 갱신) --> stable
  sending --명확한 실패(4xx 등)--> rolledBack (낙관적 반영 되돌림) --> 사용자 안내 --> stable
  sending --타임아웃·연결 끊김--> reconciling (되돌리지 않음)
    reconciling --목록 재조회(GET)--> 서버 상태로 확정(confirmed 또는 rolledBack) --> stable
```

**타임아웃을 실패로 취급하지 않고 reconciling으로 처리하기로 결정**했다. 분기가 하나 늘지만, 전파가 약한 환경에서 "서버엔 반영됐는데 화면엔 실패로 보이는" 오탐을 막는다.

이미 선택된 시험을 다시 탭하는 경우는 `ExamScheduleSelectionViewModel.handleExamTapped`의 기존 가드(`guard id != registeredApplicationId`)가 그대로 막는다.

## 아키텍처

```
화면(Home / 회차 선택)
   │  조회 / 구독
   ▼
ExamScheduleRepository  ← 신규. 캐시 판단 + in-flight 요청 합류
   │              │
   │ read/write   │ 캐시가 없을 때만
   ▼              ▼
ExamScheduleCacheStore   ExamScheduleService (기존, 변경 없음)
   (UserDefaults 구현)
```

| 파일 | 변경 |
|---|---|
| `ExamScheduleCacheStore.swift` | 신규 — protocol + UserDefaults 구현. `CachedExamState`(Codable: `value`가 `.registered(ExamDetail)` / `.unregistered` — "캐시 없음"과는 별개의 상태, `fetchedAt`은 디버깅용) 읽기/쓰기/삭제, `userId` 스코프 |
| `ExamScheduleRepository.swift` | 신규 — protocol + impl. 캐시 우선 반환, 없을 때만 Service 호출, in-flight 합류 |
| `HomeViewModel.swift` | 수정 — `makeExamState()`가 `examScheduleService` 대신 Repository 경유. `reloadExamSchedule()`이 Daily·Weekly까지 묶어 재조회하던 것을 분리 |
| `HomeCoordinatorImpl.swift` | 수정 — 등록 정보와 무관한 6개 트리거(225/231/255/264/270/285/291)에서 시험 재조회 제거. 등록·변경 2곳(113/244)은 재조회 대신 Repository의 직접 캐시 갱신 호출로 교체 |
| `ExamScheduleSelectionViewModel.swift` | 수정 — 낙관적 반영 + `reconciling` 분기 추가 |
| `AppCoordinatorImpl.swift` (`didLogout`) | 수정 — refreshToken 삭제 누락, `UserInfoManager.reset()` 미호출 확인됨. 캐시 삭제와 함께 한 곳에서 정리하도록 보강 (이 설계가 의존하는 선행 수정) |

> **구현 시 변경 (`HomeCoordinatorImpl.swift` / `HomeViewModel.swift`)** — 위 표의 8개 트리거 호출 지점은 **의도적으로 그대로 두었다.** 모든 시험 등록 정보 읽기가 캐시 우선 Repository를 경유하게 되면서, 8곳 전부에서 시험 일정 네트워크 호출이 투명하게(호출 코드를 건드리지 않고) 사라지기 때문이다. 즉 트리거 자체를 제거하거나 직접 캐시 갱신으로 바꿀 필요가 없었고, `reloadExamSchedule()`을 Daily·Weekly에서 분리하는 작업도 하지 않았다.
>
> 따라서 같은 8개 트리거에서 `getDailyPlan` · `fetchWeeklyRecommend`가 여전히 매번 재조회되는 것은 **이 기능과 무관하며, 의도적으로 범위 밖**이다(아래 "범위 밖" 참고).

### `fetchAppliedExams`의 400 처리 (화면 표시 vs 캐시 저장을 분리)

`fetchAppliedExams`는 시험을 등록하지 않은 사용자에게도 HTTP 400을 내려준다. 즉 이 엔드포인트의 400은 에러가 아니라 "미등록"이라는 정상 상태를 뜻한다. 이를 바탕으로 **화면에 보여줄 값**과 **캐시에 저장할 값**을 다른 기준으로 결정한다.

- **화면 표시**: `fetchAppliedExams`의 400은 무조건 `.unregistered`로 반환한다. 절대 에러로 던지지 않는다 — 시험을 아직 등록하지 않은, 완전히 정상적인 상태에 에러 알럿을 띄울 수는 없기 때문이다.
- **캐시 저장**: 아래 두 값이 **모두** 실측으로 확인된 신호와 일치할 때만 `.unregistered`로 캐시한다.
  - `serverCode == -1`
  - `message == "등록된 일정이 없어요"`

  코드와 메시지가 로그 한 건으로 확인된 값이라, 서버가 다른 400 상황에서 같은 코드를 재사용하거나(과잉 캐시 위험) 메시지 카피를 바꿀 경우(캐시 누락) 둘 다 발생할 수 있다. 그래서 신호가 조금이라도 다르면 **캐시에는 쓰지 않는다** — 화면은 여전히 미등록으로 보여주지만, 다음 읽기에서 다시 서버에 확인하게 된다. 신호 불일치는 `ExamScheduleRepository`가 경고 로그로 남긴다.

  TTL이 없는 설계라 "잘못 캐시된 값은 로그아웃 전까지 영원히 남는다"는 비용이 "맞는 걸 놓쳐서 한 번 더 호출한다"는 비용보다 훨씬 크다. 그래서 애매하면 캐시하지 않는 쪽으로 기운다.

## 기대 효과 (예제 가정 — 실측 아님)

아래 수치는 **시험 등록 정보 엔드포인트(`fetchAppliedExams`) 한 곳에만 적용된다.** `getDailyPlan` · `fetchWeeklyRecommend`는 이 기능의 범위가 아니며, 기존과 동일하게 8개 트리거마다 재조회된다 — 전체 Home 트래픽이 99% 줄어든다는 뜻이 아니다.

준비 기간 60일, 하루 실행 1.5회, 실행당 Home 재진입 3회, 등록·변경 준비기간 중 1.5회로 가정.

- 지금 방식: `60 * 1.5 * 3 = 270회` / 준비기간 (1인)
- 새 방식: `최초 1 + 등록·변경 1.5 = 2.5회` / 준비기간 (1인)
- `fetchAppliedExams` 호출 절감 ≈ 99%, 해당 엔드포인트 전송량도 같은 비율로 감소

실제 DAU는 Firebase Analytics 값으로 대체해 검증 가능하며, 캐시 히트/미스를 `AnalyticsService`에 이벤트로 남기면 추정치를 실측으로 바꿀 수 있다(이번 범위에는 포함하지 않음).

## 테스트 전략

- `ExamScheduleRepositoryTests` 신규 — 캐시 히트 시 Service 미호출 검증, 캐시 미스 시 fetch 후 저장 검증, 쓰기 성공 시 직접 갱신 검증, 로그아웃 시 캐시 삭제 검증, `fetchAppliedExams` 400의 신호 일치/불일치 각각에서 화면 값(`.unregistered`, 에러 아님)과 캐시 여부(일치 시만 저장) 검증
- `HomeViewModelTests` / `ExamScheduleSelectionViewModelTests` — 주입 지점이 `ExamScheduleService`에서 `ExamScheduleRepository`로 바뀌므로 기존 `MockExamScheduleService` 활용 방식을 Repository 경유로 조정
- `ExamScheduleSelectionViewModelTests` — `reconciling` 분기(타임아웃 → 재조회 → 확정/롤백) 케이스 추가

## 범위 밖

- 다른 기기 · 웹에서의 변경 감지 (이 앱 내부에서만 바뀐다는 전제)
- 영속 outbox · 멱등 키 · 자동 재시도
- SwiftData (레코드 1건엔 과설계로 판단해 보류)
- Daily · Weekly의 동일한 "전체 재조회" 패턴 개선 — 같은 증상이 확인되었으나 이번 범위에는 포함하지 않는다. 후속 과제로 남긴다.

## 결정 로그

- TTL(24h) 기반 백그라운드 재검증 안을 전체 폐기하고, 쓰기 이벤트 기반으로 대체 — "이 앱 안에서만 바뀐다"는 전제하에 타이머가 풀 문제가 애초에 없었음
- 저장소: UserDefaults / 파일(JSON) / Keychain / SwiftData 비교 후 UserDefaults로 확정
- 쓰기 타임아웃: 즉시 롤백 대신 reconciling(재조회 후 확정) 도입으로 확정
- `fetchAppliedExams`의 400: 처음엔 모든 400을 `.unregistered`로 캐시했으나, 무관한 400까지 영구 고정될 위험이 리뷰에서 지적됨 → 실측 신호(`serverCode -1` + 메시지)로 캐시 조건을 좁힘. 이후 "신호가 안 맞으면 에러를 던진다"는 동작이 미등록 사용자에게 에러 알럿을 띄우는 문제로 확인되어, 화면 표시(항상 `.unregistered`)와 캐시 저장(신호 일치 시에만)을 분리하도록 재수정

## 구현 완료

`docs/superpowers/plans/2026-10-01-exam-schedule-caching.md`에 따라 구현 완료 (2026-10-02).
