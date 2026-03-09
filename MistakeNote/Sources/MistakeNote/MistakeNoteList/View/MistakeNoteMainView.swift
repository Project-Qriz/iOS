//
//  MistakeNoteMainView.swift
//  MistakeNote
//
//  Created by Claude on 1/13/26.
//

import SwiftUI
import DesignSystem
import Combine
import QRIZUtils

public struct MistakeNoteMainView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MistakeNoteListViewModel
    private let input = PassthroughSubject<MistakeNoteListViewModel.Input, Never>()

    @State private var isDropdownExpanded: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var showSubjectFilterSheet: Bool = false
    @State private var sheetSubject: QRIZUtils.Subject = .one

    // MARK: - Initializer

    public init(viewModel: MistakeNoteListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .top) {
            mainContent
            dropdownOverlay
        }
        .background(Color.customBlue50)
        .animation(.easeInOut(duration: 0.1), value: isDropdownExpanded)
        .onChange(of: viewModel.selectedTab) { _, newTab in
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
            MistakeNoteFilterBarView(
                filterAll: viewModel.filterAll,
                hasActiveConceptFilter: !viewModel.selectedConceptsFilter.isEmpty,
                hasFilterForSubject: { viewModel.hasFilterForSubject($0) },
                onFilterAllChanged: { input.send(.filterAllChanged($0)) },
                onSubjectTapped: { subject in
                    sheetSubject = subject
                    showSubjectFilterSheet = true
                },
                onReset: { input.send(.resetConceptFilters) }
            )
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

    var questionCountLabel: some View {
        HStack {
            Text("\(viewModel.displayedQuestions.count)개")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.coolNeutral500)
            Spacer()
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

// MARK: - Preview

#Preview {
    MistakeNoteMainView(viewModel: MistakeNoteListViewModel())
}
