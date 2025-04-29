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
        case viewDidAppear
        case toHomeButtonClicked
    }
    
    enum Output {
        case fetchFailed
        case moveToGreetingView
    }
    
    // MARK: - Properties
    var previewScoresData = ResultScoresData()
    var previewConceptsData = PreviewConceptsData()
    private var subjectScores: [CGFloat] = [0, 0, 0, 0, 0]
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
            case .viewDidAppear:
                animateScoreData()
                animateConceptData()
                
            case .toHomeButtonClicked:
                output.send(.moveToGreetingView)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func analyzePreviewResult() {
        Task {
            do {
                let response = try await onboardingService.analyzePreview()
                setChartLayout(response.data)
                updateData(response.data)
            } catch {
                output.send(.fetchFailed)
            }
        }
    }
    
    private func updateData(_ data: AnalyzePreviewResponse.DataInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            previewScoresData.nickname = UserInfoManager.name
            self.previewScoresData.expectScore = data.estimatedScore
            
            if data.topConceptsToImprove.count >= 2 {
                previewConceptsData.firstConcept = data.topConceptsToImprove[0]
                previewConceptsData.secondConcept = data.topConceptsToImprove[1]
            }
            
            previewConceptsData.totalQuestions = data.weakAreaAnalysis.totalQuestions
        }
        
        updateScoreData(data)
        updateConceptData(data)
    }
    
    private func updateScoreData(_ data: AnalyzePreviewResponse.DataInfo) {
        subjectScores[0] = CGFloat(data.scoreBreakdown.part1Score)
        subjectScores[1] = CGFloat(data.scoreBreakdown.part2Score)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewScoresData.subjectCount = 2
        }
    }
    
    private func animateScoreData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewScoresData.subjectScores[0] = self.subjectScores[0]
            self.previewScoresData.subjectScores[1] = self.subjectScores[1]
        }
    }
    
    private func updateConceptData(_ data: AnalyzePreviewResponse.DataInfo) {
        for i in 0..<previewConceptsData.numOfTotalConcept {
            incorrectCountDataArr.append(IncorrectCountData(
                id: i,
                incorrectCount: data.weakAreaAnalysis.weakAreas[i].incorrectCount,
                topic: [data.weakAreaAnalysis.weakAreas[i].topic]))
        }
    }
    
    private func animateConceptData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewConceptsData.incorrectCountDataArr = self.incorrectCountDataArr
        }
    }
    
    private func setChartLayout(_ data: AnalyzePreviewResponse.DataInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewConceptsData.numOfTotalConcept = data.weakAreaAnalysis.weakAreas.count
            self.previewConceptsData.initAnimationChart(numOfCharts: self.previewConceptsData.numOfTotalConcept)
        }
    }
}
