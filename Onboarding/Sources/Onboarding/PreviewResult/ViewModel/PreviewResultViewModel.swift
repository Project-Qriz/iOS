import Foundation
import Combine
import QRIZUtils
import Network

@MainActor
final class PreviewResultViewModel: ObservableObject {
    let previewScoresData = ResultScoresData()
    let previewConceptsData = PreviewConceptsData()
    @Published var errorMessage: String? = nil

    var onNavigateToGreeting: (() -> Void)?

    private let onboardingService: OnboardingService
    private var incorrectCountDataArr: [IncorrectCountData] = []

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    func onViewDidLoad() {
        Task { await fetchResult() }
    }

    func didTapClose() {
        onNavigateToGreeting?()
    }

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

        previewScoresData.subjectScores[0] = Double(data.scoreBreakdown.part1Score)
        previewScoresData.subjectScores[1] = Double(data.scoreBreakdown.part2Score)
        previewScoresData.subjectCount = 2

        updateIncorrectArr(data)
    }

    private func updateIncorrectArr(_ data: AnalyzePreviewResponse.DataInfo) {
        var dic: [Int: [String]] = [:]
        data.weakAreaAnalysis.weakAreas.forEach { item in
            if dic[item.incorrectCount] != nil {
                dic[item.incorrectCount]?.append(item.topic)
            } else {
                dic[item.incorrectCount] = [item.topic]
            }
        }

        dic.sorted { $0.key > $1.key }.enumerated().forEach { idx, item in
            incorrectCountDataArr.append(IncorrectCountData(id: idx + 1, incorrectCount: item.key, topic: item.value))
        }

        previewConceptsData.numOfChartToPresent = incorrectCountDataArr.count
        previewConceptsData.initAnimationChart()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.previewConceptsData.incorrectCountDataArr = self?.incorrectCountDataArr ?? []
        }
    }
}
