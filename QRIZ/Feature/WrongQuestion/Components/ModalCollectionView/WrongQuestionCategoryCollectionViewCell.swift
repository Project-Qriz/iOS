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
        label.textColor = .coolNeutral800
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private var textStr: String = ""
    private let checkmarkString: NSAttributedString = {
        let checkmarkImage = UIImage(systemName: "checkmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysTemplate)

        let attachment = NSTextAttachment()
        attachment.image = checkmarkImage
        attachment.bounds.size = CGSize(width: 12, height: 10)

        let imageString = NSAttributedString(attachment: attachment)

        return imageString
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
        textStr = text
        setState(isAvailable: isAvailable, isClicked: isClicked)
    }
    
    func setState(isAvailable: Bool, isClicked: Bool) {
        if isAvailable {
            if isClicked {
                textLabel.attributedText = getCheckedString()
                layer.borderWidth = 1.2
                layer.borderColor = UIColor.coolNeutral800.cgColor
                textLabel.textColor = .coolNeutral800
                textLabel.font = .systemFont(ofSize: 14, weight: .bold)
            } else {
                textLabel.text = textStr
                layer.borderWidth = 1
                layer.borderColor = UIColor.coolNeutral200.cgColor
                textLabel.textColor = .coolNeutral800
                textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            }
        } else {
            textLabel.text = textStr
            layer.borderWidth = 1
            layer.borderColor = UIColor.coolNeutral200.withAlphaComponent(0.7).cgColor
            textLabel.textColor = .coolNeutral800.withAlphaComponent(0.7)
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setState(isAvailable: true, isClicked: false)
    }
    
    private func getCheckedString() -> NSAttributedString {
        let str = NSMutableAttributedString(string: " \(textStr)")
        str.insert(checkmarkString, at: 0)
        return str
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
