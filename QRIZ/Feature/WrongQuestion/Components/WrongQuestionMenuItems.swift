//
//  OnlyIncorrectMenu.swift
//  QRIZ
//
//  Created by 이창현 on 1/22/25.
//

import UIKit
import Combine

final class WrongQuestionMenuItems: UIStackView {
    // MARK: - Properties
    private let totalOption: WrongQuestionMenuItem = .init(title: "모두")
    private let incorrectOnlyOption: WrongQuestionMenuItem = .init(title: "오답만")
    
    let input: PassthroughSubject<WrongQuestionViewModel.Input, Never> = .init()
    
    // MARK: - Intializers
    init() {
        super.init(frame: .zero)
        addViews()
        initStack()
        setUI()
        setItemsState(isIncorrectOnly: false)
        setActions()
    }
    
    required init(coder: NSCoder) {
        fatalError("no initializer for coder: OnlyIncorrectMenu")
    }
    
    // MARK: - Methods
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
        alignment = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral200.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    private func setActions() {
        totalOption.tag = 0
        incorrectOnlyOption.tag = 1
        
        totalOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMenuOptionClicked(_:))))
        incorrectOnlyOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMenuOptionClicked(_:))))
    }
    
    @objc private func sendMenuOptionClicked(_ sender: UITapGestureRecognizer) {

        let idx = sender.view?.tag ?? 0
        
        if idx == 0 {
            input.send(.menuItemClicked(isIncorrectOnly: false))
        } else if idx == 1 {
            input.send(.menuItemClicked(isIncorrectOnly: true))
        }
    }
}

// MARK: - Auto Layout
extension WrongQuestionMenuItems {
    private func addViews() {
        addArrangedSubview(totalOption)
        addArrangedSubview(incorrectOnlyOption)
        
        NSLayoutConstraint.activate([
            totalOption.heightAnchor.constraint(equalToConstant: 41),
            totalOption.widthAnchor.constraint(equalToConstant: 123)
        ])
    }
}
