//
//  WeeklyConceptCell.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import UIKit

final class WeeklyConceptCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonViewTop: CGFloat = 16.0
        static let lockImageSize: CGFloat = 20.0
    }
    
    private enum Attributes {
        static let titleText = "주간 추천 개념"
    }
    
    // MARK: - UI
    
    private let lockImageView: UIImageView = {
        let imageView = UIImageView(image: .lock)
        imageView.tintColor = .coolNeutral800
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private lazy var titleHStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [lockImageView, titleLabel])
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()
    
    private let firstButton = TestNavigatorButton()
    private let secondButton = TestNavigatorButton()
    
    private lazy var buttonVStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [firstButton, secondButton])
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillEqually
        return view
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
    
    func configure(kind: RecommendationKind, concepts: [WeeklyConcept]) {
        titleLabel.text = kind.rawValue
        lockImageView.isHidden = (kind == .weeklyCustom)
        
        let isLocked = (kind == .previewIncomplete)
        let buttons = [firstButton, secondButton]
        
        for (index, button) in buttons.enumerated() {
            guard index < concepts.count else {
                button.isHidden = true
                continue
            }
            button.isHidden = false
            button.setWeeklyConceptUI(concept: concepts[index], locked: isLocked)
        }
    }
}

// MARK: - Layout Setup

extension WeeklyConceptCell {
    private func addSubviews() {
        [
            titleHStackView,
            buttonVStackView
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleHStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleHStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            titleHStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            
            lockImageView.heightAnchor.constraint(
                equalToConstant: Metric.lockImageSize
            ),
            lockImageView.widthAnchor.constraint(
                equalToConstant: Metric.lockImageSize
            ),
            
            buttonVStackView.topAnchor.constraint(
                equalTo: titleHStackView.bottomAnchor,
                constant: Metric.buttonViewTop
            ),
            buttonVStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            buttonVStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            buttonVStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
        ])
    }
}

