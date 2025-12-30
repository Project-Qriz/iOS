//
//  ProblemHeaderCardView.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

struct ProblemHeaderCardView: View {

    let data: ProblemHeaderData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection // 결과 아이콘 및 시험 제목
            infoSection  // 과목명 및 문제 번호
            tagSection  // 태그 영역
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.coolNeutral100), lineWidth: 1)
        )
        .overlay(alignment: .bottom) {
            TriangleBorder()
                .fill(Color.white)
                .overlay(
                    TriangleBorder()
                        .stroke(Color(.coolNeutral100), lineWidth: 1)
                )
                .frame(width: 20, height: 16)
                .offset(y: 15)
        }
    }
}

// MARK: - Subviews
private extension ProblemHeaderCardView {
    
    /// 정답 여부와 시험 제목
    var headerSection: some View {
        HStack(spacing: 14) {
            Text(data.isCorrect ? "✓" : "✕")
                .font(.system(size: 24))
                .foregroundColor(data.isCorrect ? .customMint600 : .customRed500)

            Text(data.examTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
        }
    }
    
    /// 과목명 | 문제 번호
    var infoSection: some View {
        HStack(spacing: 8) {
            Text(data.subject)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(.coolNeutral500))

            Rectangle()
                .fill(Color(.coolNeutral200))
                .frame(width: 1, height: 13)

            Text("\(data.questionNumber)번")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(.coolNeutral500))
        }
    }
    
    /// 태그 목록
    var tagSection: some View {
        HStack(spacing: 8) {
            ForEach(data.tags, id: \.self) { tag in
                TagChip(text: tag)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(.customBlue400))
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(.customBlue100))
            .cornerRadius(6)
    }
}

// MARK: - Triangle

private struct TriangleBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

// MARK: - Preview

#Preview {
    ProblemHeaderCardView(
        data: ProblemHeaderData(
            isCorrect: false,
            examTitle: "2023년도 모의고사",
            subject: "1과목",
            questionNumber: 5,
            tags: ["엔터티", "식별자"]
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
