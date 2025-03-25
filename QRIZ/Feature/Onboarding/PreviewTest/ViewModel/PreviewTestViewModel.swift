//
//  PreviewTestViewModel.swift
//  QRIZ
//
//  Created by ch on 12/18/24.
//

import Foundation
import Combine

final class PreviewTestViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case prevButtonClicked(selectedOption: Int?)
        case nextButtonClicked(selectedOption: Int?)
        case escapeButtonClicked
        case alertSubmitButtonClicked
        case alertCancelButtonClicked
    }
    
    enum Output {
        // case fetchDataSuccess
        // case fetchDataFailed
        case updateQuestion(question: QuestionData)
        case updateLastQuestionNum(num: Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case moveToPreviewResult
        case moveToHome
        case popUpAlert
        case submitSuccess
        case submitFail
        case cancelAlert
    }
    
    // MARK: - Properties
    private var questionList = QuestionData.sampleList
    private var currentNumber: Int? = nil
    private var totalTimeLimit: Int? = 1500 // tmp
    private var timer: Timer? = nil
    private var startTime: Date? = nil
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Deinitializer
    deinit {
        exitTimer()
        print("DEINIT: PreviewTestViewModel")
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                // fetch Data
                // fetch QuestionList
                // fetch totalTimeLimit
                currentNumber = 1
                output.send(.updateLastQuestionNum(num: questionList.count))
                output.send(.updateQuestion(question: questionList[0]))
            case .viewDidAppear:
                guard let totalTimeLimit = totalTimeLimit else { return }
                output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: totalTimeLimit))
                startTimer()
            case .prevButtonClicked(let selectedOption):
                updateAnswer(selectedOption: selectedOption)
                pageButtonsActionHandler(isNextButton: false)
            case .nextButtonClicked(let selectedOption):
                updateAnswer(selectedOption: selectedOption)
                pageButtonsActionHandler(isNextButton: true)
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
    
    private func updateAnswer(selectedOption: Int?) {
        if let currentNumber {
            questionList[currentNumber - 1].selectedOption = selectedOption
        }
    }
    
    private func pageButtonsActionHandler(isNextButton: Bool) {
        guard let curNum = currentNumber else { return }
        if isNextButton && curNum >= questionList.count {
            output.send(.popUpAlert)
        } else {
            let pageDiff = isNextButton ? 1 : -1
            currentNumber = curNum + pageDiff
            output.send(.updateQuestion(question: questionList[currentNumber! - 1]))
        }
    }
}

// MARK: - Methods For Timer
extension PreviewTestViewModel {
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        guard let totalTimeLimit = totalTimeLimit, let startTime = startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        let timeRemaining = totalTimeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: timeRemaining))
            print(totalTimeLimit, timeRemaining)
        } else {
            // send result
            output.send(.moveToPreviewResult)
            exitTimer()
        }
    }
    
    private func exitTimer() {
        timer?.invalidate()
        timer = nil
    }
}
