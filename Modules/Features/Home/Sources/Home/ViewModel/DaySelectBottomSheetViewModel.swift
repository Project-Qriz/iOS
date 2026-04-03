//
//  DaySelectBottomSheetViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 7/12/25.
//

import Foundation
import Combine

@MainActor
final class DaySelectBottomSheetViewModel {

    // MARK: - Properties

    private let totalDays: Int
    private let todayIndex: Int?
    private var selectedDay: Int
    private var displayWeek: Int
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(totalDays: Int, initialSelected: Int = 0, todayIndex: Int? = nil) {
        self.totalDays = totalDays
        self.selectedDay = initialSelected
        self.todayIndex = todayIndex
        self.displayWeek = initialSelected / 7
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .viewDidLoad:
                    pushFullState()

                case .dayTapped(let globalIndex):
                    confirmDaySelection(globalIndex)

                case .prevWeekTapped:
                    moveWeek(by: -1)

                case .nextWeekTapped:
                    moveWeek(by: +1)

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
                prevEnabled: displayWeek > 0,
                nextEnabled: (displayWeek + 1) * 7 < totalDays
            )
        )
    }

    private func confirmDaySelection(_ day: Int) {
        selectedDay = day
        displayWeek = day / 7
        pushFullState()
        outputSubject.send(.dayConfirmed(day))
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
