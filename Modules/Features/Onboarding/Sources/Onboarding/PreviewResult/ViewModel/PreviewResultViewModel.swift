import Foundation
import QRIZUtils
import Network

@MainActor
final class PreviewResultViewModel: ObservableObject {

    // MARK: - Properties

    let previewScoresData = ResultScoresData()
    let previewConceptsData = PreviewConceptsData()
    @Published var errorMessage: String?

    private let onNavigateToGreeting: () -> Void
    private let onboardingService: OnboardingService
    private var incorrectCountDataArr: [IncorrectCountData] = []

    // MARK: - Initializer

    init(onboardingService: OnboardingService, onNavigateToGreeting: @escaping () -> Void) {
        self.onboardingService = onboardingService
        self.onNavigateToGreeting = onNavigateToGreeting
    }

    // MARK: - Methods

    func onViewDidLoad() {
        Task { await fetchResult() }
    }

    func didTapClose() {
        onNavigateToGreeting()
    }

    // MARK: - Private

    private func fetchResult() async {
        do {
            let response = try await onboardingService.analyzePreview()
            updateData(response.data)
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func updateData(_ data: AnalyzePreviewResponse.DataInfo) {
        previewScoresData.nickname = UserInfoManager.shared.name
        previewScoresData.expectScore = data.estimatedScore

        if data.topConceptsToImprove.count >= 2 {
            previewConceptsData.firstConcept = data.topConceptsToImprove[0]
            previewConceptsData.secondConcept = data.topConceptsToImprove[1]
        }
        previewConceptsData.totalQuestions = data.weakAreaAnalysis.totalQuestions

        guard previewScoresData.subjectScores.count >= 2 else { return }
        previewScoresData.subjectScores[0] = Double(data.scoreBreakdown.part1Score)
        previewScoresData.subjectScores[1] = Double(data.scoreBreakdown.part2Score)
        previewScoresData.subjectCount = 2

        updateIncorrectArr(data)
    }

    private func updateIncorrectArr(_ data: AnalyzePreviewResponse.DataInfo) {
        let grouped = Dictionary(grouping: data.weakAreaAnalysis.weakAreas, by: \.incorrectCount)
            .mapValues { $0.map(\.topic) }

        incorrectCountDataArr = grouped
            .sorted { $0.key > $1.key }
            .enumerated()
            .map { idx, item in IncorrectCountData(id: idx + 1, incorrectCount: item.key, topic: item.value) }

        previewConceptsData.numOfChartToPresent = incorrectCountDataArr.count
        previewConceptsData.initAnimationChart()

        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled, let self else { return }
            self.previewConceptsData.incorrectCountDataArr = self.incorrectCountDataArr
        }
    }
}
