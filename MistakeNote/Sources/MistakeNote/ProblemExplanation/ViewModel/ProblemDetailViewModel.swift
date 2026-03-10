//
//  ProblemDetailViewModel.swift
//  MistakeNote
//
//  Created by Claude on 1/3/26.
//

import Foundation
import os
import QRIZUtils
import Network

@MainActor
public final class ProblemDetailViewModel: ObservableObject {

    // MARK: - Output
    public enum Output {
        case navigateToConceptTab
        case navigateToConceptDetail(chapter: Chapter, conceptItem: ConceptItem)
    }

    // MARK: - Published Properties
    @Published public var problemDetail: DailyResultDetailEntity?
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    // MARK: - Public Properties
    public var onNavigate: ((Output) -> Void)?

    // MARK: - Private Properties
    private let logger = Logger.make(category: "ProblemDetailViewModel")
    private let fetchDetail: () async throws -> DailyResultDetailEntity

    // MARK: - Initializers
    public init(fetchDetail: @escaping () async throws -> DailyResultDetailEntity) {
        self.fetchDetail = fetchDetail
    }

    // MARK: - Methods
    public func viewDidLoad() {
        Task { await fetchProblemDetail() }
    }

    public func retry() {
        Task { await fetchProblemDetail() }
    }

    public func learnButtonTapped() {
        onNavigate?(.navigateToConceptTab)
    }

    public func conceptTapped(concept: String) {
        if let (chapter, conceptItem) = findConceptItem(for: concept) {
            onNavigate?(.navigateToConceptDetail(chapter: chapter, conceptItem: conceptItem))
        }
    }

    /// 개념 이름으로 Chapter와 ConceptItem을 찾는 메서드
    private func findConceptItem(for conceptName: String) -> (Chapter, ConceptItem)? {
        let normalizedInput = conceptName.trimmingCharacters(in: .whitespacesAndNewlines)

        for chapter in Chapter.allCases {
            for conceptItem in chapter.conceptItems {
                // 정확히 일치하는 경우
                if conceptItem.title == normalizedInput {
                    return (chapter, conceptItem)
                }

                // 대소문자 무시하고 비교
                if conceptItem.title.lowercased() == normalizedInput.lowercased() {
                    return (chapter, conceptItem)
                }

                // 공백 제거하고 비교 (예: "SELECT문" vs "SELECT 문")
                if conceptItem.title.normalizingConcept().lowercased() == normalizedInput.normalizingConcept().lowercased() {
                    return (chapter, conceptItem)
                }
            }
        }

        return nil
    }

    private func fetchProblemDetail() async {
        isLoading = true
        errorMessage = nil

        do {
            problemDetail = try await fetchDetail()
        } catch {
            errorMessage = "문제 정보를 불러오는데 실패했습니다."
            logger.error("Failed to load problem detail: \(error)")
        }

        isLoading = false
    }
}
