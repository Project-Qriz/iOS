# MyPage ViewModel Unit Tests — Design Spec

**Date:** 2026-03-26
**Scope:** MyPageViewModel 유닛 테스트 인프라 구축 및 테스트 케이스 작성

---

## 목표

MyPage 패키지에 유닛 테스트 인프라를 추가하고 `MyPageViewModel`의 모든 Input→Output 경로를 검증한다. 향후 스냅샷 테스트 추가를 고려해 Package.swift에 SnapshotTesting 의존성도 함께 세팅한다.

---

## 파일 구조

```
MyPage/
├── Package.swift                          (수정)
└── Tests/
    └── MyPageTests/
        ├── TestHelpers.swift
        ├── Mocks/
        │   └── MockMyPageService.swift
        └── UnitTests/
            └── MyPageViewModelTests.swift
```

---

## Package.swift 변경

기존 패키지 의존성에 `swift-snapshot-testing` 추가, `MyPageTests` 테스트 타겟 추가.

```swift
dependencies: [
    // 기존 의존성...
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
],
targets: [
    // 기존 MyPage 타겟...
    .testTarget(
        name: "MyPageTests",
        dependencies: [
            "MyPage",
            "Network",
            .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        ]
    ),
]
```

---

## TestHelpers.swift

비동기 테스트에서 Task 완료를 대기하기 위한 상수와 헬퍼 정의.

```swift
import Foundation

let asyncSleepNanoseconds: UInt64 = 100_000_000  // 0.1초
```

---

## MockMyPageService

`MyPageService` 프로토콜을 구현하는 mock. 기존 코드베이스 패턴(`Result` 프로퍼티 + `@unchecked Sendable`)을 따른다.

- `fetchVersionResult: Result<VersionResponse, Error>` — 기본: 성공 (versionInfo: 1.0)
- `resetPlanResult: Result<DailyResetResponse, Error>` — 기본: 성공 (msg: "초기화 완료!")
- `deleteAccountResult`, `deleteSocialAccountResult` — 프로토콜 충족용 stub

---

## 테스트 케이스 (11개)

테스트 프레임워크: Swift Testing (`@Suite`, `@Test`, `#expect`)
스타일: `@MainActor`, `.serialized`, 한국어 테스트 이름

### MARK: - viewDidLoad (fetchVersion 비동기)

| # | 시나리오 | 예상 Output |
|---|----------|-------------|
| 1 | fetchVersion 성공 | `.setupView(userName: "테스트", version: "1.0")` |
| 2 | fetchVersion NetworkError 실패 | `.setupView(userName: "테스트", version: fallback)` |
| 3 | fetchVersion 일반 Error 실패 | `.setupView(userName: "테스트", version: fallback)` |

> fallback: `Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "0.0.0"` — 테스트 환경에서는 `"0.0.0"` 반환 예상

### MARK: - 동기 탭 이벤트

| # | Input | 예상 Output |
|---|-------|-------------|
| 4 | `didTapProfile` | `.navigateToSettingsView` |
| 5 | `didTapResetPlan` | `.showResetAlert` |
| 6 | `didTapRegisterExam` | `.showExamSchedule` |
| 7 | `didTapTermsOfService` | `.showTermsDetail(termItem:)` — title: "서비스 이용약관" |
| 8 | `didTapPrivacyPolicy` | `.showTermsDetail(termItem:)` — title: "개인정보 처리방침" |

### MARK: - didConfirmResetPlan (performReset 비동기)

| # | 시나리오 | 예상 Output |
|---|----------|-------------|
| 9 | resetPlan 성공 | `.resetSucceeded(message: "초기화 완료!")` |
| 10 | resetPlan NetworkError 실패 | `.showErrorAlert(title: "초기화할 수 없습니다.", description:)` |
| 11 | resetPlan 일반 Error 실패 | `.showErrorAlert(title: "초기화할 수 없습니다.", description: "잠시 후 다시 시도해주세요.")` |

---

## SUT Factory

```swift
private func makeSUT(
    userName: String = "테스트",
    service: MockMyPageService = .init()
) -> MyPageViewModel {
    MyPageViewModel(userName: userName, myPageService: service)
}
```

---

## 비동기 테스트 패턴

`fetchVersion`과 `performReset`은 내부에서 `Task { }` 로 실행되므로 `collectAsync` 대신 `Task.sleep`으로 대기한다.

```swift
let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
var received: [MyPageViewModel.Output] = []
var cancellables = Set<AnyCancellable>()

viewModel.transform(input: inputSubject.eraseToAnyPublisher())
    .sink { received.append($0) }
    .store(in: &cancellables)

inputSubject.send(.viewDidLoad)
try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

#expect(received.count == 1)
```
