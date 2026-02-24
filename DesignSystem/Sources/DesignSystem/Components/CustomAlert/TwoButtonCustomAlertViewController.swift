//
//  TwoButtonCustomAlertViewController.swift
//  DesignSystem
//
//  Created by ch on 1/7/25.
//

import UIKit
import Combine

public final class TwoButtonCustomAlertViewController: UIViewController {

    // MARK: - Properties

    private let alertView: TwoButtonCustomAlertView

    // MARK: - Initializer

    public init(
        title: String,
        titleLine: Int = 1,
        description: String,
        descriptionLine: Int = 2,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        confirmAction: UIAction? = nil,
        cancelAction: UIAction? = nil
    ) {
        self.alertView = TwoButtonCustomAlertView(
            title: title,
            titleLine: titleLine,
            description: description,
            descriptionLine: descriptionLine,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle
        )
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        addSubviews()
        setupConstraints()
    }

    // MARK: - Functions

    public func setupButtonActions(confirmAction: UIAction?, cancelAction: UIAction?) {
        if let confirmAction = confirmAction {
            alertView.setButtonAction(true, action: confirmAction)
        }

        if let cancelAction = cancelAction {
            alertView.setButtonAction(false, action: cancelAction)
        }
    }
}

// MARK: - Layout Setup

extension TwoButtonCustomAlertViewController {
    private func addSubviews() {
        view.addSubview(alertView)
    }

    private func setupConstraints() {
        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }
}
