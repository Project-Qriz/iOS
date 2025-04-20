//
//  DailyResultDetailViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import Foundation
import Combine

final class DailyResultDetailViewModel: ResultDetailViewModel {
    
    // MARK: - Intializers
    init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
        super.init()
        self.setScoresData(.total)
    }
    
    // MARK: - Properties
    var resultDetailData: ResultDetailData
    var resultScoresData: ResultScoresData = .init()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<ResultDetailViewModel.Input, Never>) {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .menuItemSelected(let selected):
                self.setScoresData(selected)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func initScoresData() {
        for i in 0..<resultScoresData.subjectScores.count {
            resultScoresData.subjectScores[i] = 0
        }
        resultScoresData.subjectCount = 0
    }
    
    private func setScoresData(_ selectedItem: ResultDetailMenuItems) {
        let subject1Count: Int = resultDetailData.subject1DetailResult.count
        let subject2Count: Int = resultDetailData.subject2DetailResult.count

        initScoresData()
        
        switch selectedItem {
        case .total:
            resultScoresData.subjectCount = subject1Count + subject2Count
            for i in 0..<subject1Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject1DetailResult[i].score
            }
            for i in 0..<subject2Count {
                resultScoresData.subjectScores[resultDetailData.subject1DetailResult.count + i] = resultDetailData.subject2DetailResult[i].score
            }
        case .subject1:
            resultScoresData.subjectCount = subject1Count
            for i in 0..<subject1Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject1DetailResult[i].score
            }
        case .subject2:
            resultScoresData.subjectCount = subject2Count
            for i in 0..<subject2Count {
                resultScoresData.subjectScores[i] = resultDetailData.subject2DetailResult[i].score
            }
        }
    }
}
