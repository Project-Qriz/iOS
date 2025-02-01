//
//  WrongQuestionCategoryViewController.swift
//  QRIZ
//
//  Created by 이창현 on 1/31/25.
//

import UIKit
import Combine

final class WrongQuestionCategoryViewController: UIViewController {

    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 선택"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        button.backgroundColor = .white
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("적용하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .customBlue500
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral200
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: WrongQuestionCategoryViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureSheetPresentation()
        addViews()
        addButtonsAction()
    }
    
    // MARK: - Methods
    private func configureSheetPresentation() {
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.preferredCornerRadius = 32.0
//            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.largestUndimmedDetentIdentifier = .none
        }
    }

    private func addButtonsAction() {
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
    }
    
    @objc private func cancelButtonAction() {
        self.dismiss(animated: true)
        // coordinator
    }
    
    @objc private func submitButtonAction() {
        self.dismiss(animated: true)
        // Coordinator & network
    }
}

// MARK: - Auto Layout
extension WrongQuestionCategoryViewController {
    private func addViews() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(cancelButton)
        self.view.addSubview(submitButton)
        self.view.addSubview(grabberView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            cancelButton.widthAnchor.constraint(equalToConstant: 14),
            cancelButton.heightAnchor.constraint(equalToConstant: 14),
            
            submitButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            submitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            submitButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 48),
            
            grabberView.widthAnchor.constraint(equalToConstant: 46),
            grabberView.heightAnchor.constraint(equalToConstant: 4),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }
}
