//
//  DailyResultViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine

final class DailyResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case cancelButtonClicked
        case moveToConceptButtonClicked
        case resultDetailButtonClicked
    }
    
    enum Output {
        case fetchFailed(isServerError: Bool)
        case moveToDailyLearn
        case moveToConcept
        case moveToResultDetail
    }
    
    // MARK: - Properties
    private var subjectScores: [CGFloat] = []
    private var subjectCount: Int = 0
    private var gradeResultList: [GradeResult] = []
    private var subject1DetailResult: [SubjectDetailData] = []
    private var subject2DetailResult: [SubjectDetailData] = []
    private var passed: Bool = false
    private var numOfDataToPresent: Int = 0
    private let nickname: String = UserInfoManager.name
    private let day: Int
    let dailyTestType: DailyLearnType
    private var dayNum: String {
        "DAY \(day)"
    }

    var resultScoresData = ResultScoresData()
    var resultGradeListData = ResultGradeListData()
    var resultDetailData = ResultDetailData()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let dailyService: DailyService
    
    // MARK: - Initializers
    init(dailyTestType: DailyLearnType, day: Int, dailyService: DailyService) {
        self.dailyTestType = dailyTestType
        self.day = day
        self.dailyService = dailyService
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .cancelButtonClicked:
                output.send(.moveToDailyLearn)
            case .moveToConceptButtonClicked:
                output.send(.moveToConcept)
            case .resultDetailButtonClicked:
                if dailyTestType == .weekly {
                    output.send(.moveToResultDetail)
                }
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task {
            do {
                if dailyTestType == .weekly {
                    try await fetchWeeklyResult()
                } else {
                    try await fetchDailyAndComprehensiveResult()
                }
                updateData()
            } catch NetworkError.serverError {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func updateData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { [weak self] in
            guard let self = self else { return }
            self.resultScoresData.nickname = self.nickname
            self.resultScoresData.subjectCount = self.subjectCount
            self.resultScoresData.passed = self.passed
            self.resultScoresData.dayNum = self.dayNum
            
            self.resultGradeListData.gradeResultList = self.gradeResultList
            
            self.resultDetailData.subject1DetailResult = self.subject1DetailResult
            self.resultDetailData.subject2DetailResult = self.subject2DetailResult
            self.resultDetailData.numOfDataToPresent = self.numOfDataToPresent
            
            for i in 0...4 {
                self.resultScoresData.subjectScores[i] = self.subjectScores[i]
            }
        }
    }
    
    private func fetchDailyAndComprehensiveResult() async throws {
        let response = try await dailyService.getDailyTestResult(dayNumber: day)
        let items = response.data.items
        self.subjectCount = items.count
        self.numOfDataToPresent = items.count
        for i in 0..<subjectCount {
            self.subjectScores.append(items[i].score)
            self.subject1DetailResult.append(SubjectDetailData(
                majorItem: SurveyCheckList.list[items[i].skillId - 1],
                score: items[i].score,
                minorItems: []))
        }
        addSubjectScoresPadding()
        self.passed = response.data.passed
        updateSubjectList(subjectResultList: response.data.subjectResultsList)
    }
    
    private func fetchWeeklyResult() async throws {
        let scoreResponse = try await dailyService.getDailyWeeklyScore(dayNumber: day)
        let scoreData = scoreResponse.data
        self.subjectCount = scoreData.subjects.reduce(0, {
            $0 + $1.majorItems.count
        })
        self.numOfDataToPresent = subjectCount
        
        try scoreData.subjects.forEach {
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
                print("Received Unknown Title for WeeklyScore")
                throw NetworkError.unknownError
            }
        }
        
        addSubjectScoresPadding()
        let resultResponse = try await dailyService.getDailyTestResult(dayNumber: day)
        self.passed = resultResponse.data.passed
        updateSubjectList(subjectResultList: resultResponse.data.subjectResultsList)
    }
    
    private func addSubjectScoresPadding() {
        if subjectCount < 5 {
            for _ in 0..<(5 - subjectCount) {
                self.subjectScores.append(0)
            }
        }
    }
    
    private func updateSubjectList(subjectResultList: [SubjectResult]) {
        subjectResultList.enumerated().forEach { [weak self] in
            guard let self = self else { return }
            self.gradeResultList.append(GradeResult(id: $0 + 1, skillName: $1.detailType, question: $1.question, correction: $1.correction))
        }
    }
}
