//
//  MyPageSection.swift
//  QRIZ
//
//  Created by 김세훈 on 5/31/25.
//

import UIKit

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
    
    enum SupportMenu: String, CaseIterable {
        case termsOfService = "서비스 이용약관"
        case privacyPolicy = "개인정보 처리방침"
        case versionInfo = "버전 정보"
    }
}

enum MyPageLayoutFactory {
    
    private enum Metric {
        static let profileTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let profileEstimated: CGFloat = 90.0
        
        static let quickActionTopOffset: CGFloat = 24.0
        static let quickActionEstimated: CGFloat = 82.0
        
        static let supportTopOffset: CGFloat = 32.0
        static let supportRowEstimated: CGFloat  = 54.0
        static let supportEstimated: CGFloat = 266.0
    }
    
    // MARK: - Functions
    
    static func profile() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.profileEstimated)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.profileTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    static func quickAction() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.quickActionEstimated)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.quickActionTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    static func support() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Metric.supportRowEstimated)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Metric.supportEstimated)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.supportTopOffset + 12,
            leading: Metric.horizontalSpacing + 1,
            bottom: 0,
            trailing: Metric.horizontalSpacing + 1
        )
        
        let background = NSCollectionLayoutDecorationItem.background(
            elementKind: String(describing: CardBackgroundView.self)
        )
        
        background.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.supportTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: -Metric.horizontalSpacing,
            trailing: Metric.horizontalSpacing
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
