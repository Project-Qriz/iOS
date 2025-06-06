//
//  QuickActionsCell.swift
//  QRIZ
//
//  Created by 김세훈 on 5/31/25.
//

import UIKit

final class QuickActionsCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalSpacing: CGFloat = 8.0
        static let buttonAspectRatio: CGFloat = 82.0 / 165.5
    }
    
    private enum Attributes {
        static let resetPlanText: String = "플랜 초기화"
        static let registerExamText: String = "시험 등록"
    }
    
    // MARK: - UI
    
    private lazy var resetPlanButton: UIButton = {
        return buildButton(title: Attributes.resetPlanText, image: .reset)
    }()
    
    private lazy var registerExamButton: UIButton = {
        return buildButton(title: Attributes.registerExamText, image: .examRegister)
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
    
    private func buildButton(title: String, image: UIImage?) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = title
        
        config.titleTextAttributesTransformer = .init { incoming in
            var attrs = incoming
            attrs.font = .systemFont(ofSize: 16, weight: .medium)
            return attrs
        }
        config.baseForegroundColor = .coolNeutral800
        
        let button = UIButton(configuration: config)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.applyQRIZShadow(radius: 16)
        
        button.addAction(UIAction(handler: { _ in
            print(button.titleLabel!.text!)
        }), for: .touchUpInside)
        return button
    }
}

// MARK: - Layout Setup

extension QuickActionsCell {
    private func addSubviews() {
        [
            resetPlanButton,
            registerExamButton
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        resetPlanButton.translatesAutoresizingMaskIntoConstraints = false
        registerExamButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resetPlanButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            resetPlanButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            resetPlanButton.widthAnchor.constraint(
                equalTo: registerExamButton.widthAnchor
            ),
            resetPlanButton.heightAnchor.constraint(
                equalTo: resetPlanButton.widthAnchor,
                multiplier: Metric.buttonAspectRatio
            ),
            
            registerExamButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            registerExamButton.leadingAnchor.constraint(
                equalTo: resetPlanButton.trailingAnchor,
                constant: Metric.horizontalSpacing
            ),
            registerExamButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            registerExamButton.heightAnchor.constraint(
                equalTo: registerExamButton.widthAnchor,
                multiplier: Metric.buttonAspectRatio
            ),
        ])
    }
}

