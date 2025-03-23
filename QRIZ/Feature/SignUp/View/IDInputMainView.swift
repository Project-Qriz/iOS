//
//  IDInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit

final class IDInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let idInputViewTopOffset: CGFloat = 20.0
        static let signUpFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "사용할 아이디를 입력한 후\n중복확인 버튼을 눌러주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
    }
    
    // MARK: - Properties
    
    private let signUpHeaderView = SignUpHeaderView()
    let idInputView = IDInputView()
    let signUpFooterView = SignUpFooterView()
    
    // MARK: - initialize
    
    init() {
        super.init(frame: .zero)
        setupUI(
            title: Attributes.headerTitle,
            progressValue: Attributes.progressValue,
            buttonTitle: Attributes.footerTitle
        )
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI(
        title: String,
        progressValue: Float,
        buttonTitle: String
    ) {
        self.backgroundColor = .white
        signUpHeaderView.configure(title: title, progress: progressValue)
        signUpFooterView.configure(buttonTitle: buttonTitle)
        signUpFooterView.updateButtonState(isValid: false)
    }
}

// MARK: - Layout Setup

extension IDInputMainView {
    private func addSubviews() {
        [
            signUpHeaderView,
            idInputView,
            signUpFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signUpHeaderView.translatesAutoresizingMaskIntoConstraints = false
        idInputView.translatesAutoresizingMaskIntoConstraints = false
        signUpFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signUpHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signUpHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            idInputView.topAnchor.constraint(equalTo: signUpHeaderView.bottomAnchor, constant: Metric.idInputViewTopOffset),
            idInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            idInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signUpFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signUpFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signUpFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signUpFooterViewBottomOffset)
        ])
    }
}
