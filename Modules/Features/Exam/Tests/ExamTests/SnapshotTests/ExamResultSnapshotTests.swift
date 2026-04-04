//
//  ExamResultSnapshotTests.swift
//  QRIZ
//

import UIKit
import SwiftUI
import XCTest
import SnapshotTesting
@testable import Exam
import QRIZUtils

@MainActor
class ExamResultSnapshotTests: ExamSnapshotTestCase {

    // MARK: - ExamResultScoreView

    func testExamResultScoreView_empty() {
        let vc = makeResultScoreVC(resultScoresData: ResultScoresData())
        assertSnapshot(of: vc, as: .image)
    }

    func testExamResultScoreView_withData() {
        let data = makeResultScoresData(nickname: "테스터", subjectCount: 2, scores: [80.0, 70.0, 0.0, 0.0, 0.0])
        let vc = makeResultScoreVC(resultScoresData: data)
        assertSnapshot(of: vc, as: .image)
    }

    // MARK: - ExamScoresGraphView

    func testExamScoresGraphView_byTotalScore() {
        // height 500: 총점 차트 단독 표시
        let vc = makeScoresGraphVC(scoreGraphData: makeScoreGraphData(count: 3, filterType: .byTotalScore), height: 500)
        assertSnapshot(of: vc, as: .image)
    }

    func testExamScoresGraphView_bySubject() {
        // height 540: bySubject는 과목별 범례 row(~40pt)가 추가되어 총점 차트보다 높이 필요
        let vc = makeScoresGraphVC(scoreGraphData: makeScoreGraphData(count: 3, filterType: .bySubject), height: 540)
        assertSnapshot(of: vc, as: .image)
    }

    // MARK: - Helpers

    private func makeResultScoresData(
        nickname: String,
        subjectCount: Int,
        scores: [Double]
    ) -> ResultScoresData {
        let data = ResultScoresData()
        data.nickname = nickname
        data.subjectCount = subjectCount
        zip(data.subjectScores.indices, scores).forEach { data.subjectScores[$0] = $1 }
        return data
    }

    private func makeResultScoreVC(resultScoresData: ResultScoresData) -> UIViewController {
        let vc = UIHostingController(rootView: ExamResultScoreView(
            resultScoresData: resultScoresData,
            resultDetailData: ResultDetailData(),
            onDetailTap: {}
        ))
        // height 600: 점수 카드 영역 + 등급 목록 헤더까지 포함
        vc.view.frame = CGRect(origin: .zero, size: CGSize(width: Self.deviceSize.width, height: 600))
        vc.view.layoutIfNeeded()
        return vc
    }

    private func makeScoresGraphVC(scoreGraphData: ScoreGraphData, height: CGFloat) -> UIViewController {
        let vc = UIHostingController(rootView: ExamScoresGraphView(scoreGraphData: scoreGraphData))
        vc.view.frame = CGRect(origin: .zero, size: CGSize(width: Self.deviceSize.width, height: height))
        vc.view.layoutIfNeeded()
        return vc
    }

    private func makeScoreGraphData(count: Int, filterType: ScoreGraphFilterType) -> ScoreGraphData {
        let data = ScoreGraphData()
        data.filterType = filterType
        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        for i in 0..<count {
            let date = calendar.date(byAdding: .month, value: i, to: baseDate)!
            let score = Double(60 + i * 10)
            data.totalScores.append(GraphData(date: date, score: score, type: ""))
            data.subject1Scores.append(GraphData(date: date, score: score * 0.6, type: "1과목"))
            data.subject2Scores.append(GraphData(date: date, score: score * 0.4, type: "2과목"))
            data.indexedSubject1Scores.append(IndexedGraphData(index: i, date: date, score: score * 0.6, type: "1과목"))
            data.indexedSubject2Scores.append(IndexedGraphData(index: i, date: date, score: score * 0.4, type: "2과목"))
        }
        return data
    }
}
