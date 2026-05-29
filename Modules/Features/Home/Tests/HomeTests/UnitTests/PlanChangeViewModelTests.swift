import Foundation
import Testing
import Combine
import QRIZNetwork
import QRIZUtils
@testable import Home

@MainActor
@Suite("PlanChangeViewModel 테스트", .serialized)
struct PlanChangeViewModelTests {

    // MARK: - TestHarness

    @MainActor
    private final class MockDelegate: PlanChangeDelegate {
        private(set) var completedCount = 0
        private(set) var resetCount = 0
        private(set) var dismissCount = 0

        func planChangeDidComplete() { completedCount += 1 }
        func planChangeDidRequestReset() { resetCount += 1 }
        func planChangeDidDismiss() { dismissCount += 1 }
    }

    @MainActor
    private final class TestHarness {
        let sut: PlanChangeViewModel
        let mockService: MockDailyService
        let mockDelegate: MockDelegate
        private(set) var received: [PlanChangeViewModel.Output] = []
        private let inputSubject = PassthroughSubject<PlanChangeViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init() {
            mockService = MockDailyService()
            mockDelegate = MockDelegate()
            sut = PlanChangeViewModel(dailyService: mockService)
            sut.delegate = mockDelegate
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: PlanChangeViewModel.Input) {
            inputSubject.send(input)
        }

        func resetReceived() { received.removeAll() }

        var currentPlanOutputs: [PlanOption] {
            received.compactMap {
                if case .applyCurrentPlan(let p) = $0 { return p }
                return nil
            }
        }

        var availablePlanOutputs: [[PlanOption]] {
            received.compactMap {
                if case .applyAvailablePlans(let p) = $0 { return p }
                return nil
            }
        }

        var selectionOutputs: [PlanOption] {
            received.compactMap {
                if case .applySelection(let p) = $0 { return p }
                return nil
            }
        }

        var confirmEnabledValues: [Bool] {
            received.compactMap {
                if case .setConfirmEnabled(let v) = $0 { return v }
                return nil
            }
        }

        var errorMessages: [String] {
            received.compactMap {
                if case .showError(let m) = $0 { return m }
                return nil
            }
        }

        var showAlertOutputs: [(title: String, description: String)] {
            received.compactMap {
                if case .showAlert(let title, let description) = $0 { return (title, description) }
                return nil
            }
        }

        var didEmitShowResetAlert: Bool {
            received.contains { if case .showResetAlert = $0 { return true }; return false }
        }
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad → applyCurrentPlan + applyAvailablePlans emit")
    func viewDidLoad_emitsPlans() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(
            .make(currentPlanType: 7, availablePlanTypes: [14, 30])
        )

        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.currentPlanOutputs.last == .sevenDay)
        #expect(h.availablePlanOutputs.last?.contains(.fourteenDay) == true)
        #expect(h.availablePlanOutputs.last?.contains(.thirtyDay) == true)
    }

    @Test("viewDidLoad — API 실패 → showError emit")
    func viewDidLoad_apiFailure_emitsError() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .failure(
            NSError(domain: "test", code: -1)
        )

        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.errorMessages.isEmpty == false)
    }

    // MARK: - selectPlan

    @Test("selectPlan → applySelection + setConfirmEnabled(true) emit")
    func selectPlan_differentFromCurrent_confirmEnabled() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(
            .make(currentPlanType: 7, availablePlanTypes: [14, 30])
        )
        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.resetReceived()

        h.send(.selectPlan(.fourteenDay))

        #expect(h.selectionOutputs.last == .fourteenDay)
        #expect(h.confirmEnabledValues.last == true)
    }

    @Test("selectPlan — 현재 플랜 선택 → setConfirmEnabled(false)")
    func selectPlan_sameAsCurrent_confirmDisabled() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(
            .make(currentPlanType: 7, availablePlanTypes: [14, 30])
        )
        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.resetReceived()

        h.send(.selectPlan(.sevenDay))

        #expect(h.selectionOutputs.last == .sevenDay)
        #expect(h.confirmEnabledValues.last == false)
    }

    // MARK: - tapConfirm

    @Test("tapConfirm — 유효한 선택 → changePlan 호출 + delegate.planChangeDidComplete()")
    func tapConfirm_validSelection_callsDelegate() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(
            .make(currentPlanType: 7, availablePlanTypes: [14, 30])
        )
        h.mockService.changePlanResult = .success(.make())

        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.send(.selectPlan(.fourteenDay))
        h.send(.tapConfirm)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockService.capturedChangePlanType == 14)
        #expect(h.mockDelegate.completedCount == 1)
        #expect(h.errorMessages.isEmpty)
    }

    @Test("tapConfirm — 선택 없음 → delegate 미호출")
    func tapConfirm_withoutSelection_doesNotCallDelegate() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(.make())

        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.send(.tapConfirm)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockDelegate.completedCount == 0)
        #expect(h.mockService.capturedChangePlanType == nil)
    }

    @Test("tapConfirm — changePlan 실패 → showError emit")
    func tapConfirm_changePlanFailure_emitsError() async throws {
        let h = TestHarness()
        h.mockService.getChangeavailablePlansResult = .success(
            .make(currentPlanType: 7, availablePlanTypes: [14, 30])
        )
        h.mockService.changePlanResult = .failure(NSError(domain: "test", code: -1))

        h.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.send(.selectPlan(.fourteenDay))
        h.send(.tapConfirm)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.errorMessages.isEmpty == false)
        #expect(h.mockDelegate.completedCount == 0)
    }

    // MARK: - tapReset / tapResetConfirmed

    @Test("tapReset → showResetAlert output emit (delegate 미호출)")
    func tapReset_emitsShowResetAlert() {
        let h = TestHarness()
        h.send(.tapReset)

        #expect(h.didEmitShowResetAlert == true)
        #expect(h.mockDelegate.resetCount == 0)
    }

    @Test("tapResetConfirmed — 성공 → resetPlan 호출 + delegate.planChangeDidRequestReset()")
    func tapResetConfirmed_success_callsDelegate() async throws {
        let h = TestHarness()
        h.mockService.resetPlanResult = .success(.make())

        h.send(.tapResetConfirmed)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockService.resetPlanCallCount == 1)
        #expect(h.mockDelegate.resetCount == 1)
        #expect(h.errorMessages.isEmpty)
    }

    @Test("tapResetConfirmed — 400 clientError → showAlert(title:description:) emit")
    func tapResetConfirmed_clientError_emitsShowAlert() async throws {
        let h = TestHarness()
        h.mockService.resetPlanResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: -1, message: "최소 5일 이상 학습 후 가능합니다.")
        )

        h.send(.tapResetConfirmed)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockDelegate.resetCount == 0)
        #expect(h.showAlertOutputs.isEmpty == false)
        #expect(h.showAlertOutputs.first?.title == "초기화할 수 없습니다.")
        #expect(h.showAlertOutputs.first?.description == "최소 5일 이상 학습 후 가능합니다.")
    }

    @Test("tapResetConfirmed — 기타 에러 → showError emit")
    func tapResetConfirmed_unknownError_emitsShowError() async throws {
        let h = TestHarness()
        h.mockService.resetPlanResult = .failure(NSError(domain: "test", code: -1))

        h.send(.tapResetConfirmed)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.mockDelegate.resetCount == 0)
        #expect(h.errorMessages.isEmpty == false)
    }

    // MARK: - tapDismiss

    @Test("tapDismiss → delegate.planChangeDidDismiss()")
    func tapDismiss_callsDelegate() {
        let h = TestHarness()
        h.send(.tapDismiss)
        #expect(h.mockDelegate.dismissCount == 1)
    }
}
