//
//  TestResultDetailViewModel.swift
//  ExamKit
//

import Foundation
import Combine
import QRIZUtils

@MainActor
public final class TestResultDetailViewModel {

    // MARK: - Enums

    public enum Input {
        case menuItemSelected(selected: ResultDetailMenuItems)
    }

    // MARK: - Properties

    public let resultDetailData: ResultDetailData
    public private(set) var resultScoresData: ResultScoresData = .init()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
        setScoresData(.total)
    }

    // MARK: - Methods

    public func transform(input: AnyPublisher<Input, Never>) {
        input
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .menuItemSelected(let selected):
                    setScoresData(selected)
                }
            }
            .store(in: &subscriptions)
    }

    private func setScoresData(_ selectedItem: ResultDetailMenuItems) {
        let subject1 = resultDetailData.subject1DetailResult
        let subject2 = resultDetailData.subject2DetailResult

        resetScoresData()

        switch selectedItem {
        case .total:
            resultScoresData.subjectCount = subject1.count + subject2.count
            fillScores(subject1)
            fillScores(subject2, startAt: subject1.count)
        case .subject1:
            resultScoresData.subjectCount = subject1.count
            fillScores(subject1)
        case .subject2:
            resultScoresData.subjectCount = subject2.count
            fillScores(subject2)
        }
    }

    private func resetScoresData() {
        for i in resultScoresData.subjectScores.indices {
            resultScoresData.subjectScores[i] = 0
        }
        resultScoresData.subjectCount = 0
    }

    private func fillScores(_ results: [SubjectDetailData], startAt offset: Int = 0) {
        for (i, result) in results.enumerated() {
            resultScoresData.subjectScores[offset + i] = result.score
        }
    }
}
