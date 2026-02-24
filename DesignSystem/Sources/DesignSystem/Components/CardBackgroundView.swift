//
//  CardBackgroundView.swift
//  DesignSystem
//
//  Created by 김세훈 on 6/4/25.
//

import UIKit

public final class CardBackgroundView: UICollectionReusableView {

    // MARK: - Initializer

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral100.cgColor

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
}
