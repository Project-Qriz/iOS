# MyPage 스냅샷 테스트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MyPageTests 타겟에 ViewController 3개 + 컴포넌트 8개, 총 11개의 스냅샷 테스트를 추가한다.

**Architecture:** `MyPageSnapshotTestCase` base class에 공통 헬퍼(`snapshotView`, `snapshotCell`, `inNav`)를 정의하고, 3개의 feature별 테스트 파일이 상속한다. UICollectionViewCell 중 trailing 또는 수직 Auto Layout 체인이 불완전한 셀(ProfileCell, QuickActionsCell, SupportHeaderCell)은 explicit frame, 수직 체인이 완전한 셀(SupportMenuCell)은 `snapshotCell` 헬퍼로 sizing한다.

**Tech Stack:** Swift, XCTest, SnapshotTesting (pointfreeco v1.18.9+), UIKit

---

## 파일 구조

| 파일 | 작업 | 역할 |
|------|------|------|
| `MyPage/Tests/MyPageTests/MyPageSnapshotTestCase.swift` | 신규 생성 | Base class + 공통 헬퍼 |
| `MyPage/Tests/MyPageTests/SnapshotTests/MyPageSnapshotTests.swift` | 신규 생성 | MyPage VC + 5 cell tests |
| `MyPage/Tests/MyPageTests/SnapshotTests/SettingsSnapshotTests.swift` | 신규 생성 | Settings VC + 2 view tests |
| `MyPage/Tests/MyPageTests/SnapshotTests/DeleteAccountSnapshotTests.swift` | 신규 생성 | DeleteAccount VC + 1 view test |

스냅샷 기준 이미지는 최초 실행 시 자동 생성 → `__Snapshots__/` 디렉터리에 저장됨.

---

## 스냅샷 테스트 워크플로우

swift-snapshot-testing은 기준 이미지가 없으면 최초 실행 시 자동으로 기록하고 테스트를 **실패**시킨다 (리뷰 기회 제공). 이후 실행부터 비교 검증한다.

따라서 각 Task의 "스냅샷 기록" 단계에서:
1. 테스트 실행 → 최초 실패 (예상된 동작)
2. `__Snapshots__/` 내 PNG 파일을 열어 시각적으로 검증
3. 재실행 → 모두 통과 확인
4. `__Snapshots__/` 디렉터리 포함 커밋

---

## Task 1: MyPageSnapshotTestCase (Base Class)

**Files:**
- Create: `MyPage/Tests/MyPageTests/MyPageSnapshotTestCase.swift`

- [ ] **Step 1: 파일 생성**

```swift
// MyPage/Tests/MyPageTests/MyPageSnapshotTestCase.swift
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
    /// 수직 Auto Layout 체인이 완전한 셀(SupportMenuCell)에만 사용.
    /// trailing 누락 또는 수직 체인 불완전한 셀(ProfileCell, QuickActionsCell, SupportHeaderCell)은 explicit frame을 사용.
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

// 파일 스코프 자유 함수 — @MainActor base class에서만 호출됨
@MainActor
func inNav(_ vc: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: vc)
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build-for-testing \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Expected: `** BUILD FOR TESTING SUCCEEDED **`

- [ ] **Step 3: 커밋**

```bash
git add MyPage/Tests/MyPageTests/MyPageSnapshotTestCase.swift
git commit -m "test: MyPageSnapshotTestCase base class 추가"
```

---

## Task 2: MyPageSnapshotTests (6개 테스트)

**Files:**
- Create: `MyPage/Tests/MyPageTests/SnapshotTests/MyPageSnapshotTests.swift`

- [ ] **Step 1: 파일 생성**

```swift
// MyPage/Tests/MyPageTests/SnapshotTests/MyPageSnapshotTests.swift
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class MyPageSnapshotTests: MyPageSnapshotTestCase {

    // MARK: - ViewController

    /// viewDidLoad → Task { fetchVersion() } fire-and-forget이므로 async 대기 필요.
    /// nav.view.frame 설정 → loadView + viewDidLoad 호출 → async Task 시작
    /// Task.sleep 이후 applySnapshot 완료 → 재레이아웃 후 스냅샷
    func testInitialState() async throws {
        let vm = MyPageViewModel(userName: "테스트", myPageService: MockMyPageService())
        let vc = MyPageViewController(viewModel: vm)
        let nav = inNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        nav.view.layoutIfNeeded()
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - 셀 컴포넌트

    /// ProfileCell: trailing 미연결 → snapshotCell이 intrinsic width만 반영
    /// explicit frame으로 full-width snapshot 보장
    /// height 60 = 22pt bold 레이블 높이 + 상하 여백
    func testProfileCell() {
        let cell = ProfileCell()
        cell.configure(with: "테스트")
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 60))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// QuickActionsCell: centerY만 있어 contentView 수직 체인 불완전 → explicit frame 사용
    /// height 82 = MyPageLayoutFactory.quickActionEstimated
    /// configureActions는 액션 콜백용이므로 snapshot에서 호출 불필요
    func testQuickActionsCell() {
        let cell = QuickActionsCell()
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 82))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// SupportHeaderCell: titleLabel.bottom 미연결 → explicit frame 사용
    /// height 70 = titleLabel 상단 여백(24) + 폰트 높이(≈21) + 하단 여백 + separator(1)
    func testSupportHeaderCell() {
        let cell = SupportHeaderCell()
        cell.frame = CGRect(origin: .zero, size: CGSize(width: 393, height: 70))
        cell.layoutIfNeeded()
        assertSnapshot(of: cell, as: .image)
    }

    /// SupportMenuCell (version 없음): chevron 표시, versionLabel 숨김
    func testSupportMenuCell_withoutVersion() {
        let cell = SupportMenuCell()
        cell.configure(title: "서비스 이용약관")
        assertSnapshot(of: snapshotCell(cell), as: .image)
    }

    /// SupportMenuCell (version 있음): versionLabel 표시, chevron 숨김
    func testSupportMenuCell_withVersion() {
        let cell = SupportMenuCell()
        cell.configure(title: "버전 정보", version: "1.0.0")
        assertSnapshot(of: snapshotCell(cell), as: .image)
    }
}
```

- [ ] **Step 2: 스냅샷 기록 (최초 실행 — 실패 예상)**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/MyPageSnapshotTests
```

Expected: 6개 테스트 모두 실패 + `__Snapshots__/MyPageSnapshotTests/` 디렉터리 생성됨

- [ ] **Step 3: 스냅샷 이미지 시각 검증**

`MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/MyPageSnapshotTests/` 경로의 PNG 파일 6개를 열어 확인:
- `testInitialState.1.png` — 전체 화면 (네비게이션 바 + 프로필 + 퀵액션 + 서포트 메뉴)
- `testProfileCell.1.png` — 이름 + chevron
- `testQuickActionsCell.1.png` — 플랜 초기화 / 시험 등록 버튼
- `testSupportHeaderCell.1.png` — "고객센터" 헤더
- `testSupportMenuCell_withoutVersion.1.png` — "서비스 이용약관" + chevron
- `testSupportMenuCell_withVersion.1.png` — "버전 정보" + "1.0.0"

- [ ] **Step 4: 재실행 — 통과 확인**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/MyPageSnapshotTests
```

Expected: `** TEST SUCCEEDED **` (6개 통과)

- [ ] **Step 5: 커밋**

```bash
git add MyPage/Tests/MyPageTests/SnapshotTests/MyPageSnapshotTests.swift
git add "MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/"
git commit -m "test: MyPageSnapshotTests 스냅샷 테스트 6개 추가"
```

---

## Task 3: SettingsSnapshotTests (3개 테스트)

**Files:**
- Create: `MyPage/Tests/MyPageTests/SnapshotTests/SettingsSnapshotTests.swift`

- [ ] **Step 1: 파일 생성**

```swift
// MyPage/Tests/MyPageTests/SnapshotTests/SettingsSnapshotTests.swift
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class SettingsSnapshotTests: MyPageSnapshotTestCase {

    // MARK: - ViewController

    /// viewDidLoad → bind() + inputSubject.send(.viewDidLoad) → .setupProfile 동기 emit
    /// → configureProfile() 즉시 호출 → Task.sleep 불필요
    /// @MainActor 보장 하에 Combine 파이프라인이 동기 처리됨
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

    // MARK: - 뷰 컴포넌트

    /// ProfileHeaderView: configure(name:email:) → "테스트님" + "test@test.com" 표시
    func testProfileHeaderView() {
        let view = ProfileHeaderView()
        view.configure(name: "테스트", email: "test@test.com")
        assertSnapshot(of: snapshotView(view), as: .image)
    }

    /// SettingsOptionView: title은 init 시 주입 (configure 메서드 없음)
    func testSettingsOptionView() {
        let view = SettingsOptionView(title: "비밀번호 재설정")
        assertSnapshot(of: snapshotView(view), as: .image)
    }
}
```

- [ ] **Step 2: 스냅샷 기록 (최초 실행 — 실패 예상)**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/SettingsSnapshotTests
```

Expected: 3개 테스트 모두 실패 + `__Snapshots__/SettingsSnapshotTests/` 디렉터리 생성됨

- [ ] **Step 3: 스냅샷 이미지 시각 검증**

`MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/SettingsSnapshotTests/` 경로 PNG 3개 확인:
- `testInitialState.1.png` — "테스트님" + "test@test.com" 프로필 헤더 + 설정 옵션 3개
- `testProfileHeaderView.1.png` — bordered card, "테스트님", "test@test.com"
- `testSettingsOptionView.1.png` — bordered row, "비밀번호 재설정" + chevron

- [ ] **Step 4: 재실행 — 통과 확인**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/SettingsSnapshotTests
```

Expected: `** TEST SUCCEEDED **` (3개 통과)

- [ ] **Step 5: 커밋**

```bash
git add MyPage/Tests/MyPageTests/SnapshotTests/SettingsSnapshotTests.swift
git add "MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/"
git commit -m "test: SettingsSnapshotTests 스냅샷 테스트 3개 추가"
```

---

## Task 4: DeleteAccountSnapshotTests (2개 테스트)

**Files:**
- Create: `MyPage/Tests/MyPageTests/SnapshotTests/DeleteAccountSnapshotTests.swift`

- [ ] **Step 1: 파일 생성**

```swift
// MyPage/Tests/MyPageTests/SnapshotTests/DeleteAccountSnapshotTests.swift
import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class DeleteAccountSnapshotTests: MyPageSnapshotTestCase {

    // MARK: - ViewController

    /// viewDidLoad: bind() + setNavigationBarTitle만 실행, inputSubject.send 없음
    /// 순수 정적 레이아웃 → Task.sleep 불필요
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

    // MARK: - 뷰 컴포넌트

    /// DeleteAccountInfoView: 정적 bullet 텍스트 2줄 (configure 메서드 없음)
    func testDeleteAccountInfoView() {
        let view = DeleteAccountInfoView()
        assertSnapshot(of: snapshotView(view), as: .image)
    }
}
```

- [ ] **Step 2: 스냅샷 기록 (최초 실행 — 실패 예상)**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/DeleteAccountSnapshotTests
```

Expected: 2개 테스트 모두 실패 + `__Snapshots__/DeleteAccountSnapshotTests/` 디렉터리 생성됨

- [ ] **Step 3: 스냅샷 이미지 시각 검증**

`MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/DeleteAccountSnapshotTests/` 경로 PNG 2개 확인:
- `testInitialState.1.png` — "회원 탈퇴" 네비게이션 타이틀 + 안내 텍스트 + 탈퇴 버튼
- `testDeleteAccountInfoView.1.png` — bordered shadow card, bullet 텍스트 2줄

- [ ] **Step 4: 재실행 — 통과 확인**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests/DeleteAccountSnapshotTests
```

Expected: `** TEST SUCCEEDED **` (2개 통과)

- [ ] **Step 5: 전체 MyPageTests 최종 확인**

```bash
xcodebuild test \
  -project /Users/hun/iOS/QRIZ.xcodeproj \
  -scheme QRIZ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:MyPageTests
```

Expected: `** TEST SUCCEEDED **` (유닛 29개 + 스냅샷 11개, 총 40개 통과)

- [ ] **Step 6: 커밋**

```bash
git add MyPage/Tests/MyPageTests/SnapshotTests/DeleteAccountSnapshotTests.swift
git add "MyPage/Tests/MyPageTests/SnapshotTests/__Snapshots__/"
git commit -m "test: DeleteAccountSnapshotTests 스냅샷 테스트 2개 추가"
```
