//
//  FilterSectionView.swift
//  QRIZ
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct FilterSectionView: View {

    // MARK: - Properties

    let chapter: Chapter
    let availableConcepts: Set<String>
    @Binding var selectedItems: Set<String>

    /// 해당 챕터에서 가용한 개념만 필터링 (공백 제거하여 비교)
    private var filteredConcepts: [String] {
        let normalizedAvailableConcepts = Set(availableConcepts.map { normalizeConceptName($0) })
        return chapter.concepts.filter { normalizedAvailableConcepts.contains(normalizeConceptName($0)) }
    }

    /// 개념 이름 정규화 (공백 제거)
    private func normalizeConceptName(_ name: String) -> String {
        name.replacingOccurrences(of: " ", with: "")
    }

    // MARK: - Body

    var body: some View {
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
                .foregroundColor(Color(uiColor: .coolNeutral800))

            Spacer()

            Button {
                toggleAllItems()
            } label: {
                Text(isAllSelected ? "전체 해제" : "전체 선택")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(uiColor: .coolNeutral600))
            }
        }
    }

    // MARK: - Private Methods

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

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: totalWidth, height: totalHeight), positions)
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
