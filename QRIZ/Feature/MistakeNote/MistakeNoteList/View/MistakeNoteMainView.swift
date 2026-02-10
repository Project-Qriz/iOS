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
    @State private var expandedFilter: FilterType? = nil
    @State private var showSubjectFilterSheet: Bool = false
    @State private var sheetSubject: Subject = .one

    // MARK: - Initializer

    init(viewModel: MistakeNoteListViewModel = MistakeNoteListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            mainContent
            dropdownOverlay
        }
        .background(Color(uiColor: .customBlue50))
        .animation(.easeInOut(duration: 0.1), value: isDropdownExpanded)
        .onChange(of: viewModel.selectedTab) { newTab in
            input.send(.tabSelected(newTab))
        }
        .sheet(isPresented: $showSubjectFilterSheet) {
            subjectFilterSheet
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            bindViewModel()
            input.send(.viewDidLoad)
        }
    }
}

// MARK: - Main Content

private extension MistakeNoteMainView {

    var mainContent: some View {
        VStack(spacing: 0) {
            tabSelector
            scrollContent
        }
    }

    var tabSelector: some View {
        VStack(spacing: 0) {
            MistakeNoteTabSelector(selectedTab: $viewModel.selectedTab)
                .padding(.horizontal, 18)
                .padding(.top, 16)
        }
        .background(Color.white)
    }

    var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                dropdownButton
                contentSection
            }
        }
    }

    var dropdownButton: some View {
        DaySelectDropdownButton(
            days: viewModel.dropdownItems,
            selectedDay: selectedItemBinding,
            isExpanded: $isDropdownExpanded
        )
        .padding(.horizontal, 18)
        .padding(.top, 24)
    }

    @ViewBuilder
    var contentSection: some View {
        if viewModel.dropdownItems.isEmpty {
            MistakeNoteNoRecordView(
                onGoToExam: {
                    input.send(.goToExamTapped)
                }
            )
        } else {
            questionSection
        }
    }

    var questionSection: some View {
        VStack(spacing: 0) {
            filterChipsRow
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .zIndex(1)

            questionCountLabel
                .padding(.horizontal, 18)
                .padding(.top, 16)

            questionListOrEmptyView
        }
    }

    @ViewBuilder
    var questionListOrEmptyView: some View {
        if viewModel.displayedQuestions.isEmpty {
            MistakeNoteEmptyView()
        } else {
            MistakeNoteQuestionListView(
                questions: viewModel.displayedQuestions,
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

// MARK: - Dropdown Overlay

private extension MistakeNoteMainView {

    @ViewBuilder
    var dropdownOverlay: some View {
        if isDropdownExpanded {
            Color.black.opacity(0.01)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isDropdownExpanded = false
                    }
                }

            DaySelectDropdownList(
                days: viewModel.dropdownItems,
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
}

// MARK: - Filter Components

private extension MistakeNoteMainView {

    var filterChipsRow: some View {
        HStack(spacing: 8) {
            FilterChipButton(
                title: "모두",
                options: ["모두", "오답만"],
                selectedOption: Binding(
                    get: { viewModel.filterAll },
                    set: { input.send(.filterAllChanged($0)) }
                ),
                isExpanded: Binding(
                    get: { expandedFilter == .all },
                    set: { expandedFilter = $0 ? .all : nil }
                )
            )

            Divider()
                .frame(height: 32)
                .background(Color(uiColor: .coolNeutral200))

            if !viewModel.selectedConceptsFilter.isEmpty {
                resetFilterButton
            }

            subjectFilterButton(subject: .one, title: "1과목")
            subjectFilterButton(subject: .two, title: "2과목")

            Spacer()
        }
    }

    var resetFilterButton: some View {
        Button {
            input.send(.resetConceptFilters)
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
        let isActive = viewModel.hasFilterForSubject(subject)

        return Button {
            sheetSubject = subject
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

    var questionCountLabel: some View {
        HStack {
            Text("\(viewModel.displayedQuestions.count)개")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(uiColor: .coolNeutral500))
            Spacer()
        }
    }
}

// MARK: - Sheet

private extension MistakeNoteMainView {

    var subjectFilterSheet: some View {
        SubjectFilterSheet(
            isPresented: $showSubjectFilterSheet,
            availableConcepts: viewModel.availableConcepts,
            initialSubject: sheetSubject,
            initialSelectedConcepts: viewModel.selectedConceptsFilter,
            onApply: { selectedConcepts in
                input.send(.conceptFilterApplied(selectedConcepts, viewModel.selectedFilterSubject))
            }
        )
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - Private Methods

private extension MistakeNoteMainView {

    var selectedItemBinding: Binding<String> {
        switch viewModel.selectedTab {
        case .daily:
            return $viewModel.selectedDay
        case .mockExam:
            return $viewModel.selectedSession
        }
    }

    func bindViewModel() {
        _ = viewModel.transform(input: input.eraseToAnyPublisher())
    }

    func handleDropdownSelection(_ item: String) {
        switch viewModel.selectedTab {
        case .daily:
            input.send(.daySelected(item))
        case .mockExam:
            input.send(.sessionSelected(item))
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
