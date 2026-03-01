//
//  TestResultDetailViewModelTests.swift
//  ExamKitTests
//

import Testing
import Foundation
import Combine
@testable import ExamKit
import QRIZUtils

@MainActor
@Suite("TestResultDetailViewModel 테스트", .serialized)
struct TestResultDetailViewModelTests {

    // MARK: - Helpers

    private func makeSubject(majorItem: String, score: Double) -> SubjectDetailData {
        SubjectDetailData(majorItem: majorItem, score: score, minorItems: [])
    }

    private func makeDetailData(
        subject1: [SubjectDetailData],
        subject2: [SubjectDetailData] = []
    ) -> ResultDetailData {
        let data = ResultDetailData()
        data.subject1DetailResult = subject1
        data.subject2DetailResult = subject2
        return data
    }

    /// receive(on: DispatchQueue.main) 비동기 처리를 위해 메인 RunLoop flush
    private func waitForMainQueue() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            RunLoop.main.perform { continuation.resume() }
        }
    }

    // MARK: - 초기화

    @Test("초기화 시 total 메뉴로 subject1 + subject2 점수 반영")
    func initSetsAllScores() {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 40), makeSubject(majorItem: "B", score: 20)],
            subject2: [makeSubject(majorItem: "C", score: 30)]
        )

        let sut = TestResultDetailViewModel(resultDetailData: detailData)

        #expect(sut.resultScoresData.subjectScores[0] == 40)
        #expect(sut.resultScoresData.subjectScores[1] == 20)
        #expect(sut.resultScoresData.subjectScores[2] == 30)
        #expect(sut.resultScoresData.subjectCount == 3)
    }

    @Test("초기화 시 subject2가 없으면 subject1만 반영")
    func initWithOnlySubject1() {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 50)]
        )

        let sut = TestResultDetailViewModel(resultDetailData: detailData)

        #expect(sut.resultScoresData.subjectScores[0] == 50)
        #expect(sut.resultScoresData.subjectCount == 1)
    }

    // MARK: - menuItemSelected

    @Test("subject1 선택 시 subject1 점수만 반영, 나머지 0")
    func selectSubject1OnlyFillsSubject1Scores() async {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 40), makeSubject(majorItem: "B", score: 20)],
            subject2: [makeSubject(majorItem: "C", score: 30)]
        )
        let sut = TestResultDetailViewModel(resultDetailData: detailData)
        let inputSubject = PassthroughSubject<TestResultDetailViewModel.Input, Never>()
        sut.transform(input: inputSubject.eraseToAnyPublisher())

        inputSubject.send(.menuItemSelected(selected: .subject1))
        await waitForMainQueue()

        #expect(sut.resultScoresData.subjectScores[0] == 40)
        #expect(sut.resultScoresData.subjectScores[1] == 20)
        #expect(sut.resultScoresData.subjectScores[2] == 0)
        #expect(sut.resultScoresData.subjectCount == 2)
    }

    @Test("subject2 선택 시 subject2 점수가 index 0부터 반영")
    func selectSubject2StartsFromIndex0() async {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 40)],
            subject2: [makeSubject(majorItem: "B", score: 30), makeSubject(majorItem: "C", score: 25)]
        )
        let sut = TestResultDetailViewModel(resultDetailData: detailData)
        let inputSubject = PassthroughSubject<TestResultDetailViewModel.Input, Never>()
        sut.transform(input: inputSubject.eraseToAnyPublisher())

        inputSubject.send(.menuItemSelected(selected: .subject2))
        await waitForMainQueue()

        #expect(sut.resultScoresData.subjectScores[0] == 30)
        #expect(sut.resultScoresData.subjectScores[1] == 25)
        #expect(sut.resultScoresData.subjectScores[2] == 0)
        #expect(sut.resultScoresData.subjectCount == 2)
    }

    @Test("total 선택 시 subject1 이후 offset에 subject2 반영")
    func selectTotalPlacesSubject2AfterSubject1() async {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 40), makeSubject(majorItem: "B", score: 20)],
            subject2: [makeSubject(majorItem: "C", score: 30), makeSubject(majorItem: "D", score: 10)]
        )
        let sut = TestResultDetailViewModel(resultDetailData: detailData)
        let inputSubject = PassthroughSubject<TestResultDetailViewModel.Input, Never>()
        sut.transform(input: inputSubject.eraseToAnyPublisher())

        inputSubject.send(.menuItemSelected(selected: .subject1))
        await waitForMainQueue()
        inputSubject.send(.menuItemSelected(selected: .total))
        await waitForMainQueue()

        #expect(sut.resultScoresData.subjectScores[0] == 40)
        #expect(sut.resultScoresData.subjectScores[1] == 20)
        #expect(sut.resultScoresData.subjectScores[2] == 30)
        #expect(sut.resultScoresData.subjectScores[3] == 10)
        #expect(sut.resultScoresData.subjectCount == 4)
    }

    @Test("메뉴 전환 시 이전 점수 초기화 후 새 점수로 대체")
    func menuSwitchResetsOldScores() async {
        let detailData = makeDetailData(
            subject1: [makeSubject(majorItem: "A", score: 50), makeSubject(majorItem: "B", score: 30)],
            subject2: [makeSubject(majorItem: "C", score: 20)]
        )
        let sut = TestResultDetailViewModel(resultDetailData: detailData)
        let inputSubject = PassthroughSubject<TestResultDetailViewModel.Input, Never>()
        sut.transform(input: inputSubject.eraseToAnyPublisher())

        // total → subject2로 전환
        inputSubject.send(.menuItemSelected(selected: .subject2))
        await waitForMainQueue()

        // subject1 자리에 subject2 점수, 이전 subject1 점수(index 1)는 0
        #expect(sut.resultScoresData.subjectScores[0] == 20)
        #expect(sut.resultScoresData.subjectScores[1] == 0)
        #expect(sut.resultScoresData.subjectCount == 1)
    }
}
