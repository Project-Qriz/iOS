//
//  SubjectFilterSheet.swift
//  QRIZ
//
//  Created by Claude on 1/19/26.
//

import SwiftUI

struct SubjectFilterSheet: View {

    // MARK: - Properties

    @Binding var isPresented: Bool
    @StateObject private var viewModel: SubjectFilterSheetViewModel
    var onApply: ((Set<String>) -> Void)?

    // MARK: - Initializer

    init(
        isPresented: Binding<Bool>,
        availableConcepts: Set<String>,
        initialSubject: Subject = .one,
        initialSelectedConcepts: Set<String> = [],
        onApply: ((Set<String>) -> Void)? = nil
    ) {
        _isPresented = isPresented
        _viewModel = StateObject(wrappedValue: SubjectFilterSheetViewModel(
            availableConcepts: availableConcepts,
            initialSubject: initialSubject,
            initialSelectedConcepts: initialSelectedConcepts
        ))
        self.onApply = onApply
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SubjectTabSelector(selectedSubject: $viewModel.selectedSubject)
                .padding(.top, 40)

            filterContent

            divider

            bottomButtons
        }
        .background(Color.white)
    }
}

// MARK: - Subviews

private extension SubjectFilterSheet {

    var filterContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                ForEach(viewModel.availableChapters, id: \.self) { chapter in
                    FilterSectionView(
                        chapter: chapter,
                        availableConcepts: viewModel.availableConcepts,
                        selectedItems: $viewModel.selectedConcepts
                    )
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
    }

    var divider: some View {
        Rectangle()
            .fill(Color(uiColor: .coolNeutral100))
            .frame(height: 1)
    }

    var bottomButtons: some View {
        HStack(spacing: 8) {
            resetButton
            applyButton
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white)
    }

    var resetButton: some View {
        Button {
            viewModel.send(.resetTapped)
        } label: {
            Text("초기화")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(viewModel.hasSelections ? Color(uiColor: .coolNeutral700) : Color(uiColor: .coolNeutral400))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
        }
        .frame(width: 80)
        .disabled(!viewModel.hasSelections)
    }

    var applyButton: some View {
        Button {
            onApply?(viewModel.selectedConcepts)
            isPresented = false
        } label: {
            Text("적용하기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(viewModel.hasChanges ? .white : Color(uiColor: .coolNeutral500))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.hasChanges ? Color(uiColor: .customBlue500) : Color(uiColor: .coolNeutral200))
                .cornerRadius(8)
        }
        .disabled(!viewModel.hasChanges)
    }
}

// MARK: - SubjectTabSelector

struct SubjectTabSelector: View {

    @Binding var selectedSubject: Subject

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(Subject.allCases.enumerated()), id: \.element) { index, subject in
                    tabButton(for: subject, index: index + 1)
                }
                Spacer()
            }
            .padding(.horizontal, 18)

            Rectangle()
                .fill(Color(uiColor: .coolNeutral100))
                .frame(height: 1)
                .padding(.horizontal, 18)
        }
    }

    private func tabButton(for subject: Subject, index: Int) -> some View {
        let isSelected = selectedSubject == subject

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSubject = subject
            }
        } label: {
            VStack(spacing: 10) {
                Text("\(index)과목")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(uiColor: .coolNeutral800) : Color(uiColor: .coolNeutral400))

                Rectangle()
                    .fill(isSelected ? Color(uiColor: .coolNeutral800) : Color.clear)
                    .frame(height: 3)
            }
            .frame(width: 60)
        }
    }
}

// MARK: - Preview

#Preview {
    SubjectFilterSheet(
        isPresented: .constant(true),
        availableConcepts: ["SELECT문", "함수", "WHERE절", "조인", "서브 쿼리", "DML"],
        initialSelectedConcepts: ["SELECT문", "함수"]
    )
}
