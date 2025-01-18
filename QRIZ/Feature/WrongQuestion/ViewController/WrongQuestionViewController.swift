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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "오답노트"
        addViews()
    }
}

// MARK: - Auto Layout
extension WrongQuestionViewController {

    private func addViews() {
        self.view.addSubview(wrongQuestionSegment)
        self.view.addSubview(segmentBorder)
        self.view.addSubview(wrongQuestionDropDown)
        self.view.addSubview(categoryChoiceButton)

        wrongQuestionSegment.translatesAutoresizingMaskIntoConstraints = false
        segmentBorder.translatesAutoresizingMaskIntoConstraints = false
        wrongQuestionDropDown.translatesAutoresizingMaskIntoConstraints = false
        categoryChoiceButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            categoryChoiceButton.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
}
