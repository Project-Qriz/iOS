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
        case tabSelected(MistakeNoteTab)
        case daySelected(String)
        case sessionSelected(String)
        case questionTapped(MistakeNoteQuestion)
    }

    enum Output {
        case navigateToClipDetail(clipId: Int)
    }

    // MARK: - Published Properties

    @Published var selectedTab: MistakeNoteTab = .daily

    // Daily
    @Published var availableDays: [String] = []
    @Published var selectedDay: String = ""

    // Mock Exam
    @Published var availableSessions: [String] = []
    @Published var selectedSession: String = ""

    // Common
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
                Task { await self.loadDailyInitialData() }

            case .tabSelected(let tab):
                self.selectedTab = tab
                Task { await self.handleTabChange(tab) }

            case .daySelected(let day):
                self.selectedDay = day
                Task { await self.loadDailyQuestions(for: day) }

            case .sessionSelected(let session):
                self.selectedSession = session
                Task { await self.loadMockExamQuestions(for: session) }

            case .questionTapped(let question):
                self.output.send(.navigateToClipDetail(clipId: question.id))
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func handleTabChange(_ tab: MistakeNoteTab) async {
        switch tab {
        case .daily:
            if availableDays.isEmpty {
                await loadDailyInitialData()
            }
        case .mockExam:
            if availableSessions.isEmpty {
                await loadMockExamInitialData()
            }
        }
    }

    // MARK: - Daily Methods

    private func loadDailyInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            let daysResponse = try await service.getCompletedDays()
            availableDays = daysResponse.data.days

            if let firstDay = availableDays.first {
                selectedDay = firstDay
                await loadDailyQuestions(for: firstDay)
            }
        } catch {
            errorMessage = "데이터를 불러오는데 실패했습니다."
            print("Failed to load daily initial data: \(error)")
        }

        isLoading = false
    }

    private func loadDailyQuestions(for day: String) async {
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
            print("Failed to load daily questions: \(error)")
        }

        isLoading = false
    }

    /// "Day6 (주간 복습)" -> "Day6"
    private func extractTestInfo(from day: String) -> String {
        day.components(separatedBy: " ").first ?? day
    }

    // MARK: - Mock Exam Methods

    private func loadMockExamInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            let sessionsResponse = try await service.getCompletedExamSessions()
            availableSessions = sessionsResponse.data.sessions

            // latestSession 또는 첫 번째 세션 선택
            let targetSession = sessionsResponse.data.latestSession ?? availableSessions.first

            if let session = targetSession {
                selectedSession = session
                await loadMockExamQuestions(for: session)
            }
        } catch {
            errorMessage = "데이터를 불러오는데 실패했습니다."
            print("Failed to load mock exam initial data: \(error)")
        }

        isLoading = false
    }

    private func loadMockExamQuestions(for session: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getClips(category: 3, testInfo: session)
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
            print("Failed to load mock exam questions: \(error)")
        }

        isLoading = false
    }
}
