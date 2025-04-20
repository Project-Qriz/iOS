//
//  DailyResultDetailViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import Foundation
import Combine

final class DailyResultDetailViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case menuItemSelected(selected: ResultDetailMenuItems)
    }
    
    enum Output {
    }
    
    // MARK: - Intializers
    init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
        
    }
    
    // MARK: - Properties
    var resultDetailData: ResultDetailData
    var resultScoresData: ResultScoresData = .init()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let _ = self else { return }
            switch event {
            case .menuItemSelected(let selected):
                print("\(selected.rawValue)")
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func initScoresData() {
        for i in 0..<resultScoresData.subjectScores.count {
            resultScoresData.subjectScores[i] = 0
        }
        resultScoresData.subjectCount = 0
    }
    
    private func setScoresData(_ selectedItem: ResultDetailMenuItems) {
        switch selectedItem {
        case .total:
            
        case .subject1:
            
        case .subject2:
            
        }
    }
}
