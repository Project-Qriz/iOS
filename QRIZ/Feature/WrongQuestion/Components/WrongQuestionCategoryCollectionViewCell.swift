//
//  WrongQuestionCategoryCollectionViewCell.swift
//  QRIZ
//
//  Created by ch on 2/2/25.
//

import UIKit

final class WrongQuestionCategoryCollectionViewCell: UICollectionViewCell {
    
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func configure(_ text: String, isAvailable: Bool, isClicked: Bool) {
        textLabel.text = text
        
    }
    
    func setState(isAvailable: Bool, isClicked: Bool) {
        if isAvailable {
            if isClicked {
                backgroundColor = .white
                layer.borderColor = UIColor.customBlue500.cgColor
                layer.borderWidth = 1.5
                textLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            } else {
                backgroundColor = .coolNeutral100
                layer.borderWidth = 0
                textLabel.textColor = .coolNeutral700
                textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            }
        } else {
            backgroundColor = .customBlue50
            layer.borderWidth = 0
            textLabel.textColor = .coolNeutral300
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    private func setUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
        layer.borderColor = UIColor.customBlue500.cgColor
        setState(isAvailable: true, isClicked: false)
    }
}

// MARK: - Auto Layout
extension WrongQuestionCategoryCollectionViewCell {
    private func addViews() {
        
        self.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
}
