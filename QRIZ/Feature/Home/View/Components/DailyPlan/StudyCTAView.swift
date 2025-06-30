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
        static let buttonText: String = "학습하러 가기"
    }
    
    // MARK: - Properties
    
    private let tapSubject = PassthroughSubject<Void, Never>()
    
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Attributes.buttonText
        config.baseBackgroundColor = .customBlue500
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
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
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
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
