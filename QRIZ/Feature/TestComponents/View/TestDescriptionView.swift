//
//  DailyTestDescriptionView.swift
//  QRIZ
//
//  Created by 이창현 on 4/3/25.
//

import UIKit

final class TestDescriptionView: UIView {
    
    // MARK: - Properties
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setBorder()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestDescriptionView")
    }
    
    // MARK: - Methods
    func setText(_ text: String) {
        label.attributedText = formattedText(text)
    }
    
    private func setBorder() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral200.cgColor
    }
    
    private func formattedText(_ text: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        return attributedText
    }
}

extension TestDescriptionView {
    private func addViews() {
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
