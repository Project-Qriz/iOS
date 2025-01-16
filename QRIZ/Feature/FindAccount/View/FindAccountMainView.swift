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
        static let horizontalMargin: CGFloat = 18.0
    }
    
    // MARK: - Properties
    
    private let findAccountHeaderView = FindAccountHeaderView()
    
    // MARK: - Initialize
    
    init(
        title: String,
        description: String
    ) {
        super.init(frame: .zero)
        setupUI(
            title: title,
            description: description
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
        description: String
    ) {
        self.backgroundColor = .white
        findAccountHeaderView.configure(title: title, description: description)
    }
}

// MARK: - Layout Setup

extension FindAccountMainView {
    private func addSubviews() {
        [
            findAccountHeaderView,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        findAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false

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
                constant: Metric.horizontalMargin
            ),
        ])
    }
}

