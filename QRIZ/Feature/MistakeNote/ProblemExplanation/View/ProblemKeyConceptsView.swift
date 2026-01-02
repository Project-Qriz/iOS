//
//  ProblemKeyConceptsView.swift
//  QRIZ
//
//  Created by Claude on 1/2/26.
//

import SwiftUI

struct ProblemKeyConceptsView: View {

    let keyConcepts: String
    let subject: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            title // 타이틀
            conceptsContent // 활용된 개념 내용
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews

private extension ProblemKeyConceptsView {

    /// "활용된 개념" 타이틀
    var title: some View {
        Text("활용된 개념")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(.coolNeutral800))
    }

    /// 활용된 개념 카드 목록
    var conceptsContent: some View {
        VStack(spacing: 8) {
            ForEach(conceptTags, id: \.self) { concept in
                ConceptCard(concept: concept, subject: subject)
            }
        }
    }

    /// keyConcepts를 쉼표로 분리하여 태그 배열로 변환
    var conceptTags: [String] {
        keyConcepts.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

// MARK: - Concept Card

private struct ConceptCard: View {
    let concept: String
    let subject: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(concept)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.coolNeutral700))

                Text(subject)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.coolNeutral500))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.coolNeutral800))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.coolNeutral200), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    ProblemKeyConceptsView(keyConcepts: "엔터티, 식별자", subject: "1과목")
        .padding()
        .background(Color(.systemGroupedBackground))
}
