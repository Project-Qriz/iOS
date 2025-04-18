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
        case viewDidAppear
        case cancelButtonClicked
        case moveToConceptButtonClicked
    }
    
    enum Output {
        case moveToDailyLearn
        case moveToConcept
    }
    
    // MARK: - Properties
    var dailyTestType: DailyLearnType
    private var nickname: String = ""
    private var subjectScores: [CGFloat] = [0, 0, 0, 0, 0]
    private var subjectCount: Int = 0
    private var gradeResultList: [GradeResult] = []
    private var passed: Bool = false
    private var dayNum: String = ""

    var resultScoresData = ResultScoresData()
    var resultGradeListData = ResultGradeListData()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(dailyTestType: DailyLearnType) {
        self.dailyTestType = dailyTestType
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .viewDidAppear:
                updateAnimationData()
            case .cancelButtonClicked:
                output.send(.moveToDailyLearn)
            case .moveToConceptButtonClicked:
                output.send(.moveToConcept)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        fetchMockData()
        updateData()
    }
    
    private func updateData() {
        resultScoresData.nickname = self.nickname
        resultScoresData.subjectCount = self.subjectCount
        resultScoresData.passed = self.passed
        resultScoresData.dayNum = self.dayNum
        resultGradeListData.gradeResultList = self.gradeResultList
    }
    
    private func updateAnimationData() {
        for i in 0...4 {
            resultScoresData.subjectScores[i] = self.subjectScores[i]
        }
    }
    
    private func fetchMockData() {
        self.nickname = "채영"
        self.subjectScores[0] = 30
        self.subjectScores[1] = 20
        self.subjectScores[2] = 15
        self.subjectScores[3] = 15
        self.subjectScores[4] = 10
        self.subjectCount = 5
        self.passed = true
        self.dayNum = "Day1".uppercased()
        
        self.gradeResultList.append(GradeResult(id: 1,
                                                skillName: "조인",
                                                question: """
                                                아래 테이블 T<S<R이 각각 다음과 같이 선언되었다. 
                                                다음 중 DELETE FROM T;를 수행한 후에 테이블 R에 남아있는 데이터로 가장 적절한 것은?
                                                """,
                                                correction: false))
        self.gradeResultList.append(GradeResult(id: 2, skillName: "SELECT 문", question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?", correction: true))
        self.gradeResultList.append(GradeResult(id: 3, skillName: "조인", question: "다음과 같은 테이블 구조에서 가장 적절한 조인 방식은?", correction: true))
        self.gradeResultList.append(GradeResult(id: 4, skillName: "조인", question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?", correction: false))
        self.gradeResultList.append(GradeResult(id: 5, skillName: "조인", question: "다음 두 쿼리의 결과가 다른 경우는?", correction: true))
        self.gradeResultList.append(GradeResult(id: 6, skillName: "조인", question: "다음 SQL문들의 실행 결과가 같은 것을 고르시오.", correction: true))
        self.gradeResultList.append(GradeResult(id: 7, skillName: "SELECT 문", question: "다음 중 SELF JOIN에 대한 설명으로 가장 부적절한 것은?", correction: false))
    }
}
