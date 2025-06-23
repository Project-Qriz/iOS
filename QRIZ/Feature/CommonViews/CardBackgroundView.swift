//
//  CardBackgroundView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/4/25.
//

import UIKit

final class CardBackgroundView: UICollectionReusableView {
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral100.cgColor
        applyQRIZShadow(radius: 14)
    }
}
