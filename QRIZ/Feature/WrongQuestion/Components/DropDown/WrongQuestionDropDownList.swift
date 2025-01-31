//
//  WrongQuestionDropDownList.swift
//  QRIZ
//
//  Created by ch on 1/18/25.
//

import UIKit

final class WrongQuestionDropDownList: UICollectionView {
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        setBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: WrongQuestionDropDownList")
    }
    
    // MARK: - Methods
    private func setBorder() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral200.cgColor
    }
}
