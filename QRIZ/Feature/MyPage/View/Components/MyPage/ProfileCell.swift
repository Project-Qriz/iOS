//
//  ProfileCell.swift
//  QRIZ
//
//  Created by 김세훈 on 5/31/25.
//

import UIKit

final class ProfileCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let spacing: CGFloat = 12.0
    }
    
    private enum Attributes {
        static let chevron: String = "chevron.right"
    }
    
    // MARK: - UI
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: Attributes.chevron, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        
        button.addAction(UIAction(handler: { _ in
            print("터치터치")
        }), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, chevronButton])
        stackView.axis = .horizontal
        stackView.spacing = Metric.spacing
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    }
    
    func configure(with userName: String) {
        userNameLabel.text = userName
    }
}

// MARK: - Layout Setup

extension ProfileCell {
    private func addSubviews() {
        [
            stackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
