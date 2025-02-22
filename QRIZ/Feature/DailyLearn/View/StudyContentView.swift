//
//  DailyLearnContentView.swift
//  QRIZ
//
//  Created by ch on 2/20/25.
//

import UIKit

final class StudyContentView: UIView {

    // MARK: - Properties
    private let keyConcept1Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let keyConcept2Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let conceptContent1Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let conceptContent2Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setBorder()
        addViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("no initializer for coder: TestNavigatorButton")
    }
    
    // MARK: - Method
    func setLabelsText(keyConcept1: String,
                       conceptContent1: String,
                       keyConcept2: String,
                       conceptContent2: String
    ) {
        keyConcept1Label.text = " 1. \(keyConcept1)"
        let conceptContent1Text = conceptContent1
        keyConcept2Label.text = " 2. \(keyConcept2)"
        let conceptContent2Text = conceptContent2
        
        let content1String = NSMutableAttributedString(string: conceptContent1Text)
        let content2String = NSMutableAttributedString(string: conceptContent2Text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        content1String.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, content1String.length))
        content2String.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, content2String.length))

        conceptContent1Label.attributedText = content1String
        conceptContent2Label.attributedText = content2String
    }
    
    private func setBorder() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}

// MARK: - Auto Layout
extension StudyContentView {
    private func addViews() {
        
        addSubview(keyConcept1Label)
        addSubview(conceptContent1Label)
        addSubview(keyConcept2Label)
        addSubview(conceptContent2Label)
        
        keyConcept1Label.translatesAutoresizingMaskIntoConstraints = false
        conceptContent1Label.translatesAutoresizingMaskIntoConstraints = false
        keyConcept2Label.translatesAutoresizingMaskIntoConstraints = false
        conceptContent2Label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            keyConcept1Label.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            keyConcept1Label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            keyConcept1Label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            conceptContent1Label.topAnchor.constraint(equalTo: keyConcept1Label.bottomAnchor, constant: 13),
            conceptContent1Label.leadingAnchor.constraint(equalTo: keyConcept1Label.leadingAnchor),
            conceptContent1Label.trailingAnchor.constraint(equalTo: keyConcept1Label.trailingAnchor),
            
            keyConcept2Label.topAnchor.constraint(equalTo: conceptContent1Label.bottomAnchor, constant: 20),
            keyConcept2Label.leadingAnchor.constraint(equalTo: keyConcept1Label.leadingAnchor),
            keyConcept2Label.trailingAnchor.constraint(equalTo: keyConcept1Label.trailingAnchor),
            
            conceptContent2Label.topAnchor.constraint(equalTo: keyConcept2Label.bottomAnchor, constant: 13),
            conceptContent2Label.leadingAnchor.constraint(equalTo: keyConcept1Label.leadingAnchor),
            conceptContent2Label.trailingAnchor.constraint(equalTo: keyConcept1Label.trailingAnchor),
            conceptContent2Label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24)
        ])
    }
}
