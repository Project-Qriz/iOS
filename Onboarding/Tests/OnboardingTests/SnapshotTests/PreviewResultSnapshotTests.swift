import XCTest
import SnapshotTesting
import SwiftUI
import QRIZUtils
@testable import Onboarding

@MainActor
class PreviewResultSnapshotTests: OnboardingSnapshotTestCase {

    func testLoadedState() {
        let vm = PreviewResultViewModel(
            onboardingService: MockOnboardingService(),
            onNavigateToGreeting: {}
        )
        // subjectScores는 [0,0,0,0,0] 5개 배열로 초기화 — 인덱스 할당으로 실제 updateData와 동일하게 재현
        vm.previewScoresData.expectScore = 72.0
        vm.previewScoresData.subjectScores[0] = 40
        vm.previewScoresData.subjectScores[1] = 32
        vm.previewScoresData.subjectCount = 2
        vm.previewConceptsData.firstConcept = "SQL 기본"
        vm.previewConceptsData.secondConcept = "SELECT문"
        vm.previewConceptsData.totalQuestions = 10

        let vc = UIHostingController(rootView: PreviewResultView(viewModel: vm))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
