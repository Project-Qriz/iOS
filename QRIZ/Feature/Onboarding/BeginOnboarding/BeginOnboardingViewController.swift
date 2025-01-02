//
//  OnBoardingViewController.swift
//  QRIZ
//
//  Created by ch on 12/13/24.
//

import UIKit
import Combine

final class BeginOnboardingViewController: UIViewController {
    
    private let beginOnboardingTitleLabel: UILabel = OnboardingTitleLabel(labelText: "SQLD를 어느정도\n알고 계신가요?")
    private let beginOnboardingSubtitleLabel: UILabel = OnboardingSubtitleLabel("선택하신 체크사항을 기반으로\n맞춤 프리뷰 테스트를 제공해 드려요!")
    private let beginOnboardingImageView: UIImageView = OnboardingImageView("onboarding1")
    private let beginOnboardingStartButton: UIButton = OnboardingButton("시작하기")
    
    private var viewModel: BeginOnboardingViewModel = BeginOnboardingViewModel()
    private let input: PassthroughSubject<BeginOnboardingViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
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
                case .moveToCheckConcept:
                    // should modify to using coordinator
                    self.navigationController?.pushViewController(CheckConceptViewController(), animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addButtonAction() {
        beginOnboardingStartButton.addAction(UIAction(handler: { _ in
            self.input.send(.didButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func addViews() {
        self.view.addSubview(beginOnboardingTitleLabel)
        self.view.addSubview(beginOnboardingSubtitleLabel)
        self.view.addSubview(beginOnboardingImageView)
        self.view.addSubview(beginOnboardingStartButton)
        
        beginOnboardingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        beginOnboardingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        beginOnboardingImageView.translatesAutoresizingMaskIntoConstraints = false
        beginOnboardingStartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            beginOnboardingTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            beginOnboardingTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            beginOnboardingTitleLabel.topAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            beginOnboardingTitleLabel.heightAnchor.constraint(equalToConstant: 76),
            beginOnboardingSubtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            beginOnboardingSubtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            beginOnboardingSubtitleLabel.topAnchor.constraint(equalTo: beginOnboardingTitleLabel.bottomAnchor, constant: 8),
            beginOnboardingSubtitleLabel.heightAnchor.constraint(equalToConstant: 48),
            beginOnboardingImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            beginOnboardingImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            beginOnboardingImageView.topAnchor.constraint(equalTo: beginOnboardingSubtitleLabel.bottomAnchor, constant: 40),
            beginOnboardingStartButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            beginOnboardingStartButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            beginOnboardingStartButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            beginOnboardingStartButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
