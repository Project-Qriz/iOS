//
//  MistakeNoteListViewModel.swift
//  QRIZ
//
//  Created by Claude on 1/21/26.
//

import Foundation
import Combine

@MainActor
final class MistakeNoteListViewModel: ObservableObject {

    // MARK: - Input & Output

    enum Input {
        case viewDidLoad
        case daySelected(String)
        case questionTapped(MistakeNoteQuestion)
    }

    enum Output {
        case navigateToClipDetail(clipId: Int)
    }

    // MARK: - Published Properties

    @Published var selectedTab: MistakeNoteTab = .daily
    @Published var availableDays: [String] = []
    @Published var selectedDay: String = ""
    @Published var filteredQuestions: [MistakeNoteQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private nonisolated(unsafe) let service: MistakeNoteService
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<Output, Never>()

    // MARK: - Initializers

    nonisolated init(service: MistakeNoteService = MistakeNoteServiceImpl()) {
        self.service = service
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                Task { await self.loadInitialData() }

            case .daySelected(let day):
                self.selectedDay = day
                Task { await self.loadQuestions(for: day) }

            case .questionTapped(let question):
                self.output.send(.navigateToClipDetail(clipId: question.id))
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            let daysResponse = try await service.getCompletedDays()
            availableDays = daysResponse.data.days

            if let firstDay = availableDays.first {
                selectedDay = firstDay
                await loadQuestions(for: firstDay)
            }
        } catch {
            errorMessage = "데이터를 불러오는데 실패했습니다."
            print("Failed to load initial data: \(error)")
        }

        isLoading = false
    }

    private func loadQuestions(for day: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let testInfo = extractTestInfo(from: day)
            let response = try await service.getClips(category: 2, testInfo: testInfo)
            filteredQuestions = response.data.map { clipData in
                MistakeNoteQuestion(
                    id: clipData.id,
                    questionNum: clipData.questionNum,
                    question: clipData.question,
                    correction: clipData.correction,
                    keyConcepts: clipData.keyConcepts,
                    date: clipData.date
                )
            }
        } catch {
            errorMessage = "문제를 불러오는데 실패했습니다."
            print("Failed to load questions: \(error)")
        }

        isLoading = false
    }

    /// "Day6 (주간 복습)" -> "Day6"
    private func extractTestInfo(from day: String) -> String {
        day.components(separatedBy: " ").first ?? day
    }
}
