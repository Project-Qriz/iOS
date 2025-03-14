//
//  BarGraphsView.swift
//  QRIZ
//
//  Created by ch on 1/1/25.
//

import SwiftUI

struct PreviewResultBarGraphsView: View {
    
    @ObservedObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 72) {
                    Spacer()
                    ForEach(previewConceptsData.incorrectCountDataArr.filter { $0.id <= 3 }) { data in
                        VStack {
                            Text("\(data.topic[0])" + "\(getAdditionalNumberText(numOfConcepts: data.topic.count))")
                                .foregroundStyle(setBarColor(rank: data.id))
                                .font(.system(size: 14, weight: .bold))
                                .lineLimit(1)
                            Rectangle()
                                .foregroundStyle(setBarColor(rank: data.id))
                                .frame(width: 28, height: CGFloat(data.incorrectCount * 15))
                                .cornerRadius(8, corners: [.topLeft, .topRight])
                                .animation(.easeInOut(duration: 1), value: CGFloat(data.incorrectCount))
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 290)
            }
        }
    }
    
    private func setBarColor(rank: Int) -> Color {
        switch rank {
        case 1:
            return .customBlue500
        case 2:
            return .coolNeutral600
        case 3:
            return .coolNeutral200
        default:
            return .clear
        }
    }
    
    private func getAdditionalNumberText(numOfConcepts: Int) -> String {
        numOfConcepts == 1 ? "" : " + \(numOfConcepts)개"
    }
}

#Preview {
    PreviewResultBarGraphsView(previewConceptsData: PreviewConceptsData(
        totalQuestions: 20,
        incorrectCountDataArr: [
                    IncorrectCountData(id: 1, incorrectCount: 5, topic: ["DDL"]),
                    IncorrectCountData(id: 2, incorrectCount: 3, topic: ["조인"]),
                    IncorrectCountData(id: 3, incorrectCount: 1, topic: ["모델이 표현하는 트랜잭션의 이해"]),
        ],
        firstConcept: "",
        secondConcept: ""
    ))
}
