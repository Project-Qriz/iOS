//
//  HistoricalScoreEntity.swift
//  QRIZUtils
//
//  Created by 김세훈 on 2/22/26.
//

public struct HistoricalScoreEntity: Comparable, Sendable {
    public let completionDateTime: String
    public let itemScores: [ItemScoreEntity]
    public let attemptCount: Int
    public let displayDate: String

    public init(
        completionDateTime: String,
        itemScores: [ItemScoreEntity],
        attemptCount: Int,
        displayDate: String
    ) {
        self.completionDateTime = completionDateTime
        self.itemScores = itemScores
        self.attemptCount = attemptCount
        self.displayDate = displayDate
    }

    public static func < (lhs: HistoricalScoreEntity, rhs: HistoricalScoreEntity) -> Bool {
        lhs.displayDate < rhs.displayDate
    }

    public static func == (lhs: HistoricalScoreEntity, rhs: HistoricalScoreEntity) -> Bool {
        lhs.displayDate == rhs.displayDate
    }
}

public struct ItemScoreEntity: Sendable {
    public let type: String
    public let score: Double

    public init(type: String, score: Double) {
        self.type = type
        self.score = score
    }
}
