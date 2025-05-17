//
//  DailyResultViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine

final  class DailyResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case cancelButtonClicked
        case moveToConceptButtonClicked
        case resultDetailButtonClicked
    }
    
    enum Output {
        case fetchFailed
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
        fetchResult()
        updateData()
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
    
    private func fetchResult() {
        Task {
            do {
                if dailyTestType == .weekly {
                    try await fetchWeeklyResult()
                } else {
                    try await fetchDailyAndComprehensiveResult()
                }
            } catch {
                output.send(.fetchFailed)
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
    
//    private func fetchMockData() {
//        self.subjectScores[0] = 30
//        self.subjectScores[1] = 20
//        self.subjectScores[2] = 15
//        self.subjectScores[3] = 15
//        self.subjectScores[4] = 10
//        self.subjectCount = 5
//        self.passed = true
//        
//        self.gradeResultList.append(GradeResult(id: 1,
//                                                skillName: "조인",
//                                                question: """
//                                                아래 테이블 T<S<R이 각각 다음과 같이 선언되었다. 
//                                                다음 중 DELETE FROM T;를 수행한 후에 테이블 R에 남아있는 데이터로 가장 적절한 것은?
//                                                """,
//                                                correction: false))
//        self.gradeResultList.append(GradeResult(id: 2, skillName: "SELECT 문", question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?", correction: true))
//        self.gradeResultList.append(GradeResult(id: 3, skillName: "조인", question: "다음과 같은 테이블 구조에서 가장 적절한 조인 방식은?", correction: true))
//        self.gradeResultList.append(GradeResult(id: 4, skillName: "조인", question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?", correction: false))
//        self.gradeResultList.append(GradeResult(id: 5, skillName: "조인", question: "다음 두 쿼리의 결과가 다른 경우는?", correction: true))
//        self.gradeResultList.append(GradeResult(id: 6, skillName: "조인", question: "다음 SQL문들의 실행 결과가 같은 것을 고르시오.", correction: true))
//        self.gradeResultList.append(GradeResult(id: 7, skillName: "SELECT 문", question: "다음 중 SELF JOIN에 대한 설명으로 가장 부적절한 것은?", correction: false))
//        
//        self.subject2DetailResult.append(SubjectDetailData(majorItem: "SQL 기본", score: 40, minorItems: [SubjectDetailMinorItem("SELECT문", 20), SubjectDetailMinorItem("함수", 10), SubjectDetailMinorItem("WHERE절", 10)]))
//        self.subject2DetailResult.append(SubjectDetailData(majorItem: "SQL 활용", score: 20, minorItems: [SubjectDetailMinorItem("서브쿼리", 10), SubjectDetailMinorItem("집합 연산자", 10)]))
//        self.subject1DetailResult.append(SubjectDetailData(majorItem: "데이터 모델링의 이해", score: 10, minorItems: [SubjectDetailMinorItem("TCL", 5), SubjectDetailMinorItem("DDL", 5)]))
//    }
}
