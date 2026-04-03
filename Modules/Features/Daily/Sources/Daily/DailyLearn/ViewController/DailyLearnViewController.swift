//
//  DailyLearnViewController.swift
//  QRIZ
//
//  Created by 이창현 on 2/15/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class DailyLearnViewController: UIViewController {

    // MARK: - Enums

    private enum Metric {
        static let cellHeight: CGFloat = 116
        static let cellSpacing: CGFloat = 16
    }

    // MARK: - Properties

    private let dailyLearnView = DailyLearnView()

    private let retestAlertViewController: TwoButtonCustomAlertViewController = .init(
        title: "시험을 다시 보겠습니까?",
        description: """
        이미 한번 봤던 시험입니다.
        만약 미달인 경우 재시험의 기회가 없습니다.
        """)

    private let viewModel: DailyLearnViewModel
    private let input: PassthroughSubject<DailyLearnViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: (any DailyNavigating)?

    private var concepts: [(Int, String)] = []

    // MARK: - Initialization

    init(dailyLearnViewModel: DailyLearnViewModel) {
        self.viewModel = dailyLearnViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    override func loadView() {
        view = dailyLearnView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupCollectionView()
        setupTestNavigatorAction()
        setupAlertButtonActions()
        bind()
        input.send(.viewDidLoad)
        tabBarController?.tabBar.isHidden = true
    }

    private func setupCollectionView() {
        dailyLearnView.studyCollectionView.dataSource = self
        dailyLearnView.studyCollectionView.delegate = self
    }

    private func setupTestNavigatorAction() {
        dailyLearnView.onTestNavigatorTap = { [weak self] in
            self?.input.send(.testNavigatorButtonClicked)
        }
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchSuccess(let state, let type, let score):
                    dailyLearnView.configure(state: state, type: type, score: score)
                case .fetchFailed(let isServerError):
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &cancellables)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &cancellables)
                    }
                case .updateContent(let concepts):
                    self.concepts = concepts
                    dailyLearnView.reloadConcepts()
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
                    coordinator?.finishDaily()
                }
            }
            .store(in: &cancellables)
    }

    private func setupAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            self?.input.send(.alertMoveClicked)
        }
        let cancelAction = UIAction { [weak self] _ in
            self?.input.send(.alertCancelClicked)
        }
        retestAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }

    private func setupNavigationItems() {
        let titleView = UILabel()
        titleView.text = "오늘의 공부"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        navigationItem.titleView = titleView

        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        button.setImage(backImage, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.input.send(.backButtonClicked)
        }, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - UICollectionViewDataSource

extension DailyLearnViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StudyContentCell.identifier,
            for: indexPath
        ) as? StudyContentCell else {
            assertionFailure("Failed to dequeue StudyContentCell")
            return UICollectionViewCell()
        }
        cell.configure(
            title: SurveyCheckList.list[concepts[indexPath.item].0 - 1],
            description: concepts[indexPath.item].1
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return concepts.count
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DailyLearnViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Metric.cellHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Metric.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        input.send(.toConceptClicked(conceptIdx: concepts[indexPath.row].0))
    }
}
