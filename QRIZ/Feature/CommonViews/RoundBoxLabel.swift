//
//  RoundBoxLabel.swift
//  QRIZ
//
//  Created by 김세훈 on 4/29/25.
//

import UIKit

final class RoundBoxLabel: UIView {
    
    // MARK: - UI
    
    private let label = UILabel()
    
    // MARK: - Initialize
    
    init(text: String, width: CGFloat, height: CGFloat) {
        super.init(frame: .zero)
        setupLabel(width: width, height: height)
        setText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    private func setupLabel(width: CGFloat, height: CGFloat) {
        backgroundColor = .customBlue500
        layer.cornerRadius = 8
        
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        addSubview(label)
        
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}

