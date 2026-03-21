import Testing
import Foundation
import QRIZUtils
@testable import Onboarding

@MainActor
@Suite("PreviewResultViewModel 테스트", .serialized)
struct PreviewResultViewModelTests {

    private func makeSUT(
        service: MockOnboardingService = .init(),
        onNavigateToGreeting: @escaping () -> Void = {}
    ) -> PreviewResultViewModel {
        PreviewResultViewModel(
            onboardingService: service,
            onNavigateToGreeting: onNavigateToGreeting
        )
    }

    // MARK: - analyzePreview 성공

    @Test("onViewDidLoad: analyzePreview 성공 → expectScore 세팅")
    func onViewDidLoad_onSuccess_setsExpectScore() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(.stub(estimatedScore: 84.5))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewScoresData.expectScore == 84.5)
    }

    @Test("onViewDidLoad: analyzePreview 성공 → subjectScores[0], subjectScores[1] 세팅")
    func onViewDidLoad_onSuccess_setsSubjectScores() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(.stub(part1Score: 45, part2Score: 38))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewScoresData.subjectScores[0] == 45)
        #expect(sut.previewScoresData.subjectScores[1] == 38)
        #expect(sut.previewScoresData.subjectCount == 2)
    }

    @Test("onViewDidLoad: analyzePreview 성공 → firstConcept, secondConcept 세팅")
    func onViewDidLoad_onSuccess_setsConcepts() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .success(
            .stub(topConceptsToImprove: ["SQL 기본", "SELECT문"])
        )
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.previewConceptsData.firstConcept == "SQL 기본")
        #expect(sut.previewConceptsData.secondConcept == "SELECT문")
    }

    // MARK: - analyzePreview 실패

    @Test("onViewDidLoad: analyzePreview 실패 → errorMessage 세팅")
    func onViewDidLoad_onFailure_setsErrorMessage() async {
        let service = MockOnboardingService()
        service.analyzePreviewResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)

        sut.onViewDidLoad()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.errorMessage != nil)
    }

    // MARK: - didTapClose

    @Test("didTapClose: onNavigateToGreeting 호출")
    func didTapClose_callsOnNavigateToGreeting() {
        var navigateCalled = false
        let sut = makeSUT(onNavigateToGreeting: { navigateCalled = true })

        sut.didTapClose()

        #expect(navigateCalled)
    }
}
