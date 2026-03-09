# Snapshot Test Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Account, Conceptbook 스냅샷 테스트 코드의 일관성·품질을 개선한다.

**Architecture:** 공통 설정을 베이스 클래스로 추출하고, 스냅샷 대상을 ViewController 전체로 통일하며, UIScreen.main.bounds를 iPhone 16 Pro 고정 크기로 교체한다. Conceptbook의 반복 보일러플레이트는 헬퍼 메서드로 추출한다.

**Tech Stack:** Swift, XCTest, swift-snapshot-testing (pointfreeco, 1.18.9+)

---

### Task 1: Account — 베이스 클래스 추가

**Files:**
- Modify: `Account/Tests/AccountTests/Snapshot/SnapshotTestHelpers.swift`

**Step 1: `AccountSnapshotTestCase` 베이스 클래스 추가**

```swift
//
//  SnapshotTestHelpers.swift
//  AccountTests
//

import UIKit

@MainActor
func inNav(_ viewController: UIViewController) -> UINavigationController {
    UINavigationController(rootViewController: viewController)
}

@MainActor
class AccountSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
```

**Step 2: 빌드 확인**

Xcode에서 AccountTests 타겟 빌드 (⌘B). 에러 없어야 함.

**Step 3: Commit**

```bash
git add Account/Tests/AccountTests/Snapshot/SnapshotTestHelpers.swift
git commit -m "test: AccountSnapshotTestCase 베이스 클래스 추가"
```

---

### Task 2: Account — LoginSnapshotTests 수정

**Files:**
- Modify: `Account/Tests/AccountTests/Snapshot/LoginSnapshotTests.swift`

**Step 1: 베이스 클래스 상속 + 고정 크기 적용**

```swift
//
//  LoginSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class LoginSnapshotTests: AccountSnapshotTestCase {

    func testInitialState() {
        let vm = LoginViewModel(
            loginService: StubLoginService(),
            userInfoService: StubUserInfoService(),
            socialLoginService: StubSocialLoginService()
        )
        let vc = LoginViewController(loginVM: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

**Step 2: 기존 레퍼런스 이미지 삭제**

스냅샷 대상(`of: vc`)은 동일하므로 재생성 불필요. 크기만 바뀌었으니 삭제 후 재기록:

```bash
rm Account/Tests/AccountTests/Snapshot/__Snapshots__/LoginSnapshotTests/testInitialState.1.png
```

**Step 3: 테스트 실행하여 새 레퍼런스 생성**

`isRecording` 없이 실행하면 레퍼런스 없을 때 자동 기록됨. Xcode에서 AccountTests 실행.
예상 결과: 첫 실행 시 "No reference" 메시지와 함께 새 이미지 기록.

**Step 4: Commit**

```bash
git add Account/Tests/AccountTests/Snapshot/LoginSnapshotTests.swift
git add Account/Tests/AccountTests/Snapshot/__Snapshots__/LoginSnapshotTests/
git commit -m "test: LoginSnapshotTests 고정 디바이스 크기 적용"
```

---

### Task 3: Account — SignUpSnapshotTests 수정

**Files:**
- Modify: `Account/Tests/AccountTests/Snapshot/SignUpSnapshotTests.swift`
- Delete: `Account/Tests/AccountTests/Snapshot/__Snapshots__/SignUpSnapshotTests/*.png`

**Step 1: 베이스 클래스 상속, setUp 도입, of: vc 통일**

```swift
//
//  SignUpSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class SignUpSnapshotTests: AccountSnapshotTestCase {

    private var signUpService: StubSignUpService!
    private var flowVM: SignUpFlowViewModel!

    override func setUp() {
        super.setUp()
        signUpService = StubSignUpService()
        flowVM = SignUpFlowViewModel(signUpService: signUpService)
    }

    func testNameInputInitialState() {
        let vc = inNav(NameInputViewController(nameInputVM: NameInputViewModel(signUpFlowViewModel: flowVM)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testIDInputInitialState() {
        let vc = inNav(IDInputViewController(idInputVM: IDInputViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testPasswordInputInitialState() {
        let vc = inNav(PasswordInputViewController(passwordInputVM: PasswordInputViewModel(signUpFlowViewModel: flowVM)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testSignUpVerificationInitialState() {
        let vc = inNav(SignUpVerificationViewController(signUpVerificationVM: SignUpVerificationViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testTermsAgreementInitialState() {
        let vm = TermsAgreementModalViewModel(signUpFlowViewModel: flowVM)
        let vc = TermsAgreementModalViewController(viewModel: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testTermsDetailInitialState() {
        let termItem = TermItem(title: "이용약관", pdfName: "terms", isAgreed: false)
        let vc = inNav(TermsDetailViewController(viewModel: TermsDetailViewModel(termItem: termItem)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }
}
```

**Step 2: 기존 레퍼런스 이미지 삭제** (of: vc.view → of: vc 변경으로 재생성 필요)

```bash
rm Account/Tests/AccountTests/Snapshot/__Snapshots__/SignUpSnapshotTests/*.png
```

**Step 3: 테스트 실행하여 새 레퍼런스 생성**

Xcode에서 AccountTests 실행. 첫 실행 시 새 이미지 자동 기록.

**Step 4: Commit**

```bash
git add Account/Tests/AccountTests/Snapshot/SignUpSnapshotTests.swift
git add Account/Tests/AccountTests/Snapshot/__Snapshots__/SignUpSnapshotTests/
git commit -m "test: SignUpSnapshotTests 베이스 클래스 상속 및 VC 스냅샷으로 통일"
```

---

### Task 4: Account — FindAccountSnapshotTests 수정

**Files:**
- Modify: `Account/Tests/AccountTests/Snapshot/FindAccountSnapshotTests.swift`
- Delete: `Account/Tests/AccountTests/Snapshot/__Snapshots__/FindAccountSnapshotTests/*.png`

**Step 1: 베이스 클래스 상속, 고정 크기, of: vc 통일**

```swift
//
//  FindAccountSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class FindAccountSnapshotTests: AccountSnapshotTestCase {

    private var recoveryService: StubAccountRecoveryService!

    override func setUp() {
        super.setUp()
        recoveryService = StubAccountRecoveryService()
    }

    func testFindIDInitialState() {
        let vc = inNav(FindIDViewController(findIDInputVM: FindIDViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testFindPasswordVerificationInitialState() {
        let vc = inNav(FindPasswordVerificationViewController(findPasswordVerificationVM: FindPasswordVerificationViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testResetPasswordInitialState() {
        let vc = inNav(ResetPasswordViewController(resetPasswordVM: ResetPasswordViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }
}
```

**Step 2: 기존 레퍼런스 이미지 삭제**

```bash
rm Account/Tests/AccountTests/Snapshot/__Snapshots__/FindAccountSnapshotTests/*.png
```

**Step 3: 테스트 실행하여 새 레퍼런스 생성**

Xcode에서 AccountTests 실행.

**Step 4: Commit**

```bash
git add Account/Tests/AccountTests/Snapshot/FindAccountSnapshotTests.swift
git add Account/Tests/AccountTests/Snapshot/__Snapshots__/FindAccountSnapshotTests/
git commit -m "test: FindAccountSnapshotTests 베이스 클래스 상속 및 VC 스냅샷으로 통일"
```

---

### Task 5: Conceptbook — 베이스 클래스 추가

**Files:**
- Create: `Conceptbook/Tests/ConceptbookTests/SnapshotTestHelpers.swift`

**Step 1: 파일 생성**

```swift
//
//  SnapshotTestHelpers.swift
//  ConceptbookTests
//

import UIKit
import XCTest

@MainActor
class ConceptbookSnapshotTestCase: XCTestCase {
    func snapshotView(_ view: UIView, width: CGFloat = 375) -> UIView {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )
        view.frame = CGRect(origin: .zero, size: size)
        view.layoutIfNeeded()
        return view
    }
}
```

**Step 2: 빌드 확인**

Xcode에서 ConceptbookTests 타겟 빌드 (⌘B). 에러 없어야 함.

**Step 3: Commit**

```bash
git add Conceptbook/Tests/ConceptbookTests/SnapshotTestHelpers.swift
git commit -m "test: ConceptbookSnapshotTestCase 베이스 클래스 추가"
```

---

### Task 6: Conceptbook — ConceptbookSnapshotTests 수정 + 구버전 폴더 삭제

**Files:**
- Modify: `Conceptbook/Tests/ConceptbookTests/ConceptbookSnapshotTests.swift`
- Delete: `Conceptbook/Tests/ConceptbookTests/__Snapshots___64/` (구버전 iOSSnapshotTestCase 폴더)

**Step 1: 베이스 클래스 상속, 헬퍼 메서드 적용**

```swift
//
//  ConceptbookSnapshotTests.swift
//  ConceptbookTests
//

import XCTest
import SnapshotTesting
@testable import Conceptbook
import QRIZUtils
import DesignSystem

@MainActor
class ConceptbookSnapshotTests: ConceptbookSnapshotTestCase {

    func testChapterInfoView() {
        let view = ChapterInfoView()
        view.configure(subjectTitle: Chapter.dataModeling.cardTitle, itemCount: Chapter.dataModeling.cardItemCount)
        assertSnapshot(of: snapshotView(view, width: 375), as: .image)
    }

    func testMenuListView() {
        let view = MenuListView()
        view.configure(with: Chapter.dataModeling.conceptItems)
        assertSnapshot(of: snapshotView(view, width: 375), as: .image)
    }

    func testSubjectCardView() {
        let view = SubjectCardView(
            image: UIImage.designSystemImage(named: Chapter.dataModeling.assetName),
            title: Chapter.dataModeling.cardTitle,
            itemCount: Chapter.dataModeling.cardItemCount
        )
        assertSnapshot(of: snapshotView(view, width: 160), as: .image)
    }
}
```

**Step 2: 구버전 폴더 삭제**

```bash
rm -rf Conceptbook/Tests/ConceptbookTests/__Snapshots___64
```

**Step 3: 테스트 실행하여 레퍼런스 이미지 검증**

Xcode에서 ConceptbookTests 실행. 기존 `__Snapshots__/`의 이미지와 비교됨. 레이아웃 변경 없으므로 통과해야 함.

**Step 4: Commit**

```bash
git add Conceptbook/Tests/ConceptbookTests/ConceptbookSnapshotTests.swift
git add Conceptbook/Tests/ConceptbookTests/SnapshotTestHelpers.swift
git rm -r Conceptbook/Tests/ConceptbookTests/__Snapshots___64
git commit -m "test: ConceptbookSnapshotTests 베이스 클래스 상속 및 보일러플레이트 제거"
```
