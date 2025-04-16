//
//  DailyResultViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit

final class DailyResultViewController: UIViewController {
    
    // MARK: - Properties
    private var dailyResultViewHostingController: DailyResultViewHostingController!

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addViews()
        setNavigationItems()
    }
    
    private func loadResultView() -> UIView {
        dailyResultViewHostingController = DailyResultViewHostingController(rootView: DailyResultView())
        self.addChild(dailyResultViewHostingController)
        dailyResultViewHostingController.didMove(toParent: self)

        let resultView = dailyResultViewHostingController.view ?? UIView(frame: .zero)
        return resultView
    }
    
    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "시험 결과"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        self.navigationItem.titleView = titleView
        
        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(xmark, for: .normal)
        button.addTarget(self, action: #selector(cancelTestResult), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func cancelTestResult() {
        print("Move To Daily Learn")
    }
}

// MARK: - AutoLayout
extension DailyResultViewController {
    private func addViews() {
        let dailyResultView = loadResultView()
        self.view.addSubview(dailyResultView)
        
        dailyResultView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dailyResultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dailyResultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dailyResultView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            dailyResultView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
