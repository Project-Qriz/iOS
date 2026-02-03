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

                        MistakeNoteQuestionListView(
                            questions: displayedQuestions,
                            onQuestionTap: { question in
                                input.send(.questionTapped(question))
                            }
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
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
            input.send(.tabSelected(newTab))
        }
        .sheet(isPresented: $showSubjectFilterSheet) {
            SubjectFilterSheet(
                isPresented: $showSubjectFilterSheet,
                availableConcepts: availableConcepts
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
        switch filterAll {
        case "오답만":
            return viewModel.filteredQuestions.filter { !$0.correction }
        default:
            return viewModel.filteredQuestions
        }
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

            subjectFilterButton(title: "1과목")
            subjectFilterButton(title: "2과목")

            Spacer()
        }
    }

    func subjectFilterButton(title: String) -> some View {
        Button {
            showSubjectFilterSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
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
}

// MARK: - FilterType

private enum FilterType {
    case all
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
