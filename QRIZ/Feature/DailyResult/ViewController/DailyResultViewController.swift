//
//  DailyResultViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit

final class DailyResultViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "데일리 테스트 결과"
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.backgroundColor = .white
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        print("VIEWDIDLOAD")
        addViews()
    }
}

extension DailyResultViewController {
    private func addViews() {
        self.view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
}
