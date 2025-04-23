//
//  DailyLearnSectionTitleLabel.swift
//  QRIZ
//
//  Created by ch on 2/17/25.
//

import UIKit

final class DailyLearnSectionTitleLabel: UILabel {

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        self.font = .systemFont(ofSize: 20, weight: .bold)
        self.textColor = .coolNeutral800
        self.textAlignment = .left
        self.numberOfLines = 1
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnSectionTitleLabel")
    }
    
    // MARK: - Method
    func setText(isStudyContentTitle: Bool, type: DailyLearnType = .daily) {

        if isStudyContentTitle {
            switch type {
            case .daily:
                self.text = "오늘 공부할 내용"
            case .weekly:
                self.text = "주간 복습 내용"
            case .monthly:
                self.text = "종합 복습 내용"
            }
        } else {
            self.text = "관련된 테스트"
        }
    }
}
