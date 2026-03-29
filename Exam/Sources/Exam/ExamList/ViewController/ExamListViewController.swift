import UIKit
import DesignSystem
import Combine
import Network

final class ExamListViewController: UIViewController {

    // MARK: - Properties
    private var contentView: ExamListView { view as! ExamListView }
    private var examList: [ExamListDataInfo] = []

    private let viewModel: ExamListViewModel
    private let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    weak var coordinator: (any ExamNavigating)?

    // MARK: - Initializers
    init(viewModel: ExamListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListViewController")
    }

    // MARK: - Methods
    override func loadView() {
        view = ExamListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setCollectionViewDataSourceAndDelegate()
        bind()
        input.send(.viewDidLoad)
        tabBarController?.tabBar.isHidden = true
    }

    private func bind() {
        let clearViewTapped = contentView.clearViewTappedPublisher.map {
            ExamListViewModel.Input.otherAreaClicked
        }
        let mergedInput = input.merge(
            with: contentView.examListFilterButton.input,
            contentView.examListFilterItemsView.input,
            clearViewTapped
        )
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed:
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                case .setCollectionViewItem(let examList):
                    self.examList = examList
                    contentView.collectionView.reloadData()
                    contentView.collectionView.setContentOffset(.zero, animated: false)
                case .selectFilterItem(let filterType):
                    contentView.selectFilterItem(filterType)
                case .setFilterItemsVisibility(let isVisible):
                    contentView.setFilterItemsVisibility(isVisible: isVisible)
                case .moveToExamView(let examId):
                    coordinator?.showExamSummary(examId: examId)
                case .cancelExamListView:
                    tabBarController?.tabBar.isHidden = false
                    if let coordinator = coordinator {
                        coordinator.delegate?.didQuitExam(coordinator)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "모의고사"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        self.navigationItem.titleView = titleView

        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(xmark, for: .normal)
        button.addTarget(self, action: #selector(cancelView), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    @objc private func cancelView() {
         input.send(.cancelButtonClicked)
    }

    private func setCollectionViewDataSourceAndDelegate() {
        contentView.collectionView.register(ExamListCell.self, forCellWithReuseIdentifier: ExamListCell.identifier)
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
    }
}

extension ExamListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        examList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExamListCell.identifier, for: indexPath) as? ExamListCell else {
            return UICollectionViewCell()
        }
        cell.configure(examInfo: examList[indexPath.item])
        return cell
    }
}

extension ExamListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        input.send(.examClicked(idx: indexPath.item))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 116)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
