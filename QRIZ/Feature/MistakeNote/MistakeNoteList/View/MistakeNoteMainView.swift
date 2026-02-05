//
//  MistakeNoteMainView.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI
import Combine

struct MistakeNoteMainView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MistakeNoteListViewModel
    private let input = PassthroughSubject<MistakeNoteListViewModel.Input, Never>()

    @State private var isDropdownExpanded: Bool = false
    @State private var hasAppeared: Bool = false

    // Filter states
    @State private var filterAll: String = "모두"
    @State private var expandedFilter: FilterType? = nil
    @State private var showSubjectFilterSheet: Bool = false
    @State private var selectedConceptsFilter: Set<String> = []
    @State private var selectedFilterSubject: Subject?

    // MARK: - Initializer

    init(viewModel: MistakeNoteListViewModel = MistakeNoteListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    MistakeNoteTabSelector(selectedTab: $viewModel.selectedTab)
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                }
                .background(Color.white)

                ScrollView {
                    VStack(spacing: 0) {
                        DaySelectDropdownButton(
                            days: dropdownItems,
                            selectedDay: selectedItemBinding,
                            isExpanded: $isDropdownExpanded
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 24)

                        filterChipsRow
                            .padding(.horizontal, 18)
                            .padding(.top, 16)
                            .zIndex(1)

                        questionCountLabel
                            .padding(.horizontal, 18)
                            .padding(.top, 16)

                        if displayedQuestions.isEmpty {
                            MistakeNoteEmptyView()
                        } else {
                            MistakeNoteQuestionListView(
                                questions: displayedQuestions,
                                onQuestionTap: { question in
                                    input.send(.questionTapped(question))
                                }
                            )
                            .padding(.horizontal, 18)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }

            if isDropdownExpanded {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isDropdownExpanded = false
                        }
                    }

                DaySelectDropdownList(
                    days: dropdownItems,
                    selectedDay: selectedItemBinding,
                    isExpanded: $isDropdownExpanded,
                    onDaySelected: { item in
                        handleDropdownSelection(item)
                    }
                )
                .padding(.horizontal, 18)
                .padding(.top, 120)
            }
        }
        .background(Color(uiColor: .customBlue50))
        .animation(.easeInOut(duration: 0.1), value: isDropdownExpanded)
        .onChange(of: viewModel.selectedTab) { newTab in
            selectedConceptsFilter = []
            selectedFilterSubject = nil
            filterAll = "모두"
            input.send(.tabSelected(newTab))
        }
        .sheet(isPresented: $showSubjectFilterSheet) {
            SubjectFilterSheet(
                isPresented: $showSubjectFilterSheet,
                availableConcepts: availableConcepts,
                initialSubject: selectedFilterSubject ?? .one,
                initialSelectedConcepts: selectedConceptsFilter,
                onApply: { selectedConcepts in
                    selectedConceptsFilter = selectedConcepts
                }
            )
            .presentationDetents([.fraction(0.6)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            bindViewModel()
            input.send(.viewDidLoad)
        }
    }

    // MARK: - Private Methods

    private func bindViewModel() {
        _ = viewModel.transform(input: input.eraseToAnyPublisher())
    }

    /// 필터링된 문제 목록
    private var displayedQuestions: [MistakeNoteQuestion] {
        var questions = viewModel.filteredQuestions

        // 오답만 필터
        if filterAll == "오답만" {
            questions = questions.filter { !$0.correction }
        }

        // 개념 필터
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

    /// 개념 이름 정규화 (공백 제거)
    private func normalizeConceptName(_ name: String) -> String {
        name.replacingOccurrences(of: " ", with: "")
    }

    /// 특정 과목에 필터가 적용되어 있는지 확인
    private func hasFilterForSubject(_ subject: Subject) -> Bool {
        guard !selectedConceptsFilter.isEmpty else { return false }

        let normalizedSelectedConcepts = Set(selectedConceptsFilter.map { normalizeConceptName($0) })
        let subjectConcepts = subject.chapters.flatMap { $0.concepts }.map { normalizeConceptName($0) }

        return normalizedSelectedConcepts.contains { selectedConcept in
            subjectConcepts.contains(selectedConcept)
        }
    }

    /// 필터 초기화
    private func resetFilters() {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
    }

    /// 현재 문제 목록에서 추출한 가용 개념 Set
    private var availableConcepts: Set<String> {
        var concepts = Set<String>()
        for question in viewModel.filteredQuestions {
            let questionConcepts = question.keyConcepts
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            concepts.formUnion(questionConcepts)
        }
        return concepts
    }

    /// 현재 탭에 따른 드롭다운 아이템
    private var dropdownItems: [String] {
        switch viewModel.selectedTab {
        case .daily:
            return viewModel.availableDays
        case .mockExam:
            return viewModel.availableSessions
        }
    }

    /// 현재 탭에 따른 선택 항목 바인딩
    private var selectedItemBinding: Binding<String> {
        switch viewModel.selectedTab {
        case .daily:
            return $viewModel.selectedDay
        case .mockExam:
            return $viewModel.selectedSession
        }
    }

    /// 드롭다운 선택 처리
    private func handleDropdownSelection(_ item: String) {
        selectedConceptsFilter = []
        selectedFilterSubject = nil
        filterAll = "모두"

        switch viewModel.selectedTab {
        case .daily:
            input.send(.daySelected(item))
        case .mockExam:
            input.send(.sessionSelected(item))
        }
    }
}

// MARK: - Subviews

private extension MistakeNoteMainView {

    var questionCountLabel: some View {
        HStack {
            Text("\(displayedQuestions.count)개")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(uiColor: .coolNeutral500))
            Spacer()
        }
    }

    var filterChipsRow: some View {
        HStack(spacing: 8) {
            FilterChipButton(
                title: "모두",
                options: ["모두", "오답만"],
                selectedOption: $filterAll,
                isExpanded: Binding(
                    get: { expandedFilter == .all },
                    set: { expandedFilter = $0 ? .all : nil }
                )
            )

            Divider()
                .frame(height: 32)
                .background(Color(uiColor: .coolNeutral200))
            
            if !selectedConceptsFilter.isEmpty {
                resetFilterButton
            }

            subjectFilterButton(subject: .one, title: "1과목")
            subjectFilterButton(subject: .two, title: "2과목")

            Spacer()
        }
    }

    var resetFilterButton: some View {
        Button {
            resetFilters()
        } label: {
            HStack(spacing: 4) {
                Text("초기화")
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundColor(Color(uiColor: .coolNeutral500))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
            )
        }
    }

    func subjectFilterButton(subject: Subject, title: String) -> some View {
        let isActive = hasFilterForSubject(subject)

        return Button {
            selectedFilterSubject = subject
            showSubjectFilterSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isActive ? .white : Color(uiColor: .coolNeutral500))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color(uiColor: .coolNeutral700) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? Color.clear : Color(uiColor: .coolNeutral200), lineWidth: 1)
            )
        }
    }
}

// MARK: - FilterType

private enum FilterType {
    case all
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
