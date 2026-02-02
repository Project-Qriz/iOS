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
    @Binding var selectedItems: Set<String>
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            
            FlowLayout(spacing: 8) {
                ForEach(chapter.concepts, id: \.self) { concept in
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
        let allConcepts = Set(chapter.concepts)
        return allConcepts.isSubset(of: selectedItems)
    }
    
    private func toggleAllItems() {
        let allConcepts = Set(chapter.concepts)
        
        if isAllSelected {
            selectedItems.subtract(allConcepts)
        } else {
            selectedItems.formUnion(allConcepts)
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
        selectedItems: .constant(["SELECT문", "함수"])
    )
    .padding()
}
