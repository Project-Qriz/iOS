//
//  DailyLearnViewController.swift
//  QRIZ
//
//  Created by 이창현 on 2/15/25.
//

import UIKit
import Combine

final class DailyLearnViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBlue50
        return scrollView
    }()
    private let scrollInnerView: UIView = .init()
    private let studyContentTitleLabel: DailyLearnSectionTitleLabel = .init()
    private let studyContentView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        collectionView.layer.masksToBounds = false
        return collectionView
    }()
    private let testSubtextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let relatedTestTitleLabel: DailyLearnSectionTitleLabel = .init()
    private let testNavigator: TestNavigatorButton = .init()
    private let retestAlertViewController: TwoButtonCustomAlertViewController = .init(
        title: "시험을 다시 보겠습니까?",
        description: """
        이미 한번 봤던 시험입니다.
        만약 미달인 경우 재시험의 기회가 없습니다.
        """)
    
    private let viewModel: DailyLearnViewModel
    private let input: PassthroughSubject<DailyLearnViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    weak var coordinator: DailyCoordinator?
    
    private var conceptArr: [(Int, String)] = []
    private var testNavigatorHeightConstraint: NSLayoutConstraint? = nil
    
    // MARK: - Initializer
    init(dailyLearnViewModel: DailyLearnViewModel) {
        self.viewModel = dailyLearnViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnViewController")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setNavigationItems()
        setCollectionViewDataSourceAndDelegate()
        bind()
        setAlertButtonActions()
        input.send(.viewDidLoad)
        addViews()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchSuccess(let state, let type, let score):
                    setTitleLabels(type: type)
                    setTestSubtextLabel(state: state)
                    setNavigatorButton(state: state, type: type, score: score)
                    setNavigatorButtonHeight(state: state)
                case .fetchFailed(let isServerError):
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                    }
                case .updateContent(let conceptArr):
                    self.conceptArr = conceptArr
                    updateCollectionViewHeight()
                case .moveToDailyTest:
                    coordinator?.showDailyTest()
                case .showRetestAlert:
                    present(retestAlertViewController, animated: true)
                case .moveToDailyTestResult:
                    coordinator?.showDailyResult()
                case .moveToConcept(let chapter, let conceptItem):
                    coordinator?.showConcept(chapter: chapter, conceptItem: conceptItem)
                case .dismissAlert:
                    retestAlertViewController.dismiss(animated: true)
                case .moveToHome:
                    tabBarController?.tabBar.isHidden = false
                    if let coordinator = coordinator {
                        coordinator.delegate?.didQuitDaily(coordinator)
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertMoveClicked)
        }
        
        let cancelAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertCancelClicked)
        }
        
        retestAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }
    
    private func setTitleLabels(type: DailyLearnType) {
        studyContentTitleLabel.setText(isStudyContentTitle: true, type: type)
        relatedTestTitleLabel.setText(isStudyContentTitle: false)
    }
    
    private func setTestSubtextLabel(state: DailyTestState) {
        switch state {
        case .unavailable:
            testSubtextLabel.text = "이전 테스트를 학습 완료했는지 확인해주세요!"
        case .zeroAttempt:
            testSubtextLabel.text = "아래의 테스트를 학습 완료해야만 다음 데일리 테스트를 진행할 수 있습니다!"
        case .passed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        case .retestRequired:
            testSubtextLabel.text = "점수 미달인 경우 재시험을 볼 수 있습니다."
        case .failed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        }
    }
    
    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "오늘의 공부"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        self.navigationItem.titleView = titleView
        
        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(backImage, for: .normal)
        button.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            input.send(.backButtonClicked)
        }), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setNavigatorButton(state: DailyTestState, type: DailyLearnType, score: Double?) {
        testNavigator.setDailyUI(state: state, type: type, score: score)
        testNavigator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendTestNavigatorClicked)))
    }
    
    @objc private func sendTestNavigatorClicked() {
        input.send(.testNavigatorButtonClicked)
    }
    
    private func setCollectionViewDataSourceAndDelegate() {
        studyContentView.register(StudyContentCell.self, forCellWithReuseIdentifier: StudyContentCell.identifier)
        studyContentView.dataSource = self
        studyContentView.delegate = self
    }
    
    private func updateCollectionViewHeight() {
        studyContentView.reloadData()
        studyContentView.layoutIfNeeded()
        studyContentView.heightAnchor.constraint(equalToConstant: studyContentView.contentSize.height).isActive = true
    }
}

// MARK: - CollectionView DataSource & Delegate
extension DailyLearnViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudyContentCell.identifier, for: indexPath) as? StudyContentCell else {
            print("Failed to create StudyContentCell")
            return UICollectionViewCell()
        }

        cell.setLabelText(titleText: "\(SurveyCheckList.list[conceptArr[indexPath.item].0 - 1])",
                          descriptionText: "\(conceptArr[indexPath.item].1)")

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conceptArr.count
    }
}

extension DailyLearnViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if conceptArr.count != 0 {
            input.send(.toConceptClicked(conceptIdx: conceptArr[indexPath.row].0))
        }
    }
}

// MARK: - Auto Layout
extension DailyLearnViewController {
    private func addViews() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollInnerView)
        self.scrollInnerView.addSubview(studyContentTitleLabel)
        self.scrollInnerView.addSubview(studyContentView)
        self.scrollInnerView.addSubview(testSubtextLabel)
        self.scrollInnerView.addSubview(relatedTestTitleLabel)
        self.scrollInnerView.addSubview(testNavigator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollInnerView.translatesAutoresizingMaskIntoConstraints = false
        studyContentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        studyContentView.translatesAutoresizingMaskIntoConstraints = false
        testSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        relatedTestTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        testNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            scrollInnerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollInnerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollInnerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollInnerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollInnerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            studyContentTitleLabel.topAnchor.constraint(equalTo: scrollInnerView.topAnchor, constant: 25),
            studyContentTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            
            studyContentView.topAnchor.constraint(equalTo: studyContentTitleLabel.bottomAnchor, constant: 17),
            studyContentView.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            studyContentView.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),
            
            relatedTestTitleLabel.topAnchor.constraint(equalTo: studyContentView.bottomAnchor, constant: 32),
            relatedTestTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            relatedTestTitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            testSubtextLabel.topAnchor.constraint(equalTo: relatedTestTitleLabel.bottomAnchor, constant: 19),
            testSubtextLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testSubtextLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: 18),
            
            testNavigator.topAnchor.constraint(equalTo: testSubtextLabel.bottomAnchor, constant: 18),
            testNavigator.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testNavigator.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),
            testNavigator.bottomAnchor.constraint(equalTo: scrollInnerView.bottomAnchor, constant: -100)
        ])
    }
    
    private func setNavigatorButtonHeight(state: DailyTestState) {
        let buttonHeight = (state == .retestRequired ? 153.0 : 116.0)
        
        testNavigatorHeightConstraint?.isActive = false
        
        testNavigatorHeightConstraint = testNavigator.heightAnchor.constraint(equalToConstant: buttonHeight)
        
        testNavigatorHeightConstraint?.isActive = true
    }
}
