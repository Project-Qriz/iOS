import Testing
import Foundation
import QRIZUtils
@testable import Onboarding

@MainActor
@Suite("CheckConceptViewModel 테스트", .serialized)
struct CheckConceptViewModelTests {

    // 싱글톤 오염 방지: 각 테스트 시작 전 UserInfoManager 초기화
    private func makeSUT(
        service: MockOnboardingService = .init(),
        onNavigate: @escaping (CheckConceptNavigation) -> Void = { _ in }
    ) -> CheckConceptViewModel {
        UserInfoManager.shared.update(
            name: "",
            userId: "",
            email: "",
            previewTestStatus: .notStarted,
            provider: nil
        )
        return CheckConceptViewModel(onboardingService: service, onNavigate: onNavigate, userInfo: .shared)
    }

    // MARK: - 초기 상태

    @Test("초기 상태: selectedSet 비어있고 isDoneButtonEnabled false")
    func initialState() {
        let sut = makeSUT()
        #expect(sut.selectedSet.isEmpty)
        #expect(!sut.isDoneButtonEnabled)
    }

    // MARK: - didTapConcept

    @Test("didTapConcept: 선택/해제 토글", arguments: [0, 5, 15, 29])
    func didTapConcept_togglesSelection(index: Int) {
        let sut = makeSUT()

        sut.didTapConcept(at: index)
        #expect(sut.selectedSet.contains(index))

        sut.didTapConcept(at: index)
        #expect(!sut.selectedSet.contains(index))
    }

    // MARK: - didTapAll

    @Test("didTapAll: 전체 30개 선택")
    func didTapAll_selectsAll() {
        let sut = makeSUT()
        sut.didTapAll()
        #expect(sut.selectedSet.count == 30)
    }

    @Test("didTapAll: 전체 선택 후 재탭 시 전체 해제")
    func didTapAll_whenAllSelected_deselectsAll() {
        let sut = makeSUT()
        sut.didTapAll()
        sut.didTapAll()
        #expect(sut.selectedSet.isEmpty)
    }

    // MARK: - didTapNone

    @Test("didTapNone: selectedSet 비워지고 isDoneButtonEnabled true")
    func didTapNone_clearsSetAndEnablesButton() {
        let sut = makeSUT()
        sut.didTapConcept(at: 0)

        sut.didTapNone()

        #expect(sut.selectedSet.isEmpty)
        #expect(sut.isDoneButtonEnabled)
    }

    @Test("didTapNone 후 didTapConcept: isDoneButtonEnabled 정상 갱신")
    func afterDidTapNone_didTapConcept_updatesDoneButton() {
        let sut = makeSUT()
        sut.didTapNone()
        // isDoneButtonEnabled = true (none 선택 상태)

        sut.didTapConcept(at: 0) // 개념 1개 선택 → true 유지
        #expect(sut.isDoneButtonEnabled)

        sut.didTapConcept(at: 0) // 개념 해제 → updateDoneButton() → isEmpty이면 false
        #expect(!sut.isDoneButtonEnabled)
    }

    // MARK: - isDoneButtonEnabled

    @Test("isDoneButtonEnabled: 선택 없을 때 false")
    func isDoneButtonEnabled_false_whenNothingSelected() {
        let sut = makeSUT()
        #expect(!sut.isDoneButtonEnabled)
    }

    @Test("isDoneButtonEnabled: 1개 이상 선택 시 true")
    func isDoneButtonEnabled_true_whenAtLeastOneSelected() {
        let sut = makeSUT()
        sut.didTapConcept(at: 0)
        #expect(sut.isDoneButtonEnabled)
    }

    // MARK: - didTapDone 네비게이션

    @Test("didTapNone 후 didTapDone → .greeting으로 navigate")
    func didTapDone_afterTapNone_navigatesToGreeting() async {
        var destination: CheckConceptNavigation?
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { destination = $0 })

        sut.didTapNone()   // isDoneButtonEnabled = true, selectedSet = empty
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(destination == .greeting)
    }

    @Test("selectedSet 있을 때 didTapDone → .previewTest로 navigate")
    func didTapDone_withSelection_navigatesToPreviewTest() async {
        var destination: CheckConceptNavigation?
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { destination = $0 })

        sut.didTapConcept(at: 0)
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(destination == .previewTest)
    }

    // MARK: - didTapDone 에러 처리

    @Test("didTapDone: sendSurvey 실패 시 errorMessage 세팅")
    func didTapDone_onServiceFailure_setsErrorMessage() async {
        let service = MockOnboardingService()
        service.sendSurveyResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)

        sut.didTapConcept(at: 0)
        sut.didTapDone()

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
    }

    @Test("didTapDone: isLoading 중 중복 탭 무시")
    func didTapDone_whileLoading_isIgnored() async {
        var navigateCount = 0
        let service = MockOnboardingService()
        let sut = makeSUT(service: service, onNavigate: { _ in navigateCount += 1 })

        sut.didTapConcept(at: 0)
        sut.didTapDone()
        sut.didTapDone() // isLoading = true 상태에서 두 번째 탭

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateCount == 1)
    }
}
