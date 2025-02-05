//
//  WrongQuestionCategoryCollectionViewCell.swift
//  QRIZ
//
//  Created by ch on 2/2/25.
//

import UIKit

class WrongQuestionCategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "WrongQuestionCategoryCollectionViewCell"
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral700
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setUI()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func configure(_ text: String) {
        textLabel.text = text
    }
    
    func setState(_ isClicked: Bool) {
        if isClicked {
            backgroundColor = .white
            layer.borderColor = UIColor.customBlue500.cgColor
            layer.borderWidth = 1.5
            textLabel.textColor = .customBlue500
            textLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        } else {
            backgroundColor = .coolNeutral100
            layer.borderWidth = 0
            textLabel.textColor = .customBlue500
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    private func setUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
        setState(false)
    }
}

// MARK: - Auto Layout
extension WrongQuestionCategoryCollectionViewCell {
    private func addViews() {
        
        self.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
}
