//
//  ExamListCell.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import UIKit

final class ExamListCell: UICollectionViewCell {
    
    // MARK: - Properties
    static var identifier: String = "ExamListCell"
    
    private let testNavigatorButton: TestNavigatorButton = .init()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaultUI()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListCell")
    }
    
    func configure(examInfo: ExamListDataInfo) {
        testNavigatorButton.setMockExamUI(
            isTestDone: examInfo.completed,
            examRound: Int(examInfo.session.replacingOccurrences(of: "회차", with: "")) ?? 0,
            score: examInfo.totalScore)
    }
    
    private func setDefaultUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.coolNeutral100.cgColor
        self.layer.shadowOpacity = 1
    }
}


extension ExamListCell {
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
