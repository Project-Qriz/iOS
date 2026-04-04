import XCTest
import SnapshotTesting
import SwiftUI
@testable import Onboarding

@MainActor
class GreetingSnapshotTests: OnboardingSnapshotTestCase {

    func testInitialState() {
        // UIHostingController에서 layoutIfNeeded()만으로는 SwiftUI의 .onAppear가
        // 실행되지 않으므로 타이머가 시작되지 않는다 — 초기 상태(빈 nickname) 캡처
        let vm = GreetingViewModel(
            userInfoService: MockUserInfoService(),
            onNavigate: {}
        )
        let vc = UIHostingController(rootView: GreetingView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
