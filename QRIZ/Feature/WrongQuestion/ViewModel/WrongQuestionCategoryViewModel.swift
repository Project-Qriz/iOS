//
//  WrongQuestionCategoryViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 2/5/25.
//

import Foundation
import Combine

final class WrongQuestionCategoryViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case cellClicked(section: Int, item: Int)
        case resetButtonClicked
        case submitButtonClicked
    }
    
    enum Output {
        case setCellState(section: Int, item: Int, isAvailable: Bool, isClicked: Bool)
        case submitSuccess
        case submitFail
    }
    
    // MARK: - Properties
    private var stateArr: [[WrongQuestionCategoryCellState]] = []
    private var items: [[String]] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let totalButtonIdx: Int = 0
    
    // MARK: - Initializer
    init(stateArr: [[WrongQuestionCategoryCellState]], items: [[String]]) {
        self.stateArr = stateArr
        self.items = items
    }
    
    // MARK: - Methods
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .cellClicked(let section, let item):
                clickEventHandler(section, item)
            case .resetButtonClicked:
                print("ResetButtonClicked")
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
            item == totalButtonIdx ? totalClickEventHandler(section, item) : singleConceptClickEventHandler(section, item)
        }
    }
    
    private func totalClickEventHandler(_ section: Int, _ item: Int) {
        if stateArr[section][item].isClicked {
            toggleButtonState(section, item)
        } else {
            for idx in 1..<stateArr[section].count {
                if idx == item { continue }
                if stateArr[section][idx].isAvailable && stateArr[section][idx].isClicked {
                    toggleButtonState(section, idx)
                }
            }
            toggleButtonState(section, item)
        }
    }
    
    private func singleConceptClickEventHandler(_ section: Int, _ item: Int) {

        if stateArr[section][item].isClicked {
            toggleButtonState(section, item)
        } else {

            var availCount: Int = 0
            var isClicked: Int = 0

            for idx in 1..<stateArr[section].count {
                if stateArr[section][idx].isAvailable { availCount += 1 }
                if stateArr[section][idx].isClicked { isClicked += 1 }
            }

            if availCount == 1 {
                toggleButtonState(section, totalButtonIdx)
            } else {
                if availCount == isClicked + 1 {
                    toggleButtonState(section, totalButtonIdx)
                    for idx in 1..<stateArr[section].count {
                        if stateArr[section][idx].isClicked { toggleButtonState(section, idx) }
                    }
                } else {
                    if stateArr[section][totalButtonIdx].isClicked { toggleButtonState(section, totalButtonIdx) }
                    toggleButtonState(section, item)
                }
            }
        }
    }
    
    private func toggleButtonState(_ section: Int, _ item: Int) {
        output.send(.setCellState(
            section: section,
            item: item,
            isAvailable: true,
            isClicked: !stateArr[section][item].isClicked
        ))
        stateArr[section][item].isClicked.toggle()
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
