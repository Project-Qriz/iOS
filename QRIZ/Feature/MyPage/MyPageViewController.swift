//
//  MyPageViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit

final class MyPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        let label = UILabel()
        label.text = "마이페이지"
        label.textColor = .green
        label.font = .boldSystemFont(ofSize: 40)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
