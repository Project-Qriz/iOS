import UIKit
import DesignSystem

enum MyPageSection: Int, CaseIterable {
    case profile
    case quickActions
    case support
}

enum MyPageSectionItem: Hashable {
    case profile(userName: String)
    case quickActions
    case supportHeader
    case supportMenu(SupportMenu)

    enum SupportMenu: Hashable {
        case termsOfService
        case privacyPolicy
        case versionInfo(version: String)

        var title: String {
            switch self {
            case .termsOfService: return "서비스 이용약관"
            case .privacyPolicy: return "개인정보 처리방침"
            case .versionInfo: return "버전 정보"
            }
        }
    }
}

enum MyPageLayoutFactory {

    // MARK: - Functions

    static func profile() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90.0)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 24.0,
            leading: 18.0,
            bottom: 0,
            trailing: 18.0
        )
        return section
    }

    static func quickAction() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(82.0)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 40.0,
            leading: 18.0,
            bottom: 0,
            trailing: 18.0
        )
        return section
    }

    static func support() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(54.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(266.0)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 40.0,
            leading: 19.0,
            bottom: 0,
            trailing: 19.0
        )

        let background = NSCollectionLayoutDecorationItem.background(
            elementKind: String(describing: CardBackgroundView.self)
        )

        background.contentInsets = NSDirectionalEdgeInsets(
            top: 38.0,
            leading: 18.0,
            bottom: -18.0,
            trailing: 18.0
        )

        section.decorationItems = [background]
        return section
    }

    static func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            guard let section = MyPageSection(rawValue: index) else { return nil }
            switch section {
            case .profile: return profile()
            case .quickActions: return quickAction()
            case .support: return support()
            }
        }

        layout.register(
            CardBackgroundView.self,
            forDecorationViewOfKind: String(describing: CardBackgroundView.self)
        )

        return layout
    }
}
