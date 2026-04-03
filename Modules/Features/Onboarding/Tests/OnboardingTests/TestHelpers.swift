import Foundation
import Combine
import Network
import QRIZUtils
@testable import Onboarding

let asyncSleepNanoseconds: UInt64 = 100_000_000

// MARK: - PreviewTestListResponse Fixtures

extension PreviewTestListResponse {
    static func stub(questionCount: Int = 3, totalTimeLimit: Int = 600) -> Self {
        PreviewTestListResponse(
            code: 1,
            msg: "ok",
            data: .init(
                questions: (1...questionCount).map { .make(questionId: $0) },
                totalTimeLimit: totalTimeLimit
            )
        )
    }
}

extension PreviewTestListQuestion {
    // options 기본 4개 — optionTapped 테스트에서 options[idx-1] 접근 시 크래시 방지
    static func make(
        questionId: Int = 1,
        skillId: Int = 1,
        category: Int = 1,
        question: String = "테스트 문제",
        description: String? = nil,
        options: [PreviewTestListOption] = [
            .init(id: 1, content: "선택지1"),
            .init(id: 2, content: "선택지2"),
            .init(id: 3, content: "선택지3"),
            .init(id: 4, content: "선택지4"),
        ],
        timeLimit: Int = 60,
        difficulty: Int = 1
    ) -> Self {
        PreviewTestListQuestion(
            questionId: questionId,
            skillId: skillId,
            category: category,
            question: question,
            description: description,
            options: options,
            timeLimit: timeLimit,
            difficulty: difficulty
        )
    }
}

// MARK: - AnalyzePreviewResponse Fixtures

extension AnalyzePreviewResponse {
    // totalScore = part1Score + part2Score로 ScoreBreakdown 생성
    static func stub(
        estimatedScore: Double = 72.0,
        totalScore: Int = 72,
        part1Score: Int = 40,
        part2Score: Int = 32,
        topConceptsToImprove: [String] = ["SQL 기본", "SELECT문"],
        totalQuestions: Int = 10,
        weakAreas: [WeakArea] = []
    ) -> Self {
        AnalyzePreviewResponse(
            code: 1,
            msg: "ok",
            data: .init(
                estimatedScore: estimatedScore,
                scoreBreakdown: .init(
                    totalScore: totalScore,
                    part1Score: part1Score,
                    part2Score: part2Score
                ),
                weakAreaAnalysis: .init(
                    totalQuestions: totalQuestions,
                    weakAreas: weakAreas
                ),
                topConceptsToImprove: topConceptsToImprove
            )
        )
    }
}

// MARK: - PreviewSubmitResponse Fixtures

extension PreviewSubmitResponse {
    static func stub() -> Self {
        PreviewSubmitResponse(code: 1, msg: "ok", data: nil)
    }
}

// MARK: - UserInfoResponse Fixtures

extension UserInfoResponse {
    // previewTestStatus 노출 — fetchUserInfo 후 UserInfoManager 상태 제어
    static func stub(
        name: String = "테스트유저",
        previewTestStatus: PreviewTestStatus = .previewCompleted
    ) -> Self {
        UserInfoResponse(
            code: 1,
            msg: "ok",
            data: UserInfo(
                name: name,
                userId: "testUser123",
                email: "test@example.com",
                previewTestStatus: previewTestStatus,
                provider: nil
            )
        )
    }
}

// MARK: - Combine Output 수집 헬퍼

/// PreviewTestViewModel Input/Output 패턴 테스트용.
/// 반드시 transform(input:)을 호출한 후 반환된 publisher를 넘길 것.
@MainActor
func collectOutputs(
    from publisher: AnyPublisher<PreviewTestViewModel.Output, Never>,
    after action: () -> Void
) async -> [PreviewTestViewModel.Output] {
    var outputs: [PreviewTestViewModel.Output] = []
    let cancellable = publisher.sink { outputs.append($0) }
    action()
    try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)
    cancellable.cancel()
    return outputs
}
