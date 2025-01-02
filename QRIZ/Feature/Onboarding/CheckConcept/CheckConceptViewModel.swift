//
//  CheckConceptViewModel.swift
//  QRIZ
//
//  Created by ch on 12/15/24.
//

import Foundation
import Combine

final class CheckConceptViewModel {
    
    enum Input {
        case didDoneButtonClicked
        case someCheckboxClicked(idx: Int)
    }
    
    enum Output {
        case moveToNextPage
        case checkboxToOn(idx: Int)
        case checkboxToOff(idx: Int)
        case setDoneButtonState(isActive: Bool)
        case requestFailed
    }
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    private(set) var selectedSet = Set<Int>()
    private var isSelectedSetEmpty: Bool = false
    private var isSelectedSetFull: Bool = false
    private var isDoneButtonActivated: Bool = false
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didDoneButtonClicked:
                // API request send
                if isSelectedSetEmpty || selectedSet.count > 0 {
                    self.output.send(.moveToNextPage)
                }
            case .someCheckboxClicked(let idx):
                checkboxStateHandler(idx)
                doneButtonStateHandler()
            }
        }
        .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func checkboxStateHandler(_ idx: Int) {
        
        if selectedSet.contains(idx) {
            if idx == 0 {
                isSelectedSetEmpty = false
            } else if idx == 1 {
                isSelectedSetFull = false
                for i in 2..<SurveyCheckList.list.count {
                    selectedSet.remove(i)
                    self.output.send(.checkboxToOff(idx: i))
                }
            } else if idx != 0 && isSelectedSetFull {
                isSelectedSetFull = false
                selectedSet.remove(1)
                self.output.send(.checkboxToOff(idx: 1))
            }
            selectedSet.remove(idx)
            self.output.send(.checkboxToOff(idx: idx))
        } else {
            if idx == 0 {
                isSelectedSetEmpty = true
                if selectedSet.count > 0 {
                    if isSelectedSetFull { isSelectedSetFull = false }
                    selectedSet.removeAll()
                    for i in 1..<SurveyCheckList.list.count { output.send(.checkboxToOff(idx: i)) }
                }
            } else {
                if idx == 1 {
                    isSelectedSetFull = true
                    for i in 2..<SurveyCheckList.list.count {
                        selectedSet.insert(i)
                        output.send(.checkboxToOn(idx: i))
                    }
                }
                if isSelectedSetEmpty {
                    isSelectedSetEmpty = false
                    selectedSet.remove(0)
                    output.send(.checkboxToOff(idx: 0))
                }
            }
            selectedSet.insert(idx)
            self.output.send(.checkboxToOn(idx: idx))
            if selectedSet.count == SurveyCheckList.list.count - 2 && !isSelectedSetFull && !isSelectedSetEmpty {
                isSelectedSetFull = true
                output.send(.checkboxToOn(idx: 1))
            }
        }
    }
    
    private func doneButtonStateHandler() {
        if isDoneButtonActivated {
            if selectedSet.count == 0 {
                isDoneButtonActivated = false
                output.send(.setDoneButtonState(isActive: false))
            }
        } else {
            if selectedSet.count > 0 {
                isDoneButtonActivated = true
                output.send(.setDoneButtonState(isActive: true))
            }
        }
    }
}
