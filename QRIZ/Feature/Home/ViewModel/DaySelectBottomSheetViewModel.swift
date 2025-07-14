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
    private var displayWeek: Int
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentWeek: Int {
        displayWeek
    }
    
    init(totalDays: Int, initialSelected: Int = 0, todayIndex: Int? = nil) {
        self.totalDays = totalDays
        self.selectedDay = initialSelected
        self.todayIndex = todayIndex
        self.displayWeek = initialSelected / 7
    }
    
    // MARK: Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .viewDidLoad:
                    self.pushFullState()
                    
                case .dayTapped(let globalIndex):
                    confirmDaySelection(globalIndex)
                    
                case .prevWeekTapped:
                    self.moveWeek(by: -1)
                    
                case .nextWeekTapped:
                    self.moveWeek(by: +1)
                    
                case .todayTapped:
                    guard let today = todayIndex else { return }
                    confirmDaySelection(today)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    
    private func moveWeek(by offset: Int) {
        let maxWeek = (totalDays - 1) / 7
        displayWeek = max(0, min(displayWeek + offset, maxWeek))
        pushFullState()
    }
    
    private func pushFullState() {
        outputSubject.send(
            .updateUI(
                week: displayWeek + 1,
                selected: selectedDay,
                totalDays: totalDays,
                prevEnabled: currentWeek > 0,
                nextEnabled: (currentWeek + 1) * 7 < totalDays
            )
        )
    }
    
    private func confirmDaySelection(_ day: Int) {
        selectedDay = day
        displayWeek = day / 7
        pushFullState()
        outputSubject.send(.dayConfirmed(day + 1))
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
        case dayConfirmed(Int)
    }
}
