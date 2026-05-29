//
//  PlanChangeMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/25/25.
//

import UIKit
import DesignSystem
import QRIZUtils
import Combine

final class PlanChangeMainView: UIView {

    // MARK: - Properties

    private var optionViews: [PlanOption: PlanChangeOptionView] = [:]
    private var currentPlan: PlanOption?
    private var availablePlans: Set<PlanOption> = []
    private var selectedPlan: PlanOption?
    private let planSelectedSubject = PassthroughSubject<PlanOption, Never>()
    private let confirmTapSubject = PassthroughSubject<Void, Never>()
    private let resetTapSubject = PassthroughSubject<Void, Never>()
    private let dismissTapSubject = PassthroughSubject<Void, Never>()

    var planSelectedPublisher: AnyPublisher<PlanOption, Never> {
        planSelectedSubject.eraseToAnyPublisher()
    }

    var confirmTapPublisher: AnyPublisher<Void, Never> {
        confirmTapSubject.eraseToAnyPublisher()
    }

    var resetTapPublisher: AnyPublisher<Void, Never> {
        resetTapSubject.eraseToAnyPublisher()
    }

    var dismissTapPublisher: AnyPublisher<Void, Never> {
        dismissTapSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        button.addAction(UIAction { [weak self] _ in
            self?.dismissTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "며칠 동안 공부할까요?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "기간에 맞게 개념과 문제를 배분해 드려요."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()

    private lazy var optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(
            string: "초기화하기",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.coolNeutral600,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(title, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.resetTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "선택한 플랜으로 변경하기"
        config.baseBackgroundColor = .coolNeutral200
        config.baseForegroundColor = .coolNeutral500
        config.titleTextAttributesTransformer = .init { attr in
            var a = attr
            a.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            return a
        }
        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            self?.confirmTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [resetButton, confirmButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildOptionViews()
        addSubviews()
        setupConstraints()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    
    private func setupUI() {
        backgroundColor = .coolNeutral100
    }

    private func buildOptionViews() {
        for option in PlanOption.allCases {
            let view = PlanChangeOptionView(option: option)
            view.onTap = { [weak self] in self?.planSelectedSubject.send(option) }
            optionViews[option] = view
            optionsStack.addArrangedSubview(view)
        }
    }

    private func updateOptionViews() {
        for option in PlanOption.allCases {
            guard let view = optionViews[option] else { continue }
            let status: PlanOptionViewState.Status
            if option == currentPlan {
                status = .current
            } else if availablePlans.contains(option) {
                status = .available
            } else {
                status = .unavailable
            }
            let isSelected = (option == selectedPlan) && (option != currentPlan)
            view.configure(state: PlanOptionViewState(status: status, isSelected: isSelected))
        }
    }

    func applyCurrentPlan(_ plan: PlanOption?) {
        currentPlan = plan
        selectedPlan = nil
        updateOptionViews()
    }

    func applyAvailablePlans(_ plans: [PlanOption]) {
        availablePlans = Set(plans)
        updateOptionViews()
        confirmButton.configuration?.title = plans.isEmpty
            ? "선택할 수 있는 플랜이 없습니다"
            : "선택한 플랜으로 변경하기"
    }

    func applySelection(_ plan: PlanOption?) {
        selectedPlan = plan
        updateOptionViews()
    }

    func setConfirmEnabled(_ enabled: Bool) {
        confirmButton.isEnabled = enabled
        confirmButton.configuration?.baseForegroundColor = enabled ? .white : .coolNeutral500
        confirmButton.configuration?.baseBackgroundColor = enabled ? .customBlue500 : .coolNeutral200
    }

    func setLoading(_ loading: Bool) {
        confirmButton.configuration?.showsActivityIndicator = loading
    }
}

// MARK: - Layout Setup

extension PlanChangeMainView {
    private func addSubviews() {
        [
            closeButton,
            titleLabel,
            subtitleLabel,
            optionsStack,
            bottomStack
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        [
            closeButton,
            titleLabel,
            subtitleLabel,
            optionsStack,
            bottomStack
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 34),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),

            optionsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            optionsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            optionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            bottomStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            confirmButton.widthAnchor.constraint(equalTo: bottomStack.widthAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
