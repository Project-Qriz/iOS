//
//  ExamListCell.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import UIKit
import DesignSystem
import Network

final class ExamListCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "ExamListCell"

    private let testNavigatorButton = TestNavigatorButton()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListCell")
    }

    // MARK: - Methods

    func configure(examInfo: ExamListDataInfo) {
        testNavigatorButton.setMockExamUI(
            isTestDone: examInfo.completed,
            examRound: Int(examInfo.session.replacingOccurrences(of: "회차", with: "")) ?? 0,
            score: examInfo.totalScore
        )
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.coolNeutral100.cgColor
        layer.shadowOpacity = 1
    }

    private func addViews() {
        addSubview(testNavigatorButton)

        testNavigatorButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            testNavigatorButton.topAnchor.constraint(equalTo: topAnchor),
            testNavigatorButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            testNavigatorButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            testNavigatorButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
