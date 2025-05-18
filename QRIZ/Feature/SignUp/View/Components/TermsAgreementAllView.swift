//
//  TermsAgreementAllView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/14/25.
//

import UIKit
import Combine

final class TermsAgreementAllView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let checkBoxSize: CGFloat = 24.0
        static let verticalMargin: CGFloat = 18.0
        static let horizontalMargin: CGFloat = 16.0
    }
    
    private enum Attributes {
        static let title: String = "전체 동의"
    }
    
    // MARK: - Properties
    
    private let checkBoxButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    var checkBoxButtonTappedPublisher: AnyPublisher<Void, Never> {
        checkBoxButtonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var checkBoxButton: UIButton = {
        let button = UIButton()
        button.setImage(.checkboxOffIcon, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.checkBoxButtonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral800
        return label
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
        backgroundColor = .white
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.coolNeutral100.cgColor
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.coolNeutral300.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 10
    }
    
    func setChecked(_ isOn: Bool) {
        let image = isOn ? UIImage.checkboxOnIcon : UIImage.checkboxOffIcon
        checkBoxButton.setImage(image, for: .normal)
    }
}

// MARK: - Layout Setup

extension TermsAgreementAllView {
    private func addSubviews() {
        [
            checkBoxButton,
            titleLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        checkBoxButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkBoxButton.topAnchor.constraint(equalTo: topAnchor, constant: Metric.verticalMargin),
            checkBoxButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            checkBoxButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.verticalMargin),
            checkBoxButton.widthAnchor.constraint(equalToConstant: Metric.checkBoxSize),
            checkBoxButton.heightAnchor.constraint(equalToConstant: Metric.checkBoxSize),
            
            titleLabel.centerYAnchor.constraint(equalTo: checkBoxButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: Metric.horizontalMargin),
        ])
    }
}

