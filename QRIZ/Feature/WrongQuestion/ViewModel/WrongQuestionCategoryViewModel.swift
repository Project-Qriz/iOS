//
//  WrongQuestionCategoryViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 2/5/25.
//

import Foundation
import Combine

struct CellState {
    var isAvailable: Bool = true
    var isClicked: Bool = false
}

final class WrongQuestionCategoryViewModel {
    
    enum Input {
        case viewWillAppear
        case cellClicked(section: Int, item: Int)
        case submitButtonClicked
    }
    
    enum Output {
        case setCellState(section: Int, item: Int, isAvailable: Bool, isClicked: Bool)
        case submitSuccess
        case submitFail
    }
    
    private var stateArr: [[CellState]] = []
    private var items: [[String]] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    init(conceptSet: Set<String>, items: [[String]]) {
        self.items = items
        setStateArr(conceptSet: conceptSet)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewWillAppear:
                sendAllCellState()
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
    
    private func setStateArr(conceptSet: Set<String>) {
        for row in items {
            var arr: [CellState] = []
            var count: Int = 0
            for elem in row {
                if conceptSet.contains(elem) {
                    arr.append(CellState())
                    count += 1
                } else {
                    arr.append(CellState(isAvailable: false))
                }
            }
            if count > 0 {
                arr[0].isAvailable = true
                arr[0].isClicked = true
            }
            stateArr.append(arr)
        }
    }
}
