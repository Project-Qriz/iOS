//
//  ScoreGraphData.swift
//  QRIZUtils
//
//  Created by 이창현 on 5/27/25.
//

import Combine
import Foundation

public final class ScoreGraphData: ObservableObject {
    @Published public var filterType: ScoreGraphFilterType = .byTotalScore
    @Published public var totalScores: [GraphData] = []
    @Published public var indexedSubject1Scores: [IndexedGraphData] = []
    @Published public var indexedSubject2Scores: [IndexedGraphData] = []
    @Published public var subject1Scores: [GraphData] = []
    @Published public var subject2Scores: [GraphData] = []

    public init() {}

    public func convertGraphScoreData(_ historicalScores: [HistoricalScoreEntity]) {
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
}

public struct GraphData: Identifiable {
    public let id = UUID()
    public let date: Date
    public let score: Double
    public let type: String

    public init(date: Date, score: Double, type: String) {
        self.date = date
        self.score = score
        self.type = type
    }
}

public struct IndexedGraphData: Identifiable {
    public let id = UUID()
    public let index: Int
    public let date: Date
    public let score: Double
    public let type: String

    public init(index: Int, date: Date, score: Double, type: String) {
        self.index = index
        self.date = date
        self.score = score
        self.type = type
    }
}
