//
//  CheckListFoldButton.swift
//  QRIZ
//
//  Created by ch on 2/25/25.
//

import UIKit

final class CheckListFoldButton: UIButton {
    
    // MARK: - Properties
    private var isFolded: Bool = false

    private let foldedImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
    private let unfoldedImage = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate)
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        tintColor = .coolNeutral700
        setImage(unfoldedImage, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Methods
    func toggleImage() {
        isFolded.toggle()
        isFolded ? setImage(foldedImage, for: .normal) : setImage(unfoldedImage, for: .normal)
    }
}
