//
//  WrongQuestionViewController.swift
//  QRIZ
//
//  Created by 이창현 on 1/14/25.
//

import UIKit
import Combine

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
    private let menuButton = WrongQuestionMenuButton()
    private let menuItems = WrongQuestionMenuItems()
    
    private let viewModel = WrongQuestionViewModel()
    private let input: PassthroughSubject<WrongQuestionViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        bind()
        setNavigationTitle()
        addViews()
        input.send(.viewDidLoad)
        addViewAction()
    }
    
    private func bind() {
        
        let mergedInput = Publishers.Merge4(input, wrongQuestionSegment.input, menuButton.input, menuItems.input)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .foldDropDown:
                    print("fold drop down")
                    // drop down collectionView hidden
                case .unfoldDropDown:
                    print("unfold drop down")
                    // drop down collectionView !hidden
                case .foldMenu:
                    menuItems.isHidden = true
                case .unfoldMenu:
                    menuItems.isHidden = false
                case .setMenuItemState(let isIncorrectOnly):
                    setMenuText(isIncorrectOnly: isIncorrectOnly)
                case .setSegmentState(let isDaily):
                    wrongQuestionSegment.setUnderlineState(isDailyClicked: isDaily)
                case .setSegmentItems(let isIncorrectOnly):
                    setUIState(isIncorrectOnly: isIncorrectOnly)
                case .showModal:
                    print("show modal")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addViewAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTouchAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func viewTouchAction() {
        input.send(.viewTouched)
    }
}

// MARK: - UI Methods
extension WrongQuestionViewController {
    
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
    
    private func setUIState(isIncorrectOnly: Bool) {
        // setdropdownstate
        setMenuText(isIncorrectOnly: isIncorrectOnly)
    }
    
    private func setMenuText(isIncorrectOnly: Bool) {
        menuButton.setOptionLabelTitle(isCorrectOnly: isIncorrectOnly)
        menuItems.setItemsState(isIncorrectOnly: isIncorrectOnly)
    }
}

// MARK: - Auto Layout
extension WrongQuestionViewController {

    private func addViews() {
        self.view.addSubview(wrongQuestionSegment)
        self.view.addSubview(segmentBorder)
        self.view.addSubview(wrongQuestionDropDown)
        self.view.addSubview(categoryChoiceButton)
        self.view.addSubview(menuButton)
        self.view.addSubview(menuItems)

        wrongQuestionSegment.translatesAutoresizingMaskIntoConstraints = false
        segmentBorder.translatesAutoresizingMaskIntoConstraints = false
        wrongQuestionDropDown.translatesAutoresizingMaskIntoConstraints = false
        categoryChoiceButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuItems.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            menuButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            menuButton.topAnchor.constraint(equalTo: categoryChoiceButton.bottomAnchor, constant: 24),
            menuButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 43),
            menuButton.heightAnchor.constraint(equalToConstant: 21),
            
            menuItems.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 16),
            menuItems.trailingAnchor.constraint(equalTo: menuButton.trailingAnchor)
        ])
        
        menuItems.isHidden = true
    }
}
