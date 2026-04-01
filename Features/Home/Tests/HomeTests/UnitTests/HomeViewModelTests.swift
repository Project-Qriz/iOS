import Foundation
import Testing
import Combine
@testable import Home
import Network
import QRIZUtils

@MainActor
@Suite("HomeViewModel 테스트", .serialized)
struct HomeViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class TestHarness {
        let sut: HomeViewModel
        private(set) var received: [HomeViewModel.Output] = []
        private let inputSubject = PassthroughSubject<HomeViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(
            examService: MockExamScheduleService,
            dailyService: MockDailyService,
            weeklyService: MockWeeklyRecommendService
        ) {
            self.sut = HomeViewModel(
                examScheduleService: examService,
                dailyService: dailyService,
                weeklyService: weeklyService
            )
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: HomeViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async throws {
            inputSubject.send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func resetReceived() { received.removeAll() }

        var stateOutputs: [HomeState] {
            received.compactMap {
                if case .updateState(let s) = $0 { return s }
                return nil
            }
        }

        var errorTitles: [String] {
            received.compactMap {
                if case .showErrorAlert(let title, _) = $0 { return title }
                return nil
            }
        }
    }

    // MARK: - Factory

    private func makeHarness(
        examService: MockExamScheduleService? = nil,
        dailyService: MockDailyService? = nil,
        weeklyService: MockWeeklyRecommendService? = nil
    ) -> TestHarness {
        TestHarness(
            examService: examService ?? MockExamScheduleService(),
            dailyService: dailyService ?? MockDailyService(),
            weeklyService: weeklyService ?? MockWeeklyRecommendService()
        )
    }

    // MARK: - Setup / Teardown

    init() {
        UserInfoManager.shared.reset()
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad 성공 → updateState emit (examStatus .registered, dailyPlans 1개)")
    func viewDidLoad_success_emitsUpdateState() async throws {
        let examService = MockExamScheduleService()
        examService.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: [.make(completed: false)]))

        let h = makeHarness(examService: examService, dailyService: dailyService)
        try await h.sendViewDidLoad()

        let state = h.stateOutputs.last
        #expect(state != nil)
        #expect(state?.dailyPlans.count == 1)
        let isRegistered: Bool
        if case .registered = state?.examStatus { isRegistered = true } else { isRegistered = false }
        #expect(isRegistered)
    }

    @Test("viewDidLoad — 시험 미등록(400) → examStatus .none")
    func viewDidLoad_examNotRegistered_examStatusNone() async throws {
        let examService = MockExamScheduleService()
        examService.fetchAppliedExamsResult = .failure(
            NetworkError.clientError(httpStatus: 400, serverCode: 0, message: "not registered")
        )
        let h = makeHarness(examService: examService)
        try await h.sendViewDidLoad()

        let state = h.stateOutputs.last
        #expect(state?.examStatus == ExamStatus.none)
    }

    @Test("viewDidLoad — 시험 조회 실패(non-400) → showErrorAlert emit")
    func viewDidLoad_examFetchFails_nonClientError_emitsErrorAlert() async throws {
        let examService = MockExamScheduleService()
        examService.fetchAppliedExamsResult = .failure(URLError(.notConnectedToInternet))
        let h = makeHarness(examService: examService)
        try await h.sendViewDidLoad()

        #expect(!h.errorTitles.isEmpty)
    }

    @Test("viewDidLoad — dailyPlan 실패 → showErrorAlert emit")
    func viewDidLoad_dailyPlanFailure_emitsError() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .failure(URLError(.notConnectedToInternet))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()

        #expect(!h.errorTitles.isEmpty)
    }

    @Test("viewDidLoad — firstIncomplete day → selectedIndex 설정")
    func viewDidLoad_setsSelectedIndexToFirstIncompletePlan() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: [
            .make(id: 1, completed: true),
            .make(id: 2, completed: true),
            .make(id: 3, completed: false)
        ]))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()

        #expect(h.stateOutputs.last?.selectedIndex == 2)
    }

    // MARK: - entryTapped

    @Test("entryTapped — preview 상태 → navigateToOnboarding")
    func entryTapped_preview_navigatesToOnboarding() async throws {
        UserInfoManager.shared.previewTestStatus = .notStarted
        let h = makeHarness()
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.entryTapped)

        #expect(h.received.contains { if case .navigateToOnboarding = $0 { return true }; return false })
    }

    @Test("entryTapped — mock 상태 → navigateToExamList")
    func entryTapped_mock_navigatesToExamList() async throws {
        UserInfoManager.shared.previewTestStatus = .previewCompleted
        let h = makeHarness()
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.entryTapped)

        #expect(h.received.contains { if case .navigateToExamList = $0 { return true }; return false })
    }

    // MARK: - resetTapped

    @Test("resetTapped → showResetAlert emit")
    func resetTapped_emitsShowResetAlert() {
        let h = makeHarness()
        h.send(.resetTapped)

        #expect(h.received.contains { if case .showResetAlert = $0 { return true }; return false })
    }

    // MARK: - daySelected

    @Test("daySelected(3) → updateState with selectedIndex 3")
    func daySelected_updatesSelectedIndex() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: (0..<5).map { .make(id: $0) }))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.daySelected(3))

        #expect(h.stateOutputs.last?.selectedIndex == 3)
    }

    // MARK: - dayHeaderTapped

    @Test("dayHeaderTapped → showDaySelectAlert with correct totalDays")
    func dayHeaderTapped_emitsShowDaySelectAlert() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: (0..<7).map { .make(id: $0) }))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.dayHeaderTapped)

        let alert = h.received.first.flatMap { output -> (Int, Int, Int?)? in
            if case .showDaySelectAlert(let total, let selected, let today) = output {
                return (total, selected, today)
            }
            return nil
        }
        #expect(alert?.0 == 7)
    }

    // MARK: - didConfirmResetPlan

    @Test("didConfirmResetPlan 성공 → resetSucceeded emit")
    func didConfirmResetPlan_success_emitsResetSucceeded() async throws {
        let dailyService = MockDailyService()
        dailyService.resetPlanResult = .success(.make(msg: "초기화 성공"))
        let h = makeHarness(dailyService: dailyService)

        h.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.received.contains {
            if case .resetSucceeded(let msg) = $0 { return msg == "초기화 성공" }
            return false
        })
    }

    @Test("didConfirmResetPlan 실패 → showErrorAlert emit")
    func didConfirmResetPlan_failure_emitsErrorAlert() async throws {
        let dailyService = MockDailyService()
        dailyService.resetPlanResult = .failure(URLError(.notConnectedToInternet))
        let h = makeHarness(dailyService: dailyService)

        h.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!h.errorTitles.isEmpty)
    }

    // MARK: - ctaTapped

    @Test("ctaTapped — 일반 day → showDaily type .daily")
    func ctaTapped_normalDay_showsDailyType() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: [
            .make(id: 0, reviewDay: false, comprehensiveReviewDay: false)
        ]))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.ctaTapped(day: 0))

        #expect(h.received.contains {
            if case .showDaily(let day, let type) = $0 { return day == 1 && type == .daily }
            return false
        })
    }

    @Test("ctaTapped — reviewDay → showDaily type .weekly")
    func ctaTapped_reviewDay_showsWeeklyType() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: [
            .make(id: 0, reviewDay: true, comprehensiveReviewDay: false)
        ]))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.ctaTapped(day: 0))

        #expect(h.received.contains {
            if case .showDaily(_, let type) = $0 { return type == .weekly }
            return false
        })
    }

    @Test("ctaTapped — comprehensiveReviewDay → showDaily type .monthly")
    func ctaTapped_comprehensiveReviewDay_showsMonthlyType() async throws {
        let dailyService = MockDailyService()
        dailyService.getDailyPlanResult = .success(.make(plans: [
            .make(id: 0, reviewDay: false, comprehensiveReviewDay: true)
        ]))
        let h = makeHarness(dailyService: dailyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.ctaTapped(day: 0))

        #expect(h.received.contains {
            if case .showDaily(_, let type) = $0 { return type == .monthly }
            return false
        })
    }

    // MARK: - weeklyConceptTapped

    @Test("weeklyConceptTapped — 유효한 개념 → showConceptPDF emit")
    func weeklyConceptTapped_validConcept_emitsShowConceptPDF() async throws {
        let weeklyService = MockWeeklyRecommendService()
        weeklyService.fetchWeeklyRecommendResult = .success(.make(items: [.make()]))
        let h = makeHarness(weeklyService: weeklyService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.weeklyConceptTapped(0))

        #expect(h.received.contains {
            if case .showConceptPDF = $0 { return true }
            return false
        })
    }

    @Test("reloadExamSchedule — 실패 → showErrorAlert emit")
    func reloadExamSchedule_failure_emitsErrorAlert() async throws {
        let examService = MockExamScheduleService()
        examService.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let h = makeHarness(examService: examService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        examService.fetchAppliedExamsResult = .failure(URLError(.notConnectedToInternet))
        h.sut.reloadExamSchedule()
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(!h.errorTitles.isEmpty)
    }

    // MARK: - reloadExamSchedule

    @Test("reloadExamSchedule → updateState emit with examStatus")
    func reloadExamSchedule_updatesState() async throws {
        let examService = MockExamScheduleService()
        examService.fetchAppliedExamsResult = .success(.make(examDate: "2026-12-31"))
        let h = makeHarness(examService: examService)
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.sut.reloadExamSchedule()
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        let state = h.stateOutputs.last
        #expect(state != nil)
        #expect(state?.examStatus != ExamStatus.none)
    }

    // MARK: - reloadUserState

    @Test("reloadUserState — previewCompleted → entryState .mock")
    func reloadUserState_previewCompleted_entryStateMock() async throws {
        UserInfoManager.shared.previewTestStatus = .notStarted
        let h = makeHarness()
        try await h.sendViewDidLoad()
        h.resetReceived()

        UserInfoManager.shared.previewTestStatus = .previewCompleted
        h.sut.reloadUserState()

        #expect(h.stateOutputs.last?.entryState == .mock)
    }

    @Test("reloadUserState — notStarted → entryState .preview")
    func reloadUserState_notStarted_entryStatePreview() async throws {
        UserInfoManager.shared.previewTestStatus = .previewCompleted
        let h = makeHarness()
        try await h.sendViewDidLoad()
        h.resetReceived()

        UserInfoManager.shared.previewTestStatus = .notStarted
        h.sut.reloadUserState()

        #expect(h.stateOutputs.last?.entryState == .preview)
    }
}
