//
//  DailyTestOptionsView.swift
//  QRIZ
//
//  Created by 이창현 on 4/2/25.
//

import UIKit

final class DailyTestContentsView: UIStackView {
    
    // MARK: - Properties
    private let numberLabel: QuestionNumberLabel = .init()
    private let titleLabel: QuestionTitleLabel = .init()
    private let descriptionLabel: DailyTestDescriptionView = .init()
    private let optionLabels: [QuestionOptionLabel] = {
        var arr: [QuestionOptionLabel] = []
        for i in 1...4 {
            arr.append(QuestionOptionLabel(optNum: i))
        }
        return arr
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupStack()
        setMargins()
        addViews()
        addCustomSpacing()
        setMockUI()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    private func setupStack() {
        axis = .vertical
        alignment = .leading
        spacing = 32
    }
    
    private func setMargins() {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 35, left: 0, bottom: 35, right: 0)
    }
    
    // MARK: - TEST
    private func setMockUI() {
        numberLabel.setNumber(1)
        titleLabel.setTitle("데이터 모델링에서 '유연성'이 의미하는 바는?")
        optionLabels[0].setOptionString("ㄱ. null ㄴ. NULL ㄷ. null ㄹ. NULL")
        optionLabels[1].setOptionString("ㄱ. null ㄴ. NULL ㄷ. null ㄹ. NULL")
        optionLabels[2].setOptionString("ㄱ. null ㄴ. NULL ㄷ. null ㄹ. NULL")
        optionLabels[3].setOptionString("ㄱ. null ㄴ. NULL ㄷ. null ㄹ. NULL")
    }
}

// MARK: - Layout
extension DailyTestContentsView {
    private func addViews() {
        addArrangedSubview(numberLabel)
        addArrangedSubview(titleLabel)
        addArrangedSubview(descriptionLabel)
        for option in optionLabels {
            addArrangedSubview(option)
        }
    }
    
    private func addCustomSpacing() {
        setCustomSpacing(8, after: numberLabel)
        setCustomSpacing(10, after: titleLabel)
        setCustomSpacing(8, after: numberLabel)
    }
}
