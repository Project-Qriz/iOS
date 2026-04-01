import Foundation
import Network

@MainActor
final class MockWeeklyRecommendService: WeeklyRecommendService {

    var fetchWeeklyRecommendResult: Result<WeeklyRecommendResponse, Error> = .success(.make())

    func fetchWeeklyRecommend() async throws -> WeeklyRecommendResponse {
        try fetchWeeklyRecommendResult.get()
    }
}
