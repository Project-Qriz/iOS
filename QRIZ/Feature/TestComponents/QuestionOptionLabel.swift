//
//  QuestionOptionLabel.swift
//  QRIZ
//
//  Created by ch on 12/21/24.
//

import UIKit

final class QuestionOptionLabel: UILabel {

    var optionNumberLabel: UILabel = UILabel()
    var optionStringLabel: UILabel = UILabel()
    
    init(optNum: Int, optStr: String) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        createNumberLabel(optNum)
        createStringLabel(optStr)
        addViews()
    }
    
    private func addViews() {
        self.addSubview(optionNumberLabel)
        self.addSubview(optionStringLabel)
        
        optionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        optionStringLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            optionNumberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            optionNumberLabel.widthAnchor.constraint(equalToConstant: 32),
            optionNumberLabel.heightAnchor.constraint(equalToConstant: 32),
            optionNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            optionStringLabel.leadingAnchor.constraint(equalTo: optionNumberLabel.trailingAnchor, constant: 18),
            optionStringLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            optionStringLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            optionStringLabel.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: QuestionOptionLabel")
    }
    
    private func createNumberLabel(_ optNum: Int) {
        optionNumberLabel = UILabel()
        optionNumberLabel.backgroundColor = .white
        optionNumberLabel.text = "\(optNum)"
        optionNumberLabel.textAlignment = .center
        optionNumberLabel.font = .boldSystemFont(ofSize: 16)
        optionNumberLabel.textColor = .coolNeutral600
        optionNumberLabel.numberOfLines = 0
        optionNumberLabel.layer.masksToBounds = true
        optionNumberLabel.layer.cornerRadius = 16
        optionNumberLabel.layer.borderColor = UIColor.coolNeutral600.cgColor
        optionNumberLabel.layer.borderWidth = 1.2
    }
    
    private func createStringLabel(_ optStr: String) {
        optionStringLabel = UILabel()
        optionStringLabel.text = optStr
        optionStringLabel.font = .systemFont(ofSize: 14)
        optionStringLabel.textColor = .coolNeutral800
        optionStringLabel.numberOfLines = 1
    }
    
    func setOptionString(_ str: String) {
        optionStringLabel.text = str
    }
    
    func setOptionStatus(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .customBlue100
            optionNumberLabel.backgroundColor = .customBlue500
            optionNumberLabel.textColor = .white
            optionNumberLabel.layer.cornerRadius = 16
            optionNumberLabel.layer.masksToBounds = true
            optionNumberLabel.layer.borderWidth = 0
            optionStringLabel.textColor = .customBlue500
        } else {
            self.backgroundColor = .white
            optionNumberLabel.backgroundColor = .white
            optionNumberLabel.textColor = .coolNeutral600
            optionNumberLabel.layer.cornerRadius = 16
            optionNumberLabel.layer.masksToBounds = true
            optionNumberLabel.layer.borderWidth = 1.2
            optionStringLabel.textColor = .coolNeutral800
        }
    }
}
