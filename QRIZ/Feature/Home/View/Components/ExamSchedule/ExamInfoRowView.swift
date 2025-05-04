//
//  ExamInfoRowView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/4/25.
//

import UIKit
import Combine

final class ExamInfoRowView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let defaultMargnin: CGFloat = 24.0
    }
    
    private enum Attributes {
        static let statusImage: String = "record.circle.fill"
    }
    
    // MARK: - UI
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()
    
    private let statusImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let image  = UIImage(systemName: Attributes.statusImage, withConfiguration: config)?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var examInfoVStackVeiw: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            examNameLabel, examDateLabel, periodLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.setCustomSpacing(8, after: examDateLabel)
        return stackView
    }()
    
    private let examNameLabel: UILabel = {
        let label = UILabel()
        label.text = "제 52회 SQL 개발자"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let examDateLabel: UILabel = {
        let label = UILabel()
        label.text = "접수기간: 01.29(월) 10:00 ~ 02.02(금) 18:00"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.text = "시험일: 5월25일(토)"
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
    
    func configure(examDate: String, examName: String, period: String) {
        examDateLabel.text = examDate
        examNameLabel.text = examName
        periodLabel.text = period
    }
}

// MARK: - Layout Setup

extension ExamInfoRowView {
    private func addSubviews() {
        [
            separator,
            statusImageView,
            examInfoVStackVeiw
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        examInfoVStackVeiw.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            statusImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            
            examInfoVStackVeiw.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            examInfoVStackVeiw.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 16),
            examInfoVStackVeiw.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            examInfoVStackVeiw.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
}
