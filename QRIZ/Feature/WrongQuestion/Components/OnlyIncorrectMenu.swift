//
//  OnlyIncorrectMenu.swift
//  QRIZ
//
//  Created by 이창현 on 1/22/25.
//

import UIKit

final class OnlyIncorrectMenu: UIStackView {
    // MARK: - Properties
    private let totalOption: OnlyIncorrectMenuItem = .init(title: "모두")
    private let incorrectOnlyOption: OnlyIncorrectMenuItem = .init(title: "오답만")
    
    // MARK: - Intializers
    init() {
        super.init(frame: .zero)
        initStack()
        addViews()
        setItemsState(isIncorrectOnly: false)
        setUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("no initializer for coder: OnlyIncorrectMenu")
    }
    
    // MARK: - Method
    func setItemsState(isIncorrectOnly: Bool) {
        if isIncorrectOnly {
            totalOption.textColor = .coolNeutral400
            incorrectOnlyOption.textColor = .coolNeutral800
        } else {
            totalOption.textColor = .coolNeutral800
            incorrectOnlyOption.textColor = .coolNeutral400
        }
    }
    
    private func initStack() {
        axis = .vertical
        distribution = .fillEqually
        
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral200.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    private func addViews() {
        addArrangedSubview(totalOption)
        addArrangedSubview(incorrectOnlyOption)
        
        totalOption.translatesAutoresizingMaskIntoConstraints = false
        incorrectOnlyOption.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalOption.heightAnchor.constraint(equalToConstant: 41),
            incorrectOnlyOption.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
}
