//
//  WrongQuestionViewModel.swift
//  QRIZ
//
//  Created by ch on 1/23/25.
//

import Foundation
import Combine

final class WrongQuestionViewModel {
    
    enum Input {
        case viewDidLoad
        case dropDownClicked
        case menuButtonClicked
        case menuItemClicked(isIncorrectOnly: Bool)
        case segmentClicked(isDaily: Bool)
        case sliderButtonClicked
    }
    
    enum Output {
        //        case fetchSuccess
        //        case fetchFailed
        case foldDropDown
        case unfoldDropDown
        case foldMenu
        case unfoldMenu
        case setMenuItemState(isIncorrectOnly: Bool)
        case setSegmentState(isDaily: Bool)
        case showModal
    }
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private var isDropDownFolded: Bool = true
    private var isMenuFolded: Bool = true
    private var isIncorrectOnly: Bool = true
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                print("VIEW DID LOAD")
                // send success || fail
            case .dropDownClicked:
                if isDropDownFolded {
                    output.send(.unfoldDropDown)
                    isDropDownFolded = false
                }
            case .menuButtonClicked:
                if isMenuFolded {
                    output.send(.unfoldMenu)
                    isMenuFolded = false
                } else {
                    output.send(.foldMenu)
                    isMenuFolded = true
                }
            case .menuItemClicked(let isIncorrectOnly):
                output.send(.setMenuItemState(isIncorrectOnly: isIncorrectOnly))
                output.send(.foldMenu)
                isMenuFolded = true
            case .segmentClicked(let isDaily):
                output.send(.setSegmentState(isDaily: isDaily))
            case .sliderButtonClicked:
                output.send(.showModal)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
