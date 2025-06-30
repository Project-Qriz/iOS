//
//  StudySummaryCell.swift
//  QRIZ
//
//  Created by 김세훈 on 6/29/25.
//

import UIKit

struct StudyConcept {
    let type: String
    let keyConcept: String
    
    init(from skill: PlannedSkill) {
        self.type = skill.type
        self.keyConcept = skill.keyConcept
    }
}

final class StudySummaryCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let hInset: CGFloat = 20.0
        static let vInset: CGFloat = 20.0
        static let cardVStackViewTopOffset: CGFloat = 12.0
        static let dashedLineHeight: CGFloat = 1.0
        static let ellipsisTopOffset: CGFloat = 12.0
    }
    
    // MARK: - Properties
    
    private var cardStackToEllipsisConstraint: NSLayoutConstraint!
    private var cardStackToBottomConstraint: NSLayoutConstraint!
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let dashedLineView = DashedLineView()
    
    private let cardStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let ellipsis: UIImageView = {
        let imageView = UIImageView(image: .ellipsis)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
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
        applyQRIZShadow(radius: 8.0)
    }
    
    func configure(number: Int, concepts: [StudyConcept]) {
        titleLabel.attributedText = makeTitleAttributedText(number: number)
        
        cardStack.arrangedSubviews.forEach {
            cardStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        concepts.forEach { concept in
            let card = ConceptCardView(keyConcept: concept.type, description: concept.keyConcept)
            cardStack.addArrangedSubview(card)
        }
        
        let showEllipsis = concepts.count >= 3
        ellipsis.isHidden = !showEllipsis
        cardStackToEllipsisConstraint.isActive = showEllipsis
        cardStackToBottomConstraint.isActive = !showEllipsis
    }
    
    private func makeTitleAttributedText(number: Int) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        let boldFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let text = "학습해야 하는 개념 \(number)가지"
        
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: baseFont,
                .foregroundColor: UIColor.coolNeutral800
            ]
        )
        
        let numberString = "\(number)"
        if let range = text.range(of: numberString) {
            let nsRange = NSRange(range, in: text)
            attr.addAttributes([ .font: boldFont ], range: nsRange)
        }
        
        return attr
    }
}

// MARK: - Layout Setup

extension StudySummaryCell {
    private func addSubviews() {
        [
            titleLabel,
            dashedLineView,
            cardStack,
            ellipsis
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dashedLineView.translatesAutoresizingMaskIntoConstraints = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        ellipsis.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.vInset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            
            dashedLineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.vInset),
            dashedLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            dashedLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            dashedLineView.heightAnchor.constraint(equalToConstant: Metric.dashedLineHeight),
            
            cardStack.topAnchor.constraint(equalTo: dashedLineView.bottomAnchor, constant: Metric.cardVStackViewTopOffset),
            cardStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            cardStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            
            ellipsis.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ellipsis.topAnchor.constraint(equalTo: cardStack.bottomAnchor, constant: Metric.ellipsisTopOffset),
        ])
        
        cardStackToEllipsisConstraint =
            cardStack.bottomAnchor.constraint(equalTo: ellipsis.topAnchor, constant: -Metric.ellipsisTopOffset)
        cardStackToBottomConstraint =
            cardStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.vInset)

        cardStackToBottomConstraint.isActive = true
    }
}
