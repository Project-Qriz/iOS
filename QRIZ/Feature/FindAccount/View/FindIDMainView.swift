//
//  FindAccountMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit

final class FindIDMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 40.0
        static let inputViewTopOffset: CGFloat = 20.0
        static let horizontalMargin: CGFloat = 18.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
    }
    
    private enum Attributes {
        static let buttonTitle: String = "아이디 찾기"
    }
    
    // MARK: - Properties
    
    private let findAccountHeaderView = FindAccountHeaderView()
    let findIDInputView = FindIDInputView()
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        setupUI()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
        findAccountHeaderView.configure(
            title: FindAccountType.findId.headerTitle,
            description: UILabel.setLineSpacing(8, text: FindAccountType.findId.headerDescription)
        )
        signUpFooterView.configure(buttonTitle: Attributes.buttonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension FindIDMainView {
    private func addSubviews() {
        [
            findAccountHeaderView,
            findIDInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        findAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false
        findIDInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            findAccountHeaderView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.headerViewTopOffset
            ),
            findAccountHeaderView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            findAccountHeaderView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            
            findIDInputView.topAnchor.constraint(
                equalTo: findAccountHeaderView.bottomAnchor,
                constant: Metric.inputViewTopOffset
            ),
            findIDInputView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            findIDInputView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            
            signUpFooterView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            signUpFooterView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            signUpFooterView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: Metric.signUpFooterViewBottomOffset
            )
        ])
    }
}

