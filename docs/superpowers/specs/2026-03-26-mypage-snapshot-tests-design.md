# MyPage 스냅샷 테스트 — Design Spec

**Date:** 2026-03-26
**Scope:** MyPage 모듈 스냅샷 테스트 추가 (ViewController 3개 + 컴포넌트 8개, 총 11개)

---

## 목표

`MyPageTests` 타겟에 ViewController 레벨 스냅샷 테스트 3개와 개별 컴포넌트 스냅샷 테스트 8개를 추가한다. SnapshotTesting 의존성은 이미 `Package.swift`에 포함되어 있다.

---

## 파일 구조

```
MyPage/Tests/MyPageTests/
├── MyPageSnapshotTestCase.swift         (신규 — base class)
└── SnapshotTests/
    ├── MyPageSnapshotTests.swift        (신규 — VC + 5 cell tests)
    ├── SettingsSnapshotTests.swift      (신규 — VC + 2 view tests)
    └── DeleteAccountSnapshotTests.swift (신규 — VC + 1 view test)
```

---

## MyPageSnapshotTestCase

모든 스냅샷 테스트의 base class. Account/MistakeNote 모듈 패턴을 따른다.
`@MainActor` 어노테이션이 필수 — Settings/DeleteAccount VC 테스트의 동기 보장 조건이다.
`inNav`는 이 파일의 파일 스코프(class 밖)에 선언한다.

```swift
import UIKit
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class MyPageSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro

    /// UIView 서브클래스용: width 고정, height intrinsic sizing
    func snapshotView(_ view: UIView, width: CGFloat = 393) -> UIView {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        return view
    }

    /// UICollectionViewCell용: contentView 기준 sizing
    /// ⚠️ 수직 Auto Layout 체인이 완전한 셀(ProfileCell, SupportMenuCell)에만 사용.
    /// 체인이 불완전한 셀(QuickActionsCell, SupportHeaderCell)은 explicit frame을 사용.
    func snapshotCell(_ cell: UICollectionViewCell, width: CGFloat = 393) -> UICollectionViewCell {
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        cell.frame = CGRect(origin: .zero, size: size)
        cell.layoutIfNeeded()
        return cell
    }
}

@MainActor
func inNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
```

---

## MyPageSnapshotTests (6개 테스트)

파일 상단 imports: `import XCTest`, `import SnapshotTesting`, `@testable import MyPage`

`class MyPageSnapshotTests: MyPageSnapshotTestCase`

### MARK: - ViewController

#### testInitialState — async

`viewDidLoad` → `Task { fetchVersion() }` fire-and-forget이므로 async 대기 필요.

```swift
func testInitialState() async throws {
    let vm = MyPageViewModel(userName: "테스트", myPageService: MockMyPageService())
    let vc = MyPageViewController(viewModel: vm)
    let nav = inNav(vc)
    nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    nav.view.layoutIfNeeded()
    try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
    nav.view.layoutIfNeeded()   // applySnapshot 이후 재레이아웃
    assertSnapshot(of: nav, as: .image)
}
```

### MARK: - 셀 컴포넌트

| # | 테스트 | configure 인자 | 사이징 방식 | 비고 |
|---|--------|---------------|------------|------|
| 2 | `testProfileCell` | `"테스트"` | `snapshotCell` | 수직 체인 완전 (top/bottom → contentView) |
| 3 | `testQuickActionsCell` | — | explicit `CGSize(width: 393, height: 82)` | centerY만 있어 height 미결정. `configureActions`는 액션 콜백용이므로 snapshot에서 호출 불필요 |
| 4 | `testSupportHeaderCell` | — | explicit `CGSize(width: 393, height: 70)` | titleLabel.bottom 미연결 |
| 5 | `testSupportMenuCell_withoutVersion` | `title: "서비스 이용약관"` | `snapshotCell` | chevron 표시, versionLabel 숨김 |
| 6 | `testSupportMenuCell_withVersion` | `title: "버전 정보", version: "1.0.0"` | `snapshotCell` | versionLabel 표시, chevron 숨김 |

**`snapshotCell` 사용 패턴 (ProfileCell, SupportMenuCell):**
```swift
func testProfileCell() {
    let cell = ProfileCell()
    cell.configure(with: "테스트")
    assertSnapshot(of: snapshotCell(cell), as: .image)
}
```

**explicit frame 패턴 (QuickActionsCell, SupportHeaderCell):**
```swift
func testQuickActionsCell() {
    let cell = QuickActionsCell()
    cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 82))
    cell.layoutIfNeeded()
    assertSnapshot(of: cell, as: .image)
}

func testSupportHeaderCell() {
    let cell = SupportHeaderCell()
    cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 70))
    cell.layoutIfNeeded()
    assertSnapshot(of: cell, as: .image)
}
```

---

## SettingsSnapshotTests (3개 테스트)

파일 상단 imports: `import XCTest`, `import SnapshotTesting`, `@testable import MyPage`

`class SettingsSnapshotTests: MyPageSnapshotTestCase`

### MARK: - ViewController

#### testInitialState — sync

`viewDidLoad` → `.setupProfile` 동기 emit → `configureProfile()` 즉시 호출. `Task.sleep` 불필요.

```swift
func testInitialState() {
    let vm = SettingsViewModel(
        userName: "테스트",
        email: "test@test.com",
        provider: "kakao",
        myPageService: MockMyPageService(),
        socialLoginService: MockSocialLoginService()
    )
    let vc = SettingsViewController(viewModel: vm)
    let nav = inNav(vc)
    nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    nav.view.layoutIfNeeded()
    assertSnapshot(of: nav, as: .image)
}
```

### MARK: - 뷰 컴포넌트

| # | 테스트 | 비고 |
|---|--------|------|
| 2 | `testProfileHeaderView` | `configure(name: "테스트", email: "test@test.com")` → `"테스트님"` 표시 |
| 3 | `testSettingsOptionView` | `SettingsOptionView(title: "비밀번호 재설정")` — init에서 title 주입 |

```swift
func testProfileHeaderView() {
    let view = ProfileHeaderView()
    view.configure(name: "테스트", email: "test@test.com")
    assertSnapshot(of: snapshotView(view), as: .image)
}

func testSettingsOptionView() {
    let view = SettingsOptionView(title: "비밀번호 재설정")
    assertSnapshot(of: snapshotView(view), as: .image)
}
```

---

## DeleteAccountSnapshotTests (2개 테스트)

파일 상단 imports: `import XCTest`, `import SnapshotTesting`, `@testable import MyPage`

`class DeleteAccountSnapshotTests: MyPageSnapshotTestCase`

### MARK: - ViewController

#### testInitialState — sync

`viewDidLoad`에서 데이터 로딩 없음. 정적 레이아웃.

```swift
func testInitialState() {
    let vm = DeleteAccountViewModel(
        provider: "kakao",
        myPageService: MockMyPageService(),
        socialLoginService: MockSocialLoginService()
    )
    let vc = DeleteAccountViewController(viewModel: vm)
    let nav = inNav(vc)
    nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
    nav.view.layoutIfNeeded()
    assertSnapshot(of: nav, as: .image)
}
```

### MARK: - 뷰 컴포넌트

| # | 테스트 | 비고 |
|---|--------|------|
| 2 | `testDeleteAccountInfoView` | 정적 — bullet 안내 텍스트 2줄 |

```swift
func testDeleteAccountInfoView() {
    let view = DeleteAccountInfoView()
    assertSnapshot(of: snapshotView(view), as: .image)
}
```

---

## 기존 인프라 활용

| 항목 | 파일 | 용도 |
|------|------|------|
| `asyncSleepNanoseconds` | `TestHelpers.swift` | MyPage VC async 대기 |
| `MockMyPageService` | `Mocks/MockMyPageService.swift` | 기본값(성공) 그대로 사용 |
| `MockSocialLoginService` | `Mocks/MockSocialLoginService.swift` | Settings/DeleteAccount VC 생성 |

---

## Task 분류

| Task | 내용 | 테스트 수 |
|------|------|----------|
| Task 1 | `MyPageSnapshotTestCase` 작성 | — |
| Task 2 | `MyPageSnapshotTests` 작성 | 6개 |
| Task 3 | `SettingsSnapshotTests` 작성 | 3개 |
| Task 4 | `DeleteAccountSnapshotTests` 작성 | 2개 |
