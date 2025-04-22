//
//  ChapterInfoView .swift
//  QRIZ
//
//  Created by 김세훈 on 4/22/25.
//

import UIKit

final class ChapterInfoView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let appNameLabelTopOffset: CGFloat = 24.0
        static let verticalMargin: CGFloat = 12.0
        static let horizontalMargin: CGFloat = 18.0
        static let itemCountLabelBottomOffset: CGFloat = -24.0
    }
    
    // MARK: - Enums
    
    private enum Attributes {
        static let appName = "Qriz"
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.appName
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .customBlue500
        return label
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .coolNeutral500
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
    }
    
    func configure(subjectTitle: String, itemCount: Int) {
        subjectLabel.text = subjectTitle
        itemCountLabel.text = "\(itemCount)개 항목"
    }
}

// MARK: - Layout Setup

extension ChapterInfoView {
    private func addSubviews() {
        [
            appNameLabel,
            subjectLabel,
            itemCountLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.appNameLabelTopOffset),
            appNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            subjectLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: Metric.verticalMargin),
            subjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            itemCountLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: Metric.verticalMargin),
            itemCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            itemCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Metric.itemCountLabelBottomOffset)
        ])
    }
}
