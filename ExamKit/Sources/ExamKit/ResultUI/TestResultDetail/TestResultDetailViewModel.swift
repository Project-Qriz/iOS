//
//  TestResultDetailViewModel.swift
//  ExamKit
//

import Foundation
import Combine
import QRIZUtils

@MainActor
public final class TestResultDetailViewModel: ResultDetailViewModel {

    // MARK: - Properties
    public var resultDetailData: ResultDetailData
    public var resultScoresData: ResultScoresData = .init()

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initializers
    public init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
        super.init()
        Task { [weak self] in
            guard let self else { return }
            await setScoresData(.total)
        }
    }

    // MARK: - Methods
    public func transform(input: AnyPublisher<ResultDetailViewModel.Input, Never>) {
        input
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .menuItemSelected(let selected):
                    Task { [weak self] in
                        guard let self else { return }
                        await setScoresData(selected)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func initScoresData() {
        for i in 0..<self.resultScoresData.subjectScores.count {
            self.resultScoresData.subjectScores[i] = 0
        }
        self.resultScoresData.subjectCount = 0
    }

    @MainActor
    private func setScoresData(_ selectedItem: ResultDetailMenuItems) {
        let subject1Count: Int = self.resultDetailData.subject1DetailResult.count
        let subject2Count: Int = self.resultDetailData.subject2DetailResult.count

        self.initScoresData()

        switch selectedItem {
        case .total:
            self.resultScoresData.subjectCount = subject1Count + subject2Count
            for i in 0..<subject1Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject1DetailResult[i].score
            }
            for i in 0..<subject2Count {
                resultScoresData.subjectScores[subject1Count + i] = resultDetailData.subject2DetailResult[i].score
            }
        case .subject1:
            self.resultScoresData.subjectCount = subject1Count
            for i in 0..<subject1Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject1DetailResult[i].score
            }
        case .subject2:
            self.resultScoresData.subjectCount = subject2Count
            for i in 0..<subject2Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject2DetailResult[i].score
            }
        }
    }
}
