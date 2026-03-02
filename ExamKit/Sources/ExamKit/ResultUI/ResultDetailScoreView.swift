//
//  ResultDetailScoreView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct ResultDetailScoreView: View {

    // MARK: - Properties
    @ObservedObject public var resultScoresData: ResultScoresData
    @ObservedObject public var resultDetailData: ResultDetailData
    private let rankColors: [Color] = [.customBlue900, .customBlue500, .customBlue300, .customBlue200, .customBlue100]

    private var rankOffset: Int {
        resultScoresData.selectedMenuItem == .total ? resultDetailData.subject1DetailResult.count : 0
    }

    // MARK: - Initializers
    public init(resultScoresData: ResultScoresData, resultDetailData: ResultDetailData) {
        self.resultScoresData = resultScoresData
        self.resultDetailData = resultDetailData
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: 32) {
            if resultScoresData.selectedMenuItem != .subject2 {
                ForEach(Array(resultDetailData.subject1DetailResult.enumerated()), id: \.offset) { idx, subject in
                    subjectSectionView(subject: subject, rank: idx)
                }
            }
            if resultScoresData.selectedMenuItem != .subject1 {
                ForEach(Array(resultDetailData.subject2DetailResult.enumerated()), id: \.offset) { idx, subject in
                    subjectSectionView(subject: subject, rank: rankOffset + idx)
                }
            }
        }
    }

    // MARK: - Methods
    @ViewBuilder
    private func subjectSectionView(subject: SubjectDetailData, rank: Int) -> some View {
        VStack(spacing: 11) {
            HStack {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(rankColor(at: rank))
                Text(subject.majorItem)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black)
                Spacer()
            }

            Spacer(minLength: 4)

            ForEach(Array(subject.minorItems.enumerated()), id: \.offset) { idx, item in
                VStack(spacing: 8) {
                    HStack {
                        Text(item.subItem)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.black)
                        Spacer()
                        Text("\(Int(item.score))점")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.coolNeutral800)
                    }
                    if idx != subject.minorItems.count - 1 {
                        Divider()
                            .overlay(Color.customBlue200)
                    }
                }
            }
        }
    }

    private func rankColor(at rank: Int) -> Color {
        guard rankColors.indices.contains(rank) else { return .white }
        return rankColors[rank]
    }
}

#Preview {
    let scoreData = ResultScoresData()
    let detailData = ResultDetailData()
    detailData.subject1DetailResult = [
        SubjectDetailData(majorItem: "데이터 모델링의 이해", score: 40, minorItems: [
            SubItemInfoEntity(subItem: "엔터티", score: 20),
            SubItemInfoEntity(subItem: "속성", score: 10),
            SubItemInfoEntity(subItem: "관계", score: 10)
        ]),
        SubjectDetailData(majorItem: "데이터 모델과 성능", score: 15, minorItems: [
            SubItemInfoEntity(subItem: "정규화", score: 10),
            SubItemInfoEntity(subItem: "반정규화", score: 5)
        ])
    ]
    detailData.subject2DetailResult = [
        SubjectDetailData(majorItem: "SQL 기본", score: 30, minorItems: [
            SubItemInfoEntity(subItem: "SELECT", score: 15),
            SubItemInfoEntity(subItem: "JOIN", score: 15)
        ]),
        SubjectDetailData(majorItem: "SQL 활용", score: 25, minorItems: [
            SubItemInfoEntity(subItem: "서브쿼리", score: 10),
            SubItemInfoEntity(subItem: "윈도우 함수", score: 15)
        ])
    ]
    return ResultDetailScoreView(resultScoresData: scoreData, resultDetailData: detailData)
}
