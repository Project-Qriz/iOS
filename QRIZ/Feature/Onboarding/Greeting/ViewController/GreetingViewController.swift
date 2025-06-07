//
//  GreetingViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

final class GreetingViewController: UIViewController {
    
    // MARK: - Properties
    private var nickname: String = "임시"
    private var greetingTitleLabel: UILabel = OnboardingTitleLabel(labelText: "님\n환영합니다")
    private let greetingSubtitleLabel: UILabel = OnboardingSubtitleLabel("준비되어 있는 오늘의 공부와, 모의고사로\n시험을 같이 준비해봐요!")
    private let greetingImageView: UIImageView = UIImageView(image: UIImage(named: "onboarding3"))
    
    private var viewModel: GreetingViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<GreetingViewModel.Input, Never> = .init()
    
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: - Initializers
    init(viewModel: GreetingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        setTitleLabelText()
        bind()
        addViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.input.send(.viewDidAppear)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToHome:
                    if let coordinator = coordinator {
                        coordinator.delegate?.didFinishOnboarding(coordinator)
                    }
                case .fetchFailed:
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                }
            }
            .store(in: &subscriptions)
    }

    private func setTitleLabelText() {
        greetingTitleLabel.text = "\(nickname)\(greetingTitleLabel.text ?? "님\n환영합니다")"
    }
}

// MARK: - Auto Layout
extension GreetingViewController {
    private func addViews() {
        self.view.addSubview(greetingTitleLabel)
        self.view.addSubview(greetingSubtitleLabel)
        self.view.addSubview(greetingImageView)
        
        greetingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            greetingTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            greetingTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            greetingTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            greetingTitleLabel.heightAnchor.constraint(equalToConstant: 76),
            greetingSubtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            greetingSubtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            greetingSubtitleLabel.topAnchor.constraint(equalTo: greetingTitleLabel.bottomAnchor, constant: 12),
            greetingSubtitleLabel.heightAnchor.constraint(equalToConstant: 48),
            greetingImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            greetingImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            greetingImageView.topAnchor.constraint(equalTo: greetingSubtitleLabel.bottomAnchor, constant: 40),
            greetingImageView.heightAnchor.constraint(equalToConstant: self.view.frame.width)
        ])
    }
}
