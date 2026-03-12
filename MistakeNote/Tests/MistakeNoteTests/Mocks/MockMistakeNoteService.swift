// MistakeNote/Tests/MistakeNoteTests/Mocks/MockMistakeNoteService.swift

import Foundation
import Network

final class MockMistakeNoteService: MistakeNoteService, @unchecked Sendable {

    var completedDaysResult: Result<CompletedDailyDaysResponse, Error> = .success(
        CompletedDailyDaysResponse(code: 1, msg: "ok", data: .init(days: ["Day1", "Day2", "Day3"]))
    )

    var completedExamSessionsResult: Result<CompletedExamSessionsResponse, Error> = .success(
        CompletedExamSessionsResponse(
            code: 1, msg: "ok",
            data: .init(sessions: ["1회차", "2회차", "3회차"], latestSession: "3회차")
        )
    )

    var clipsResult: Result<ClipsResponse, Error> = .success(
        ClipsResponse(code: 1, msg: "ok", data: [])
    )

    var clipDetailResult: Result<ClipDetailResponse, Error> = .success(
        ClipDetailResponse(
            code: 1, msg: "ok",
            data: DailyResultDetail(
                skillName: "SQL 기본",
                questionText: "테스트 문제",
                questionNum: 1,
                description: nil,
                option1: "1번",
                option2: "2번",
                option3: "3번",
                option4: "4번",
                answer: 1,
                solution: "해설",
                checked: 2,
                correction: false,
                testInfo: "Day1",
                skillId: 1,
                title: "1과목",
                keyConcepts: "SELECT문"
            )
        )
    )

    func getCompletedDays() async throws -> CompletedDailyDaysResponse {
        try completedDaysResult.get()
    }

    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse {
        try completedExamSessionsResult.get()
    }

    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse {
        try clipsResult.get()
    }

    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse {
        try clipDetailResult.get()
    }
}
