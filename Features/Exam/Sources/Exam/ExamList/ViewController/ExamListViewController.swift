import UIKit
import DesignSystem
import Combine
import Network

final class ExamListViewController: UIViewController {

    // MARK: - Properties

    private let examListView = ExamListView()
    private var examList: [ExamListDataInfo] = []

    private let viewModel: ExamListViewModel
    private let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    private weak var coordinator: (any ExamNavigating)?

    private var hasAppeared = false

    // MARK: - Initialization

    init(viewModel: ExamListViewModel, coordinator: any ExamNavigating) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListViewController")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = examListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupCollectionView()
        bind()
        input.send(.viewDidLoad)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard hasAppeared else {
            hasAppeared = true
            return
        }
        input.send(.reloadList)
    }

    // MARK: - Methods

    private func bind() {
        let filterButtonTapped = examListView.examListFilterButton.tap
            .map { ExamListViewModel.Input.filterButtonClicked }
        let filterItemSelected = examListView.examListFilterItemsView.filterSelectionPublisher
            .map { ExamListViewModel.Input.filterItemSelected(filterType: $0) }
        let clearViewTapped = examListView.clearViewTappedPublisher
            .map { ExamListViewModel.Input.otherAreaClicked }
        let mergedInput = input.merge(
            with: filterButtonTapped,
            filterItemSelected,
            clearViewTapped
        )
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed:
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &cancellables)
                case .setCollectionViewItem(let examList):
                    self.examList = examList
                    examListView.collectionView.reloadData()
                    examListView.collectionView.setContentOffset(.zero, animated: false)
                case .selectFilterItem(let filterType):
                    examListView.selectFilterItem(filterType)
                case .setFilterItemsVisibility(let isVisible):
                    examListView.setFilterItemsVisibility(isVisible: isVisible)
                case .moveToExamView(let examId):
                    coordinator?.showExamSummary(examId: examId)
                case .cancelExamListView:
                    coordinator?.cancelExamList()
                }
            }
            .store(in: &cancellables)
    }

    private func setupNavigationItems() {
        let titleView = UILabel()
        titleView.text = "모의고사"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        navigationItem.titleView = titleView

        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        button.setImage(xmark, for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.input.send(.cancelButtonClicked)
        }, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    private func setupCollectionView() {
        examListView.collectionView.register(ExamListCell.self, forCellWithReuseIdentifier: ExamListCell.identifier)
        examListView.collectionView.dataSource = self
        examListView.collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource

extension ExamListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        examList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            indexPath.item < examList.count,
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExamListCell.identifier,
                for: indexPath
            ) as? ExamListCell
        else {
            return UICollectionViewCell()
        }
        let examInfo = examList[indexPath.item]
        cell.configure(isCompleted: examInfo.completed, examRound: examInfo.examId, score: examInfo.totalScore)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ExamListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < examList.count else { return }
        input.send(.examClicked(examId: examList[indexPath.item].examId))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: ExamListView.Metric.cellHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        ExamListView.Metric.cellSpacing
    }
}
