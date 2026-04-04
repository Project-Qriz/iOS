import UIKit
import DesignSystem
import Combine

private typealias ProfileRegistration = UICollectionView.CellRegistration<ProfileCell, String>
private typealias QuickActionsRegistration = UICollectionView.CellRegistration<QuickActionsCell, Void>
private typealias SupportHeaderRegistration = UICollectionView.CellRegistration<SupportHeaderCell, Void>
private typealias SupportMenuRegistration = UICollectionView.CellRegistration<SupportMenuCell, MyPageSectionItem.SupportMenu>

final class MyPageMainView: UIView {

    // MARK: - Properties

    private let profileTapSubject = PassthroughSubject<Void, Never>()
    private let selectionSubject = PassthroughSubject<MyPageSectionItem, Never>()
    private let resetPlanTappedSubject = PassthroughSubject<Void, Never>()
    private let registerExamTappedSubject = PassthroughSubject<Void, Never>()

    var profileTapPublisher: AnyPublisher<Void, Never> {
        profileTapSubject.eraseToAnyPublisher()
    }

    var selectionPublisher: AnyPublisher<MyPageSectionItem, Never> {
        selectionSubject.eraseToAnyPublisher()
    }

    var resetPlanTappedPublisher: AnyPublisher<Void, Never> {
        resetPlanTappedSubject.eraseToAnyPublisher()
    }

    var registerExamTappedPublisher: AnyPublisher<Void, Never> {
        registerExamTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private lazy var profileRegistration = ProfileRegistration { [weak self] cell, _, userName in
        cell.configure(with: userName)
        cell.onTap { [weak self] in
            self?.profileTapSubject.send()
        }
    }

    private lazy var quickActionRegistration = QuickActionsRegistration { [weak self] cell, _, _ in
        cell.configureActions(
            onResetPlan: { [weak self] in self?.resetPlanTappedSubject.send() },
            onRegisterExam: { [weak self] in self?.registerExamTappedSubject.send() }
        )
    }

    private let supportHeaderRegistration = SupportHeaderRegistration { _, _, _ in
    }

    private let supportMenuRegistration = SupportMenuRegistration { cell, _, menu in
        switch menu {
        case .versionInfo(let version):
            cell.configure(title: menu.title, version: version)
        default:
            cell.configure(title: menu.title)
        }
    }

    private let collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: MyPageLayoutFactory.makeLayout()
        )
        cv.backgroundColor = .customBlue50
        return cv
    }()

    private lazy var dataSource = UICollectionViewDiffableDataSource<MyPageSection, MyPageSectionItem>(
        collectionView: collectionView) { [weak self] cv, indexPath, item in
            guard let self else { return UICollectionViewCell() }

            switch item {
            case .profile(let name):
                return cv.dequeueConfiguredReusableCell(
                    using: self.profileRegistration,
                    for: indexPath,
                    item: name
                )

            case .quickActions:
                return cv.dequeueConfiguredReusableCell(
                    using: self.quickActionRegistration,
                    for: indexPath,
                    item: ()
                )

            case .supportHeader:
                return cv.dequeueConfiguredReusableCell(
                    using: self.supportHeaderRegistration,
                    for: indexPath,
                    item: ()
                )

            case .supportMenu(let menu):
                return cv.dequeueConfiguredReusableCell(
                    using: self.supportMenuRegistration,
                    for: indexPath,
                    item: menu
                )
            }
        }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
        collectionView.delegate = self
        _ = profileRegistration
        _ = quickActionRegistration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .customBlue50
    }

    func applySnapshot(userName: String, appVersion: String) {
        var snapshot = NSDiffableDataSourceSnapshot<MyPageSection, MyPageSectionItem>()
        snapshot.appendSections([.profile, .quickActions, .support])
        snapshot.appendItems([.profile(userName: userName)], toSection: .profile)
        snapshot.appendItems([.quickActions], toSection: .quickActions)
        snapshot.appendItems([
            .supportHeader,
            .supportMenu(.termsOfService),
            .supportMenu(.privacyPolicy),
            .supportMenu(.versionInfo(version: appVersion))
        ], toSection: .support)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Layout Setup

extension MyPageMainView {
    private func addSubviews() {
        addSubview(collectionView)
    }

    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate

extension MyPageMainView: UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cv.deselectItem(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            selectionSubject.send(item)
        }
    }
}
