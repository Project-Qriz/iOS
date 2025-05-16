//
//  TermsAgreementHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/13/25.
//

import UIKit
import Combine

final class TermsAgreementHeaderView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let xmarkSize: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let title: String = "약관동의"
        static let xmark: String = "xmark"
    }
    
    // MARK: - Properties
    
    private let dismissButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    var dismissButtonTappedPublisher: AnyPublisher<Void, Never> {
        dismissButtonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Attributes.xmark), for: .normal)
        button.tintColor = .coolNeutral800
        button.addAction(UIAction { [weak self] _ in
            self?.dismissButtonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension TermsAgreementHeaderView {
    private func addSubviews() {
        [
            titleLabel,
            dismissButton
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: Metric.xmarkSize),
            dismissButton.heightAnchor.constraint(equalToConstant: Metric.xmarkSize),
        ])
    }
}

