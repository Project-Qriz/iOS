//
//  WrongQuestionCategoryReusableView.swift
//  QRIZ
//
//  Created by 이창현 on 2/5/25.
//

import UIKit

final class WrongQuestionCategoryReusableView: UICollectionReusableView {
    
    static let identifier = "WrongQuestionCategoryReusableView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: WrongQuestionCategoryReusableView")
    }
    
    func configure(_ text: String) {
        self.titleLabel.text = text
    }
}

// MARK: - Auto Layout
extension WrongQuestionCategoryReusableView {
    private func addViews() {
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
}
