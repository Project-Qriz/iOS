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
    }

    enum Output {
        case navigateToConcept
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
                output.send(.navigateToConcept)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
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
