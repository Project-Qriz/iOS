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
    var subject1Scores: [GraphData] = []
    var subject2Scores: [GraphData] = []
    @Published var indexedSubject1Scores: [IndexedGraphData] = []
    @Published var indexedSubject2Scores: [IndexedGraphData] = []
    
    func convertGraphScoreData(_ historicalScores : [HistoricalScore]) {
        if historicalScores.isEmpty { return }
        historicalScores.forEach {
            totalScores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[0].score + $0.itemScores[1].score,
                type: ""
            ))
            subject1Scores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[0].score,
                type: "1과목"
            ))
            subject2Scores.append(GraphData(
                date: $0.displayDate.graphDate,
                score: $0.itemScores[1].score,
                type: "2과목"
            ))
        }
        indexedSubject1Scores = subject1Scores.enumerated().map { idx, item in
            IndexedGraphData(index: idx, date: item.date, score: item.score, type: "1과목")
        }
        indexedSubject2Scores = subject2Scores.enumerated().map { idx, item in
            IndexedGraphData(index: idx, date: item.date, score: item.score, type: "2과목")
        }
    }
    
    init() { }
}

struct GraphData {
    let date: Date
    let score: Double
    let type: String
}

struct IndexedGraphData: Identifiable {
    let id = UUID()
    let index: Int
    let date: Date
    let score: Double
    let type: String
}
