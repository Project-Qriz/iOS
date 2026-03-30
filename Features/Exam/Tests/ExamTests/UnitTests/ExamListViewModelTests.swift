import Foundation
import Testing
import Combine
@testable import Exam
import Network
import QRIZUtils

@MainActor
@Suite("ExamListViewModel 테스트", .serialized)
struct ExamListViewModelTests {

    // MARK: - Test Harness

    @MainActor
    private final class TestHarness {
        private let sut: ExamListViewModel
        private(set) var received: [ExamListViewModel.Output] = []
        private let inputSubject = PassthroughSubject<ExamListViewModel.Input, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(service: any ExamService) {
            self.sut = ExamListViewModel(examService: service)
            sut.transform(input: inputSubject.eraseToAnyPublisher())
                .sink { [weak self] in self?.received.append($0) }
                .store(in: &cancellables)
        }

        func send(_ input: ExamListViewModel.Input) {
            inputSubject.send(input)
        }

        func sendViewDidLoad() async throws {
            inputSubject.send(.viewDidLoad)
            try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        }

        func resetReceived() { received.removeAll() }

        var visibilityOutputs: [Bool] {
            received.compactMap {
                if case .setFilterItemsVisibility(let v) = $0 { return v }
                return nil
            }
        }

        var filterOutputs: [ExamListFilterType] {
            received.compactMap {
                if case .selectFilterItem(let type) = $0 { return type }
                return nil
            }
        }

        var collectionViewItems: [[ExamListDataInfo]] {
            received.compactMap {
                if case .setCollectionViewItem(let list) = $0 { return list }
                return nil
            }
        }
    }

    // MARK: - Factory

    private func makeService(
        result: Result<[ExamListDataInfo], Error> = .success([])
    ) -> MockExamService {
        let service = MockExamService()
        service.getExamListResult = result.map { data in
            ExamListResponse(code: 1, msg: "ok", data: data)
        }
        return service
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad 성공 → setCollectionViewItem + selectFilterItem(.total) 순서로 emit")
    func viewDidLoad_success_emitsCollectionViewItemAndFilter() async throws {
        let items = MockExamService.makeExamList(count: 3)
        let h = TestHarness(service: makeService(result: .success(items)))
        try await h.sendViewDidLoad()

        #expect(h.received.count == 2)
        guard case .setCollectionViewItem(let examList) = h.received[0] else {
            Issue.record("Expected .setCollectionViewItem first, got \(h.received[0])")
            return
        }
        #expect(examList.count == 3)
        guard case .selectFilterItem(let filterType) = h.received[1] else {
            Issue.record("Expected .selectFilterItem second, got \(h.received[1])")
            return
        }
        #expect(filterType == .total)
    }

    @Test("viewDidLoad 실패 → fetchFailed emit")
    func viewDidLoad_failure_emitsFetchFailed() async throws {
        let h = TestHarness(service: makeService(result: .failure(URLError(.notConnectedToInternet))))
        try await h.sendViewDidLoad()

        #expect(h.received.count == 1)
        guard case .fetchFailed = h.received.first else {
            Issue.record("Expected .fetchFailed, got \(h.received)")
            return
        }
    }

    // MARK: - reloadList

    @Test("reloadList → selectFilterItem(.total) 즉시 emit 후 fetch 결과 emit")
    func reloadList_resetsFilterAndFetches() async throws {
        let h = TestHarness(service: makeService())
        try await h.sendViewDidLoad()
        // 필터를 .completed로 변경한 뒤 완전히 격리
        h.send(.filterItemSelected(filterType: .completed))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        h.resetReceived()

        h.send(.reloadList)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        // reloadList는 즉시 .selectFilterItem(.total)을 보내고, fetchData 완료 후 .setCollectionViewItem + .selectFilterItem(.total)을 보냄
        #expect(h.filterOutputs.first == .total)
        #expect(!h.collectionViewItems.isEmpty)
    }

    // MARK: - filterButtonClicked

    @Test("filterButtonClicked 첫 번째 → setFilterItemsVisibility(isVisible: true)")
    func filterButtonClicked_first_showsFilter() {
        let h = TestHarness(service: makeService())
        h.send(.filterButtonClicked)

        #expect(h.visibilityOutputs == [true])
    }

    @Test("filterButtonClicked 두 번 → true → false 토글")
    func filterButtonClicked_twice_togglesFilter() {
        let h = TestHarness(service: makeService())
        h.send(.filterButtonClicked)
        h.send(.filterButtonClicked)

        #expect(h.visibilityOutputs == [true, false])
    }

    // MARK: - filterItemSelected

    @Test("filterItemSelected 다른 필터 → setFilterItemsVisibility(false) + fetch 결과 emit")
    func filterItemSelected_differentFilter_hidesAndFetches() async throws {
        let items = MockExamService.makeExamList(count: 2)
        let h = TestHarness(service: makeService(result: .success(items)))
        try await h.sendViewDidLoad()
        h.resetReceived()

        h.send(.filterItemSelected(filterType: .incomplete))
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(h.visibilityOutputs.contains(false))
        guard let fetched = h.collectionViewItems.first else {
            Issue.record("Expected .setCollectionViewItem, got \(h.received)")
            return
        }
        #expect(fetched.count == 2)
        #expect(h.filterOutputs.contains(.incomplete))
    }

    @Test("filterItemSelected 동일 필터 → 아무것도 emit 안 함")
    func filterItemSelected_sameFilter_emitsNothing() {
        let h = TestHarness(service: makeService())
        h.send(.filterItemSelected(filterType: .total))

        #expect(h.received.isEmpty)
    }

    // MARK: - otherAreaClicked

    @Test("otherAreaClicked — 필터 열려있을 때 → setFilterItemsVisibility(false) emit")
    func otherAreaClicked_whenFilterVisible_hidesFilter() {
        let h = TestHarness(service: makeService())
        h.send(.filterButtonClicked)
        h.resetReceived()

        h.send(.otherAreaClicked)

        #expect(h.visibilityOutputs == [false])
    }

    @Test("otherAreaClicked — 필터 닫혀있을 때 → 아무것도 emit 안 함")
    func otherAreaClicked_whenFilterHidden_emitsNothing() {
        let h = TestHarness(service: makeService())
        h.send(.otherAreaClicked)

        #expect(h.received.isEmpty)
    }

    // MARK: - cancelButtonClicked

    @Test("cancelButtonClicked → cancelExamListView emit")
    func cancelButtonClicked_emitsCancelExamListView() {
        let h = TestHarness(service: makeService())
        h.send(.cancelButtonClicked)

        #expect(h.received.count == 1)
        guard case .cancelExamListView = h.received.first else {
            Issue.record("Expected .cancelExamListView, got \(h.received)")
            return
        }
    }

    // MARK: - examClicked

    @Test("examClicked → moveToExamView(examId:) emit")
    func examClicked_emitsMoveToExamView() {
        let h = TestHarness(service: makeService())
        h.send(.examClicked(examId: 42))

        #expect(h.received.count == 1)
        guard case .moveToExamView(let examId) = h.received.first else {
            Issue.record("Expected .moveToExamView, got \(h.received)")
            return
        }
        #expect(examId == 42)
    }
}
