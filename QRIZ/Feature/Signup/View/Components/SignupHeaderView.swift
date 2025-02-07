//
//  SignupHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

final class SignupHeaderView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let progressViewHeight: CGFloat = 4.0
        static let titleLabelTopOffset: CGFloat = 40.0
        static let leadingMargin: CGFloat = 18.0
    }
    
    // MARK: - UI
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.tintColor = .customBlue500
        progressView.trackTintColor = .coolNeutral100
        return progressView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - initialize
    
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
        self.backgroundColor = .white
    }
    
    func configure(title: NSAttributedString, progress: Float) {
        titleLabel.attributedText = title
        progressView.setProgress(max(0.0, min(progress, 1.0)), animated: false)
    }
}

// MARK: - Layout Setup

extension SignupHeaderView {
    private func addSubviews() {
        [
            progressView,
            titleLabel,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Metric.progressViewHeight),
            
            titleLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: Metric.titleLabelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.leadingMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
