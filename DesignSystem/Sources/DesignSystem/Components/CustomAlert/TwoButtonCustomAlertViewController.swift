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
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: CustomAlertViewController")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.8)
        setupLayout()
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

// MARK: - Layout

extension TwoButtonCustomAlertViewController {
    private func setupLayout() {
        self.view.addSubview(alertView)

        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
        ])
    }
}
