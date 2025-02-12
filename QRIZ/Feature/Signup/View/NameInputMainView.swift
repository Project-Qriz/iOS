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
        static let signupFooterViewBottomOffset: CGFloat = -16.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let headerTitle: String = "이름을 입력해주세요!"
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
    }
    
    // MARK: - Properties
    
    private let signupHeaderView = SignupHeaderView()
    let singleInputView = SingleInputView()
    let signupFooterView = SignupFooterView()
    
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
        signupHeaderView.configure(
            title: Attributes.headerTitle,
            progress: Attributes.progressValue
        )
        signupFooterView.configure(buttonTitle: Attributes.footerTitle)
    }
}

// MARK: - Layout Setup

extension NameInputMainView {
    private func addSubviews() {
        [
            signupHeaderView,
            singleInputView,
            signupFooterView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        singleInputView.translatesAutoresizingMaskIntoConstraints = false
        signupFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            singleInputView.topAnchor.constraint(equalTo: signupHeaderView.bottomAnchor, constant: Metric.singleInputViewTopOffset),
            singleInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            singleInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            signupFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            signupFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            signupFooterView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Metric.signupFooterViewBottomOffset)
        ])
    }
}
