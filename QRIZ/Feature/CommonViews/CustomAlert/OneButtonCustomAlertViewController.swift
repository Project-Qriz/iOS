//
//  OneButtonCustomAlertViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/16/25.
//

import UIKit
import Combine

final class OneButtonCustomAlertViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalPadding: CGFloat = 37.0
    }
    
    // MARK: - Properties
    
    private let rootView: OneButtonCustomAlertMainView
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(title: String, description: String? = nil) {
        self.rootView = OneButtonCustomAlertMainView()
        rootView.config(title: title, description: description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubviews()
        setupConstraints()
        observe()
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        view.backgroundColor = UIColor.coolNeutral800.withAlphaComponent(0.7)
    }
    
    private func observe() {
        rootView.confirmButtonTappedPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Layout Setup

extension OneButtonCustomAlertViewController {
    private func addSubviews() {
        view.addSubview(rootView)
    }
    
    private func setupConstraints() {
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metric.horizontalPadding),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metric.horizontalPadding),
        ])
    }
}
