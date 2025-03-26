//
//  StudyContentCell.swift
//  QRIZ
//
//  Created by ch on 3/27/25.
//

import UIKit

final class StudyContentCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier: String = "StudyContentCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral800
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral500
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    private let conceptBookNavigator: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral600
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.attributedText = NSAttributedString(string: "개념서에서 보기＞", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        self.layer.cornerRadius = 8
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: StudyContentCell")
    }
    
    // MARK: - Methods
    func setLabelText(titleText: String, descriptionText: String) {
        titleLabel.text = titleText
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: descriptionText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        descriptionLabel.attributedText = attributedString
    }
}

// MARK: - Auto Layout
extension StudyContentCell {
    private func addViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(conceptBookNavigator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        conceptBookNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            conceptBookNavigator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            conceptBookNavigator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
}
