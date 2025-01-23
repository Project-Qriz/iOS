//
//  WrongQuestionViewController.swift
//  QRIZ
//
//  Created by 이창현 on 1/14/25.
//

import UIKit

final class WrongQuestionViewController: UIViewController {
    
    // MARK: - Properties
    private let wrongQuestionSegment =  WrongQuestionSegment()
    private let segmentBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral100
        return view
    }()
    private let wrongQuestionDropDown = WrongQuestionDropDown()
    private let categoryChoiceButton = CategoryChoiceButton()
    private let onlyIncorrectButton = OnlyIncorrectButton()
    private let onlyIncorrectMenu = OnlyIncorrectMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setNavigationTitle()
        addViews()
    }
    
    private func setNavigationTitle() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        
        navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.coolNeutral800
        ]
        
        navigationItem.title = "오답노트"
    }
}

// MARK: - Auto Layout
extension WrongQuestionViewController {

    private func addViews() {
        self.view.addSubview(wrongQuestionSegment)
        self.view.addSubview(segmentBorder)
        self.view.addSubview(wrongQuestionDropDown)
        self.view.addSubview(categoryChoiceButton)
        self.view.addSubview(onlyIncorrectButton)
        self.view.addSubview(onlyIncorrectMenu)

        wrongQuestionSegment.translatesAutoresizingMaskIntoConstraints = false
        segmentBorder.translatesAutoresizingMaskIntoConstraints = false
        wrongQuestionDropDown.translatesAutoresizingMaskIntoConstraints = false
        categoryChoiceButton.translatesAutoresizingMaskIntoConstraints = false
        onlyIncorrectButton.translatesAutoresizingMaskIntoConstraints = false
        onlyIncorrectMenu.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            wrongQuestionSegment.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            wrongQuestionSegment.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            wrongQuestionSegment.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            wrongQuestionSegment.heightAnchor.constraint(equalToConstant: 48),
            
            segmentBorder.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            segmentBorder.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            segmentBorder.topAnchor.constraint(equalTo: wrongQuestionSegment.bottomAnchor),
            segmentBorder.heightAnchor.constraint(equalToConstant: 1),
            
            wrongQuestionDropDown.topAnchor.constraint(equalTo: segmentBorder.bottomAnchor),
            wrongQuestionDropDown.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrongQuestionDropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrongQuestionDropDown.heightAnchor.constraint(equalToConstant: 94),
            
            categoryChoiceButton.topAnchor.constraint(equalTo: wrongQuestionDropDown.bottomAnchor, constant: 16),
            categoryChoiceButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            categoryChoiceButton.widthAnchor.constraint(equalToConstant: 40),
            categoryChoiceButton.heightAnchor.constraint(equalToConstant: 40),
            
            onlyIncorrectButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            onlyIncorrectButton.topAnchor.constraint(equalTo: categoryChoiceButton.bottomAnchor, constant: 24),
            onlyIncorrectButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 43),
            onlyIncorrectButton.heightAnchor.constraint(equalToConstant: 21),
            
            onlyIncorrectMenu.topAnchor.constraint(equalTo: onlyIncorrectButton.bottomAnchor, constant: 16),
            onlyIncorrectMenu.trailingAnchor.constraint(equalTo: onlyIncorrectButton.trailingAnchor),
            onlyIncorrectMenu.widthAnchor.constraint(equalToConstant: 123),
            onlyIncorrectMenu.heightAnchor.constraint(equalToConstant: 82)
        ])
        
//        onlyIncorrectMenu.isHidden = true
    }
}
