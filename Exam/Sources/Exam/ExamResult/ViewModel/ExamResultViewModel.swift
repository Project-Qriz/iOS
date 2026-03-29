import Foundation
import QRIZUtils
import Network

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
    private var subjectCount: Int = 0
    private var gradeResultList: [GradeResult] = []
    private var subject1DetailResult: [SubjectDetailData] = []
    private var subject2DetailResult: [SubjectDetailData] = []
    private var historicalScores: [HistoricalScoreEntity] = []
    private var numOfDataToPresent: Int = 0
    private var nickname: String {
        UserInfoManager.shared.name
    }
    private let examId: Int
    private let examService: any ExamService

    // MARK: - Initialization

    init(examId: Int, examService: any ExamService) {
        self.examId = examId
        self.examService = examService
    }

    // MARK: - Methods

    func onViewDidLoad() {
        fetchTask?.cancel()
        fetchTask = Task { await fetchData() }
    }

    func didTapCancel() {
        delegate?.didRequestQuitExam()
    }

    func didTapMoveToConcept() {
        delegate?.didRequestMoveToConcept()
    }

    func didTapResultDetail() {
        delegate?.didRequestMoveToResultDetail()
    }

    func didTapProblem(questionId: Int) {
        delegate?.didRequestShowProblemDetail(questionId: questionId)
    }

    // MARK: - Private

    private func fetchData() async {
        do {
            try await fetchResultResponse()
            try await fetchScoreResponse()
            updateData()
        } catch NetworkError.serverError {
            errorMessage = "관리자에게 문의하세요."
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func fetchResultResponse() async throws {
        let resultResponse = try await examService.getExamResult(examId: examId)
        let data = resultResponse.data
        historicalScores = data.historicalScores.map { $0.toEntity() }
        data.problemResults.enumerated().forEach { [weak self] in
            guard let self = self else { return }
            self.gradeResultList.append(
                GradeResult(id: $0 + 1,
                            questionId: $1.questionId,
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
            case SubjectTitle.subject1.rawValue:
                $0.majorItems.forEach { [weak self] item in
                    guard let self = self else { return }
                    self.subject1DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores.map { $0.toEntity() }))
                    self.subjectScores.append(item.score)
                }
            case SubjectTitle.subject2.rawValue:
                $0.majorItems.forEach { [weak self] item in
                    guard let self = self else { return }
                    self.subject2DetailResult.append(SubjectDetailData(majorItem: item.majorItem, score: item.score, minorItems: item.subItemScores.map { $0.toEntity() }))
                    self.subjectScores.append(item.score)
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

            self.resultDetailData.subject1DetailResult = self.subject1DetailResult
            self.resultDetailData.subject2DetailResult = self.subject2DetailResult
            self.resultDetailData.numOfDataToPresent = self.numOfDataToPresent

            for i in 0...4 {
                self.resultScoresData.subjectScores[i] = self.subjectScores[i]
            }

            self.scoreGraphData.convertGraphScoreData(self.historicalScores.sorted())
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
