//
//  HomeViewController.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit

final class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        let label = UILabel()
        label.text = "홈"
        label.textColor = .green
        label.font = .boldSystemFont(ofSize: 40)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

