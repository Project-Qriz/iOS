//
//  ConceptCardView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/30/25.
//

import UIKit

final class ConceptCardView: UIView {
    
    private enum Metric {
        static let vInset: CGFloat = 12.0
        static let hInset: CGFloat = 16.0
        static let spacing: CGFloat = 8.0
    }
    
    // MARK: - UI
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let keyConceptLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    // MARK: - Initialize
    
    init(type: String, keyConcept: String) {
        super.init(frame: .zero)
        typeLabel.text = type
        keyConceptLabel.text = keyConcept
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
        layer.cornerRadius = 12.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.customBlue100.cgColor
    }
}

// MARK: - Layout Setup

extension ConceptCardView {
    private func addSubviews() {
        [
            typeLabel,
            keyConceptLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        keyConceptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.vInset),
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.hInset),
            
            keyConceptLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: Metric.spacing),
            keyConceptLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.hInset),
            keyConceptLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metric.vInset)
        ])
    }
}
