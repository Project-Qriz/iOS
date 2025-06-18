//
//  ExamResultViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import Foundation
import Combine

final class ExamResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case cancelButtonClicked
        case moveToConceptButtonClicked
        case resultDetailButtonClicked
    }
    
    enum Output {
        case fetchFailed(isServerError: Bool)
        case moveToExamList
        case moveToConcept
        case moveToResultDetail
    }
    
    // MARK: - Properties
    private var subjectScores: [CGFloat] = []
    private var subjectCount: Int = 0
    private var gradeResultList: [GradeResult] = []
    private var subject1DetailResult: [SubjectDetailData] = []
    private var subject2DetailResult: [SubjectDetailData] = []
    private var historicalScores: [HistoricalScore] = []
    private var numOfDataToPresent: Int = 0
    private var nickname: String {
        UserInfoManager.shared.name
    }
    private let examId: Int
    
    var resultScoresData = ResultScoresData()
    var resultGradeListData = ResultGradeListData()
    var resultDetailData = ResultDetailData()
    var scoreGraphData = ScoreGraphData()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let examService: ExamService
    
    // MARK: - Initializers
    init(examId: Int, examService: ExamService) {
        self.examId = examId
        self.examService = examService
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .cancelButtonClicked:
                output.send(.moveToExamList)
            case .moveToConceptButtonClicked:
                output.send(.moveToConcept)
            case .resultDetailButtonClicked:
                output.send(.moveToResultDetail)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await fetchResultResponse()
                try await fetchScoreResponse()
                updateData()
            } catch NetworkError.serverError {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func fetchResultResponse() async throws {
        let resultResponse = try await examService.getExamResult(examId: examId)
        let data = resultResponse.data
        historicalScores = data.historicalScores
        data.problemResults.enumerated().forEach { [weak self] in
            guard let self = self else { return }
            self.gradeResultList.append(
                GradeResult(id: $0 + 1,
                            skillName: $1.skillName,
                            question: $1.question,
                            correction: $1.correction))
        }
    }
    
    private func fetchScoreResponse() async throws {
        let scoreResponse = try await examService.getExamScore(examId: examId)
        let scoreData = scoreResponse.data
        self.subjectCount = scoreData.reduce(0, {
            $0 + $1.majorItems.count
        })
        self.numOfDataToPresent = subjectCount
        
        try scoreData.forEach {
            switch $0.title {
            case "1과목":
                $0.majorItems.forEach { [weak self] item in
                    guard let self = self else { return }
                    self.subject1DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores))
                    self.subjectScores.append(item.score)
                }
            case "2과목":
                $0.majorItems.forEach { [weak self] item in
                    guard let self = self else { return }
                    self.subject2DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores))
                    self.subjectScores.append(item.score)
                }
            default:
                print("Received Unknown Title for ExamScore")
                throw NetworkError.unknownError
            }
        }
        
        addSubjectScoresPadding()
    }
    
    private func updateData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { [weak self] in
            guard let self = self else { return }
            self.resultScoresData.nickname = self.nickname
            self.resultScoresData.subjectCount = self.subjectCount
            
            self.resultGradeListData.gradeResultList = self.gradeResultList
            
            self.resultDetailData.subject1DetailResult = self.subject1DetailResult
            self.resultDetailData.subject2DetailResult = self.subject2DetailResult
            self.resultDetailData.numOfDataToPresent = self.numOfDataToPresent
            
            for i in 0...4 {
                self.resultScoresData.subjectScores[i] = self.subjectScores[i]
            }
            
            scoreGraphData.convertGraphScoreData(self.historicalScores.sorted())
        }
    }
    
    private func addSubjectScoresPadding() {
        if subjectCount < 5 {
            for _ in 0..<(5 - subjectCount) {
                self.subjectScores.append(0)
            }
        }
    }
}

