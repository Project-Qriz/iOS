import XCTest
import SnapshotTesting
@testable import Onboarding

@MainActor
class PreviewTestSnapshotTests: OnboardingSnapshotTestCase {
    
    func testInitialState() {
        let view = PreviewTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        
        view.questionNumberLabel.text = "01."
        view.questionTitleLabel.text = "다음 중 데이터 모델에 대한 설명으로 가장 올바른 것은?"
        view.optionLabels[0].setOptionString("엔티티는 업무에서 사용되는 데이터의 집합이다.")
        view.optionLabels[1].setOptionString("속성은 엔티티를 구성하는 항목으로 더 이상 분리될 수 없다.")
        view.optionLabels[2].setOptionString("관계는 엔티티 간의 업무적인 연관성을 나타낸다.")
        view.optionLabels[3].setOptionString("식별자는 엔티티 내에서 각 인스턴스를 구분하는 구분자이다.")
        view.pageIndicatorLabel.setCurrentPage(1)
        view.pageIndicatorLabel.setTotalPage(5)
        view.timeLabel.text = "30:00"
        view.previousButton.isHidden = true
        
        view.layoutIfNeeded()
        
        assertSnapshot(of: view, as: .image)
    }
}
