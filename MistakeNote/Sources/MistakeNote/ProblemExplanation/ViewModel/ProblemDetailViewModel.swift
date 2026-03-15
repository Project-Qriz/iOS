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

    // MARK: - Properties

    @Published public var problemDetail: DailyResultDetailEntity?
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    public var onNavigate: ((Output) -> Void)?

    private let logger = Logger.make(category: "ProblemDetailViewModel")
    private let fetchDetail: () async throws -> DailyResultDetailEntity

    // MARK: - Initialization

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

        let normalizedTarget = normalizedInput.normalizingConcept().lowercased()
        for chapter in Chapter.allCases {
            for conceptItem in chapter.conceptItems {
                if conceptItem.title.normalizingConcept().lowercased() == normalizedTarget {
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

// MARK: - Output

extension ProblemDetailViewModel {
    public enum Output {
        case navigateToConceptTab
        case navigateToConceptDetail(chapter: Chapter, conceptItem: ConceptItem)
    }
}
