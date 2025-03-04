//
//  MistakeNoteViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit

final class MistakeNoteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "오답노트"
        label.textColor = .green
        label.font = .boldSystemFont(ofSize: 40)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
