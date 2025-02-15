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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .coolNeutral700
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "오늘의 공부"
        return label
    }()
    
    // MARK: - Initializer
    init(day: Int) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setNavigationBarTitle(title: "오늘의 공부")
    }
}
