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
        case goToExamTapped
        case filterAllChanged(String)
        case conceptFilterApplied(Set<String>, Subject?)
        case resetConceptFilters
    }

    enum Output {
        case navigateToClipDetail(clipId: Int)
        case navigateToExam
    }

    // MARK: - Published Properties

    @Published var selectedTab: MistakeNoteTab = .daily

    // Daily
    @Published var availableDays: [String] = []
    @Published var selectedDay: String = ""

    // Mock Exam
    @Published var availableSessions: [String] = []
    @Published var selectedSession: String = ""

    // Questions
    @Published var filteredQuestions: [MistakeNoteQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filter
    @Published var filterAll: String = "모두"
    @Published var selectedConceptsFilter: Set<String> = []
    @Published var selectedFilterSubject: Subject?

    // MARK: - Computed Properties

    var dropdownItems: [String] {
        switch selectedTab {
        case .daily:
            return availableDays
        case .mockExam:
            return availableSessions
        }
    }

    var displayedQuestions: [MistakeNoteQuestion] {
        var questions = filteredQuestions

        if filterAll == "오답만" {
            questions = questions.filter { !$0.correction }
        }

        if !selectedConceptsFilter.isEmpty {
            let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { normalizeConceptName($0) })
            questions = questions.filter { question in
                let questionConcepts = question.keyConcepts
                    .components(separatedBy: ",")
                    .map { normalizeConceptName($0.trimmingCharacters(in: .whitespaces)) }
                return questionConcepts.contains { normalizedSelectedConcepts.contains($0) }
            }
        }

        return questions
    }

    var availableConcepts: Set<String> {
        var concepts = Set<String>()
        for question in filteredQuestions {
            let questionConcepts = question.keyConcepts
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            concepts.formUnion(questionConcepts)
        }
        return concepts
    }

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
                self.resetAllFilters()
                Task { await self.handleTabChange(tab) }

            case .daySelected(let day):
                self.selectedDay = day
                self.resetAllFilters()
                Task { await self.loadDailyQuestions(for: day) }

            case .sessionSelected(let session):
                self.selectedSession = session
                self.resetAllFilters()
                Task { await self.loadMockExamQuestions(for: session) }

            case .questionTapped(let question):
                self.output.send(.navigateToClipDetail(clipId: question.id))

            case .goToExamTapped:
                self.output.send(.navigateToExam)

            case .filterAllChanged(let filter):
                self.filterAll = filter

            case .conceptFilterApplied(let concepts, let subject):
                self.selectedConceptsFilter = concepts
                self.selectedFilterSubject = subject

            case .resetConceptFilters:
                self.resetConceptFilters()
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    func hasFilterForSubject(_ subject: Subject) -> Bool {
        guard !selectedConceptsFilter.isEmpty else { return false }

        let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { normalizeConceptName($0) })
        let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { normalizeConceptName($0) }

        return normalizedSelectedConcepts.contains { selectedConcept in
            subjectConcepts.contains(selectedConcept)
        }
    }

    // MARK: - Private Methods

    private func normalizeConceptName(_ name: String) -> String {
        name.replacingOccurrences(of: " ", with: "")
    }

    private func resetConceptFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
    }

    private func resetAllFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
        filterAll = "모두"
    }

    private func handleTabChange(_ tab: MistakeNoteTab) async {
        switch tab {
        case .daily:
            if availableDays.isEmpty {
                await loadDailyInitialData()
            } else {
                await loadDailyQuestions(for: selectedDay)
            }
        case .mockExam:
            if availableSessions.isEmpty {
                await loadMockExamInitialData()
            } else {
                await loadMockExamQuestions(for: selectedSession)
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

    /// "3회차 (제일 최신 회차)" -> "3회차"
    private func extractSessionInfo(from session: String) -> String {
        session.components(separatedBy: " ").first ?? session
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

        let testInfo = extractSessionInfo(from: session)

        do {
            let response = try await service.getClips(category: 3, testInfo: testInfo)
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
