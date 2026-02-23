//
//  CountdownTimer.swift
//  QRIZUtils
//
//  Created by 김세훈 on 1/14/25.
//

import Foundation
import Combine

/// 카운트다운 타이머입니다.
/// - Combine 구독을 통해 UI 업데이트
public final class CountdownTimer {

    // MARK: - Properties

    private let remainingTime: CurrentValueSubject<Int, Never>
    private var timer: Timer?
    private let initialTime: Int

    public var remainingTimePublisher: AnyPublisher<Int, Never> {
        remainingTime.eraseToAnyPublisher()
    }
    
    // MARK: - Initialize

    public init(totalTime: Int) {
        self.initialTime = totalTime
        self.remainingTime = CurrentValueSubject<Int, Never>(totalTime)
    }

    // MARK: - Functions

    public func start() {
        stop() // 기존 타이머 해제
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newTime = self.remainingTime.value - 1
            self.remainingTime.send(newTime)

            if newTime <= 0 {
                self.stop()
                self.remainingTime.send(0)
            }
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func reset() {
        stop()
        remainingTime.send(initialTime)
    }
}
