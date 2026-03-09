//
//  MistakeNoteListViewModel.swift
//  MistakeNote
//
//  Created by Claude on 1/21/26.
//

import Foundation
import Combine
import os
import QRIZUtils
import Network

public enum QuestionFilter: String, CaseIterable, Sendable {
    case all = "모두"
    case incorrectOnly = "오답만"
}

@MainActor
public final class MistakeNoteListViewModel: ObservableObject {

    // MARK: - Input & Output

    public enum Input {
        case viewDidLoad
        case tabSelected(MistakeNoteTab)
        case daySelected(String)
        case sessionSelected(String)
        case questionTapped(MistakeNoteQuestion)
        case goToExamTapped
        case filterAllChanged(QuestionFilter)
        case conceptFilterApplied(Set<String>, QRIZUtils.Subject?)
        case resetConceptFilters
    }

    public enum Output {
        case navigateToClipDetail(clipId: Int)
        case navigateToExam(tab: MistakeNoteTab)
    }

    // MARK: - Published Properties

    @Published public var selectedTab: MistakeNoteTab = .daily

    // Daily
    @Published public var availableDays: [String] = []
    @Published public var selectedDay: String = ""

    // Mock Exam
    @Published public var availableSessions: [String] = []
    @Published public var selectedSession: String = ""

    // Questions
    @Published public var filteredQuestions: [MistakeNoteQuestion] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    // Filter
    @Published public var filterAll: QuestionFilter = .all
    @Published public var selectedConceptsFilter: Set<String> = []
    @Published public var selectedFilterSubject: QRIZUtils.Subject?

    // MARK: - Computed Properties

    public var dropdownItems: [String] {
        switch selectedTab {
        case .daily:
            return availableDays
        case .mockExam:
            return availableSessions
        }
    }

    public var displayedQuestions: [MistakeNoteQuestion] {
        var questions = filteredQuestions

        if filterAll == .incorrectOnly {
            questions = questions.filter { !$0.correction }
        }

        if !selectedConceptsFilter.isEmpty {
            let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { $0.normalizingConcept() })
            questions = questions.filter { question in
                let questionConcepts = question.keyConcepts
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces).normalizingConcept() }
                return questionConcepts.contains { normalizedSelectedConcepts.contains($0) }
            }
        }

        return questions
    }

    public var availableConcepts: Set<String> {
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

    private let logger = Logger.make(category: "MistakeNoteListViewModel")
    private let service: MistakeNoteService
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<Output, Never>()

    // MARK: - Initializers

    public init(service: MistakeNoteService = MistakeNoteServiceImpl()) {
        self.service = service
    }

    // MARK: - Methods

    public func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
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
                Task { await self.loadClips(category: 2, testInfo: self.extractTestInfo(from: day)) }

            case .sessionSelected(let session):
                self.selectedSession = session
                self.resetAllFilters()
                Task { await self.loadClips(category: 3, testInfo: self.extractSessionInfo(from: session)) }

            case .questionTapped(let question):
                self.output.send(.navigateToClipDetail(clipId: question.id))

            case .goToExamTapped:
                self.output.send(.navigateToExam(tab: self.selectedTab))

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

    public func hasFilterForSubject(_ subject: QRIZUtils.Subject) -> Bool {
        guard !selectedConceptsFilter.isEmpty else { return false }

        let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { $0.normalizingConcept() })
        let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { $0.normalizingConcept() }

        return normalizedSelectedConcepts.contains { selectedConcept in
            subjectConcepts.contains(selectedConcept)
        }
    }

    // MARK: - Private Methods

    private func resetConceptFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
    }

    private func resetAllFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
        filterAll = .all
    }

    private func handleTabChange(_ tab: MistakeNoteTab) async {
        switch tab {
        case .daily:
            if availableDays.isEmpty {
                await loadDailyInitialData()
            } else {
                await loadClips(category: 2, testInfo: extractTestInfo(from: selectedDay))
            }
        case .mockExam:
            if availableSessions.isEmpty {
                await loadMockExamInitialData()
            } else {
                await loadClips(category: 3, testInfo: extractSessionInfo(from: selectedSession))
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
                await loadClips(category: 2, testInfo: extractTestInfo(from: firstDay))
            }
        } catch {
            errorMessage = "데이터를 불러오는데 실패했습니다."
            logger.error("Failed to load daily initial data: \(error)")
        }

        isLoading = false
    }

    private func loadClips(category: Int, testInfo: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getClips(category: category, testInfo: testInfo)
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
            logger.error("Failed to load clips (category: \(category)): \(error)")
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
                await loadClips(category: 3, testInfo: extractSessionInfo(from: session))
            }
        } catch {
            errorMessage = "데이터를 불러오는데 실패했습니다."
            logger.error("Failed to load mock exam initial data: \(error)")
        }

        isLoading = false
    }

}
