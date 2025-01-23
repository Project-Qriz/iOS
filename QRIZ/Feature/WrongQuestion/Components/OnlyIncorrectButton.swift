//
//  OnlyIncorrectButton.swift
//  QRIZ
//
//  Created by ch on 1/18/25.
//

import UIKit

final class OnlyIncorrectButton: UIButton {
    
    // MARK: - Properties
    private let optionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral800
        label.textAlignment = .right
        label.text = "모두"
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        let imageView = UIImageView(image: image)
        imageView.tintColor = .coolNeutral800
        return imageView
    }()
    
    // MARK: - Intializer
    init() {
        super.init(frame: .zero)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnlyIncorrectButton")
    }
    
    // MARK: - Public Method
    func setOptionLabelTitle(isCorrectOnly: Bool) {
        if isCorrectOnly {
            optionLabel.text = "오답만"
        } else {
            optionLabel.text = "전체"
        }
    }
}

// MARK: - Auto Layout
extension OnlyIncorrectButton {
    private func addViews() {

        addSubview(optionLabel)
        addSubview(chevronImageView)
        
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalToConstant: 9),
            chevronImageView.heightAnchor.constraint(equalToConstant: 4.5),
            chevronImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            optionLabel.centerYAnchor.constraint(equalTo: chevronImageView.centerYAnchor),
            optionLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -6)
        ])
    }
}
