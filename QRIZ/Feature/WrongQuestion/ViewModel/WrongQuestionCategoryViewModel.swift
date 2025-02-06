//
//  WrongQuestionCategoryViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 2/5/25.
//

import Foundation
import Combine

final class WrongQuestionCategoryViewModel {
    
    enum Input {
        case cellClicked(section: Int, item: Int)
        case submitButtonClicked
    }
    
    enum Output {
        case setCellState(section: Int, item: Int, isAvailable: Bool, isClicked: Bool)
        case submitSuccess
        case submitFail
    }
    
    private var stateArr: [[WrongQuestionCategoryCellState]] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    init(stateArr: [[WrongQuestionCategoryCellState]]) {
        self.stateArr = stateArr
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .cellClicked(let section, let item):
                clickEventHandler(section, item)
            case .submitButtonClicked:
                // network
                output.send(.submitSuccess)
            }
        }
        .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func clickEventHandler(_ section: Int, _ item: Int) {
        if stateArr[section][item].isAvailable {
            output.send(.setCellState(
                section: section,
                item: item,
                isAvailable: true,
                isClicked: !stateArr[section][item].isClicked
            ))
            stateArr[section][item].isClicked.toggle()
        }
    }
    
    private func sendAllCellState() {
        for section in 0..<stateArr.count {
            for item in 0..<stateArr[section].count {
                output.send(.setCellState(
                    section: section,
                    item: item,
                    isAvailable: stateArr[section][item].isAvailable,
                    isClicked: stateArr[section][item].isClicked
                ))
            }
        }
    }
}
