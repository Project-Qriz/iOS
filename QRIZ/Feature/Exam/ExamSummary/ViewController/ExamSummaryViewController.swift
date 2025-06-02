//
//  ExamSummaryViewController.swift
//  QRIZ
//
//  Created by ch on 5/14/25.
//

import UIKit
import Combine

final class ExamSummaryViewController: UIViewController {
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        let attributedText = NSMutableAttributedString(string: "배운 내용을 기반으로\n실제같은 모의고사를 풀어봐요", attributes: [.paragraphStyle: paragraphStyle])
        label.attributedText = attributedText
        
        return label
    }()
    private let summaryImageView: UIImageView = {
        let image = UIImage(named: "examSummary")
        let imageView = UIImageView(image: image)
        imageView.layer.shadowColor = UIColor.coolNeutral100.cgColor
        imageView.layer.shadowOpacity = 1
        return imageView
    }()
    private let bottomButton: OnboardingButton = .init("테스트 시작하기")
    
    private let viewModel: ExamSummaryViewModel
    private let input: PassthroughSubject<ExamSummaryViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: ExamSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamSummaryViewController")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        addViews()
        bind()
        addButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationColor(isDefault: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigationColor(isDefault: true)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToExam(let examId):
                    let vc = UINavigationController(
                        rootViewController: ExamTestViewController(
                            viewModel: ExamTestViewModel(
                            examId: examId,
                            examService: ExamServiceImpl())))
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addButtonAction() {
        bottomButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.beginExamButtonClicked)
        }), for: .touchUpInside)
    }
}

// MARK: - Auto Layout
extension ExamSummaryViewController {
    private func addViews() {
        [titleLabel, summaryImageView, bottomButton].forEach({ [weak self] in
            guard let self = self else { return }
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            
            summaryImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            summaryImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            summaryImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            summaryImageView.heightAnchor.constraint(equalTo: summaryImageView.widthAnchor, multiplier: 0.88),
            
            bottomButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomButton.leadingAnchor.constraint(equalTo: summaryImageView.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: summaryImageView.trailingAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: 48)
            
        ])
    }
    
    private func setNavigationColor(isDefault: Bool) {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        
        if !isDefault {
            appearance.backgroundColor = .customBlue50
        }
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
