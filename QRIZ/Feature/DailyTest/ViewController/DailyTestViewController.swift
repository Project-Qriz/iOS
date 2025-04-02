//
//  DailyTestViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit

final class DailyTestViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let progressView: TestProgressView = .init()
    private let footerView: DailyTestFooterView = .init()
    private let questionNumberLabel = QuestionNumberLabel(0)
    private let questionTitleLabel = QuestionTitleLabel("")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addViews()
        progressView.progress = 0.3 // temp
    }
}

// Auto Layout
extension DailyTestViewController {
    private func addViews() {
        self.view.addSubview(progressView)
        self.view.addSubview(footerView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 108),
            
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}
