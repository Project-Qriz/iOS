import Foundation
import Network
import QRIZUtils

@MainActor
final class MockExamService: ExamService {

    var getExamListResult: Result<ExamListResponse, Error> = .success(
        ExamListResponse(code: 1, msg: "ok", data: [])
    )
    var getExamResultResult: Result<ExamResultResponse, Error> = .success(MockExamService.makeExamResult())
    var getExamScoreResult: Result<ExamScoreResponse, Error> = .success(MockExamService.makeExamScore())

    func getExamList(filterType: ExamListFilterType) async throws -> ExamListResponse {
        try getExamListResult.get()
    }

    func getExamQuestion(examId: Int) async throws -> ExamQuestionResponse {
        fatalError("not implemented")
    }

    func submitTest(examId: Int, testSubmitData: [TestSubmitData]) async throws {
        fatalError("not implemented")
    }

    func getExamScore(examId: Int) async throws -> ExamScoreResponse {
        try getExamScoreResult.get()
    }

    func getExamResult(examId: Int) async throws -> ExamResultResponse {
        try getExamResultResult.get()
    }

    func getExamResultDetail(examId: Int, questionId: Int) async throws -> ExamResultDetailResponse {
        fatalError("not implemented")
    }

    // MARK: - Sample Data

    static func makeExamList(count: Int = 3, completed: Bool = false) -> [ExamListDataInfo] {
        guard count > 0 else { return [] }
        return (1...count).map {
            ExamListDataInfo(
                completed: completed,
                session: "\($0)회차",
                totalScore: completed ? Double($0 * 10) : nil
            )
        }
    }

    static func makeExamResult(problemCount: Int = 2, historicalCount: Int = 3) -> ExamResultResponse {
        let problems: [ExamResultResponse.ProblemResult]
        if problemCount > 0 {
            problems = (1...problemCount).map { i in
                ExamResultResponse.ProblemResult(
                    questionId: i,
                    questionNum: i,
                    skillName: "DDL",
                    question: "문제 \(i)",
                    correction: i % 2 == 0
                )
            }
        } else {
            problems = []
        }

        let historical: [HistoricalScore]
        if historicalCount > 0 {
            historical = (1...historicalCount).map { i in
                HistoricalScore(
                    completionDateTime: String(format: "2026-%02d-01T10:00:00", i),
                    itemScores: [
                        HistoricalScore.ItemScore(type: "1과목", score: Double(60 + i * 5)),
                        HistoricalScore.ItemScore(type: "2과목", score: Double(55 + i * 5))
                    ],
                    attemptCount: i,
                    displayDate: String(format: "%02d-01", i)
                )
            }
        } else {
            historical = []
        }

        return ExamResultResponse(
            code: 1,
            msg: "ok",
            data: ExamResultResponse.DataInfo(problemResults: problems, historicalScores: historical)
        )
    }

    static func makeExamScore(subject1MajorCount: Int = 1, subject2MajorCount: Int = 1) -> ExamScoreResponse {
        ExamScoreResponse(
            code: 1,
            msg: "ok",
            data: [
                ExamScoreResponse.SubjectInfo(
                    title: "1과목",
                    totalScore: 80.0,
                    majorItems: (1...max(1, subject1MajorCount)).map { i in
                        ExamScoreResponse.SubjectInfo.MajorItemInfo(
                            majorItem: "데이터 모델링 \(i)",
                            score: 80.0,
                            subItemScores: []
                        )
                    }
                ),
                ExamScoreResponse.SubjectInfo(
                    title: "2과목",
                    totalScore: 70.0,
                    majorItems: (1...max(1, subject2MajorCount)).map { i in
                        ExamScoreResponse.SubjectInfo.MajorItemInfo(
                            majorItem: "SQL 기본 \(i)",
                            score: 70.0,
                            subItemScores: []
                        )
                    }
                )
            ]
        )
    }
}
