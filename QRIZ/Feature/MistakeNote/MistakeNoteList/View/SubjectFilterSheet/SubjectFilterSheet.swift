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
    @State private var selectedSubject: Subject = .one
    @State private var selectedConcepts: Set<String> = []

    var onApply: ((Set<String>) -> Void)?

    private var hasSelections: Bool {
        !selectedConcepts.isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SubjectTabSelector(selectedSubject: $selectedSubject)
                .padding(.top, 29)

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
                ForEach(selectedSubject.chapters, id: \.self) { chapter in
                    FilterSectionView(
                        chapter: chapter,
                        selectedItems: $selectedConcepts
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
        Button(action: resetSelections) {
            Text("초기화")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(hasSelections ? Color(uiColor: .coolNeutral700) : Color(uiColor: .coolNeutral400))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(uiColor: .coolNeutral700), lineWidth: 1)
                )
        }
        .frame(width: 80)
        .disabled(!hasSelections)
    }

    var applyButton: some View {
        Button(action: applySelections) {
            Text("적용하기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(hasSelections ? .white : Color(uiColor: .coolNeutral500))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(hasSelections ? Color(uiColor: .customBlue500) : Color(uiColor: .coolNeutral200))
                .cornerRadius(8)
        }
        .disabled(!hasSelections)
    }
}

// MARK: - Private Methods

private extension SubjectFilterSheet {

    func resetSelections() {
        selectedConcepts.removeAll()
    }

    func applySelections() {
        onApply?(selectedConcepts)
        isPresented = false
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
    SubjectFilterSheet(isPresented: .constant(true))
}
