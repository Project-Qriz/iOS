//
//  UIViewController+Alert.swift
//  DesignSystem
//
//  Created by Claude on 2/15/26.
//

import UIKit
import Combine

public extension UIViewController {
    /// `에러 메시지를 표시용 원버튼 얼럿을 보여주는 함수입니다.`
    /// - Parameters:
    ///   - title: 얼럿에 표시할 에러 제목
    ///   - description: 얼럿에 표시할 에러 설명
    ///   - cancellables: 구독을 저장할 AnyCancellable
    func showOneButtonAlert(with title: String, for description: String? = nil, storingIn cancellables: inout Set<AnyCancellable>) {
        let oneButtonAlert = OneButtonCustomAlertViewController(title: title, description: description)
        oneButtonAlert.confirmButtonTappedPublisher
            .sink { [weak oneButtonAlert] _ in
                oneButtonAlert?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        present(oneButtonAlert, animated: true)
    }
}
