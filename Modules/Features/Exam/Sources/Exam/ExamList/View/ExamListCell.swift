//
//  ExamListCell.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import UIKit
import DesignSystem

final class ExamListCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "ExamListCell"

    private let testNavigatorButton = TestNavigatorButton()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(isCompleted: Bool, examRound: Int, score: Double?) {
        testNavigatorButton.setMockExamUI(
            isTestDone: isCompleted,
            examRound: examRound,
            score: score
        )
    }

    private func setupAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.coolNeutral100.cgColor
        layer.shadowOpacity = 1
    }
}

// MARK: - Layout Setup

extension ExamListCell {
    private func addSubviews() {
        addSubview(testNavigatorButton)
    }

    private func setupConstraints() {
        testNavigatorButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            testNavigatorButton.topAnchor.constraint(equalTo: topAnchor),
            testNavigatorButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            testNavigatorButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            testNavigatorButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
