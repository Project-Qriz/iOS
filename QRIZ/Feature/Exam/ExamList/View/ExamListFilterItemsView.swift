//
//  ExamListFilterItemsView.swift
//  QRIZ
//
//  Created by 이창현 on 5/12/25.
//

import UIKit
import Combine

final class ExamListFilterItemsView: UIStackView {
    
    // MARK: - Properties
    private var itemButtonsDic: [ExamListFilterType: UIButton] = [:]
    private var selectedFilter: ExamListFilterType = .total
    
    let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        setStackView()
        appendItemLabels()
        addSubviews()
        setLayer()
        isHidden = true
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func setItemSelected(selectedType: ExamListFilterType) {
        if let newSelected = itemButtonsDic[selectedType], let oldSelected = itemButtonsDic[selectedFilter] {
            setButtonState(button: oldSelected, isSelected: false)
            setButtonState(button: newSelected, isSelected: true)
            selectedFilter = selectedType
        }
    }
    
    private func setStackView() {
        distribution = .equalSpacing
        alignment = .fill
        spacing = 0
        isLayoutMarginsRelativeArrangement = true
        axis = .vertical
    }

    private func appendItemLabels() {
        ExamListFilterType.allCases.forEach { [weak self] type in
            guard let self = self else { return }

            let button = UIButton()
            button.setTitle(type.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            
            if type == .total {
                setButtonState(button: button, isSelected: true)
            } else {
                setButtonState(button: button, isSelected: false)
            }
            
            button.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.input.send(.filterItemSelected(filterType: type))
            }), for: .touchUpInside)
            
            self.itemButtonsDic[type] = button
        }
    }
    
    private func setButtonState(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.setTitleColor(.customBlue500, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        } else {
            button.setTitleColor(.coolNeutral600, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    private func setLayer() {
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 0.7
    }
}

extension ExamListFilterItemsView {
    private func addSubviews() {
        itemButtonsDic.sorted(by: {
            $0.key < $1.key
        }).forEach {
            addArrangedSubview($0.value)
            $0.value.widthAnchor.constraint(equalToConstant: 123).isActive = true
            $0.value.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        
        layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 0)
    }
}
