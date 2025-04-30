//
//  ExamScheduleRegisteredCell.swift
//  QRIZ
//
//  Created by 김세훈 on 4/29/25.
//

import UIKit

final class ExamScheduleRegisteredCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let defaultMargin: CGFloat = 24.0
        static let dDayStackViewTopOffset: CGFloat = 12.0
        static let separatorWidth: CGFloat = 8.0
        static let separatorHeight: CGFloat = 3.0
        static let cardViewTopOffset: CGFloat = 20.0
        static let innerLabelOffset: CGFloat = 8.0
        static let suggestionLabelTopOffset: CGFloat = 16.0
        static let tableSeparatorHeight: CGFloat = 1.0
        static let actionButtonTopOffset: CGFloat = 16.0
        static let actionButtonHeightMultiple: CGFloat = 40 / 291
    }
    
    private enum Attributes {
        static let suggestionText: String = "일정을 변경할까요?"
        static let actionButtonTitle: String = "변경하기"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dDayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dBox, separator, numberBox])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let dBox = RoundBoxLabel(text: "D", width: 49, height: 50)
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue500
        return view
    }()
    
    private let numberBox = RoundBoxLabel(text: "24", width: 59, height: 50)
    
    // cardView
    private let detailCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth  = 1
        view.layer.borderColor  = UIColor.customBlue100.cgColor
        return view
    }()
    
    private let examDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let examNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let separator2: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue100
        return view
    }()
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.suggestionText
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Attributes.actionButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .coolNeutral800
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.coolNeutral200.cgColor
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
    
    func configure(userName: String, dday: Int, detail: ExamScheduleItem.Kind.Detail) {
        titleLabel.text = "\(userName)님이\n등록한 시험까지"
        numberBox.setText("\(dday)")
        examDateLabel.text = detail.examDateText
        examNameLabel.text = detail.examName
        periodLabel.text   = detail.applyPeriod
    }
}

// MARK: - Layout Setup

extension ExamScheduleRegisteredCell {
    private func addSubviews() {
        [
            titleLabel,
            dDayStackView,
            detailCardView
        ].forEach(addSubview(_:))
        
        [
            examDateLabel,
            examNameLabel,
            periodLabel,
            separator2,
            suggestionLabel,
            actionButton
        ].forEach(detailCardView.addSubview(_:))
    }
    
    private func setupConstraints() {
        [
            titleLabel,
            dDayStackView,
            separator,
            detailCardView,
            examDateLabel,
            examNameLabel,
            periodLabel,
            separator2,
            suggestionLabel,
            actionButton
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            dDayStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.dDayStackViewTopOffset),
            dDayStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dDayStackView.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            
            separator.widthAnchor.constraint(equalToConstant: Metric.separatorWidth),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight),
            
            detailCardView.topAnchor.constraint(equalTo: dDayStackView.bottomAnchor, constant: Metric.cardViewTopOffset),
            detailCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            examDateLabel.topAnchor.constraint(equalTo: detailCardView.topAnchor, constant: Metric.defaultMargin),
            examDateLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            
            examNameLabel.topAnchor.constraint(equalTo: examDateLabel.bottomAnchor, constant: Metric.innerLabelOffset),
            examNameLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            
            periodLabel.topAnchor.constraint(equalTo: examNameLabel.bottomAnchor, constant: Metric.innerLabelOffset),
            periodLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            
            separator2.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: Metric.innerLabelOffset),
            separator2.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            separator2.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -Metric.defaultMargin),
            separator2.heightAnchor.constraint(equalToConstant: Metric.tableSeparatorHeight),
            
            suggestionLabel.topAnchor.constraint(equalTo: separator2.bottomAnchor, constant: Metric.suggestionLabelTopOffset),
            suggestionLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            
            actionButton.topAnchor.constraint(equalTo: suggestionLabel.bottomAnchor, constant: Metric.actionButtonTopOffset),
            actionButton.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: Metric.defaultMargin),
            actionButton.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -Metric.defaultMargin),
            actionButton.bottomAnchor.constraint(equalTo: detailCardView.bottomAnchor, constant: -Metric.defaultMargin),
            actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor, multiplier: Metric.actionButtonHeightMultiple)
        ])
    }
}
