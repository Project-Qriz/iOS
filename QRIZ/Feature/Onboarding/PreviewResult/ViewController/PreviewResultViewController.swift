//
//  UIPreviewResultViewController.swift
//  QRIZ
//
//  Created by ch on 12/28/24.
//

import UIKit
import SwiftUI
import Combine

final class PreviewResultViewController: UIViewController {

    // MARK: - Properties
    private var previewResultViewHostingController: PreviewResultViewHostingController!
    
    private var viewModel: PreviewResultViewModel
    private let input: PassthroughSubject<PreviewResultViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: - Initializers
    init(viewModel: PreviewResultViewModel) {
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
        setNavigationItems()
        addViews()
        bind()
        input.send(.viewDidLoad)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed:
                    self.showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                case .moveToGreetingView:
                    self.coordinator?.showGreeting()
                }
            }
            .store(in: &subscriptions)
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
        input.send(.toHomeButtonClicked)
    }
    
    private func loadResultView() -> UIView {
        previewResultViewHostingController = PreviewResultViewHostingController(
            rootView: PreviewResultView(
                previewScoresData: self.viewModel.previewScoresData,
                previewConceptsData: self.viewModel.previewConceptsData
            ))
        self.addChild(previewResultViewHostingController)
        previewResultViewHostingController.didMove(toParent: self)
        let resultView = previewResultViewHostingController.view ?? UIView(frame: .zero)
        return resultView
    }
}

// MARK: - Auto Layout
extension PreviewResultViewController {

    private func addViews() {
        let previewResultView = loadResultView()
        self.view.addSubview(previewResultView)
        
        previewResultView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewResultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            previewResultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            previewResultView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            previewResultView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
