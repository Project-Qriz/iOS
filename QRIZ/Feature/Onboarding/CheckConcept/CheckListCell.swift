//
//  CheckListCell.swift
//  QRIZ
//
//  Created by ch on 12/15/24.
//

import UIKit

class CheckListCell: UICollectionViewCell {

    static let identifier = "CheckListCell"
    
    private let textLabel = UILabel()
    var checkbox: UIImageView

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
    
    func toggleCheckbox(_ nextState: CheckBoxState) {
        self.checkbox.image = nextState == .on ? UIImage(named: "checkboxOnIcon") : UIImage(named: "checkboxOffIcon")
    }
    
    private func addViews() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .center
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textLabel)
        self.addSubview(checkbox)
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            textLabel.widthAnchor.constraint(equalToConstant: self.frame.width / 2),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            checkbox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func configure(_ itemContent: String) {
        textLabel.text = itemContent
        textLabel.font = .systemFont(ofSize: 15)
        textLabel.textColor = .black
        textLabel.textAlignment = .left
    }
}
