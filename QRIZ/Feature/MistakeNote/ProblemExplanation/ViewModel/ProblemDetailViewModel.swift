//
//  ProblemDetailViewModel.swift
//  QRIZ
//
//  Created by Claude on 1/3/26.
//

import Foundation
import Combine

@MainActor
final class ProblemDetailViewModel: ObservableObject {

    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case learnButtonTapped
        case conceptTapped(concept: String)
    }

    enum Output {
        case navigateToConceptTab
        case navigateToConceptDetail(chapter: Chapter, conceptItem: ConceptItem)
    }

    // MARK: - Published Properties
    @Published var problemDetail: DailyResultDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let service: DailyService
    private let questionId: Int
    private let dayNumber: Int
    private var cancellables = Set<AnyCancellable>()
    private let output: PassthroughSubject<Output, Never> = .init()

    // MARK: - Initializers
    init(service: DailyService, questionId: Int, dayNumber: Int) {
        self.service = service
        self.questionId = questionId
        self.dayNumber = dayNumber
    }

    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                Task { await self.fetchProblemDetail() }
            case .learnButtonTapped:
                output.send(.navigateToConceptTab)
            case .conceptTapped(let concept):
                if let (chapter, conceptItem) = self.findConceptItem(for: concept) {
                    output.send(.navigateToConceptDetail(chapter: chapter, conceptItem: conceptItem))
                }
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
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
                let normalizedTitle = conceptItem.title.replacingOccurrences(of: " ", with: "")
                let normalizedSearch = normalizedInput.replacingOccurrences(of: " ", with: "")
                if normalizedTitle.lowercased() == normalizedSearch.lowercased() {
                    return (chapter, conceptItem)
                }
            }
        }

        return nil
    }

    func fetchProblemDetail() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getDailyResultDetail(
                dayNumber: dayNumber,
                questionId: questionId
            )
            problemDetail = response.data
        } catch {
            errorMessage = "문제 정보를 불러오는데 실패했습니다."
            print("Failed to load problem detail: \(error)")
        }

        isLoading = false
    }
}
