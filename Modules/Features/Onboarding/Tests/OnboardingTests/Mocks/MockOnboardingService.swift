import Foundation
import QRIZNetwork
import QRIZUtils
@testable import Onboarding

// @MainActor: Sendable 요구를 암묵적으로 충족하면서 mutable 프로퍼티를 안전하게 접근.
@MainActor
final class MockOnboardingService: OnboardingService {
    var sendSurveyResult: Result<Void, Error> = .success(())
    var getPreviewTestListResult: Result<PreviewTestListResponse, Error> = .success(.stub())
    var submitPreviewResult: Result<PreviewSubmitResponse, Error> = .success(.stub())
    var analyzePreviewResult: Result<AnalyzePreviewResponse, Error> = .success(.stub())

    func sendSurvey(keyConcepts: [String]) async throws {
        if case .failure(let error) = sendSurveyResult { throw error }
    }

    func getPreviewTestList() async throws -> PreviewTestListResponse {
        try getPreviewTestListResult.get()
    }

    func submitPreview(testSubmitDataList: [TestSubmitData]) async throws -> PreviewSubmitResponse {
        try submitPreviewResult.get()
    }

    func analyzePreview() async throws -> AnalyzePreviewResponse {
        try analyzePreviewResult.get()
    }
}
