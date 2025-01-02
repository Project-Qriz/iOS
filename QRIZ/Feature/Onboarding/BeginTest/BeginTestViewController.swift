//
//  TestStartViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

final class BeginTestViewController: UIViewController {
    
    let beginTestTitleLabel: UILabel = OnboardingTitleLabel(labelText: "테스트를\n진행해볼까요?")
    let beginTestSubtitleLabel: UILabel = OnboardingSubtitleLabel("간단한 프리뷰 테스트로 실력을 점검하고\n이후 맞춤형 개념과 데일리 테스트를 경험해 보세요!")
    let beginImageView: UIImageView = OnboardingImageView("onboarding2")
    let beginTestButton: UIButton = OnboardingButton("간단한 테스트 시작")
    
    private var viewModel: BeginTestViewModel = BeginTestViewModel()
    private let input: PassthroughSubject<BeginTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        self.navigationItem.hidesBackButton = true
        bind()
        addViews()
        addButtonAction()
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToPreviewTest:
                    self.navigationController?.pushViewController(PreviewTestViewController(), animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addButtonAction() {
        beginTestButton.addAction(UIAction(handler: { _ in
            self.input.send(.didButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func addViews() {
        self.view.addSubview(beginTestTitleLabel)
        self.view.addSubview(beginTestSubtitleLabel)
        self.view.addSubview(beginImageView)
        self.view.addSubview(beginTestButton)
        
        beginTestTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        beginTestSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        beginImageView.translatesAutoresizingMaskIntoConstraints = false
        beginTestButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            beginTestTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            beginTestTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            beginTestTitleLabel.topAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            beginTestTitleLabel.heightAnchor.constraint(equalToConstant: 76),
            beginTestSubtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            beginTestSubtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            beginTestSubtitleLabel.topAnchor.constraint(equalTo: beginTestTitleLabel.bottomAnchor, constant: 8),
            beginTestSubtitleLabel.heightAnchor.constraint(equalToConstant: 48),
            beginImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            beginImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            beginImageView.topAnchor.constraint(equalTo: beginTestSubtitleLabel.bottomAnchor, constant: 40),
            beginTestButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            beginTestButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            beginTestButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            beginTestButton.heightAnchor.constraint(equalToConstant: 48)
        ])

    }
}
