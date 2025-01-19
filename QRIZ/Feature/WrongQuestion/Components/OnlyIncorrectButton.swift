//
//  OnlyIncorrectButton.swift
//  QRIZ
//
//  Created by ch on 1/18/25.
//

import UIKit

final class OnlyIncorrectButton: UIButton {
    
    // MARK: - Properties
    private lazy var menuItems: UIMenu = UIMenu(title: "", options: [], children: [
        UIAction(title: "모두", handler: { [weak self] _ in
            guard let self = self else { return }

            self.setTitleText(isIncorrectOnly: false)
        }),
        UIAction(title: "오답만",  handler: { [weak self] _ in
            guard let self = self else { return }
            
            setTitleText(isIncorrectOnly: true)
        })
    ])
    
    // MARK: - Intializer
    init() {
        super.init(frame: .zero)
        menu = menuItems
        setTitleText(isIncorrectOnly: false)
        self.showsMenuAsPrimaryAction = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: OnlyIncorrectButton")
    }
}

// MARK: - UI
extension OnlyIncorrectButton {
    private func setTitleText(isIncorrectOnly: Bool) {
        isIncorrectOnly ?
        setAttributedTitle(NSAttributedString(string: "오답만", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.coolNeutral800
        ]), for: .normal) :
        setAttributedTitle(NSAttributedString(string: "모두", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.coolNeutral800
        ]), for: .normal)
        
        imageView?.image = UIImage(systemName: "chevron.down")
    }
}
