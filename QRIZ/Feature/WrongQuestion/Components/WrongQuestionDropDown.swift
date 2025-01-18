//
//  WrongQuestionDropDown.swift
//  QRIZ
//
//  Created by ch on 1/15/25.
//

import UIKit

final class WrongQuestionDropDown: UIView {
    
    // MARK: - Properties
    private let dropDownLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = .white
        label.textColor = .coolNeutral800
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.coolNeutral200.cgColor
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        var image = UIImage(systemName: "chevron.down")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .coolNeutral800
        return imageView
    }()
    
    // MARK: - initializer
    init() {
        super.init(frame: .zero)
        backgroundColor = .coolNeutral100
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setLabelText(_ text: String) {
        dropDownLabel.text = text
    }
}

// MARK: - Auto Layout
extension WrongQuestionDropDown {
    private func addViews() {
        addSubview(dropDownLabel)
        dropDownLabel.addSubview(chevronImageView)
        
        dropDownLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dropDownLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            dropDownLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            dropDownLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            dropDownLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24),

            chevronImageView.centerYAnchor.constraint(equalTo: dropDownLabel.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: dropDownLabel.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 13),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
