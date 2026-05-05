import Testing
import Foundation
@testable import Onboarding

@MainActor
@Suite("PlanDurationSelectionViewModel 테스트", .serialized)
struct PlanDurationSelectionViewModelTests {

    private func makeSUT(
        service: MockDailyService = .init(),
        onNavigate: @escaping () -> Void = {}
    ) -> PlanDurationSelectionViewModel {
        PlanDurationSelectionViewModel(dailyService: service, onNavigate: onNavigate)
    }

    // MARK: - 초기 상태

    @Test("초기 상태: selectedPlanType nil, isLoading false, errorMessage nil")
    func initialState() {
        let sut = makeSUT()
        #expect(sut.selectedPlanType == nil)
        #expect(!sut.isLoading)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - didSelectPlan

    @Test("didSelectPlan: selectedPlanType 설정", arguments: [7, 14, 30])
    func didSelectPlan_setsPlanType(planType: Int) {
        let sut = makeSUT()
        sut.didSelectPlan(planType)
        #expect(sut.selectedPlanType == planType)
    }

    @Test("didSelectPlan: 다른 플랜 재선택 시 selectedPlanType 갱신")
    func didSelectPlan_updatesWhenReselected() {
        let sut = makeSUT()
        sut.didSelectPlan(7)
        sut.didSelectPlan(30)
        #expect(sut.selectedPlanType == 30)
    }

    // MARK: - didTapConfirm 선택 없을 때

    @Test("didTapConfirm: 선택 없을 때 API 호출하지 않음")
    func didTapConfirm_withoutSelection_doesNotCallAPI() async {
        let service = MockDailyService()
        let sut = makeSUT(service: service)

        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(service.capturedPlanType == nil)
    }

    // MARK: - didTapConfirm 성공

    @Test("didTapConfirm: 성공 시 올바른 planType으로 API 호출", arguments: [7, 14, 30])
    func didTapConfirm_onSuccess_callsAPIWithCorrectPlanType(planType: Int) async {
        let service = MockDailyService()
        let sut = makeSUT(service: service)

        sut.didSelectPlan(planType)
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(service.capturedPlanType == planType)
    }

    @Test("didTapConfirm: 성공 시 onNavigate 호출")
    func didTapConfirm_onSuccess_callsOnNavigate() async {
        var navigateCalled = false
        let sut = makeSUT(onNavigate: { navigateCalled = true })

        sut.didSelectPlan(7)
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateCalled)
    }

    @Test("didTapConfirm: 성공 후 isLoading false")
    func didTapConfirm_onSuccess_setsIsLoadingFalse() async {
        let sut = makeSUT()

        sut.didSelectPlan(14)
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!sut.isLoading)
    }

    // MARK: - didTapConfirm 실패

    @Test("didTapConfirm: 실패 시 errorMessage 세팅")
    func didTapConfirm_onFailure_setsErrorMessage() async {
        let service = MockDailyService()
        service.selectPlanResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)

        sut.didSelectPlan(7)
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
    }

    @Test("didTapConfirm: 실패 시 onNavigate 호출하지 않음")
    func didTapConfirm_onFailure_doesNotCallOnNavigate() async {
        var navigateCalled = false
        let service = MockDailyService()
        service.selectPlanResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service, onNavigate: { navigateCalled = true })

        sut.didSelectPlan(7)
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!navigateCalled)
    }

    // MARK: - didTapConfirm 중복 탭

    @Test("didTapConfirm: isLoading 중 중복 탭 무시")
    func didTapConfirm_whileLoading_isIgnored() async {
        var navigateCount = 0
        let sut = makeSUT(onNavigate: { navigateCount += 1 })

        sut.didSelectPlan(7)
        sut.didTapConfirm()
        sut.didTapConfirm()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateCount == 1)
    }
}
