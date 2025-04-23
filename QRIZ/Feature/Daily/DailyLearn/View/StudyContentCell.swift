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
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setBorder()
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
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
    
    private func setBorder() {
        self.layer.cornerRadius = 8
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 8
        self.layer.shadowColor = UIColor.coolNeutral100.cgColor
    }
    
    @objc private func handleLongPress(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            self.backgroundColor = .coolNeutral800.withAlphaComponent(0.1)
        case .cancelled, .failed, .ended:
            self.backgroundColor = .white
        default:
            break
        }
    }
}

// MARK: - Auto Layout
extension StudyContentCell {
    private func addViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
    }
}
