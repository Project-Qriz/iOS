//
//  ExamListFilterItemsView.swift
//  QRIZ
//
//  Created by 이창현 on 5/12/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class ExamListFilterItemsView: UIStackView {

    // MARK: - Properties

    private var selectedFilter: ExamListFilterType = .total
    private let filterSelectedSubject: PassthroughSubject<ExamListFilterType, Never> = .init()
    
    var filterSelectionPublisher: AnyPublisher<ExamListFilterType, Never> {
        filterSelectedSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private var itemButtonsDic: [ExamListFilterType: UIButton] = [:]

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupStackView()
        setupItemButtons()
        addSubviews()
        setupConstraints()
        setupAppearance()
        isHidden = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func updateSelectedItem(_ filterType: ExamListFilterType) {
        guard let newSelected = itemButtonsDic[filterType],
              let oldSelected = itemButtonsDic[selectedFilter] else { return }
        updateButtonState(button: oldSelected, isSelected: false)
        updateButtonState(button: newSelected, isSelected: true)
        selectedFilter = filterType
    }

    private func setupStackView() {
        distribution = .equalSpacing
        alignment = .fill
        spacing = 0
        isLayoutMarginsRelativeArrangement = true
        axis = .vertical
    }

    private func setupItemButtons() {
        ExamListFilterType.allCases.forEach { type in
            let button = UIButton()
            button.setTitle(type.rawValue, for: .normal)
            button.contentHorizontalAlignment = .left
            updateButtonState(button: button, isSelected: type == .total)
            button.addAction(UIAction { [weak self] _ in
                self?.filterSelectedSubject.send(type)
            }, for: .touchUpInside)
            itemButtonsDic[type] = button
        }
    }

    private func updateButtonState(button: UIButton, isSelected: Bool) {
        button.setTitleColor(isSelected ? .customBlue500 : .coolNeutral600, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: isSelected ? .bold : .medium)
    }

    private func setupAppearance() {
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 0.7
    }
}

// MARK: - Layout Setup

extension ExamListFilterItemsView {
    private func addSubviews() {
        itemButtonsDic.sorted(by: { $0.key < $1.key }).forEach {
            addArrangedSubview($0.value)
        }
    }

    private func setupConstraints() {
        itemButtonsDic.values.forEach {
            $0.widthAnchor.constraint(equalToConstant: 123).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 0)
    }
}
