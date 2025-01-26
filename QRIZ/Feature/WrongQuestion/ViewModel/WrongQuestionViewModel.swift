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
        case viewTouched
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
        case setSegmentItems(isIncorrectOnly: Bool)
        case showModal
    }
    
    private struct SegmentInfo {
        var isIncorrectOnly: Bool = false
        // category list, question list, selected dropdown item, selected category,
    }
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private var isSegmentDaily: Bool = true
    private var dailyTestSegmentInfo: SegmentInfo = .init()
    private var mockExamSegmentInfo: SegmentInfo = .init()
    private var isDropDownFolded: Bool = true
    private var isMenuFolded: Bool = true
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .viewDidLoad:
                print("VIEW DID LOAD")
                // send success || fail
            case .viewTouched:
                setFoldItemsState(foldMenu: true, foldDropDown: true)
            case .dropDownClicked:
                if isDropDownFolded {
                    setFoldItemsState(foldMenu: true, foldDropDown: false)
                } else {
                    setFoldItemsState(foldMenu: true, foldDropDown: true)
                }
            case .menuButtonClicked:
                if isMenuFolded {
                    setFoldItemsState(foldMenu: false, foldDropDown: true)
                } else {
                    setFoldItemsState(foldMenu: true, foldDropDown: true)
                }
            case .menuItemClicked(let isIncorrectOnly):
                setFoldItemsState(foldMenu: true, foldDropDown: true)
                output.send(.setMenuItemState(isIncorrectOnly: isIncorrectOnly))
                if isSegmentDaily {
                    dailyTestSegmentInfo.isIncorrectOnly = isIncorrectOnly
                } else {
                    mockExamSegmentInfo.isIncorrectOnly = isIncorrectOnly
                }
            case .segmentClicked(let isDaily):
                setFoldItemsState(foldMenu: true, foldDropDown: true)
                output.send(.setSegmentState(isDaily: isDaily))
                if isDaily {
                    output.send(.setSegmentItems(
                        isIncorrectOnly: dailyTestSegmentInfo.isIncorrectOnly
                    ))
                } else {
                    output.send(.setSegmentItems(
                        isIncorrectOnly: mockExamSegmentInfo.isIncorrectOnly
                    ))
                }
                isSegmentDaily = isDaily
            case .sliderButtonClicked:
                setFoldItemsState(foldMenu: true, foldDropDown: true)
                output.send(.showModal)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func setFoldItemsState(foldMenu: Bool, foldDropDown: Bool) {

        if foldMenu {
            output.send(.foldMenu)
            isMenuFolded = true
        } else {
            output.send(.unfoldMenu)
            isMenuFolded = false
        }
        
        if foldDropDown {
            output.send(.foldDropDown)
            isDropDownFolded = true
        } else {
            output.send(.unfoldDropDown)
            isDropDownFolded = false
        }
    }
}
