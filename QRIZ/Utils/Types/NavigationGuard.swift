//
//  NavigationGuard.swift
//  QRIZ
//
//  Created on 2025/12/27.
//

import Foundation

/// Coordinator에서 중복 화면 전환을 방지하기 위한 프로토콜
@MainActor
protocol NavigationGuard: AnyObject {
    var isNavigating: Bool { get set }
}

@MainActor
extension NavigationGuard {
    /// 안전한 화면 전환을 위한 가드
    /// - Parameter action: 실행할 네비게이션 액션
    /// - Returns: 네비게이션이 실행되었는지 여부
    @discardableResult
    func guardNavigation(_ action: () -> Void) -> Bool {
        guard !isNavigating else {
            return false
        }

        isNavigating = true
        action()

        // 네비게이션 애니메이션 완료 후 플래그 리셋 (0.5초)
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isNavigating = false
        }

        return true
    }
}
