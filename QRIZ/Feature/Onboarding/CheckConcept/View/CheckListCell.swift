//
//  CheckListCell.swift
//  QRIZ
//
//  Created by ch on 12/15/24.
//

import UIKit

final class CheckListCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "CheckListCell"
    
    private let textLabel = UILabel()
    private let checkbox: UIImageView

    // MARK: - Initializers
    override init(frame: CGRect) {
        checkbox = UIImageView(image: UIImage(named: "checkboxOffIcon"))
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: CheckListCell")
    }
    
    // MARK: - Methods
    func toggleCheckbox(_ isNextStateOn: Bool) {
        self.checkbox.image = isNextStateOn == true ? UIImage(named: "checkboxOnIcon") : UIImage(named: "checkboxOffIcon")
    }
    
    func configure(_ itemContent: String) {
        textLabel.text = itemContent
        textLabel.font = .systemFont(ofSize: 15)
        textLabel.textColor = .black
        textLabel.textAlignment = .left
    }
}

// MARK: - Auto Layout
extension CheckListCell {
    private func addViews() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .center
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textLabel)
        self.addSubview(checkbox)
        
        NSLayoutConstraint.activate([
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 12),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
