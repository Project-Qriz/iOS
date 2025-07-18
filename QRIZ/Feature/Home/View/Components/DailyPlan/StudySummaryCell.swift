//
//  StudySummaryCell.swift
//  QRIZ
//
//  Created by 김세훈 on 6/29/25.
//

import UIKit

final class StudySummaryCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let hInset: CGFloat = 20.0
        static let vInset: CGFloat = 20.0
        static let cardVStackViewTopOffset: CGFloat = 12.0
        static let dashedLineHeight: CGFloat = 1.0
        static let ellipsisTopOffset: CGFloat = 12.0
    }
    
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
    
    private lazy var bodyVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardStack, ellipsis])
        stackView.axis = .vertical
        stackView.spacing = Metric.ellipsisTopOffset
        stackView.alignment = .fill
        stackView.setCustomSpacing(Metric.ellipsisTopOffset, after: cardStack)
        return stackView
    }()
    
    private let lockContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8.0
        view.isHidden = true
        return view
    }()
    
    private let lockMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .coolNeutral500
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var lockVStackView: UIStackView = {
        let icon = UIImageView(image: .lock)
        let stackView = UIStackView(arrangedSubviews: [icon, lockMessageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
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
    
    func configure(plan: DailyPlan) {
        resetView()
        shouldLock(plan) ? applyLockedUI(plan: plan) : applyStudyUI(plan: plan)
    }
    
    private func resetView() {
        cardStack.arrangedSubviews.forEach {
            cardStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        ellipsis.isHidden = true
        lockContainer.isHidden = true
        lockVStackView.isHidden = true
        lockMessageLabel.text = nil
        
        titleLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.textColor = .coolNeutral800
        titleLabel.alpha = 1.0
    }
    
    private func shouldLock(_ plan: DailyPlan) -> Bool {
        (plan.reviewDay || plan.comprehensiveReviewDay) && plan.plannedSkills.isEmpty
    }
    
    private func applyStudyUI(plan: DailyPlan) {
        let prefix = (plan.reviewDay || plan.comprehensiveReviewDay) ? "복습해야 하는 개념" : "학습해야 하는 개념"
        titleLabel.attributedText = makeTitleAttributedText(prefix: prefix, number: plan.plannedSkills.count)
        addCards(plan.plannedSkills)
        updateEllipsisVisibility(count: plan.plannedSkills.count)
    }
    
    private func applyLockedUI(plan: DailyPlan) {
        titleLabel.text = "복습해야 하는 개념 준비중"
        titleLabel.textColor = .coolNeutral300
        titleLabel.alpha = 0.6
        
        let skill = PlannedSkill(id: -1, type: "주요항목", keyConcept: "세부 항목", description: "")
        addCards([skill, skill])
        
        lockContainer.isHidden = false
        lockVStackView.isHidden = false
        lockMessageLabel.text = lockedMessage(from: plan)
    }
    
    private func lockedMessage(from plan: DailyPlan) -> String {
        let day = Int(plan.dayNumber.filter { $0.isNumber }) ?? 0
        return day > 1 ? "Day \(day - 1)까지\n모두 완료해 주세요!" : "이전 학습을 완료해 주세요!"
    }
    
    private func addCards(_ skills: [PlannedSkill]) {
        for skill in skills {
            let card = ConceptCardView(type: skill.type, keyConcept: skill.keyConcept)
            cardStack.addArrangedSubview(card)
        }
    }
    
    private func updateEllipsisVisibility(count: Int) {
        ellipsis.isHidden = count < 3
    }
    
    private func makeTitleAttributedText(prefix: String, number: Int) -> NSAttributedString {
        let base = UIFont.systemFont(ofSize: 18, weight: .medium)
        let bold = UIFont.systemFont(ofSize: 18, weight: .bold)
        let text = "\(prefix) \(number)가지"
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [.font: base, .foregroundColor: UIColor.coolNeutral800]
        )
        if let range = text.range(of: "\(number)") {
            attr.addAttributes([.font: bold], range: NSRange(range, in: text))
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
            bodyVStackView,
            lockContainer
        ].forEach(contentView.addSubview(_:))
        
        lockContainer.addSubview(lockVStackView)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dashedLineView.translatesAutoresizingMaskIntoConstraints = false
        bodyVStackView.translatesAutoresizingMaskIntoConstraints = false
        lockContainer.translatesAutoresizingMaskIntoConstraints = false
        lockVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.vInset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            
            dashedLineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.vInset),
            dashedLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            dashedLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            dashedLineView.heightAnchor.constraint(equalToConstant: Metric.dashedLineHeight),
            
            bodyVStackView.topAnchor.constraint(equalTo: dashedLineView.bottomAnchor, constant: Metric.cardVStackViewTopOffset),
            bodyVStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.hInset),
            bodyVStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.hInset),
            bodyVStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.vInset),
            
            lockContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            lockContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lockContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lockContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            lockVStackView.centerXAnchor.constraint(equalTo: lockContainer.centerXAnchor),
            lockVStackView.centerYAnchor.constraint(equalTo: lockContainer.centerYAnchor),
        ])
    }
}
