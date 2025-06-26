//
//  HomeSection.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case examSchedule
    case examEntry
    case dailyHeader
}

enum HomeSectionItem: Hashable {
    case schedule(userName: String, status: ExamStatus)
    case entry(EntryCardState)
}

enum HomeLayoutFactory {
    
    private enum Metric {
        static let examScheduleEstimated: CGFloat = 364.0
        static let examScheduleTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 40.0
        
        static let examEntryEstimated: CGFloat = 106.0
        
        static let studyHeaderHeight: CGFloat = 24.0
    }
    
    // MARK: - Functions
    
    private static func examSchedule() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examScheduleEstimated)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.examScheduleTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    private static func examEntry() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examEntryEstimated)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.verticalSpacing,
            leading: Metric.horizontalSpacing,
            bottom: Metric.verticalSpacing,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    private static func dailyHeader() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(1)
        )
        let dummyItem  = NSCollectionLayoutItem(layoutSize: size)
        let dummyGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitems: [dummyItem]
        )
        let section = NSCollectionLayoutSection(group: dummyGroup)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(Metric.studyHeaderHeight)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { index, _ in
            guard let section = HomeSection(rawValue: index) else { return nil }
            switch section {
            case .examSchedule: return examSchedule()
            case .examEntry: return examEntry()
            case .dailyHeader: return dailyHeader()
            }
        }
    }
}
