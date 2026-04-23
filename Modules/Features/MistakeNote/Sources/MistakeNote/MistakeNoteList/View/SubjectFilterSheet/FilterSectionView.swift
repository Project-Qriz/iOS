//
//  FilterSectionView.swift
//  MistakeNote
//
//  Created by Claude on 1/31/26.
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct FilterSectionView: View {

    // MARK: - Properties

    public let chapter: Chapter
    public let availableConcepts: Set<String>
    @Binding public var selectedItems: Set<String>

    /// 해당 챕터에서 가용한 개념만 필터링 (공백 제거하여 비교)
    private var filteredConcepts: [String] {
        let normalizedAvailableConcepts = Set(availableConcepts.map { $0.normalizingConcept() })
        return chapter.concepts.filter { normalizedAvailableConcepts.contains($0.normalizingConcept()) }
    }

    // MARK: - Initialization

    public init(chapter: Chapter, availableConcepts: Set<String>, selectedItems: Binding<Set<String>>) {
        self.chapter = chapter
        self.availableConcepts = availableConcepts
        _selectedItems = selectedItems
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            FlowLayout(spacing: 8) {
                ForEach(filteredConcepts, id: \.self) { concept in
                    FilterChip(
                        title: concept,
                        isSelected: selectedItems.contains(concept)
                    ) {
                        toggleItem(concept)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var sectionHeader: some View {
        HStack {
            Text(chapter.rawValue)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.coolNeutral800)

            Spacer()

            Button {
                toggleAllItems()
            } label: {
                Text(isAllSelected ? "전체 해제" : "전체 선택")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.coolNeutral600)
            }
        }
    }

    // MARK: - Methods

    private var isAllSelected: Bool {
        let allFilteredConcepts = Set(filteredConcepts)
        return allFilteredConcepts.isSubset(of: selectedItems)
    }

    private func toggleAllItems() {
        let allFilteredConcepts = Set(filteredConcepts)

        if isAllSelected {
            selectedItems.subtract(allFilteredConcepts)
        } else {
            selectedItems.formUnion(allFilteredConcepts)
        }
    }

    private func toggleItem(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
}

// MARK: - Preview

#Preview {
    FilterSectionView(
        chapter: .sqlBasic,
        availableConcepts: ["SELECT문", "함수", "WHERE절"],
        selectedItems: .constant(["SELECT문", "함수"])
    )
    .padding()
}
