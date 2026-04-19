import XCTest
import SnapshotTesting
import QRIZUtils
@testable import Onboarding

@MainActor
class PreviewTestSnapshotTests: OnboardingSnapshotTestCase {
    
    func testInitialState() {
        let view = PreviewTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)

        view.updateQuestion(QuestionData(
            question: "다음 중 데이터 모델에 대한 설명으로 가장 올바른 것은?",
            option1: "엔티티는 업무에서 사용되는 데이터의 집합이다.",
            option2: "속성은 엔티티를 구성하는 항목으로 더 이상 분리될 수 없다.",
            option3: "관계는 엔티티 간의 업무적인 연관성을 나타낸다.",
            option4: "식별자는 엔티티 내에서 각 인스턴스를 구분하는 구분자이다.",
            timeLimit: 1800,
            questionNumber: 1
        ))
        view.pageIndicatorLabel.setCurrentPage(1)
        view.pageIndicatorLabel.setTotalPage(5)
        view.timeLabel.text = "30:00"
        view.previousButton.isHidden = true

        view.layoutIfNeeded()

        assertSnapshot(of: view, as: .image)
    }
}
