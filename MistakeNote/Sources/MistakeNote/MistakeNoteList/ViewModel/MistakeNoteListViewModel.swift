//
//  MistakeNoteListViewModel.swift
//  MistakeNote
//
//  Created by Claude on 1/21/26.
//

import Foundation
import os
import QRIZUtils
import Network

public enum QuestionFilter: String, CaseIterable, Sendable {
    case all = "모두"
    case incorrectOnly = "오답만"
}

@MainActor
public final class MistakeNoteListViewModel: ObservableObject {

    // MARK: - Properties

    @Published public var selectedTab: MistakeNoteTab = .daily
    @Published public var availableDays: [String] = []
    @Published public var selectedDay: String = ""
    @Published public var availableSessions: [String] = []
    @Published public var selectedSession: String = ""
    @Published public var filteredQuestions: [MistakeNoteQuestion] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var filterAll: QuestionFilter = .all
    @Published public var selectedConceptsFilter: Set<String> = []
    @Published public var selectedFilterSubject: QRIZUtils.Subject?

    public var dropdownItems: [String] {
        switch selectedTab {
        case .daily: return availableDays
        case .mockExam: return availableSessions
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

    public var onNavigate: ((Output) -> Void)?

    private let logger = Logger.make(category: "MistakeNoteListViewModel")
    private let service: MistakeNoteService

    // MARK: - Initialization

    public init(service: MistakeNoteService = MistakeNoteServiceImpl()) {
        self.service = service
    }

    // MARK: - Methods

    public func viewDidLoad() async {
        await loadDailyInitialData()
    }

    public func tabSelected(_ tab: MistakeNoteTab) {
        selectedTab = tab
        resetAllFilters()
        Task { await handleTabChange(tab) }
    }

    public func daySelected(_ day: String) {
        selectedDay = day
        resetAllFilters()
        Task { await loadClips(category: 2, testInfo: extractTestInfo(from: day)) }
    }

    public func sessionSelected(_ session: String) {
        selectedSession = session
        resetAllFilters()
        Task { await loadClips(category: 3, testInfo: extractSessionInfo(from: session)) }
    }

    public func questionTapped(_ question: MistakeNoteQuestion) {
        onNavigate?(.navigateToClipDetail(clipId: question.id))
    }

    public func goToExamTapped() {
        onNavigate?(.navigateToExam(tab: selectedTab))
    }

    public func filterAllChanged(_ filter: QuestionFilter) {
        filterAll = filter
    }

    public func conceptFilterApplied(_ concepts: Set<String>, _ subject: QRIZUtils.Subject?) {
        selectedConceptsFilter = concepts
        selectedFilterSubject = subject
    }

    public func resetConceptFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
    }

    public func hasFilterForSubject(_ subject: QRIZUtils.Subject) -> Bool {
        guard !selectedConceptsFilter.isEmpty else { return false }

        let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { $0.normalizingConcept() })
        let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { $0.normalizingConcept() }

        return normalizedSelectedConcepts.contains { selectedConcept in
            subjectConcepts.contains(selectedConcept)
        }
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

    private func loadMockExamInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            let sessionsResponse = try await service.getCompletedExamSessions()
            availableSessions = sessionsResponse.data.sessions

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

// MARK: - Output

extension MistakeNoteListViewModel {
    public enum Output {
        case navigateToClipDetail(clipId: Int)
        case navigateToExam(tab: MistakeNoteTab)
    }
}
