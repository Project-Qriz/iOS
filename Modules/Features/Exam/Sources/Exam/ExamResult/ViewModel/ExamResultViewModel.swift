//
//  ExamResultViewModel.swift
//  QRIZ
//

import Foundation
import QRIZUtils
import QRIZNetwork

@MainActor
protocol ExamResultViewModelDelegate: AnyObject {
    func didRequestQuitExam()
    func didRequestMoveToConcept()
    func didRequestMoveToResultDetail()
    func didRequestShowProblemDetail(questionId: Int)
}

@MainActor
final class ExamResultViewModel: ObservableObject {

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
    let scoreGraphData = ScoreGraphData()

    // MARK: - Properties

    weak var delegate: (any ExamResultViewModelDelegate)?

    private var fetchTask: Task<Void, Never>?
    private var subjectScores: [Double] = []
    private var subjectCount = 0
    private var gradeResultList: [GradeResult] = []
    private var subject1DetailResult: [SubjectDetailData] = []
    private var subject2DetailResult: [SubjectDetailData] = []
    private var historicalScores: [HistoricalScoreEntity] = []
    private var numOfDataToPresent = 0
    private let nickname: String
    private let examId: Int
    private let examService: any ExamService
    private let analyticsService: any AnalyticsService

    // MARK: - Initialization

    init(
        examId: Int,
        examService: any ExamService,
        analyticsService: any AnalyticsService = AnalyticsManager.shared,
        userInfo: UserInfoManager
    ) {
        self.nickname = userInfo.name
        self.examId = examId
        self.examService = examService
        self.analyticsService = analyticsService
    }

    // MARK: - Methods

    func onViewDidLoad() {
        fetchTask?.cancel()
        resetFetchState()
        fetchTask = Task { await fetchData() }
    }

    func didTapCancel() {
        delegate?.didRequestQuitExam()
    }

    func didTapConcept() {
        delegate?.didRequestMoveToConcept()
    }

    func didTapResultDetail() {
        delegate?.didRequestMoveToResultDetail()
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
        historicalScores = []
        numOfDataToPresent = 0
    }

    private func fetchData() async {
        do {
            async let fetchResult: Void = fetchResultResponse()
            async let fetchScore: Void = fetchScoreResponse()
            try await fetchResult
            try await fetchScore
            updateData()
        } catch is CancellationError {
            return
        } catch NetworkError.serverError(_) {
            errorMessage = "관리자에게 문의하세요."
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func fetchResultResponse() async throws {
        let response = try await examService.getExamResult(examId: examId)
        let data = response.data
        historicalScores = data.historicalScores.map { $0.toEntity() }
        gradeResultList = data.problemResults.enumerated().map { index, item in
            GradeResult(
                id: index + 1,
                questionId: item.questionId,
                skillName: item.skillName,
                question: item.question,
                correction: item.correction
            )
        }
    }

    private func fetchScoreResponse() async throws {
        let scoreResponse = try await examService.getExamScore(examId: examId)
        let scoreData = scoreResponse.data
        subjectCount = scoreData.reduce(0) { $0 + $1.majorItems.count }
        numOfDataToPresent = subjectCount

        for subject in scoreData {
            switch subject.title {
            case SubjectTitle.subject1.rawValue:
                subject.majorItems.forEach {
                    subject1DetailResult.append(SubjectDetailData(majorItem: $0.majorItem, score: $0.score, minorItems: $0.subItemScores.map { $0.toEntity() }))
                    subjectScores.append($0.score)
                }
            case SubjectTitle.subject2.rawValue:
                subject.majorItems.forEach {
                    subject2DetailResult.append(SubjectDetailData(majorItem: $0.majorItem, score: $0.score, minorItems: $0.subItemScores.map { $0.toEntity() }))
                    subjectScores.append($0.score)
                }
            default:
                throw NetworkError.unknownError
            }
        }

        addSubjectScoresPadding()
    }

    private func updateData() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self else { return }
            self.resultScoresData.nickname = self.nickname
            self.resultScoresData.subjectCount = self.subjectCount

            self.resultGradeListData.gradeResultList = self.gradeResultList
            let score = self.gradeResultList.filter { $0.correction }.count
            self.analyticsService.log(.examComplete(score: score, total: self.gradeResultList.count))

            self.resultDetailData.subject1DetailResult = self.subject1DetailResult
            self.resultDetailData.subject2DetailResult = self.subject2DetailResult
            self.resultDetailData.numOfDataToPresent = self.numOfDataToPresent

            zip(self.resultScoresData.subjectScores.indices, self.subjectScores).forEach { index, score in
                self.resultScoresData.subjectScores[index] = score
            }

            self.scoreGraphData.totalScores = []
            self.scoreGraphData.subject1Scores = []
            self.scoreGraphData.subject2Scores = []
            self.scoreGraphData.indexedSubject1Scores = []
            self.scoreGraphData.indexedSubject2Scores = []
            self.scoreGraphData.convertGraphScoreData(self.historicalScores.sorted())
        }
    }

    private func addSubjectScoresPadding() {
        if subjectCount < 5 {
            for _ in 0..<(5 - subjectCount) {
                subjectScores.append(0)
            }
        }
    }
}
