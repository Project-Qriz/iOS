//
//  QuestionOptionLabel.swift
//  QRIZ
//
//  Created by ch on 12/21/24.
//

import UIKit

final class QuestionOptionLabel: UILabel {

    // MARK: - Properties
    private var optionNumberLabel: UILabel!
    private var optionStringLabel: UILabel!
    
    // MARK: - Initializers
    init(optNum: Int) {
        super.init(frame: .zero)
        createNumberLabel(optNum)
        createStringLabel()
        setOptionState(isSelected: false)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionOptionLabel")
    }
    
    // MARK: - Methods
    func setOptionString(_ str: String) {
        optionStringLabel.attributedText = formattedText(str)
    }
    
    func setOptionState(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .customBlue100
            optionNumberLabel.backgroundColor = .customBlue500
            optionNumberLabel.textColor = .white
            optionNumberLabel.layer.borderWidth = 0
        } else {
            self.backgroundColor = .white
            optionNumberLabel.backgroundColor = .white
            optionNumberLabel.textColor = .coolNeutral700
            optionNumberLabel.layer.borderWidth = 1.2
        }
    }
    
    private func createNumberLabel(_ optNum: Int) {
        optionNumberLabel = UILabel()
        optionNumberLabel.text = "\(optNum)"
        optionNumberLabel.textAlignment = .center
        optionNumberLabel.font = .boldSystemFont(ofSize: 16)
        optionNumberLabel.numberOfLines = 1

        optionNumberLabel.layer.masksToBounds = true
        optionNumberLabel.layer.cornerRadius = 20
        optionNumberLabel.layer.borderColor = UIColor.coolNeutral700.cgColor
        optionNumberLabel.layer.borderWidth = 1.25
    }
    
    private func createStringLabel() {
        optionStringLabel = UILabel()
        optionStringLabel.textAlignment = .left
        optionStringLabel.textColor = .coolNeutral700
        optionStringLabel.font = .systemFont(ofSize: 16, weight: .regular)
        optionStringLabel.numberOfLines = 0
    }
    
    private func formattedText(_ string: String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: string)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = 8
        
        string.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.length))
        
        return string
    }
}

// MARK: - AutoLayout
extension QuestionOptionLabel {
    private func addViews() {
        self.addSubview(optionNumberLabel)
        self.addSubview(optionStringLabel)
        
        optionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        optionStringLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            optionNumberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            optionNumberLabel.widthAnchor.constraint(equalToConstant: 40),
            optionNumberLabel.heightAnchor.constraint(equalTo: optionNumberLabel.widthAnchor),
            optionNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            optionStringLabel.leadingAnchor.constraint(equalTo: optionNumberLabel.trailingAnchor, constant: 16),
            optionStringLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            optionStringLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            optionStringLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
}
