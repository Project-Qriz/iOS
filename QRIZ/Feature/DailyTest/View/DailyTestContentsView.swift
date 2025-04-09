//
//  DailyTestOptionsView.swift
//  QRIZ
//
//  Created by 이창현 on 4/2/25.
//

import UIKit
import Combine

final class DailyTestContentsView: UIStackView {
    
    // MARK: - Properties
    private let numberLabel: QuestionNumberLabel = .init()
    private let titleLabel: QuestionTitleLabel = .init()
    private let descriptionLabel: DailyTestDescriptionView = .init()
    private let optionLabels: [QuestionOptionLabel] = {
        var arr: [QuestionOptionLabel] = []
        for optionIdx in 1...4 {
            let option = QuestionOptionLabel(optNum: optionIdx)
            option.tag = optionIdx
            arr.append(option)
        }
        return arr
    }()
    
    let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupStack()
        setMargins()
        addViews()
        addOptionsActions()
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
        optionLabels.forEach {
            $0.setOptionState(isSelected: false)
            $0.setOptionString(options[$0.tag - 1])
        }
    }
    
    func setOptionState(optionIdx: Int, isSelected: Bool) {
        optionLabels[optionIdx - 1].setOptionState(isSelected: isSelected)
    }
    
    private func setupStack() {
        axis = .vertical
        alignment = .fill
    }
    
    private func setMargins() {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 35, left: 0, bottom: 35, right: 0)
    }
    
    private func addOptionsActions() {
        optionLabels.forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendTappedOption(_:))))
        }
    }
    
    @objc private func sendTappedOption(_ sender: UITapGestureRecognizer) {
        guard let optionIdx = sender.view?.tag else { return }
        input.send(.optionTapped(optionIdx: optionIdx))
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
        
        addCustomSpacing()
    }
    
    private func addCustomSpacing() {
        setCustomSpacing(14, after: numberLabel)
        setCustomSpacing(14, after: titleLabel)
        setCustomSpacing(16, after: descriptionLabel)
    }
}
