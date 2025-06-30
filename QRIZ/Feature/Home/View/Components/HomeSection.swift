//
//  HomeSection.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit

struct StudySummary: Equatable, Hashable {
    let skills: [PlannedSkill]
}

enum HomeSection: Int, CaseIterable {
    case examSchedule
    case examEntry
    case dailyHeader
    case daySelector
    case studySummary
}

enum HomeSectionItem: Hashable {
    case schedule(userName: String, status: ExamStatus)
    case entry(EntryCardState)
    case day(Int)
    case studySummary(StudySummary)
}

enum HomeLayoutFactory {
    
    private enum Metric {
        static let examScheduleEstimated: CGFloat = 364.0
        static let examScheduleTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 40.0
        
        static let examEntryEstimated: CGFloat = 106.0
        
        static let studyHeaderHeight: CGFloat = 24.0
        
        static let studySummaryEstimated: CGFloat = 245.0
        static let studySummaryTopOffset: CGFloat = 16.0
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
    
    private static func daySelector(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let inset: CGFloat = Metric.horizontalSpacing
        let spacing: CGFloat = 8
        let avail = env.container.effectiveContentSize.width - inset * 2
        let itemWidth = (avail - spacing * 2) / 3
        let itemHeight = itemWidth * 0.6
        
        let itemSize  = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: .init(layoutSize: itemSize),
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 19,
            leading: inset,
            bottom: 8,
            trailing: inset
        )
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private static func studySummary(env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let inset: CGFloat = Metric.horizontalSpacing
        let avail = env.container.effectiveContentSize.width - inset * 2
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(avail),
            heightDimension: .estimated(Metric.studySummaryEstimated)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [.init(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(
            top: Metric.studySummaryTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { index, env in
            guard let section = HomeSection(rawValue: index) else { return nil }
            switch section {
            case .examSchedule: return examSchedule()
            case .examEntry: return examEntry()
            case .dailyHeader: return dailyHeader()
            case .daySelector: return daySelector(env: env)
            case .studySummary: return studySummary(env: env)
            }
        }
    }
}
