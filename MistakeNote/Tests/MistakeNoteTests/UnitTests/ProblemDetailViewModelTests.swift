// MistakeNote/Tests/MistakeNoteTests/UnitTests/ProblemDetailViewModelTests.swift

import Testing
import Foundation
@testable import MistakeNote
import QRIZUtils

@MainActor
@Suite("ProblemDetailViewModel 테스트", .serialized)
struct ProblemDetailViewModelTests {

    private func makeSUT(
        fetchResult: Result<DailyResultDetailEntity, Error> = .success(.make())
    ) -> ProblemDetailViewModel {
        ProblemDetailViewModel {
            try fetchResult.get()
        }
    }

    // MARK: - 내비게이션

    @Test("learnButtonTapped() → onNavigate(.navigateToConceptTab)")
    func learnButtonTapped_triggersNavigateToConceptTab() {
        let sut = makeSUT()
        var output: ProblemDetailViewModel.Output?
        sut.onNavigate = { output = $0 }

        sut.learnButtonTapped()

        if case .navigateToConceptTab = output {
            // pass
        } else {
            Issue.record("Expected navigateToConceptTab")
        }
    }

    @Test("존재하는 concept tap → navigateToConceptDetail")
    func conceptTapped_existingConcept_triggersNavigateToConceptDetail() {
        let sut = makeSUT()
        var output: ProblemDetailViewModel.Output?
        sut.onNavigate = { output = $0 }

        let existingConcept = Chapter.allCases[0].conceptItems[0].title
        sut.conceptTapped(concept: existingConcept)

        if case .navigateToConceptDetail = output {
            // pass
        } else {
            Issue.record("Expected navigateToConceptDetail for concept: \(existingConcept)")
        }
    }

    @Test("존재하지 않는 concept tap → onNavigate 미호출")
    func conceptTapped_unknownConcept_doesNotTriggerNavigate() {
        let sut = makeSUT()
        var navigateCalled = false
        sut.onNavigate = { _ in navigateCalled = true }

        sut.conceptTapped(concept: "존재하지않는개념XYZ")

        #expect(navigateCalled == false)
    }

    // MARK: - 비동기 로딩

    @Test("viewDidLoad() 성공 → problemDetail 설정")
    func viewDidLoad_setsProblemDetail() async {
        let entity = DailyResultDetailEntity.make(questionText: "실제 문제")
        let sut = makeSUT(fetchResult: .success(entity))

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.problemDetail?.questionText == "실제 문제")
        #expect(!sut.isLoading)
    }

    @Test("viewDidLoad() 실패 → errorMessage 설정")
    func viewDidLoad_setsErrorMessage_onFailure() async {
        let sut = makeSUT(fetchResult: .failure(URLError(.notConnectedToInternet)))

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
        #expect(!sut.isLoading)
    }

    @Test("retry() 호출 후 성공 → problemDetail 설정")
    func retry_afterFailure_setsProblemDetail() async {
        var callCount = 0
        let sut = ProblemDetailViewModel {
            callCount += 1
            if callCount == 1 { throw URLError(.notConnectedToInternet) }
            return .make(questionText: "재시도 성공")
        }

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        #expect(sut.errorMessage != nil)

        sut.retry()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.problemDetail?.questionText == "재시도 성공")
        #expect(sut.errorMessage == nil)
    }
}
