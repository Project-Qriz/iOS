//
//  DaySelectBottomSheetViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 7/12/25.
//

import UIKit
import Combine

final class DaySelectBottomSheetViewModel {
    
    // MARK: Properties
    
    private let totalDays: Int
    private let todayIndex: Int?
    private var selectedDay: Int
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentWeek: Int {
        selectedDay / 7
    }
    
    init(totalDays: Int, initialSelected: Int = 0, todayIndex: Int? = nil) {
        self.totalDays = totalDays
        self.selectedDay = initialSelected
        self.todayIndex = todayIndex
    }
    
    // MARK: Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .viewDidLoad:
                    self.pushFullState()
                    
                case .dayTapped(let index):
                    let oldWeek = currentWeek
                    selectedDay = index
                    if currentWeek != oldWeek {
                        pushFullState()
                    } else {
                        outputSubject.send(.updateSelectedDay(selected: selectedDay, totalDays: totalDays))
                    }
                    
                case .prevWeekTapped:
                    self.moveWeek(by: -1)
                    
                case .nextWeekTapped:
                    self.moveWeek(by: +1)
                    
                case .todayTapped:
                    guard let today = todayIndex else { return }
                    self.selectedDay = today
                    self.pushFullState()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    
    private func moveWeek(by offset: Int) {
        let newWeek = max(0, min(currentWeek + offset, (totalDays - 1) / 7))
        guard newWeek != currentWeek else { return }
        selectedDay = newWeek * 7
        pushFullState()
    }
    
    private func pushFullState() {
        outputSubject.send(
            .updateUI(
                week: currentWeek + 1,
                selected: selectedDay,
                totalDays: totalDays,
                prevEnabled: currentWeek > 0,
                nextEnabled: (currentWeek + 1) * 7 < totalDays
            )
        )
    }
}

extension DaySelectBottomSheetViewModel {
    enum Input {
        case viewDidLoad
        case dayTapped(Int)
        case prevWeekTapped
        case nextWeekTapped
        case todayTapped
    }
    
    enum Output {
        case updateUI(
            week: Int,
            selected: Int,
            totalDays: Int,
            prevEnabled: Bool,
            nextEnabled: Bool
        )
        case updateSelectedDay(selected:Int, totalDays: Int)
    }
}
