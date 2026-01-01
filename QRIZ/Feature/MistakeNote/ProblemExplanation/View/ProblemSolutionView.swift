//
//  ProblemSolutionView.swift
//  QRIZ
//
//  Created by Claude on 12/31/25.
//

import SwiftUI

struct ProblemSolutionView: View {

    let keyConcepts: String
    let solutionText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            title // 타이틀
            solutionContent // 풀이 내용
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews

private extension ProblemSolutionView {

    /// "풀이" 타이틀
    var title: some View {
        Text("풀이")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(.coolNeutral800))
    }

    /// 풀이 내용 박스
    var solutionContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 주제
            Text(keyConcepts)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))

            // 구분선
            Divider()
                .background(Color(.coolNeutral200))

            // 풀이 내용
            Text(solutionText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.coolNeutral200), lineWidth: 1.5)
        )
    }
}

// MARK: - Preview

#Preview {
    ProblemSolutionView(
        keyConcepts: "조인",
        solutionText: """
        최적의 해결방안 선택 이유:
        1. FULL OUTER JOIN으로 모든 케이스 포함
        2. NVL로 NULL 부서명 처리
        3. COUNT(employee_id)로 정확한 직원 수 계산
        4. CASE 식으로 NULL 정렬 처리
        5. ORDER BY로 정렬 요건 충족
        """
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
