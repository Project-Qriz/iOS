import UIKit
import Combine
import QRIZUtils

final class ExamListView: UIView {

    // MARK: - Enums

    enum Metric {
        static let cellHeight: CGFloat = 116
        static let cellSpacing: CGFloat = 8
    }

    // MARK: - Views
    let examListFilterButton = ExamListFilterButton()
    let examListFilterItemsView = ExamListFilterItemsView()
    private(set) var collectionView: UICollectionView!
    private let customClearView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    // MARK: - Publishers
    private let clearViewTappedSubject = PassthroughSubject<Void, Never>()
    var clearViewTappedPublisher: AnyPublisher<Void, Never> {
        clearViewTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .customBlue50
        setupCollectionView()
        setupClearViewGesture()
        addViews()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListView")
    }

    // MARK: - Setup
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
    }

    private func setupClearViewGesture() {
        customClearView.isUserInteractionEnabled = true
        customClearView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(sendClearViewTapped))
        )
    }

    @objc private func sendClearViewTapped() {
        clearViewTappedSubject.send()
    }

    // MARK: - Methods
    func selectFilterItem(_ filterType: ExamListFilterType) {
        examListFilterItemsView.updateSelectedItem(filterType)
        examListFilterButton.setText(filterType: filterType)
    }

    func setFilterItemsVisibility(isVisible: Bool) {
        examListFilterItemsView.isHidden = !isVisible
        customClearView.isHidden = !isVisible
    }
}

// MARK: - AutoLayout
extension ExamListView {
    private func addViews() {
        addSubview(collectionView)
        addSubview(examListFilterButton)
        addSubview(customClearView)
        addSubview(examListFilterItemsView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        examListFilterButton.translatesAutoresizingMaskIntoConstraints = false
        customClearView.translatesAutoresizingMaskIntoConstraints = false
        examListFilterItemsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            examListFilterButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            examListFilterButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            examListFilterButton.widthAnchor.constraint(equalToConstant: 90),
            examListFilterButton.heightAnchor.constraint(equalToConstant: 32),

            examListFilterItemsView.topAnchor.constraint(equalTo: examListFilterButton.bottomAnchor, constant: 8),
            examListFilterItemsView.leadingAnchor.constraint(equalTo: examListFilterButton.leadingAnchor),

            collectionView.topAnchor.constraint(equalTo: examListFilterButton.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: examListFilterButton.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            customClearView.topAnchor.constraint(equalTo: topAnchor),
            customClearView.bottomAnchor.constraint(equalTo: bottomAnchor),
            customClearView.leadingAnchor.constraint(equalTo: leadingAnchor),
            customClearView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
