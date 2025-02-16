//
//  DailyLearnViewController.swift
//  QRIZ
//
//  Created by 이창현 on 2/15/25.
//

import UIKit

final class DailyLearnViewController: UIViewController {
    
    // MARK: - Properties
    private var day: Int
    private let testNavigator: TestNavigatorButton = .init()
    
    // MARK: - Initializer
    init(day: Int) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnViewController")
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setNavigationBarTitle(title: "오늘의 공부")
        addViews()
        setNavigatorButton()
    }
    
    private func setNavigatorButton() {
        testNavigator.updateUI(isAvailable: false, isTestDone: true, score: 70, type: .monthly)
    }
}

extension DailyLearnViewController {
    private func addViews() {
        self.view.addSubview(testNavigator)
        
        testNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            testNavigator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            testNavigator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            testNavigator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            testNavigator.heightAnchor.constraint(equalToConstant: 123)
        ])
    }
}
