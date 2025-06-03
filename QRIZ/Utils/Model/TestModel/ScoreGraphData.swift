//
//  ScoreGraphData.swift
//  QRIZ
//
//  Created by 이창현 on 5/27/25.
//

import Foundation

final class ScoreGraphData: ObservableObject {
    @Published var filterType: ScoreGraphFilterType = .byTotalScore
    @Published var totalScores: [GraphData] = []
    @Published var subjectScores: [GraphData] = []
    
    func convertGraphScoreData(_ historicalScores : [HistoricalScore]) {
        if historicalScores.isEmpty { return }
        historicalScores.forEach {
            totalScores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[0].score + $0.itemScores[1].score,
                type: ""
            ))
            subjectScores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[0].score,
                type: "1과목"
            ))
            subjectScores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[1].score,
                type: "2과목"
            ))
        }
    }
    
}

struct GraphData {
    let date: Date
    let score: Double
    let type: String
}
