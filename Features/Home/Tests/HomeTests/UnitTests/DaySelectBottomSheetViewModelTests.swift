import Foundation
import Testing
import Combine
@testable import Home

@MainActor
@Suite("DaySelectBottomSheetViewModel 테스트", .serialized)
struct DaySelectBottomSheetViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class TestHarness {
        private let sut: DaySelectBottomSheetViewModel
        private(set) var received: [DaySelectBottomSheetViewModel.Output] = []
        private let inputSubject = PassthroughSubject<DaySelectBottomSheetViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(totalDays: Int, initialSelected: Int = 0, todayIndex: Int? = nil) {
            self.sut = DaySelectBottomSheetViewModel(
                totalDays: totalDays,
                initialSelected: initialSelected,
                todayIndex: todayIndex
            )
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: DaySelectBottomSheetViewModel.Input) {
            inputSubject.send(input)
        }

        func resetReceived() { received.removeAll() }

        var updateUIOutputs: [(week: Int, selected: Int, totalDays: Int, prevEnabled: Bool, nextEnabled: Bool)] {
            received.compactMap {
                if case .updateUI(let w, let s, let t, let p, let n) = $0 { return (w, s, t, p, n) }
                return nil
            }
        }

        var confirmedDays: [Int] {
            received.compactMap {
                if case .dayConfirmed(let d) = $0 { return d }
                return nil
            }
        }
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad → 초기 상태 updateUI emit")
    func viewDidLoad_emitsInitialState() {
        let h = TestHarness(totalDays: 14, initialSelected: 0)
        h.send(.viewDidLoad)

        #expect(h.updateUIOutputs.count == 1)
        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 1)
        #expect(ui.selected == 0)
        #expect(ui.totalDays == 14)
        #expect(ui.prevEnabled == false)
        #expect(ui.nextEnabled == true)
    }

    @Test("viewDidLoad — totalDays 1 → prevEnabled/nextEnabled 모두 false")
    func viewDidLoad_totalDays1_bothNavigationDisabled() {
        let h = TestHarness(totalDays: 1, initialSelected: 0)
        h.send(.viewDidLoad)

        let ui = h.updateUIOutputs[0]
        #expect(ui.prevEnabled == false)
        #expect(ui.nextEnabled == false)
        #expect(ui.totalDays == 1)
    }

    @Test("viewDidLoad — 마지막 주 선택 → nextEnabled false")
    func viewDidLoad_lastWeek_nextDisabled() {
        let h = TestHarness(totalDays: 7, initialSelected: 6)
        h.send(.viewDidLoad)

        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 1)
        #expect(ui.nextEnabled == false)
    }

    // MARK: - prevWeekTapped / nextWeekTapped

    @Test("nextWeekTapped → week 2로 이동, prevEnabled true")
    func nextWeekTapped_movesToWeek2() {
        let h = TestHarness(totalDays: 14)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.nextWeekTapped)

        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 2)
        #expect(ui.prevEnabled == true)
        #expect(ui.nextEnabled == false)
    }

    @Test("prevWeekTapped — week 1에서 호출 → week 유지")
    func prevWeekTapped_atWeek1_clamped() {
        let h = TestHarness(totalDays: 14)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.prevWeekTapped)

        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 1)
        #expect(ui.prevEnabled == false)
    }

    @Test("next → prev → week 원복")
    func nextThenPrev_returnsToWeek1() {
        let h = TestHarness(totalDays: 14)
        h.send(.viewDidLoad)
        h.send(.nextWeekTapped)
        h.resetReceived()

        h.send(.prevWeekTapped)

        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 1)
    }

    // MARK: - dayTapped

    @Test("dayTapped → dayConfirmed + updateUI emit")
    func dayTapped_emitsDayConfirmedAndUpdateUI() {
        let h = TestHarness(totalDays: 14)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.dayTapped(3))

        #expect(h.confirmedDays == [3])
        #expect(h.updateUIOutputs.count == 1)
        #expect(h.updateUIOutputs[0].selected == 3)
    }

    @Test("dayTapped — 2주차 day → displayWeek 자동 이동")
    func dayTapped_secondWeekDay_updatesDisplayWeek() {
        let h = TestHarness(totalDays: 14)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.dayTapped(9))

        let ui = h.updateUIOutputs[0]
        #expect(ui.week == 2)
        #expect(ui.selected == 9)
    }

    // MARK: - todayTapped

    @Test("todayTapped — todayIndex 있음 → dayConfirmed(todayIndex)")
    func todayTapped_withTodayIndex_confirmsToday() {
        let h = TestHarness(totalDays: 14, todayIndex: 5)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.todayTapped)

        #expect(h.confirmedDays == [5])
    }

    @Test("todayTapped — todayIndex nil → 아무것도 emit 안 함")
    func todayTapped_withoutTodayIndex_emitsNothing() {
        let h = TestHarness(totalDays: 14, todayIndex: nil)
        h.send(.viewDidLoad)
        h.resetReceived()

        h.send(.todayTapped)

        #expect(h.confirmedDays.isEmpty)
    }
}
