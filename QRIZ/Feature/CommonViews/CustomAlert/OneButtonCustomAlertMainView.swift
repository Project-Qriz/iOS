//
//  OneButtonCustomAlertMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 2/16/25.
//

import UIKit
import Combine

final class OneButtonCustomAlertMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let contentInsets: CGFloat = 20.0
        static let confirmButtonTopOffset: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let confirmButtonTitle: String = "확인"
    }
    
    // MARK: - Properties
    
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    var confirmButtonTappedPublisher: AnyPublisher<Void, Never> {
        confirmButtonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var stackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(Attributes.confirmButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.customBlue500, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.confirmButtonTappedSubject.send()
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
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    func config(title: String, description: String? = nil) {
        titleLabel.text = title
        descriptionLabel.attributedText = UILabel.setLineSpacing(4, text: description ?? "")
    }
}

// MARK: - Layout Setup

extension OneButtonCustomAlertMainView {
    private func addSubviews() {
        [
            stackview,
            confirmButton
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        stackview.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: topAnchor, constant: Metric.contentInsets),
            stackview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.contentInsets),
            stackview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.contentInsets),
            
            confirmButton.topAnchor.constraint(
                equalTo: stackview.bottomAnchor,
                constant: Metric.confirmButtonTopOffset
            ),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.contentInsets),
            confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.contentInsets)
        ])
    }
}

