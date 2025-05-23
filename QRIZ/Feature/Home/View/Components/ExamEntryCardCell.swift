//
//  ExamEntryCardCell.swift
//  QRIZ
//
//  Created by 김세훈 on 5/22/25.
//

import UIKit
import Combine

final class ExamEntryCardCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    enum State {
        case preview
        case mock
    }
    
    private enum Metric {
        static let verticalMargin: CGFloat = 28.0
        static let titleLabelLeadingOffset: CGFloat = 16.0
        static let descriptionLabelTopOffset: CGFloat = 8.0
        static let imageViewMargin: CGFloat = 24.0
        static let imageViewSize: CGFloat = 58.0
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
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
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral100.cgColor
    }
    
    func configure(state: ExamEntryCardCell.State) {
        switch state {
        case .preview:
            titleLabel.text = "프리뷰 시험"
            descriptionLabel.text = "간단한 테스트로 실력을 확인해봐요!"
            imageView.image = .onboarding2
            
        case .mock:
            titleLabel.text = "모의고사 응시"
            descriptionLabel.text = "실전처럼 준비하기"
            imageView.image = .mockExam
        }
    }
}

// MARK: - Layout Setup

extension ExamEntryCardCell {
    private func addSubviews() {
        [
            titleLabel,
            descriptionLabel,
            imageView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.titleLabelLeadingOffset),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.titleLabelLeadingOffset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.verticalMargin),
            
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Metric.imageViewMargin),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.verticalMargin),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.imageViewMargin),
            imageView.heightAnchor.constraint(equalToConstant: Metric.imageViewSize),
            imageView.widthAnchor.constraint(equalToConstant: Metric.imageViewSize)
        ])
    }
}
