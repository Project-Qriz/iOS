//
//  ResultScoresDataTests.swift
//  ExamKitTests
//

import Testing
import QRIZUtils

@Suite("ResultScoresData 테스트")
struct ResultScoresDataTests {

    // MARK: - totalScore

    @Test("기본값은 0")
    func defaultTotalScoreIsZero() {
        let data = ResultScoresData()
        #expect(data.totalScore == 0)
    }

    @Test("subjectScores 합산")
    func totalScoreIsSum() {
        let data = ResultScoresData()
        data.subjectScores = [40, 20, 30, 0, 0]
        #expect(data.totalScore == 90)
    }

    @Test("모든 점수가 있을 때 합산")
    func totalScoreAllFilled() {
        let data = ResultScoresData()
        data.subjectScores = [20, 20, 20, 20, 20]
        #expect(data.totalScore == 100)
    }

    // MARK: - cumulativePercentage

    @Test("누적 퍼센트", arguments: [
        (idx: 0, expected: 0.4),
        (idx: 1, expected: 0.6),
        (idx: 2, expected: 0.9),
    ])
    func cumulativePercentage(idx: Int, expected: Double) {
        let data = ResultScoresData()
        data.subjectScores = [40, 20, 30, 0, 0]
        #expect(data.cumulativePercentage(idx: idx) == expected)
    }

    @Test("범위 밖 인덱스 → 0 반환", arguments: [-1, 5])
    func cumulativePercentageOutOfBounds(idx: Int) {
        let data = ResultScoresData()
        #expect(data.cumulativePercentage(idx: idx) == 0)
    }
}
