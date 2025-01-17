//
//  FindAccountMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit

final class FindAccountMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 24.0
        static let inputViewTopOffset: CGFloat = 32.0
        static let horizontalMargin: CGFloat = 18.0
    }
    
    // MARK: - Properties
    
    private let findAccountHeaderView = FindAccountHeaderView()
    private let findAccountInputView = FindAccountInputView()
    
    // MARK: - Initialize
    
    init(
        title: String,
        description: String,
        inputTitle: String,
        placeholder: String,
        errorText: String
    ) {
        super.init(frame: .zero)
        setupUI(
            headerTitle: title,
            description: description,
            inputTitle: inputTitle,
            placeholder: placeholder,
            errorText: errorText
        )
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI(
        headerTitle: String,
        description: String,
        inputTitle: String,
        placeholder: String,
        errorText: String
    ) {
        self.backgroundColor = .white
        findAccountHeaderView.configure(title: headerTitle, description: description)
        findAccountInputView.configure(
            titleText: inputTitle,
            placeholder: placeholder,
            errorText: errorText
        )
    }
}

// MARK: - Layout Setup

extension FindAccountMainView {
    private func addSubviews() {
        [
            findAccountHeaderView,
            findAccountInputView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        findAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false
        findAccountInputView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            findAccountInputView.topAnchor.constraint(
                equalTo: findAccountHeaderView.bottomAnchor,
                constant: Metric.inputViewTopOffset
            ),
            findAccountInputView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            findAccountInputView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
        ])
    }
}

