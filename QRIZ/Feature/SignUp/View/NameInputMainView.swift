//
//  NameInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

final class NameInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let singleInputViewTopOffset: CGFloat = 20.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "이름을 입력해주세요!"
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
    }
    
    // MARK: - Properties
    
    private let signUpHeaderView = SignUpHeaderView()
    let singleInputView = SingleInputView()
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
        signUpHeaderView.configure(
            title: Attributes.headerTitle,
            progress: Attributes.progressValue
        )
        signUpFooterView.configure(buttonTitle: Attributes.footerTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension NameInputMainView {
    private func addSubviews() {
        [
            signUpHeaderView,
            singleInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signUpHeaderView.translatesAutoresizingMaskIntoConstraints = false
        singleInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signUpHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signUpHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            singleInputView.topAnchor.constraint(equalTo: signUpHeaderView.bottomAnchor, constant: Metric.singleInputViewTopOffset),
            singleInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            singleInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signUpFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signUpFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signUpFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signUpFooterViewBottomOffset)
        ])
    }
}
