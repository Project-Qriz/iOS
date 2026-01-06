//
//  ProblemQuestionSectionView.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

struct ProblemQuestionSectionView: View {
    
    let data: ProblemQuestionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            title // 타이틀
            
            VStack(alignment: .leading, spacing: 16) {
                questionHeader // 질문 텍스트
                
                if let description = data.description, !description.isEmpty {
                    descriptionBox(description)
                }
                
                optionsList // 사지선다
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.coolNeutral200), lineWidth: 1.5)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews

extension ProblemQuestionSectionView {
    
    /// "문제" 타이틀
    var title: some View {
        Text("문제")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(.coolNeutral800))
    }
    
    /// 문제 번호와 질문 텍스트
    var questionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(String(format: "%02d", data.questionNumber)).")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
            
            Text(data.questionText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(.coolNeutral800))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    /// 추가 설명 (SQL 코드)
    func descriptionBox(_ description: String) -> some View {
        Text(description)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundColor(Color(.coolNeutral800))
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    /// 선택지 목록 (사지선다)
    var optionsList: some View {
        VStack(spacing: 4) {
            ForEach(data.options, id: \.number) { option in
                ProblemOptionView(option: option)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ProblemQuestionSectionView(
            data: MockDailyResultData.incorrectSample.questionData
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
