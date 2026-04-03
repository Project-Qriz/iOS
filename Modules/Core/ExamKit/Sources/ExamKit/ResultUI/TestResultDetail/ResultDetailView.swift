//
//  ResultDetailView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import Combine
import QRIZUtils

public struct ResultDetailView: View {

    @ObservedObject public var resultScoresData: ResultScoresData
    @ObservedObject public var resultDetailData: ResultDetailData
    public let input: PassthroughSubject<TestResultDetailViewModel.Input, Never> = .init()

    public init(resultScoresData: ResultScoresData, resultDetailData: ResultDetailData) {
        self.resultScoresData = resultScoresData
        self.resultDetailData = resultDetailData
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    Text("개념별 점수 분석")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.coolNeutral800)
                    Spacer()
                }

                Spacer(minLength: 14)

                HStack(spacing: 0) {
                    Menu {
                        ForEach(ResultDetailMenuItems.allCases, id: \.self) { item in
                            Button(action: {
                                resultScoresData.selectedMenuItem = item
                                input.send(.menuItemSelected(selected: item))
                            }) {
                                Text(item.rawValue)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(resultScoresData.selectedMenuItem.rawValue)
                                .foregroundStyle(Color.coolNeutral600)
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 9, height: 4)
                                .foregroundStyle(Color.coolNeutral600)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                }

                Spacer(minLength: 24)

                ResultScoreCircularChartView(resultScoresData: resultScoresData)
                    .frame(width: 164, height: 164)

                Spacer(minLength: 32)

                ResultDetailScoreView(resultScoresData: resultScoresData, resultDetailData: resultDetailData)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 18)
            .background(.white)
        }
        .background(.white)
    }
}

#Preview {
    ResultDetailView(resultScoresData: ResultScoresData(), resultDetailData: ResultDetailData())
}
