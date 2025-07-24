//
//  StudyCTAView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/30/25.
//

import UIKit
import Combine

final class StudyCTAView: UICollectionReusableView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonHeightMultiplier: CGFloat = 0.14
    }
    
    private enum Attributes {
        static let learnText  = "학습하러 가기"
        static let reviewText = "복습하러 가기"
    }
    
    // MARK: - Properties
    
    private let tapSubject = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitle(Attributes.learnText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.coolNeutral500, for: .disabled)
        button.backgroundColor = .customBlue500
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.tapSubject.send()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
    }
    
    func configure(enabled: Bool, isReview: Bool) {
        let title = isReview ? Attributes.reviewText : Attributes.learnText
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .disabled)
        button.backgroundColor = enabled ? .customBlue500 : .coolNeutral200
        button.isEnabled = enabled
    }
}

// MARK: - Layout Setup

extension StudyCTAView {
    private func addSubviews() {
        addSubview(button)
    }
    
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.heightAnchor.constraint(equalTo: widthAnchor, multiplier: Metric.buttonHeightMultiplier)
        ])
    }
}
