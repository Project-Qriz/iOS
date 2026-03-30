import Foundation
import Network
import QRIZUtils

@MainActor
final class MockExamService: ExamService {

    var getExamListResult: Result<ExamListResponse, Error> = .success(
        ExamListResponse(code: 1, msg: "ok", data: [])
    )

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
        fatalError("not implemented")
    }

    func getExamResult(examId: Int) async throws -> ExamResultResponse {
        fatalError("not implemented")
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
}
