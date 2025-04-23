//
//  SubjectCardView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/14/25.
//

import UIKit

final class SubjectCardView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let imageViewTopOffset: CGFloat = 8.0
        static let imageViewHeightMultiplier: CGFloat = 156 / 105
        static let itemCountLabelTopOffset: CGFloat = 6.0
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .right
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral800
        label.numberOfLines = 2
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    // MARK: - Initialize
    
    init(image: UIImage?, title: String, itemCount: Int) {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        configure(image: image, title: title, itemCount: itemCount)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    func configure(image: UIImage?, title: String, itemCount: Int) {
        imageView.image = image
        titleLabel.text = title
        itemCountLabel.text = "\(itemCount)항목"
    }
}

// MARK: - Layout Setup

extension SubjectCardView {
    private func addSubviews() {
        [
            imageView,
            titleLabel,
            itemCountLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.heightAnchor.constraint(
                    equalTo: imageView.widthAnchor,
                    multiplier: Metric.imageViewHeightMultiplier
                ),
                
                titleLabel.topAnchor.constraint(
                    equalTo: imageView.bottomAnchor,
                    constant: Metric.imageViewTopOffset
                ),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                
                itemCountLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Metric.itemCountLabelTopOffset
                ),
                itemCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                itemCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }
}
