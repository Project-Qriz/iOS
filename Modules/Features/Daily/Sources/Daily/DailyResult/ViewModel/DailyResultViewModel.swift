//
//  DailyResultViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import QRIZUtils
import Network

@MainActor
protocol DailyResultViewModelDelegate: AnyObject {
    func didRequestQuitDaily()
    func didRequestMoveToConcept()
    func didRequestShowResultDetail(_ data: ResultDetailData)
    func didRequestShowProblemDetail(questionId: Int)
}

@MainActor
final class DailyResultViewModel: ObservableObject {
    
    // MARK: - Enums
    
    private enum SubjectTitle: String {
        case subject1 = "1과목"
        case subject2 = "2과목"
    }
    
    // MARK: - Published
    
    @Published var errorMessage: String?
    
    // MARK: - Observable Data
    
    let resultScoresData = ResultScoresData()
    let resultGradeListData = ResultGradeListData()
    let resultDetailData = ResultDetailData()
    
    // MARK: - Properties
    
    let dailyTestType: DailyLearnType
    weak var delegate: (any DailyResultViewModelDelegate)?

    private var fetchTask: Task<Void, Never>?
    private var subjectScores: [Double] = []
    private var subjectCount = 0
    private var gradeResultList: [GradeResult] = []
    private var subject1DetailResult: [SubjectDetailData] = []
    private var subject2DetailResult: [SubjectDetailData] = []
    private var passed = false
    private var numOfDataToPresent = 0
    private let nickname = UserInfoManager.shared.name
    private let day: Int
    private var dayNum: String { "DAY \(day)" }
    private let dailyService: DailyService

    // MARK: - Initialization

    init(dailyTestType: DailyLearnType, day: Int, dailyService: DailyService) {
        self.dailyTestType = dailyTestType
        self.day = day
        self.dailyService = dailyService
    }
    
    // MARK: - Methods

    func onViewDidLoad() {
        fetchTask?.cancel()
        resetFetchState()
        fetchTask = Task { await fetchData() }
    }
    
    func didTapCancel() {
        delegate?.didRequestQuitDaily()
    }

    func didTapResultDetail() {
        // View에서 .weekly 조건부 렌더링으로 이미 제어하지만 방어적으로 재검증
        guard dailyTestType == .weekly else { return }
        delegate?.didRequestShowResultDetail(resultDetailData)
    }

    func didTapConcept() {
        delegate?.didRequestMoveToConcept()
    }

    func didTapProblem(questionId: Int) {
        delegate?.didRequestShowProblemDetail(questionId: questionId)
    }
    
    // MARK: - Private

    private func resetFetchState() {
        subjectScores = []
        subjectCount = 0
        gradeResultList = []
        subject1DetailResult = []
        subject2DetailResult = []
        passed = false
        numOfDataToPresent = 0
    }

    private func fetchData() async {
        do {
            if dailyTestType == .weekly {
                try await fetchWeeklyResult()
            } else {
                try await fetchDailyAndComprehensiveResult()
            }
            updateData()
        } catch NetworkError.serverError {
            errorMessage = "관리자에게 문의하세요."
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
    
    private func updateData() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self else { return }
            self.resultScoresData.nickname = self.nickname
            self.resultScoresData.subjectCount = self.subjectCount
            self.resultScoresData.passed = self.passed
            self.resultScoresData.dayNum = self.dayNum
            
            self.resultGradeListData.gradeResultList = self.gradeResultList
            
            self.resultDetailData.subject1DetailResult = self.subject1DetailResult
            self.resultDetailData.subject2DetailResult = self.subject2DetailResult
            self.resultDetailData.numOfDataToPresent = self.numOfDataToPresent
            
            zip(self.resultScoresData.subjectScores.indices, self.subjectScores).forEach { index, score in
                self.resultScoresData.subjectScores[index] = score
            }
        }
    }
    
    private func fetchDailyAndComprehensiveResult() async throws {
        let response = try await dailyService.getDailyTestResult(dayNumber: day)
        let items = response.data.items
        subjectCount = items.count
        numOfDataToPresent = items.count
        for i in 0..<subjectCount {
            subjectScores.append(items[i].score)
            subject1DetailResult.append(SubjectDetailData(
                majorItem: SurveyCheckList.list[items[i].skillId - 1],
                score: items[i].score,
                minorItems: []
            ))
        }
        addSubjectScoresPadding()
        passed = response.data.passed
        updateSubjectList(subjectResultList: response.data.subjectResultsList)
    }
    
    private func fetchWeeklyResult() async throws {
        let scoreResponse = try await dailyService.getDailyWeeklyScore(dayNumber: day)
        let scoreData = scoreResponse.data
        subjectCount = scoreData.subjects.reduce(0) { $0 + $1.majorItems.count }
        numOfDataToPresent = subjectCount
        
        try scoreData.subjects.forEach {
            switch $0.title {
            case SubjectTitle.subject1.rawValue:
                $0.majorItems.forEach { item in
                    subject1DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores.map { $0.toEntity() }))
                    subjectScores.append(item.score)
                }
            case SubjectTitle.subject2.rawValue:
                $0.majorItems.forEach { item in
                    subject2DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores.map { $0.toEntity() }))
                    subjectScores.append(item.score)
                }
            default:
                throw NetworkError.unknownError
            }
        }
        
        addSubjectScoresPadding()
        let resultResponse = try await dailyService.getDailyTestResult(dayNumber: day)
        passed = resultResponse.data.passed
        updateSubjectList(subjectResultList: resultResponse.data.subjectResultsList)
    }
    
    private func addSubjectScoresPadding() {
        if subjectCount < 5 {
            for _ in 0..<(5 - subjectCount) {
                subjectScores.append(0)
            }
        }
    }
    
    private func updateSubjectList(subjectResultList: [SubjectResult]) {
        subjectResultList.enumerated().forEach {
            gradeResultList.append(GradeResult(
                id: $0 + 1,
                questionId: $1.questionId,
                skillName: $1.detailType,
                question: $1.question,
                correction: $1.correction
            ))
        }
    }
}
