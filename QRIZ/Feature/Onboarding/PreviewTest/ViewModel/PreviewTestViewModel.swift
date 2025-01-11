//
//  PreviewTestViewModel.swift
//  QRIZ
//
//  Created by ch on 12/18/24.
//

import Foundation
import Combine

final class PreviewTestViewModel {
    
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case prevButtonClicked
        case nextButtonClicked
        case optionSelected(idx: Int)
        case escapeButtonClicked
        case alertSubmitButtonClicked
        case alertCancelButtonClicked
    }
    
    enum Output {
        // case loadDataSuccess
        // case loadDataFailed
        case selectOption(idx: Int)
        case deselectOption(idx: Int)
        case updateQuestion(question: QuestionData)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case updateNextButton(isLastQuestion: Bool)
        case moveToPreviewResult
        case moveToHome
        case popUpAlert
        case submitSuccess
        case submitFail
        case cancelAlert
    }
    
    private var questionList = QuestionData.sampleList
    private var currentNumber: Int? = nil
    private var totalTimeLimit: Int? = 1500 // tmp
    private var timeRemaining: Int = 1500
    private var timer: Timer? = nil
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    deinit {
        exitTimer()
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                // fetch Data
                // fetch QuestionList
                // fetch totalTimeLimit
                currentNumber = 1
                output.send(.updateQuestion(question: questionList[0]))
            case .viewDidAppear:
                // timer
                guard let totalTimeLimit = totalTimeLimit else { return }
                output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: timeRemaining))
                startTimer()
            case .prevButtonClicked:
                buttonActionHandler(isNextButton: false)
            case .nextButtonClicked:
                buttonActionHandler(isNextButton: true)
            case .optionSelected(let idx):
                optionSelectHandler(idx: idx)
            case .escapeButtonClicked:
                exitTimer()
                // coordinator role
                output.send(.moveToHome)
            case .alertSubmitButtonClicked:
                alertActionHandler()
            case .alertCancelButtonClicked:
                output.send(.cancelAlert)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func alertActionHandler() {
        // should handle network, send data
        timer?.invalidate()
        timer = nil
        output.send(.submitSuccess)
        output.send(.moveToPreviewResult)
    }
    
    private func buttonActionHandler(isNextButton: Bool) {
        
        guard let curNum = currentNumber else { return }
        
        if isNextButton {
            if curNum >= questionList.count {
                output.send(.popUpAlert)
            } else {
                if curNum == questionList.count - 1 {
                    output.send(.updateNextButton(isLastQuestion: true))
                }
                currentNumber = curNum + 1
                output.send(.updateQuestion(question: questionList[currentNumber! - 1]))
                for i in 1...4 {
                    output.send(.deselectOption(idx: i))
                }
                if let selectedOption = questionList[currentNumber! - 1].selectedOption {
                    output.send(.selectOption(idx: selectedOption))
                }
            }
        } else {
            if curNum > 1 {
                if curNum == questionList.count {
                    output.send(.updateNextButton(isLastQuestion: false))
                }
                currentNumber = curNum - 1
                output.send(.updateQuestion(question: questionList[currentNumber! - 1]))
                for i in 1...4 {
                    output.send(.deselectOption(idx: i))
                }
                if let selectedOption = questionList[currentNumber! - 1].selectedOption {
                    output.send(.selectOption(idx: selectedOption))
                }
            }
        }
    }
    
    private func optionSelectHandler(idx: Int) {
        guard let currentNumber = currentNumber else { return }
        if let selectedOption = questionList[currentNumber - 1].selectedOption {
            if selectedOption == idx {
                questionList[currentNumber - 1].selectedOption = nil
                output.send(.deselectOption(idx: idx))
            } else {
                questionList[currentNumber - 1].selectedOption = idx
                output.send(.deselectOption(idx: selectedOption))
                output.send(.selectOption(idx: idx))
            }
        } else {
            questionList[currentNumber - 1].selectedOption = idx
            output.send(.selectOption(idx: idx))
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            guard let totalTimeLimit = totalTimeLimit else { return }
            output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: timeRemaining))
            print(totalTimeLimit, timeRemaining)
        } else {
            // send result
            output.send(.moveToPreviewResult)
        }
    }
    
    private func exitTimer() {
        timer?.invalidate()
        timer = nil
    }
}
