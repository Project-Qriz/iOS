//
//  CheckConceptViewModel.swift
//  QRIZ
//
//  Created by ch on 12/15/24.
//

import Foundation
import Combine

final class CheckConceptViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case checkAllClicked
        case checkNoneClicked(isOn: Bool)
        case someCheckboxClicked(idx: Int)
        case didDoneButtonClicked
    }
    
    enum Output {
        case moveToNextPage
        case setAllAndNone(numOfSelectedConcept: Int, checkNoneClicked: Bool)
        case checkboxToOn(idx: Int)
        case checkboxToOff(idx: Int)
        case setDoneButtonState(isActive: Bool)
        case requestFailed
    }
    
    // MARK: - Properties
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) var selectedSet = Set<Int>()
    private var numOfSelectedConcept: Int = 0
    private var isDoneButtonActivated: Bool = false
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .checkAllClicked:
                allStateHandler()
                doneButtonStateHandler()
            case .checkNoneClicked(let isOn):
                noneStateHandler()
                doneButtonStateHandler(checkNoneClicked: isOn)
            case .didDoneButtonClicked:
                // API request send
                if isDoneButtonActivated {
                    self.output.send(.moveToNextPage)
                }
            case .someCheckboxClicked(let idx):
                conceptStateHandler(idx)
                output.send(.setAllAndNone(numOfSelectedConcept: numOfSelectedConcept, checkNoneClicked: false))
                doneButtonStateHandler()
            }
        }
        .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func allStateHandler() {
        if numOfSelectedConcept == SurveyCheckList.list.count {
            iterConceptHandler(toSelected: false)
            output.send(.setAllAndNone(numOfSelectedConcept: numOfSelectedConcept, checkNoneClicked: false))
        } else {
            iterConceptHandler(toSelected: true)
            output.send(.setAllAndNone(numOfSelectedConcept: numOfSelectedConcept, checkNoneClicked: false))
        }
    }
    
    private func noneStateHandler() {
        iterConceptHandler(toSelected: false)
        output.send(.setAllAndNone(numOfSelectedConcept: numOfSelectedConcept, checkNoneClicked: true))
    }
    
    private func conceptStateHandler(_ idx: Int) {
        selectedSet.contains(idx) ? deselectConceptHandler(idx) : selectConceptHandler(idx)
    }
    
    private func iterConceptHandler(toSelected: Bool) {
        for idx in 0..<SurveyCheckList.list.count {
            toSelected ? selectConceptHandler(idx) : deselectConceptHandler(idx)
        }
    }
    
    private func deselectConceptHandler(_ idx: Int) {
        if selectedSet.contains(idx) {
            numOfSelectedConcept -= 1
            selectedSet.remove(idx)
            output.send(.checkboxToOff(idx: idx))
        }
    }
    
    private func selectConceptHandler(_ idx: Int) {
        if !selectedSet.contains(idx) {
            numOfSelectedConcept += 1
            selectedSet.insert(idx)
            output.send(.checkboxToOn(idx: idx))
        }
    }
    
    private func doneButtonStateHandler(checkNoneClicked: Bool = false) {
        if checkNoneClicked {
            if !isDoneButtonActivated {
                isDoneButtonActivated = true
                output.send(.setDoneButtonState(isActive: true))
            }
        } else {
            if numOfSelectedConcept == 0 {
                if isDoneButtonActivated {
                    isDoneButtonActivated = false
                    output.send(.setDoneButtonState(isActive: false))
                }
            } else {
                if !isDoneButtonActivated {
                    isDoneButtonActivated = true
                    output.send(.setDoneButtonState(isActive: true))
                }
            }
        }
    }
}
