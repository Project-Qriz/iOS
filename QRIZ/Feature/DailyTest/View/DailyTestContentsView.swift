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
    func updateQuestion(_ question: QuestionData) {
        numberLabel.setNumber(question.questionNumber)
        titleLabel.setTitle(question.question)
        if let description = question.description {
            descriptionLabel.isHidden = false
            descriptionLabel.setText(description)
        } else {
            descriptionLabel.isHidden = true
        }
        let options = [question.option1, question.option2, question.option3, question.option4]
        for i in 0...3 {
            optionLabels[i].setOptionState(isSelected: false)
            optionLabels[i].setOptionString(options[i])
        }
    }
    
    private func setupStack() {
        axis = .vertical
        alignment = .fill
    }
    
    private func setMargins() {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 35, left: 0, bottom: 35, right: 0)
    }
    
    // MARK: - TEST
    private func setMockUI() {
        numberLabel.setNumber(1)
        titleLabel.setTitle("다음과 같은 상황에서 적절한 엔터티 도출 방식은?")
        optionLabels[0].setOptionString("""
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """)
        optionLabels[1].setOptionString("""
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """)
        optionLabels[2].setOptionString("""
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """)
        optionLabels[3].setOptionString("""
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """)
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
        setCustomSpacing(14, after: numberLabel)
        setCustomSpacing(14, after: titleLabel)
        setCustomSpacing(16, after: descriptionLabel)
    }
}
