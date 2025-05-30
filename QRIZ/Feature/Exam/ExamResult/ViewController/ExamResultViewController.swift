//
//  ExamResultViewController.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import UIKit
import Combine

final class ExamResultViewController: UIViewController {
    
    // MARK: - Properties
    private var examResultHostingController: ExamResultHostingController!
    
    private let viewModel: ExamResultViewModel
    private let input: PassthroughSubject<ExamResultViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: ExamResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamResultViewController")
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
        let mergedInput = input.merge(with: examResultHostingController.rootView.input)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed(let isServerError):
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                    }
                case .moveToConcept:
                    print("Move To Concept")
                case .moveToExamList:
                    print("Move To ExamList")
                case .moveToResultDetail:
                    let vm = TestResultDetailViewModel(resultDetailData: self.viewModel.resultDetailData)
                    let vc = TestResultDetailViewController(viewModel: vm)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func loadResultView() -> UIView {
        examResultHostingController = ExamResultHostingController(
            rootView: ExamResultView(
                resultScoresData: self.viewModel.resultScoresData,
                resultGradeListData: self.viewModel.resultGradeListData,
                resultDetailData: self.viewModel.resultDetailData,
                scoreGraphData: self.viewModel.scoreGraphData))
        self.addChild(examResultHostingController)
        examResultHostingController.didMove(toParent: self)

        let resultView = examResultHostingController.view ?? UIView(frame: .zero)
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
        input.send(.cancelButtonClicked)
    }
}

// MARK: - AutoLayout
extension ExamResultViewController {
    private func addViews() {
        let examResultView = loadResultView()
        self.view.addSubview(examResultView)
        
        examResultView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            examResultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            examResultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            examResultView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            examResultView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
