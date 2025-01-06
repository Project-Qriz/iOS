//
//  CustomAlertViewController.swift
//  QRIZ
//
//  Created by ch on 1/7/25.
//

import UIKit

class CustomAlertViewController: UIViewController {
    
    private var alertView: CustomAlertView = CustomAlertView(alertType: .onlyConfirm, title: "", description: "", descriptionLine: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.8)
        addViews()
    }
    
    func setAlertView(alertView: CustomAlertView) {
        self.alertView = alertView
    }
    
    private func addViews() {

        self.view.addSubview(alertView)

        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 295),
            alertView.heightAnchor.constraint(equalToConstant: 146)
        ])
    }
}
