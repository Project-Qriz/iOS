//
//  PreviewResultViewModel.swift
//  QRIZ
//
//  Created by ch on 12/28/24.
//

import Foundation
import Combine

final class PreviewResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case toHomeButtonClicked
    }
    
    enum Output {
        case fetchFailed
        case moveToGreetingView
    }
    
    // MARK: - Properties
    var previewScoresData = ResultScoresData()
    var previewConceptsData = PreviewConceptsData()
    private var incorrectCountDataArr: [IncorrectCountData] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let onboardingService: OnboardingService
    
    // MARK: - Intializers
    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                analyzePreviewResult()
            case .toHomeButtonClicked:
                output.send(.moveToGreetingView)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func analyzePreviewResult() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await onboardingService.analyzePreview()
                updateData(response.data)
            } catch {
                output.send(.fetchFailed)
            }
        }
    }
    
    private func updateData(_ data: AnalyzePreviewResponse.DataInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            previewScoresData.nickname = UserInfoManager.shared.name
            self.previewScoresData.expectScore = data.estimatedScore
            
            if data.topConceptsToImprove.count >= 2 {
                previewConceptsData.firstConcept = data.topConceptsToImprove[0]
                previewConceptsData.secondConcept = data.topConceptsToImprove[1]
            }
            
            previewConceptsData.totalQuestions = data.weakAreaAnalysis.totalQuestions
        }
        
        updateScoreData(data)
        updateIncorrectArr(data)
    }
    
    private func updateScoreData(_ data: AnalyzePreviewResponse.DataInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            previewScoresData.subjectScores[0] = CGFloat(data.scoreBreakdown.part1Score)
            previewScoresData.subjectScores[1] = CGFloat(data.scoreBreakdown.part2Score)
            previewScoresData.subjectCount = 2
        }
    }
    
    private func updateIncorrectArr(_ data: AnalyzePreviewResponse.DataInfo) {
        updateLocIncorrectArr(data)
        updateConceptIncorrectArr()
    }
    
    private func updateLocIncorrectArr(_ data: AnalyzePreviewResponse.DataInfo) {
        var dic: [Int: [String]] = [:]
        
        data.weakAreaAnalysis.weakAreas.forEach { item in
            if let _ = dic[item.incorrectCount] {
                dic[item.incorrectCount]?.append(item.topic)
            } else {
                dic[item.incorrectCount] = [item.topic]
            }
        }
        
        dic.sorted { lhs, rhs in
            lhs.key > rhs.key
        }.enumerated().forEach { [weak self] idx, item in
            guard let self = self else { return }
            self.incorrectCountDataArr.append(
                IncorrectCountData(id: idx + 1,
                                   incorrectCount: item.key,
                                   topic: item.value))
        }
    }
    
    private func updateConceptIncorrectArr() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewConceptsData.numOfChartToPresent = self.incorrectCountDataArr.count
            self.previewConceptsData.initAnimationChart()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.previewConceptsData.incorrectCountDataArr = self.incorrectCountDataArr
            }
        }
    }
}
