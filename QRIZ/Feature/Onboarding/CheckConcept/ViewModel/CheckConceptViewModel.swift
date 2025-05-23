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
        case moveToBeginPreviewTest
        case moveToGreeting
        case setAllAndNone(numOfSelectedConcept: Int, checkNoneClicked: Bool)
        case checkboxToOn(idx: Int)
        case checkboxToOff(idx: Int)
        case setDoneButtonState(isActive: Bool)
        case requestFailed
    }
    
    // MARK: - Properties
    private(set) var selectedSet = Set<Int>()
    private var isDoneButtonActivated: Bool = false
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let onboardingService: OnboardingService
    
    // MARK: - Initializers
    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }
    
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
                sendSurvey()
            case .someCheckboxClicked(let idx):
                conceptStateHandler(idx)
                output.send(.setAllAndNone(numOfSelectedConcept: selectedSet.count, checkNoneClicked: false))
                doneButtonStateHandler()
            }
        }
        .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func allStateHandler() {
        if selectedSet.count == SurveyCheckList.list.count {
            iterConceptHandler(toSelected: false)
            output.send(.setAllAndNone(numOfSelectedConcept: selectedSet.count, checkNoneClicked: false))
        } else {
            iterConceptHandler(toSelected: true)
            output.send(.setAllAndNone(numOfSelectedConcept: selectedSet.count, checkNoneClicked: false))
        }
    }
    
    private func noneStateHandler() {
        iterConceptHandler(toSelected: false)
        output.send(.setAllAndNone(numOfSelectedConcept: selectedSet.count, checkNoneClicked: true))
    }
    
    private func conceptStateHandler(_ idx: Int) {
        selectedSet.contains(idx) ? deselectConceptHandler(idx) : selectConceptHandler(idx)
    }
    
    private func iterConceptHandler(toSelected: Bool) {
        if toSelected {
            for idx in 0..<SurveyCheckList.list.count {
                selectConceptHandler(idx)
            }
        } else {
            selectedSet.removeAll()
            for idx in 0..<SurveyCheckList.list.count{
                output.send(.checkboxToOff(idx: idx))
            }
        }
    }
    
    private func deselectConceptHandler(_ idx: Int) {
        if selectedSet.contains(idx) {
            selectedSet.remove(idx)
            output.send(.checkboxToOff(idx: idx))
        }
    }
    
    private func selectConceptHandler(_ idx: Int) {
        if !selectedSet.contains(idx) {
            selectedSet.insert(idx)
            output.send(.checkboxToOn(idx: idx))
        }
    }
    
    private func doneButtonStateHandler(checkNoneClicked: Bool = false) {
        let newState = checkNoneClicked || !selectedSet.isEmpty
        if isDoneButtonActivated != newState {
            isDoneButtonActivated = newState
            output.send(.setDoneButtonState(isActive: newState))
        }
    }
    
    private func sendSurvey() {
        Task {
            do {
                if isDoneButtonActivated {
                    let keyConcepts = selectedSet.map { SurveyCheckList.list[$0] }
                    _ = try await onboardingService.sendSurvey(keyConcepts: keyConcepts)
                    if selectedSet.isEmpty {
                        output.send(.moveToGreeting)
                    } else {
                        self.output.send(.moveToBeginPreviewTest)
                    }
                }
            } catch {
                output.send(.requestFailed)
            }
        }
    }
}
