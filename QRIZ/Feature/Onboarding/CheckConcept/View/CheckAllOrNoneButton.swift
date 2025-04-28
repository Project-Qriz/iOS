//
//  CheckAllOrNoView.swift
//  QRIZ
//
//  Created by ch on 2/24/25.
//

import UIKit
import Combine

final class CheckAllOrNoneButton : UIView {
    
    // MARK: - Properties
    private enum CheckState: String {
        case on = "checkboxOnIcon"
        case off = "checkboxOffIcon"
        case some = "checkboxSomeIcon"
    }
    
    private var isAllButton: Bool = false
    private var state: CheckState = .off
    
    private let checkbox: UIImageView = UIImageView(image: UIImage(named: "checkboxOffIcon"))
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.backgroundColor = .white
        return label
    }()
    
    let input: PassthroughSubject<CheckConceptViewModel.Input, Never> = .init()
    
    // MARK: - Intializers
    init(isAll: Bool) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.isAllButton = isAll
        setLabelText()
        setBorder()
        addViews()
        addAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func checkboxHandler(numOfSelectedConcept: Int, checkNoneClicked: Bool = false) {
        isAllButton ? checkAllBoxHandler(numOfSelectedConcept) : checkNoneBoxHandler(checkNoneClicked)
    }
    
    private func checkAllBoxHandler(_ numOfSelectedConcept: Int) {
        switch numOfSelectedConcept {
        case 0:
            if state != .off {
                checkbox.image = UIImage(named: CheckState.off.rawValue)
                state = .off
            }
        case SurveyCheckList.list.count:
            if state != .on {
                checkbox.image = UIImage(named: CheckState.on.rawValue)
                state = .on
            }
        default:
            if state != .some {
                checkbox.image = UIImage(named: CheckState.some.rawValue)
                state = .some
            }
        }
    }
    
    private func checkNoneBoxHandler(_ isSenderCheckNone: Bool) {
        if isSenderCheckNone || state == .on {
            let nextState = (state == .on ? CheckState.off : CheckState.on)
            checkbox.image = UIImage(named: nextState.rawValue)
            state = nextState
        }
    }
    
    private func setLabelText() {
        label.text = isAllButton ? "전부 아는 개념이에요!" : "모든 개념을 처음 봐요"
    }
    
    private func setBorder() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral100.cgColor
    }
    
    private func addAction() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendClickedEvent)))
    }
    
    @objc private func sendClickedEvent() {
        if isAllButton {
            input.send(.checkAllClicked)
        } else {
            state == .on ? input.send(.checkNoneClicked(isOn: false)) : input.send(.checkNoneClicked(isOn: true))
        }
    }
}

// MARK: - Auto Layout
extension CheckAllOrNoneButton {
    private func addViews() {
        addSubview(checkbox)
        addSubview(label)
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalTo: checkbox.widthAnchor),
            checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
