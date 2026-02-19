//
//  ScoreGraphData.swift
//  QRIZ
//
//  Created by 이창현 on 5/27/25.
//

import Foundation
import QRIZUtils
import Network

final class ScoreGraphData: ObservableObject {
    @Published var filterType: ScoreGraphFilterType = .byTotalScore
    @Published var totalScores: [GraphData] = []
    var subject1Scores: [GraphData] = []
    var subject2Scores: [GraphData] = []
    @Published var indexedSubject1Scores: [IndexedGraphData] = []
    @Published var indexedSubject2Scores: [IndexedGraphData] = []
    
    func convertGraphScoreData(_ historicalScores: [HistoricalScore]) {
        guard !historicalScores.isEmpty else { return }

        for (idx, score) in historicalScores.enumerated() {
            let date = score.displayDate.graphDate
            let score1 = score.itemScores[0].score
            let score2 = score.itemScores[1].score

            totalScores.append(GraphData(date: date, score: score1 + score2, type: ""))
            subject1Scores.append(GraphData(date: date, score: score1, type: "1과목"))
            subject2Scores.append(GraphData(date: date, score: score2, type: "2과목"))
            indexedSubject1Scores.append(IndexedGraphData(index: idx, date: date, score: score1, type: "1과목"))
            indexedSubject2Scores.append(IndexedGraphData(index: idx, date: date, score: score2, type: "2과목"))
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
