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
